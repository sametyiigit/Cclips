import AppKit
import Combine
import SwiftData

@MainActor
final class ClipboardStore: ObservableObject {
    @Published var clips: [ClipItem] = []
    @Published var searchText = ""
    @Published var selectedCollection: ClipCollection = .all
    @Published var selectedClipID: UUID?
    @Published var statusMessage: String?

    let privacySettings: PrivacySettings

    private let modelContext: ModelContext
    private let linkMetadataService: LinkMetadataService
    private let pasteStackController = PasteStackController()
    private var cancellables = Set<AnyCancellable>()
    private var suppressedHash: String?
    private let maxHistoryCount = 500

    init(
        modelContext: ModelContext,
        privacySettings: PrivacySettings,
        linkMetadataService: LinkMetadataService = LinkMetadataService()
    ) {
        self.modelContext = modelContext
        self.privacySettings = privacySettings
        self.linkMetadataService = linkMetadataService
        bindStatusMessageExpiry()
        loadClips()
    }

    var filteredClips: [ClipItem] {
        clips.filter { clip in
            let matchesCollection = selectedCollection.matches(clip)
            let matchesSearch: Bool
            if searchText.isEmpty {
                matchesSearch = true
            } else {
                let haystack = [
                    clip.title,
                    clip.textContent,
                    clip.linkTitle,
                    clip.linkHost,
                    clip.sourceApplicationName
                ]
                .compactMap { $0 }
                .joined(separator: "\n")
                .localizedCaseInsensitiveContains(searchText)
                matchesSearch = haystack
            }
            return matchesCollection && matchesSearch
        }
    }

    var selectedClip: ClipItem? {
        guard let selectedClipID else { return filteredClips.first }
        return clips.first(where: { $0.id == selectedClipID }) ?? filteredClips.first
    }

    var pinnedClips: [ClipItem] {
        clips.filter(\.pinned)
    }

    func clipCount(for collection: ClipCollection) -> Int {
        clips.filter { collection.matches($0) }.count
    }

    func ingest(payload: ClipboardPayload, sourceApplication: NSRunningApplication?) {
        guard !payload.contentHash.isEmpty else { return }

        if suppressedHash == payload.contentHash {
            suppressedHash = nil
            return
        }

        if let bundleIdentifier = sourceApplication?.bundleIdentifier,
           privacySettings.shouldIgnore(bundleIdentifier: bundleIdentifier) {
            return
        }

        if let existing = clips.first(where: { $0.contentHash == payload.contentHash }) {
            existing.lastCopiedAt = .now
            if let appName = sourceApplication?.localizedName {
                existing.sourceApplicationName = appName
            }
            if let bundleIdentifier = sourceApplication?.bundleIdentifier {
                existing.sourceBundleIdentifier = bundleIdentifier
            }
            persistChanges()
            loadClips(selecting: existing.id)
            return
        }

        let classification = ClipboardClassifier.classify(text: payload.text, imageData: payload.imageData)
        let clip = ClipItem(
            title: classification.title,
            kind: classification.kind,
            sourceApplicationName: sourceApplication?.localizedName,
            sourceBundleIdentifier: sourceApplication?.bundleIdentifier,
            textContent: payload.text,
            imageData: payload.imageData,
            contentHash: payload.contentHash,
            detectedColorHex: classification.detectedColorHex,
            normalizedURL: classification.normalizedURL
        )

        modelContext.insert(clip)
        pruneIfNeeded(keeping: clip.id)
        persistChanges()
        loadClips(selecting: clip.id)

        if let urlString = classification.normalizedURL, let url = URL(string: urlString) {
            Task {
                let metadata = await linkMetadataService.fetchMetadata(for: url)
                await MainActor.run {
                    guard let metadata else { return }
                    clip.linkTitle = metadata.title
                    clip.linkHost = metadata.host
                    clip.linkPreviewImageData = metadata.previewImageData
                    clip.linkFaviconData = metadata.faviconData
                    if let title = metadata.title, !title.isEmpty {
                        clip.title = title
                    }
                    persistChanges()
                    loadClips(selecting: clip.id)
                }
            }
        }
    }

    func loadClips(selecting selectedID: UUID? = nil) {
        var descriptor = FetchDescriptor<ClipItem>(
            sortBy: [SortDescriptor(\.lastCopiedAt, order: .reverse)]
        )
        descriptor.includePendingChanges = true

        do {
            let fetched = try modelContext.fetch(descriptor)
            clips = fetched.sorted(by: clipSort)

            if let selectedID {
                selectedClipID = selectedID
            } else if let selectedClipID,
                      !clips.contains(where: { $0.id == selectedClipID }) {
                self.selectedClipID = nil
            }
        } catch {
            statusMessage = "Failed to load clipboard history."
        }
    }

    func togglePin(for clip: ClipItem) {
        clip.pinned.toggle()
        persistChanges()
        loadClips(selecting: clip.id)
    }

    func delete(_ clip: ClipItem) {
        let deletedID = clip.id
        modelContext.delete(clip)
        persistChanges()
        loadClips(selecting: clips.first(where: { $0.id != deletedID })?.id)
    }

    func clearHistory() {
        clips.filter { !$0.pinned }.forEach(modelContext.delete)
        persistChanges()
        loadClips()
        statusMessage = "Unpinned history cleared."
    }

    func copyToClipboard(_ clip: ClipItem, pasteAfterCopy: Bool = false) {
        suppressedHash = clip.contentHash

        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()

        var items: [NSPasteboardWriting] = []
        if let text = clip.textContent, !text.isEmpty {
            items.append(text as NSString)
        }
        if let image = clip.image {
            items.append(image)
        }
        if items.isEmpty, let urlString = clip.normalizedURL {
            items.append(urlString as NSString)
        }

        if !items.isEmpty {
            pasteboard.writeObjects(items)
        }

        var didPaste = false
        if pasteAfterCopy {
            didPaste = PasteSimulator.simulateCommandV()
        }

        clip.lastCopiedAt = .now
        persistChanges()
        loadClips(selecting: clip.id)

        if pasteAfterCopy {
            statusMessage = didPaste
                ? "Pasted \(clip.title)."
                : "Copied \(clip.title). Automatic paste needs Accessibility access in Settings."
        } else {
            statusMessage = "Copied \(clip.title)."
        }
    }

    func enqueueForPasteStack(_ clip: ClipItem) {
        pasteStackController.enqueue(clipID: clip.id)
        statusMessage = "Queued for paste stack: \(clip.title)"
    }

    func queuePinnedForPasteStack() {
        pasteStackController.replaceQueue(with: pinnedClips.map(\.id))
        statusMessage = pinnedClips.isEmpty
            ? "No pinned items to queue."
            : "Queued \(pinnedClips.count) pinned clips."
    }

    func performPasteStackAdvance() {
        guard let nextID = pasteStackController.advance(),
              let clip = clips.first(where: { $0.id == nextID }) else {
            statusMessage = "Paste stack is empty."
            return
        }

        copyToClipboard(clip, pasteAfterCopy: true)

        if pasteStackController.remainingCount == 0 {
            statusMessage = "Paste stack completed."
        } else {
            statusMessage = "Pasted \(clip.title). \(pasteStackController.remainingCount) left."
        }
    }
    private func persistChanges() {
        do {
            try modelContext.save()
        } catch {
            statusMessage = "Failed to save clipboard history."
        }
    }

    private func pruneIfNeeded(keeping clipID: UUID) {
        let nonPinned = clips.filter { !$0.pinned && $0.id != clipID }
        let overflow = (nonPinned.count + 1) - maxHistoryCount
        guard overflow > 0 else { return }

        nonPinned
            .sorted(by: { $0.lastCopiedAt < $1.lastCopiedAt })
            .prefix(overflow)
            .forEach(modelContext.delete)
    }

    private func clipSort(_ lhs: ClipItem, _ rhs: ClipItem) -> Bool {
        if lhs.pinned != rhs.pinned {
            return lhs.pinned && !rhs.pinned
        }
        return lhs.lastCopiedAt > rhs.lastCopiedAt
    }

    private func bindStatusMessageExpiry() {
        $statusMessage
            .compactMap { $0 }
            .sink { [weak self] _ in
                Task { @MainActor in
                    try? await Task.sleep(for: .seconds(3))
                    self?.statusMessage = nil
                }
            }
            .store(in: &cancellables)
    }
}
