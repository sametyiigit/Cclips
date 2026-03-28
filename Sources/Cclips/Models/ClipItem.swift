import AppKit
import SwiftData

enum ClipKind: String, CaseIterable, Codable {
    case text
    case link
    case color
    case image
}

@Model
final class ClipItem: Identifiable {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var lastCopiedAt: Date
    var pinned: Bool
    var title: String
    var kindRaw: String
    var sourceApplicationName: String?
    var sourceBundleIdentifier: String?
    var textContent: String?
    @Attribute(.externalStorage) var imageData: Data?
    var contentHash: String
    var detectedColorHex: String?
    var normalizedURL: String?
    var linkTitle: String?
    var linkHost: String?
    @Attribute(.externalStorage) var linkPreviewImageData: Data?
    @Attribute(.externalStorage) var linkFaviconData: Data?

    init(
        id: UUID = UUID(),
        createdAt: Date = .now,
        lastCopiedAt: Date = .now,
        pinned: Bool = false,
        title: String,
        kind: ClipKind,
        sourceApplicationName: String? = nil,
        sourceBundleIdentifier: String? = nil,
        textContent: String? = nil,
        imageData: Data? = nil,
        contentHash: String,
        detectedColorHex: String? = nil,
        normalizedURL: String? = nil,
        linkTitle: String? = nil,
        linkHost: String? = nil,
        linkPreviewImageData: Data? = nil,
        linkFaviconData: Data? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.lastCopiedAt = lastCopiedAt
        self.pinned = pinned
        self.title = title
        self.kindRaw = kind.rawValue
        self.sourceApplicationName = sourceApplicationName
        self.sourceBundleIdentifier = sourceBundleIdentifier
        self.textContent = textContent
        self.imageData = imageData
        self.contentHash = contentHash
        self.detectedColorHex = detectedColorHex
        self.normalizedURL = normalizedURL
        self.linkTitle = linkTitle
        self.linkHost = linkHost
        self.linkPreviewImageData = linkPreviewImageData
        self.linkFaviconData = linkFaviconData
    }

    var kind: ClipKind {
        get { ClipKind(rawValue: kindRaw) ?? .text }
        set { kindRaw = newValue.rawValue }
    }

    var previewSubtitle: String {
        if let sourceApplicationName, !sourceApplicationName.isEmpty {
            return sourceApplicationName
        }
        return relativeTimestamp
    }

    var relativeTimestamp: String {
        lastCopiedAt.formatted(date: .abbreviated, time: .shortened)
    }

    var image: NSImage? {
        guard let imageData else { return nil }
        return NSImage(data: imageData)
    }

    var linkPreviewImage: NSImage? {
        guard let linkPreviewImageData else { return nil }
        return NSImage(data: linkPreviewImageData)
    }

    var faviconImage: NSImage? {
        guard let linkFaviconData else { return nil }
        return NSImage(data: linkFaviconData)
    }
}
