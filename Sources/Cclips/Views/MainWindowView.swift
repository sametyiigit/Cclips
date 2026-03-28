import SwiftUI

struct MainWindowView: View {
    @ObservedObject var store: ClipboardStore
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
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
        .overlay {
            if !hasCompletedOnboarding {
                WelcomeOverlay(
                    openSettings: openSettings,
                    dismiss: { hasCompletedOnboarding = true }
                )
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
                hasCompletedOnboarding = false
            } label: {
                Label("Welcome", systemImage: "sparkles")
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

private struct WelcomeOverlay: View {
    let openSettings: () -> Void
    let dismiss: () -> Void

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.black.opacity(0.22))
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 22) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Welcome to Cclips")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                        Text("Clipboard history, pinning, and quick paste flow in one lightweight Mac app.")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.headline)
                    }
                    .buttonStyle(.plain)
                }

                HStack(spacing: 14) {
                    WelcomeFeatureCard(
                        title: "Copy Anywhere",
                        detail: "Everything you copy appears in history and stays searchable.",
                        systemImage: "doc.on.clipboard"
                    )
                    WelcomeFeatureCard(
                        title: "Open Fast",
                        detail: "Use Shift-Command-V to bring Cclips forward from anywhere.",
                        systemImage: "keyboard"
                    )
                    WelcomeFeatureCard(
                        title: "Paste In Order",
                        detail: "Queue important clips, then advance them with Shift-Command-C.",
                        systemImage: "list.bullet.clipboard"
                    )
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Recommended first step")
                        .font(.headline)
                    Text("Open Privacy settings if you want automatic paste simulation. Cclips still works for history and manual recopy without it.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Button("Open Privacy Settings") {
                        openSettings()
                    }

                    Spacer()

                    Button("Start Using Cclips") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(28)
            .frame(width: 760)
            .background(.ultraThickMaterial, in: RoundedRectangle(cornerRadius: 28))
            .shadow(color: .black.opacity(0.16), radius: 30, y: 12)
        }
    }
}

private struct WelcomeFeatureCard: View {
    let title: String
    let detail: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: systemImage)
                .font(.title2.weight(.semibold))
                .foregroundStyle(.orange)
            Text(title)
                .font(.headline)
            Text(detail)
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(.background.opacity(0.78), in: RoundedRectangle(cornerRadius: 20))
    }
}
