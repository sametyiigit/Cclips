import SwiftUI

enum ClipCollection: String, CaseIterable, Identifiable {
    case all
    case pinned
    case links
    case images
    case colors

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: "All Clips"
        case .pinned: "Pinned"
        case .links: "Links"
        case .images: "Images"
        case .colors: "Colors"
        }
    }

    var systemImage: String {
        switch self {
        case .all: "clock.arrow.circlepath"
        case .pinned: "pin.fill"
        case .links: "link"
        case .images: "photo"
        case .colors: "eyedropper.full"
        }
    }

    func matches(_ clip: ClipItem) -> Bool {
        switch self {
        case .all: true
        case .pinned: clip.pinned
        case .links: clip.kind == .link
        case .images: clip.kind == .image
        case .colors: clip.kind == .color
        }
    }

    var accentColor: Color {
        switch self {
        case .all: .blue
        case .pinned: .orange
        case .links: .green
        case .images: .pink
        case .colors: .mint
        }
    }
}
