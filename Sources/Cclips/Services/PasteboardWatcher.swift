import AppKit
import CryptoKit
import Foundation

@MainActor
final class PasteboardWatcher: NSObject {
    private var timer: Timer?
    private var lastChangeCount: Int
    private let pasteboard: NSPasteboard
    private var onChange: ((ClipboardPayload, NSRunningApplication?) -> Void)?

    init(pasteboard: NSPasteboard = .general) {
        self.pasteboard = pasteboard
        self.lastChangeCount = pasteboard.changeCount
        self.onChange = nil
        super.init()
    }

    func start(onChange: @escaping (ClipboardPayload, NSRunningApplication?) -> Void) {
        guard timer == nil else { return }
        self.onChange = onChange

        timer = Timer.scheduledTimer(
            timeInterval: 0.7,
            target: self,
            selector: #selector(handleTimerTick),
            userInfo: nil,
            repeats: true
        )
        RunLoop.main.add(timer!, forMode: .common)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        onChange = nil
    }

    @objc private func handleTimerTick() {
        guard let onChange else { return }
        poll(onChange: onChange)
    }

    private func poll(onChange: (ClipboardPayload, NSRunningApplication?) -> Void) {
        guard pasteboard.changeCount != lastChangeCount else { return }
        lastChangeCount = pasteboard.changeCount

        let text = pasteboard.string(forType: .string)
        let imageData = NSImage(pasteboard: pasteboard)?.tiffRepresentation

        guard text != nil || imageData != nil else { return }

        let hash = hashPayload(text: text, imageData: imageData)
        let payload = ClipboardPayload(text: text, imageData: imageData, contentHash: hash)
        onChange(payload, NSWorkspace.shared.frontmostApplication)
    }

    private func hashPayload(text: String?, imageData: Data?) -> String {
        var hasher = SHA256()
        if let text {
            hasher.update(data: Data(text.utf8))
        }
        if let imageData {
            hasher.update(data: imageData)
        }
        let digest = hasher.finalize()
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
