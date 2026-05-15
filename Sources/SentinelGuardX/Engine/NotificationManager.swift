import Foundation
import UserNotifications

final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()

    private var isSetUp = false

    private override init() {
        super.init()
    }

    /// Must be called after the app has fully launched (e.g. from applicationDidFinishLaunching)
    func setup() {
        // Guard: UNUserNotificationCenter requires a valid bundle
        guard Bundle.main.bundleIdentifier != nil else {
            print("[SentinelGuardX] Notifications unavailable — no bundle identifier")
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self, !self.isSetUp else { return }
            self.isSetUp = true

            let center = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                if granted {
                    self.registerCategories()
                }
            }
        }
    }

    private func registerCategories() {
        let viewAction = UNNotificationAction(identifier: "VIEW", title: "View Details", options: .foreground)
        let dismissAction = UNNotificationAction(identifier: "DISMISS", title: "Dismiss", options: .destructive)

        let threatCategory = UNNotificationCategory(
            identifier: "THREAT",
            actions: [viewAction, dismissAction],
            intentIdentifiers: []
        )
        let scanCategory = UNNotificationCategory(
            identifier: "SCAN",
            actions: [viewAction],
            intentIdentifiers: []
        )

        UNUserNotificationCenter.current().setNotificationCategories([threatCategory, scanCategory])
    }

    // MARK: - Send Notifications (all guarded)

    func sendThreatNotification(threat: ThreatInfo) {
        guard isSetUp else { return }
        let content = UNMutableNotificationContent()
        content.title = "⚠️ Threat Detected"
        content.subtitle = threat.name
        content.body = "Severity: \(threat.severity.rawValue) — \(threat.filePath)"
        content.sound = .defaultCritical
        content.categoryIdentifier = "THREAT"

        let request = UNNotificationRequest(identifier: "threat-\(threat.id)", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }

    func sendScanCompleteNotification(filesScanned: Int, threatsFound: Int, duration: TimeInterval) {
        guard isSetUp else { return }
        let content = UNMutableNotificationContent()
        content.title = threatsFound > 0 ? "⚠️ Scan Complete — \(threatsFound) Threat(s)" : "✅ Scan Complete — No Threats"
        content.body = "Scanned \(filesScanned) files in \(String(format: "%.0f", duration))s"
        content.sound = threatsFound > 0 ? .defaultCritical : .default
        content.categoryIdentifier = "SCAN"

        let request = UNNotificationRequest(identifier: "scan-\(UUID())", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }

    func sendScheduledScanNotification(type: ScanType) {
        guard isSetUp else { return }
        let content = UNMutableNotificationContent()
        content.title = "🔄 Scheduled Scan Starting"
        content.body = "\(type.rawValue) is now running"
        content.sound = .default

        let request = UNNotificationRequest(identifier: "scheduled-\(UUID())", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }

    func sendRealTimeAlert(fileName: String, threatName: String) {
        guard isSetUp else { return }
        let content = UNMutableNotificationContent()
        content.title = "🔴 Real-Time Alert"
        content.subtitle = threatName
        content.body = "Suspicious file detected: \(fileName)"
        content.sound = .defaultCritical
        content.categoryIdentifier = "THREAT"

        let request = UNNotificationRequest(identifier: "realtime-\(UUID())", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - UNUserNotificationCenterDelegate
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [.banner, .sound]
    }
}
