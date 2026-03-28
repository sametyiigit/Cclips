import SwiftUI

struct MainWindowView: View {
    @ObservedObject var store: ClipboardStore
    let openSettings: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            topBar

            Divider()

            HStack(spacing: 0) {
                SidebarView(store: store)
                    .frame(width: 220)

                Divider()

                ClipListView(store: store)
                    .frame(minWidth: 320, idealWidth: 380, maxWidth: 420)

                Divider()

                ClipDetailView(
                    clip: store.selectedClip,
                    onCopy: { store.copyToClipboard($0) },
                    onPaste: { store.copyToClipboard($0, pasteAfterCopy: true) },
                    onPin: { store.togglePin(for: $0) },
                    onQueue: { store.enqueueForPasteStack($0) },
                    onDelete: { store.delete($0) }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .overlay(alignment: .bottom) {
            if let statusMessage = store.statusMessage {
                Text(statusMessage)
                    .font(.callout.weight(.medium))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(.ultraThickMaterial, in: Capsule())
                    .padding()
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .preferredColorScheme(nil)
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            Text("All Clips")
                .font(.title2.weight(.semibold))

            Spacer(minLength: 20)

            TextField("Search clipboard history", text: $store.searchText)
                .textFieldStyle(.roundedBorder)
                .frame(width: 280)

            Spacer()

            Button {
                store.queuePinnedForPasteStack()
            } label: {
                Label("Queue Pinned", systemImage: "list.bullet.clipboard")
            }

            Button {
                store.clearHistory()
            } label: {
                Label("Clear History", systemImage: "trash")
            }

            Button {
                openSettings()
            } label: {
                Label("Privacy", systemImage: "hand.raised")
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(.regularMaterial)
    }
}
