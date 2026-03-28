import Carbon
import Foundation

final class HotKeyManager {
    private enum HotKeyAction: UInt32 {
        case showHistory = 1
        case pasteStack = 2
    }

    private static let signature = fourCharCode("CCLP")

    private var eventHandler: EventHandlerRef?
    private var registeredHotKeys: [EventHotKeyRef?] = []

    init() {
        installHandler()
        registerHotKeys()
    }

    deinit {
        registeredHotKeys.forEach { hotKey in
            if let hotKey {
                UnregisterEventHotKey(hotKey)
            }
        }

        if let eventHandler {
            RemoveEventHandler(eventHandler)
        }
    }

    private func installHandler() {
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        InstallEventHandler(
            GetApplicationEventTarget(),
            { _, event, _ in
                var hotKeyID = EventHotKeyID()
                let status = GetEventParameter(
                    event,
                    EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &hotKeyID
                )

                guard status == noErr else { return status }
                guard hotKeyID.signature == HotKeyManager.signature else { return noErr }

                switch HotKeyAction(rawValue: hotKeyID.id) {
                case .showHistory:
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: .showHistoryHotKeyPressed, object: nil)
                    }
                case .pasteStack:
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: .pasteStackHotKeyPressed, object: nil)
                    }
                case .none:
                    break
                }

                return noErr
            },
            1,
            &eventType,
            nil,
            &eventHandler
        )
    }

    private func registerHotKeys() {
        registeredHotKeys = [
            register(keyCode: UInt32(kVK_ANSI_V), modifiers: UInt32(shiftKey | cmdKey), action: .showHistory),
            register(keyCode: UInt32(kVK_ANSI_C), modifiers: UInt32(shiftKey | cmdKey), action: .pasteStack)
        ]
    }

    private func register(keyCode: UInt32, modifiers: UInt32, action: HotKeyAction) -> EventHotKeyRef? {
        var hotKeyRef: EventHotKeyRef?
        let hotKeyID = EventHotKeyID(signature: Self.signature, id: action.rawValue)

        let status = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )

        return status == noErr ? hotKeyRef : nil
    }
}

private func fourCharCode(_ string: String) -> OSType {
    string.utf8.reduce(0) { partialResult, character in
        (partialResult << 8) + OSType(character)
    }
}
