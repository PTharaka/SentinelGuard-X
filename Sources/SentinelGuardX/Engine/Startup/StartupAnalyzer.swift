import Foundation
import Observation

@Observable
final class StartupAnalyzer {
    var items: [StartupItem] = []
    var isAnalyzing = false

    func analyze() {
        isAnalyzing = true
        items = []

        Task {
            var found: [StartupItem] = []

            // User LaunchAgents
            let home = FileUtils.homeDirectory()
            let userAgentsDir = home.appendingPathComponent("Library/LaunchAgents")
            found += parseLaunchItems(at: userAgentsDir, type: .launchAgent)

            // System LaunchAgents
            let systemAgentsDir = URL(fileURLWithPath: "/Library/LaunchAgents")
            found += parseLaunchItems(at: systemAgentsDir, type: .launchAgent)

            // System LaunchDaemons
            let daemonsDir = URL(fileURLWithPath: "/Library/LaunchDaemons")
            found += parseLaunchItems(at: daemonsDir, type: .launchDaemon)

            await MainActor.run {
                self.items = found
                self.isAnalyzing = false
            }
        }
    }

    private func parseLaunchItems(at directory: URL, type: StartupItem.StartupItemType) -> [StartupItem] {
        let fm = FileManager.default
        guard let contents = try? fm.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        ) else { return [] }

        return contents.compactMap { url -> StartupItem? in
            guard url.pathExtension == "plist" else { return nil }

            let name = url.deletingPathExtension().lastPathComponent
            let isSuspicious = isSuspiciousName(name)

            // Try to read the plist for the label
            let plistData = try? Data(contentsOf: url)
            let plist = plistData.flatMap {
                try? PropertyListSerialization.propertyList(from: $0, format: nil) as? [String: Any]
            }

            let label = plist?["Label"] as? String ?? name
            let isDisabled = plist?["Disabled"] as? Bool ?? false
            let bundleId = plist?["Label"] as? String

            return StartupItem(
                name: label,
                path: url.path,
                type: type,
                isEnabled: !isDisabled,
                isSuspicious: isSuspicious,
                bundleIdentifier: bundleId,
                isSigned: !isSuspicious
            )
        }
    }

    private func isSuspiciousName(_ name: String) -> Bool {
        // Check for randomized-looking names
        let suspiciousPatterns = [
            name.count > 30,
            name.filter({ $0.isNumber }).count > name.count / 2,
            name.contains("hidden"),
            name.contains("temp"),
        ]
        return suspiciousPatterns.contains(true)
    }
}
