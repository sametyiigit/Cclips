import SwiftData

@MainActor
final class AppContext {
    static let shared = AppContext()

    private(set) var modelContainer: ModelContainer?
    private(set) var store: ClipboardStore?
    private(set) var accessibilityMonitor: AccessibilityPermissionMonitor?
    let pasteboardWatcher = PasteboardWatcher()
    let hotKeyManager = HotKeyManager()
    weak var appDelegate: AppDelegate?

    private init() {}

    func configure(
        modelContainer: ModelContainer,
        store: ClipboardStore,
        accessibilityMonitor: AccessibilityPermissionMonitor
    ) {
        self.modelContainer = modelContainer
        self.store = store
        self.accessibilityMonitor = accessibilityMonitor
    }
}
