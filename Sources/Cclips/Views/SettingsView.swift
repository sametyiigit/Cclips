import SwiftUI

struct SettingsView: View {
    @ObservedObject var privacySettings: PrivacySettings
    @ObservedObject var accessibilityMonitor: AccessibilityPermissionMonitor
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        Form {
            Section("Permissions") {
                HStack {
                    Label(
                        accessibilityMonitor.isTrusted ? "Accessibility access granted" : "Accessibility access required",
                        systemImage: accessibilityMonitor.isTrusted ? "checkmark.shield.fill" : "exclamationmark.triangle.fill"
                    )
                    .foregroundStyle(accessibilityMonitor.isTrusted ? .green : .orange)

                    Spacer()

                    Text(accessibilityMonitor.isTrusted ? "Ready" : "Not Granted")
                        .foregroundStyle(.secondary)
                }

                Text("Global shortcuts and automatic Command-V simulation depend on macOS Accessibility permission.")
                    .font(.callout)
                    .foregroundStyle(.secondary)

                Text(accessibilityMonitor.permissionHelpText)
                    .font(.callout)
                    .foregroundStyle(.secondary)

                LabeledContent("Current executable") {
                    Text(accessibilityMonitor.executablePath)
                        .font(.caption.monospaced())
                        .multilineTextAlignment(.trailing)
                        .textSelection(.enabled)
                }

                LabeledContent("Current bundle") {
                    Text(accessibilityMonitor.bundlePath)
                        .font(.caption.monospaced())
                        .multilineTextAlignment(.trailing)
                        .textSelection(.enabled)
                }

                HStack {
                    Button("Request Accessibility Access") {
                        accessibilityMonitor.requestAccessPrompt()
                    }

                    Button("Open Accessibility Settings") {
                        accessibilityMonitor.openAccessibilitySettings()
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("How to test")
                        .font(.headline)
                    Text("1. Grant access here.")
                    Text("2. Copy text in another app and press Shift-Command-V.")
                    Text("3. Queue an item in Cclips, switch to TextEdit, then press Shift-Command-C.")
                }
                .font(.callout)
            }

            Section("Privacy") {
                Toggle("Ignore common password managers", isOn: $privacySettings.ignorePasswordManagers)
                Text("Cclips will skip clips copied from known password manager apps so sensitive secrets are less likely to be stored.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            Section("Ignored Apps") {
                Text("Add bundle identifiers, one per line or comma-separated. Example: `com.apple.keychainaccess`")
                    .font(.callout)
                    .foregroundStyle(.secondary)

                TextEditor(text: $privacySettings.ignoredBundleIDsText)
                    .font(.body.monospaced())
                    .frame(minHeight: 180)
            }

            Section("Hotkeys") {
                LabeledContent("Open history") {
                    Text("Shift-Command-V")
                }
                LabeledContent("Paste stack") {
                    Text("Shift-Command-C")
                }
            }

            Section("Onboarding") {
                Text("Reopen the welcome flow if you want to re-check the first-run guidance.")
                    .font(.callout)
                    .foregroundStyle(.secondary)

                Button("Show Welcome Screen Again") {
                    hasCompletedOnboarding = false
                }
            }
        }
        .formStyle(.grouped)
        .padding(20)
    }
}
