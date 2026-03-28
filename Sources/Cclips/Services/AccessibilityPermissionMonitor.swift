import ApplicationServices
import AppKit
import Foundation

@MainActor
final class AccessibilityPermissionMonitor: NSObject, ObservableObject {
    @Published private(set) var isTrusted = false

    override init() {
        super.init()
        refresh()
    }

    func refresh() {
        isTrusted = AXIsProcessTrusted()
    }

    func requestAccessPrompt() {
        let promptKey = "AXTrustedCheckOptionPrompt"
        let options = [promptKey: true] as CFDictionary
        isTrusted = AXIsProcessTrustedWithOptions(options)
    }

    func openAccessibilitySettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") else {
            return
        }
        NSWorkspace.shared.open(url)
    }

    var executablePath: String {
        Bundle.main.executableURL?.path ?? ProcessInfo.processInfo.arguments.first ?? "Unknown"
    }

    var bundlePath: String {
        Bundle.main.bundleURL.path
    }

    var isRunningFromAppBundle: Bool {
        bundlePath.hasSuffix(".app")
    }

    var permissionHelpText: String {
        if isTrusted {
            return "Accessibility access is enabled for the currently running Cclips process."
        }

        if isRunningFromAppBundle {
            return "Accessibility is not enabled for this exact Cclips app yet."
        }

        return "Cclips is currently running as a raw executable, likely from Xcode or SwiftPM. macOS permissions are path-specific, so the enabled Cclips entry may belong to a different binary."
    }
}
