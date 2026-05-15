import SwiftUI
import Observation

enum NavigationSection: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case scanner = "Scanner"
    case cleaner = "Cleaner"
    case quarantine = "Quarantine"
    case startup = "Startup"
    case network = "Network"
    case privacy = "Privacy"
    case settings = "Settings"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .dashboard: return "shield.checkered"
        case .scanner: return "magnifyingglass.circle.fill"
        case .cleaner: return "sparkles"
        case .quarantine: return "lock.shield.fill"
        case .startup: return "bolt.circle.fill"
        case .network: return "network"
        case .privacy: return "eye.slash.circle.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

@Observable
final class AppState {
    // Navigation
    var selectedSection: NavigationSection = .dashboard

    // Protection
    var isProtectionActive: Bool = true {
        didSet {
            if isProtectionActive {
                fileMonitor.startMonitoring()
            } else {
                fileMonitor.stopMonitoring()
            }
        }
    }
    var threatsBlocked: Int = 0
    var filesScanned: Int = 0
    var lastScanDate: Date? = nil
    var databaseVersion: String = "2026.05.14-b"

    // Phase 1 Engines
    var scannerEngine = ScannerCore()
    var cleanerEngine = CleanerCore()
    var quarantineEngine = QuarantineCore()
    var startupAnalyzer = StartupAnalyzer()
    var systemMonitor = SystemMonitor()
    var networkMonitorEngine = NetworkMonitorEngine()
    var privacyMonitor = PrivacyMonitor()

    // Phase 2 Engines
    var fileMonitor = FileMonitor()
    var scanScheduler = ScanScheduler()
    var scanHistory = ScanHistory()
    
    // Phase 3 Engines
    var securityAuditor = SecurityAuditor()
    var usbMonitor = USBDeviceMonitor()

    init() {
        // Wire up cross-references
        scannerEngine.scanHistory = scanHistory
        scanScheduler.scannerCore = scannerEngine

        // Load persisted stats
        threatsBlocked = UserDefaults.standard.integer(forKey: "sgx_threatsBlocked")
        filesScanned = UserDefaults.standard.integer(forKey: "sgx_filesScanned")
        if let lastDate = UserDefaults.standard.object(forKey: "sgx_lastScanDate") as? Date {
            lastScanDate = lastDate
        }

        // Update stats from scan history
        if let lastRecord = scanHistory.lastScanRecord {
            if lastScanDate == nil { lastScanDate = lastRecord.date }
        }
    }

    func updateStatsAfterScan() {
        filesScanned += scannerEngine.filesScanned
        threatsBlocked += scannerEngine.threatsFound.count
        lastScanDate = Date()
        UserDefaults.standard.set(filesScanned, forKey: "sgx_filesScanned")
        UserDefaults.standard.set(threatsBlocked, forKey: "sgx_threatsBlocked")
        UserDefaults.standard.set(lastScanDate, forKey: "sgx_lastScanDate")
    }
}
