import Testing
@testable import Cclips

@Test func detectsLinks() {
    let result = ClipboardClassifier.classify(
        text: "https://example.com/path",
        imageData: nil
    )

    #expect(result.kind == .link)
    #expect(result.normalizedURL == "https://example.com/path")
}

@Test func detectsHexColors() {
    let result = ClipboardClassifier.classify(
        text: "Primary brand color is #12ABef",
        imageData: nil
    )

    #expect(result.kind == .color)
    #expect(result.detectedColorHex == "#12ABEF")
}

@Test func fallsBackToTextTitles() {
    let result = ClipboardClassifier.classify(
        text: "First line\nSecond line",
        imageData: nil
    )

    #expect(result.kind == .text)
    #expect(result.title == "First line")
}
