import SwiftUI

struct ClipDetailView: View {
    let clip: ClipItem?
    let onCopy: (ClipItem) -> Void
    let onPaste: (ClipItem) -> Void
    let onPin: (ClipItem) -> Void
    let onQueue: (ClipItem) -> Void
    let onDelete: (ClipItem) -> Void

    var body: some View {
        Group {
            if let clip {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        header(for: clip)
                        preview(for: clip)
                        metadata(for: clip)
                        actions(for: clip)
                    }
                    .padding(28)
                }
            } else {
                ContentUnavailableView(
                    "Choose a Clip",
                    systemImage: "rectangle.on.rectangle.angled",
                    description: Text("Select an item from the left to inspect, pin, re-copy, or add it to your paste stack.")
                )
            }
        }
    }

    private func header(for clip: ClipItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(clip.title)
                .font(.largeTitle.weight(.bold))
            Text("\(clip.kind.rawValue.capitalized) clip from \(clip.sourceApplicationName ?? "Unknown App")")
                .foregroundStyle(.secondary)
            Text("Captured \(clip.relativeTimestamp)")
                .font(.callout)
                .foregroundStyle(.tertiary)
        }
    }

    @ViewBuilder
    private func preview(for clip: ClipItem) -> some View {
        switch clip.kind {
        case .image:
            if let image = clip.image {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 380, maxHeight: 260)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
            }
        case .color:
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(hex: clip.detectedColorHex ?? "#888888"))
                .frame(height: 180)
                .overlay(alignment: .bottomLeading) {
                    Text(clip.detectedColorHex ?? "Unknown")
                        .font(.title2.monospaced())
                        .foregroundStyle(.white)
                        .padding(20)
                }
        case .link:
            VStack(alignment: .leading, spacing: 14) {
                if let preview = clip.linkPreviewImage {
                    Image(nsImage: preview)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 240)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                }

                HStack(spacing: 12) {
                    if let favicon = clip.faviconImage {
                        Image(nsImage: favicon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                    } else {
                        Image(systemName: "globe")
                            .font(.title2)
                            .foregroundStyle(.green)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(clip.linkTitle ?? clip.title)
                            .font(.headline)
                        Text(clip.normalizedURL ?? clip.textContent ?? "")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        case .text:
            if let text = clip.textContent {
                ScrollView {
                    Text(text)
                        .font(.body.monospaced())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                        .padding(18)
                }
                .frame(minHeight: 220)
                .background(.quinary.opacity(0.35), in: RoundedRectangle(cornerRadius: 18))
            }
        }
    }

    private func metadata(for clip: ClipItem) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(clip.sourceApplicationName ?? "Unknown App", systemImage: "macwindow")
            if let bundleIdentifier = clip.sourceBundleIdentifier {
                Label(bundleIdentifier, systemImage: "shippingbox")
            }
            if let url = clip.normalizedURL {
                Label(url, systemImage: "link")
            }
        }
        .font(.callout)
        .foregroundStyle(.secondary)
    }

    private func actions(for clip: ClipItem) -> some View {
        HStack(spacing: 12) {
            Button {
                onCopy(clip)
            } label: {
                Label("Copy Again", systemImage: "doc.on.doc")
            }

            Button {
                onPaste(clip)
            } label: {
                Label("Paste Now", systemImage: "arrow.down.doc")
            }

            Button {
                onQueue(clip)
            } label: {
                Label("Queue", systemImage: "list.bullet.clipboard")
            }

            Button {
                onPin(clip)
            } label: {
                Label(clip.pinned ? "Unpin" : "Pin", systemImage: clip.pinned ? "pin.slash" : "pin")
            }

            Button(role: .destructive) {
                onDelete(clip)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .buttonStyle(.borderedProminent)
    }
}
