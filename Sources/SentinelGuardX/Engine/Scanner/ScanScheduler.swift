import Foundation
import Observation

@Observable
final class ScanScheduler {
    var isEnabled: Bool = false
    var frequency: ScanFrequency = .daily
    var scanType: ScanType = .quick
    var nextScanDate: Date?
    var lastScheduledScan: Date?

    enum ScanFrequency: String, CaseIterable, Identifiable {
        case every6h = "Every 6 Hours"
        case every12h = "Every 12 Hours"
        case daily = "Daily"
        case weekly = "Weekly"
        var id: String { rawValue }

        var interval: TimeInterval {
            switch self {
            case .every6h: return 6 * 3600
            case .every12h: return 12 * 3600
            case .daily: return 24 * 3600
            case .weekly: return 7 * 24 * 3600
            }
        }

        var icon: String {
            switch self {
            case .every6h: return "6.circle.fill"
            case .every12h: return "12.circle.fill"
            case .daily: return "sun.max.fill"
            case .weekly: return "calendar"
            }
        }
    }

    private var timer: Timer?
    var scannerCore: ScannerCore?

    init() { load() }

    func start() {
        guard isEnabled else { return }
        reschedule()
    }

    func toggle() {
        isEnabled.toggle()
        save()
        if isEnabled {
            reschedule()
        } else {
            timer?.invalidate()
            timer = nil
            nextScanDate = nil
        }
    }

    func updateFrequency(_ freq: ScanFrequency) {
        frequency = freq
        save()
        if isEnabled { reschedule() }
    }

    func updateScanType(_ type: ScanType) {
        scanType = type
        save()
    }

    private func reschedule() {
        timer?.invalidate()
        guard isEnabled else {
            nextScanDate = nil
            return
        }

        nextScanDate = Date().addingTimeInterval(frequency.interval)
        timer = Timer.scheduledTimer(withTimeInterval: frequency.interval, repeats: true) { [weak self] _ in
            self?.triggerScheduledScan()
        }
    }

    private func triggerScheduledScan() {
        guard let scanner = scannerCore, !scanner.isScanning else { return }
        lastScheduledScan = Date()
        nextScanDate = Date().addingTimeInterval(frequency.interval)
        NotificationManager.shared.sendScheduledScanNotification(type: scanType)
        scanner.startScan(type: scanType)
        save()
    }

    private func save() {
        UserDefaults.standard.set(isEnabled, forKey: "sgx_scheduleEnabled")
        UserDefaults.standard.set(frequency.rawValue, forKey: "sgx_scheduleFrequency")
        UserDefaults.standard.set(scanType.rawValue, forKey: "sgx_scheduleScanType")
    }

    private func load() {
        isEnabled = UserDefaults.standard.bool(forKey: "sgx_scheduleEnabled")
        if let f = UserDefaults.standard.string(forKey: "sgx_scheduleFrequency"),
           let freq = ScanFrequency(rawValue: f) {
            frequency = freq
        }
        if let t = UserDefaults.standard.string(forKey: "sgx_scheduleScanType"),
           let type = ScanType(rawValue: t) {
            scanType = type
        }
    }
}
