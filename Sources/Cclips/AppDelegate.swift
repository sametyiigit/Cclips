import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    private var windowController: NSWindowController?
    private var settingsWindowController: NSWindowController?
    private var statusItem: NSStatusItem?
    private let statusPopover = NSPopover()

    func applicationDidFinishLaunching(_ notification: Notification) {
        AppContext.shared.appDelegate = self
        NSApp.setActivationPolicy(.accessory)
        configureStatusItem()
        createMainWindowIfNeeded()
        startClipboardMonitoring()
        observeHotKeys()
        showMainWindow()
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        AppContext.shared.accessibilityMonitor?.refresh()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func showMainWindow() {
        createMainWindowIfNeeded()
        AppContext.shared.accessibilityMonitor?.refresh()
        NSApp.activate(ignoringOtherApps: true)
        closeStatusPopover()
        windowController?.showWindow(nil)
        windowController?.window?.makeKeyAndOrderFront(nil)
    }

    func hideMainWindow() {
        windowController?.close()
    }

    func toggleMainWindow() {
        guard let window = windowController?.window else {
            showMainWindow()
            return
        }

        if window.isVisible && NSApp.isActive {
            window.orderOut(nil)
        } else {
            showMainWindow()
        }
    }

    func showSettings() {
        createSettingsWindowIfNeeded()
        AppContext.shared.accessibilityMonitor?.refresh()
        NSApp.activate(ignoringOtherApps: true)
        closeStatusPopover()
        settingsWindowController?.showWindow(nil)
        settingsWindowController?.window?.makeKeyAndOrderFront(nil)
    }

    func windowWillClose(_ notification: Notification) {
        guard let window = notification.object as? NSWindow else { return }

        if window.identifier == NSUserInterfaceItemIdentifier("cclips-main-window") {
            NSApp.hide(nil)
        }
    }

    private func createMainWindowIfNeeded() {
        guard windowController == nil, let store = AppContext.shared.store else { return }

        let contentView = MainWindowView(
            store: store,
            openSettings: { [weak self] in self?.showSettings() }
        )
        let hostingController = NSHostingController(rootView: contentView)
        let window = NSWindow(contentViewController: hostingController)
        window.identifier = NSUserInterfaceItemIdentifier("cclips-main-window")
        window.title = "Cclips"
        window.delegate = self
        window.setContentSize(NSSize(width: 1120, height: 720))
        window.minSize = NSSize(width: 900, height: 560)
        window.center()
        window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
        window.isReleasedWhenClosed = false
        window.collectionBehavior = [.fullScreenPrimary]
        window.titleVisibility = .visible

        let controller = NSWindowController(window: window)
        controller.shouldCascadeWindows = false
        windowController = controller
    }

    private func createSettingsWindowIfNeeded() {
        guard settingsWindowController == nil,
              let store = AppContext.shared.store,
              let accessibilityMonitor = AppContext.shared.accessibilityMonitor else {
            return
        }

        let rootView = SettingsView(
            privacySettings: store.privacySettings,
            accessibilityMonitor: accessibilityMonitor
        )

        let hostingController = NSHostingController(rootView: rootView)
        let window = NSWindow(contentViewController: hostingController)
        window.identifier = NSUserInterfaceItemIdentifier("cclips-settings-window")
        window.title = "Cclips Settings"
        window.setContentSize(NSSize(width: 560, height: 420))
        window.minSize = NSSize(width: 520, height: 360)
        window.center()
        window.styleMask = [.titled, .closable, .miniaturizable]
        window.isReleasedWhenClosed = false
        window.titleVisibility = .visible

        let controller = NSWindowController(window: window)
        controller.shouldCascadeWindows = false
        settingsWindowController = controller
    }

    private func configureStatusItem() {
        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "clipboard", accessibilityDescription: "Cclips")
            button.imagePosition = .imageOnly
            button.target = self
            button.action = #selector(toggleStatusPopover(_:))
            button.toolTip = "Cclips"
        }

        statusPopover.behavior = .transient
        self.statusItem = statusItem
        guard let store = AppContext.shared.store else { return }

        let view = MenuBarHistoryView(
            store: store,
            openMainWindow: { [weak self] in self?.showMainWindow() },
            openSettings: { [weak self] in self?.showSettings() },
            closeMenu: { [weak self] in self?.closeStatusPopover() }
        )

        statusPopover.contentViewController = NSHostingController(rootView: view)
        statusPopover.contentSize = NSSize(width: 360, height: 420)
    }

    private func closeStatusPopover() {
        statusPopover.performClose(nil)
    }

    private func startClipboardMonitoring() {
        AppContext.shared.pasteboardWatcher.start { payload, sourceApplication in
            guard let store = AppContext.shared.store else { return }
            Task { @MainActor in
                store.ingest(payload: payload, sourceApplication: sourceApplication)
            }
        }
    }

    private func observeHotKeys() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleShowHistoryHotKey(_:)),
            name: .showHistoryHotKeyPressed,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePasteStackHotKey(_:)),
            name: .pasteStackHotKeyPressed,
            object: nil
        )
    }

    @objc private func handleShowHistoryHotKey(_ notification: Notification) {
        showMainWindow()
    }

    @objc private func handlePasteStackHotKey(_ notification: Notification) {
        AppContext.shared.store?.performPasteStackAdvance()
    }

    @objc private func toggleStatusPopover(_ sender: Any?) {
        guard let button = statusItem?.button else { return }

        if statusPopover.isShown {
            closeStatusPopover()
        } else {
            statusPopover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
