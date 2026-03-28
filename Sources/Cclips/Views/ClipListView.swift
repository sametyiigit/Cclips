import SwiftUI

struct ClipListView: View {
    @ObservedObject var store: ClipboardStore

    var body: some View {
        Group {
            if store.filteredClips.isEmpty {
                ContentUnavailableView(
                    "No Clips Yet",
                    systemImage: "clipboard",
                    description: Text("Copy something anywhere on your Mac and it will appear here.")
                )
            } else {
                List {
                    ForEach(store.filteredClips) { clip in
                        Button {
                            store.selectedClipID = clip.id
                        } label: {
                            ClipRowView(clip: clip)
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(
                            isSelected(clip)
                                ? Color.accentColor.opacity(0.16)
                                : Color.clear
                        )
                            .contextMenu {
                                Button(clip.pinned ? "Unpin" : "Pin") {
                                    store.togglePin(for: clip)
                                }
                                Button("Copy Again") {
                                    store.copyToClipboard(clip)
                                }
                                Button("Paste Now") {
                                    store.copyToClipboard(clip, pasteAfterCopy: true)
                                }
                                Button("Add to Paste Stack") {
                                    store.enqueueForPasteStack(clip)
                                }
                                Divider()
                                Button("Delete", role: .destructive) {
                                    store.delete(clip)
                                }
                            }
                    }
                }
                .listStyle(.inset)
            }
        }
    }

    private func isSelected(_ clip: ClipItem) -> Bool {
        let activeID = store.selectedClipID ?? store.selectedClip?.id
        return activeID == clip.id
    }
}
