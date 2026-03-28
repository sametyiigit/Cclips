import XCTest
@testable import Cclips

final class ClipboardClassifierAppTests: XCTestCase {
    func testDetectsLinks() {
        let result = ClipboardClassifier.classify(
            text: "https://example.com/path",
            imageData: nil
        )

        XCTAssertEqual(result.kind, .link)
        XCTAssertEqual(result.normalizedURL, "https://example.com/path")
    }

    func testDetectsHexColors() {
        let result = ClipboardClassifier.classify(
            text: "Primary brand color is #12ABef",
            imageData: nil
        )

        XCTAssertEqual(result.kind, .color)
        XCTAssertEqual(result.detectedColorHex, "#12ABEF")
    }

    func testFallsBackToTextTitles() {
        let result = ClipboardClassifier.classify(
            text: "First line\nSecond line",
            imageData: nil
        )

        XCTAssertEqual(result.kind, .text)
        XCTAssertEqual(result.title, "First line")
    }
}
