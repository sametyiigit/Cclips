import Foundation

@MainActor
final class PrivacySettings: ObservableObject {
    @Published var ignorePasswordManagers: Bool {
        didSet {
            UserDefaults.standard.set(ignorePasswordManagers, forKey: Self.ignorePasswordManagersKey)
        }
    }

    @Published var ignoredBundleIDsText: String {
        didSet {
            UserDefaults.standard.set(ignoredBundleIDsText, forKey: Self.ignoredBundleIDsKey)
        }
    }

    private static let ignorePasswordManagersKey = "ignorePasswordManagers"
    private static let ignoredBundleIDsKey = "ignoredBundleIDsText"

    private let passwordManagerBundleIDs: Set<String> = [
        "com.1password.1password",
        "com.1password.1password7",
        "com.agilebits.onepassword7",
        "com.bitwarden.desktop",
        "com.lastpass.LastPass",
        "com.roboform.RoboForm",
        "com.dashlane.dashlanephonefinal"
    ]

    init() {
        ignorePasswordManagers = UserDefaults.standard.object(forKey: Self.ignorePasswordManagersKey) as? Bool ?? true
        ignoredBundleIDsText = UserDefaults.standard.string(forKey: Self.ignoredBundleIDsKey) ?? ""
    }

    func shouldIgnore(bundleIdentifier: String) -> Bool {
        ignoredBundleIDs.contains(bundleIdentifier)
    }

    var ignoredBundleIDs: Set<String> {
        var bundleIDs = Set(
            ignoredBundleIDsText
                .split(whereSeparator: { $0.isNewline || $0 == "," })
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        )

        if ignorePasswordManagers {
            bundleIDs.formUnion(passwordManagerBundleIDs)
        }

        if let ownBundleID = Bundle.main.bundleIdentifier {
            bundleIDs.insert(ownBundleID)
        }

        return bundleIDs
    }
}
