import SwiftUI

struct MenuBarHistoryView: View {
    @ObservedObject var store: ClipboardStore
    let openMainWindow: () -> Void
    let openSettings: () -> Void
    let closeMenu: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Cclips")
                        .font(.title2.weight(.bold))
                    Text("Shift-Command-V opens history")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button("Open") {
                    closeMenu()
                    openMainWindow()
                }
            }

            Divider()

            if store.clips.isEmpty {
                Text("Copy something to start building your clipboard history.")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ForEach(store.clips.prefix(8)) { clip in
                    Button {
                        closeMenu()
                        store.copyToClipboard(clip)
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: icon(for: clip))
                                .frame(width: 18)
                                .foregroundStyle(.secondary)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(clip.title)
                                    .lineLimit(1)
                                Text(clip.relativeTimestamp)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if clip.pinned {
                                Image(systemName: "pin.fill")
                                    .foregroundStyle(.orange)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }

            Divider()

            HStack {
                Button("Paste Next") {
                    closeMenu()
                    store.performPasteStackAdvance()
                }
                Button("Settings") {
                    closeMenu()
                    openSettings()
                }
                Spacer()
                Button("Quit") {
                    closeMenu()
                    NSApplication.shared.terminate(nil)
                }
            }
        }
        .padding(16)
        .frame(width: 360)
    }

    private func icon(for clip: ClipItem) -> String {
        switch clip.kind {
        case .text: "text.alignleft"
        case .link: "link"
        case .color: "eyedropper"
        case .image: "photo"
        }
    }
}
