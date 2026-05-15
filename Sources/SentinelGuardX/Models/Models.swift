import Foundation

enum ThreatSeverity: String, Codable, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"
}

struct ThreatInfo: Identifiable, Codable {
    let id: UUID
    let name: String
    let category: String
    let severity: ThreatSeverity
    let description: String
    let detectedAt: Date
    let filePath: String
    let fileHash: String

    init(
        id: UUID = UUID(),
        name: String,
        category: String = "Malware",
        severity: ThreatSeverity = .medium,
        description: String = "",
        detectedAt: Date = Date(),
        filePath: String = "",
        fileHash: String = ""
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.severity = severity
        self.description = description
        self.detectedAt = detectedAt
        self.filePath = filePath
        self.fileHash = fileHash
    }
}

struct ScanResult: Identifiable {
    let id = UUID()
    let fileURL: URL
    let threat: ThreatInfo?
    let hash: String
    let fileSize: UInt64
    let isClean: Bool

    init(fileURL: URL, threat: ThreatInfo? = nil, hash: String = "", fileSize: UInt64 = 0) {
        self.fileURL = fileURL
        self.threat = threat
        self.hash = hash
        self.fileSize = fileSize
        self.isClean = threat == nil
    }
}

struct QuarantineItem: Identifiable, Codable {
    let id: UUID
    let originalPath: String
    let quarantinedPath: String
    let fileName: String
    let threatName: String
    let severity: ThreatSeverity
    let quarantinedAt: Date
    let fileSize: UInt64
    let fileHash: String

    init(
        id: UUID = UUID(),
        originalPath: String,
        quarantinedPath: String,
        fileName: String,
        threatName: String,
        severity: ThreatSeverity = .medium,
        quarantinedAt: Date = Date(),
        fileSize: UInt64 = 0,
        fileHash: String = ""
    ) {
        self.id = id
        self.originalPath = originalPath
        self.quarantinedPath = quarantinedPath
        self.fileName = fileName
        self.threatName = threatName
        self.severity = severity
        self.quarantinedAt = quarantinedAt
        self.fileSize = fileSize
        self.fileHash = fileHash
    }
}

struct CleanerCategory: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let description: String
    var size: UInt64 = 0
    var itemCount: Int = 0
    var isSelected: Bool = true
    var isAnalyzing: Bool = false

    static let caches = CleanerCategory(
        name: "System Caches", icon: "archivebox.fill",
        description: "Application and system cache files"
    )
    static let logs = CleanerCategory(
        name: "Log Files", icon: "doc.text.fill",
        description: "System and application log files"
    )
    static let browser = CleanerCategory(
        name: "Browser Data", icon: "globe",
        description: "Browser caches, cookies, and temp files"
    )
    static let trash = CleanerCategory(
        name: "Trash", icon: "trash.fill",
        description: "Files in the Trash"
    )
}

struct StartupItem: Identifiable {
    let id = UUID()
    let name: String
    let path: String
    let type: StartupItemType
    var isEnabled: Bool
    let isSuspicious: Bool
    let bundleIdentifier: String?
    let isSigned: Bool

    enum StartupItemType: String {
        case launchAgent = "Launch Agent"
        case launchDaemon = "Launch Daemon"
        case loginItem = "Login Item"
    }
}

struct NetworkConnection: Identifiable {
    let id = UUID()
    let processName: String
    let localAddress: String
    let remoteAddress: String
    let port: Int
    let state: String
    let protocol_: String
    let isSuspicious: Bool
    let timestamp: Date

    init(
        processName: String = "Unknown",
        localAddress: String = "",
        remoteAddress: String = "",
        port: Int = 0,
        state: String = "ESTABLISHED",
        protocol_: String = "TCP",
        isSuspicious: Bool = false,
        timestamp: Date = Date()
    ) {
        self.processName = processName
        self.localAddress = localAddress
        self.remoteAddress = remoteAddress
        self.port = port
        self.state = state
        self.protocol_ = protocol_
        self.isSuspicious = isSuspicious
        self.timestamp = timestamp
    }
}

struct PrivacyPermission: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let status: PermissionStatus
    let description: String
    let appsWithAccess: [String]

    enum PermissionStatus: String {
        case granted = "Granted"
        case denied = "Denied"
        case notDetermined = "Not Set"
        case restricted = "Restricted"
    }
}
