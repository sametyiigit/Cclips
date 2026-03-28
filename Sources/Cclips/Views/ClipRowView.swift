import SwiftUI

struct ClipRowView: View {
    let clip: ClipItem

    var body: some View {
        HStack(spacing: 12) {
            preview

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(clip.title)
                        .font(.headline)
                        .lineLimit(1)
                    if clip.pinned {
                        Image(systemName: "pin.fill")
                            .foregroundStyle(.orange)
                            .font(.caption)
                    }
                }

                if let snippet = clip.textContent, !snippet.isEmpty {
                    Text(snippet.replacingOccurrences(of: "\n", with: " "))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                } else if let host = clip.linkHost {
                    Text(host)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                } else {
                    Text(clip.previewSubtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                Text(clip.kind.rawValue.capitalized)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(clip.relativeTimestamp)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 6)
    }

    @ViewBuilder
    private var preview: some View {
        switch clip.kind {
        case .image:
            if let image = clip.image {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 54, height: 54)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                roundedIcon("photo")
            }
        case .color:
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: clip.detectedColorHex ?? "#999999"))
                .frame(width: 54, height: 54)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.black.opacity(0.08))
                )
        case .link:
            if let favicon = clip.faviconImage {
                Image(nsImage: favicon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 54, height: 54)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            } else {
                roundedIcon("link")
            }
        case .text:
            roundedIcon("text.alignleft")
        }
    }

    private func roundedIcon(_ systemImage: String) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.quaternary.opacity(0.55))
            .frame(width: 54, height: 54)
            .overlay {
                Image(systemName: systemImage)
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
    }
}
