import SwiftData
import SwiftUI

@main
@MainActor
struct CclipsApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var store: ClipboardStore
    @StateObject private var accessibilityMonitor: AccessibilityPermissionMonitor

    init() {
        let container: ModelContainer
        do {
            let configuration = ModelConfiguration("Cclips")
            container = try ModelContainer(for: ClipItem.self, configurations: configuration)
        } catch {
            fatalError("Failed to create model container: \(error)")
        }

        let privacySettings = PrivacySettings()
        let store = ClipboardStore(modelContext: container.mainContext, privacySettings: privacySettings)
        let accessibilityMonitor = AccessibilityPermissionMonitor()
        _store = StateObject(wrappedValue: store)
        _accessibilityMonitor = StateObject(wrappedValue: accessibilityMonitor)
        AppContext.shared.configure(
            modelContainer: container,
            store: store,
            accessibilityMonitor: accessibilityMonitor
        )
    }

    var body: some Scene {
        Settings { EmptyView() }
    }
}
