import AppKit
import Foundation

struct ClipboardClassification {
    let kind: ClipKind
    let title: String
    let normalizedURL: String?
    let detectedColorHex: String?
}

enum ClipboardClassifier {
    static func classify(text: String?, imageData: Data?) -> ClipboardClassification {
        if let imageData, let image = NSImage(data: imageData) {
            let title = image.size.width > 0 && image.size.height > 0
                ? "Image \(Int(image.size.width))×\(Int(image.size.height))"
                : "Image Clip"
            return ClipboardClassification(
                kind: .image,
                title: title,
                normalizedURL: nil,
                detectedColorHex: nil
            )
        }

        let trimmedText = text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let detectedURL = firstURL(in: trimmedText) {
            return ClipboardClassification(
                kind: .link,
                title: detectedURL.absoluteString,
                normalizedURL: detectedURL.absoluteString,
                detectedColorHex: nil
            )
        }

        if let hex = firstHexColor(in: trimmedText) {
            return ClipboardClassification(
                kind: .color,
                title: hex.uppercased(),
                normalizedURL: nil,
                detectedColorHex: hex.uppercased()
            )
        }

        let title = previewTitle(from: trimmedText)
        return ClipboardClassification(
            kind: .text,
            title: title,
            normalizedURL: nil,
            detectedColorHex: nil
        )
    }

    static func firstURL(in text: String?) -> URL? {
        guard let text, !text.isEmpty else { return nil }
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        return detector?.firstMatch(in: text, options: [], range: range)?.url
    }

    static func firstHexColor(in text: String?) -> String? {
        guard let text, !text.isEmpty else { return nil }
        let pattern = #"#(?:[0-9A-Fa-f]{3}|[0-9A-Fa-f]{6}|[0-9A-Fa-f]{8})\b"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        guard let match = regex.firstMatch(in: text, options: [], range: range),
              let matchRange = Range(match.range, in: text) else {
            return nil
        }
        return String(text[matchRange])
    }

    private static func previewTitle(from text: String?) -> String {
        guard let text, !text.isEmpty else {
            return "Empty Clip"
        }

        let compact = text
            .split(whereSeparator: \.isNewline)
            .first?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? text

        guard compact.count > 72 else { return compact }
        return String(compact.prefix(69)) + "..."
    }
}
