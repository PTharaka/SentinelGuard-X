import Foundation
import Observation
import CoreServices

struct FileEvent: Identifiable {
    let id = UUID()
    let path: String
    let fileName: String
    let eventType: FileEventType
    let timestamp: Date
    var threatInfo: ThreatInfo?

    enum FileEventType: String {
        case created = "Created"
        case modified = "Modified"
        case deleted = "Deleted"
        case renamed = "Renamed"
    }
}

@Observable
final class FileMonitor {
    var isMonitoring = false
    var recentEvents: [FileEvent] = []
    var realTimeThreatsDetected: Int = 0

    private var stream: FSEventStreamRef?
    private let monitorQueue = DispatchQueue(label: "com.sentinelguardx.filemonitor", qos: .utility)

    private var watchedPaths: [String] {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        return [
            "\(home)/Downloads",
            "\(home)/Desktop",
            "/Applications"
        ]
    }

    func startMonitoring() {
        guard !isMonitoring else { return }

        var context = FSEventStreamContext()
        context.info = Unmanaged.passUnretained(self).toOpaque()

        let cfPaths = watchedPaths as CFArray

        guard let eventStream = FSEventStreamCreate(
            nil,
            fileMonitorCallback,
            &context,
            cfPaths,
            FSEventStreamEventId(kFSEventStreamEventIdSinceNow),
            1.5,
            UInt32(kFSEventStreamCreateFlagFileEvents | kFSEventStreamCreateFlagUseCFTypes | kFSEventStreamCreateFlagNoDefer)
        ) else { return }

        stream = eventStream
        FSEventStreamSetDispatchQueue(eventStream, monitorQueue)
        FSEventStreamStart(eventStream)
        isMonitoring = true
    }

    func stopMonitoring() {
        guard let stream = stream else { return }
        FSEventStreamStop(stream)
        FSEventStreamInvalidate(stream)
        FSEventStreamRelease(stream)
        self.stream = nil
        isMonitoring = false
    }

    fileprivate func handleEvent(path: String, flags: FSEventStreamEventFlags) {
        let url = URL(fileURLWithPath: path)
        let fileName = url.lastPathComponent

        // Skip hidden/system files
        if fileName.hasPrefix(".") { return }

        let eventType: FileEvent.FileEventType
        if flags & UInt32(kFSEventStreamEventFlagItemCreated) != 0 {
            eventType = .created
        } else if flags & UInt32(kFSEventStreamEventFlagItemModified) != 0 {
            eventType = .modified
        } else if flags & UInt32(kFSEventStreamEventFlagItemRemoved) != 0 {
            eventType = .deleted
        } else if flags & UInt32(kFSEventStreamEventFlagItemRenamed) != 0 {
            eventType = .renamed
        } else {
            return
        }

        // Only scan regular files (not directories)
        guard flags & UInt32(kFSEventStreamEventFlagItemIsFile) != 0 else { return }

        var event = FileEvent(path: path, fileName: fileName, eventType: eventType, timestamp: Date())

        // Auto-scan new/modified files for threats
        if (eventType == .created || eventType == .modified) && FileManager.default.fileExists(atPath: path) {
            // Check with hash signatures
            if let hash = HashEngine.sha256(of: url) {
                if let threat = ThreatSignatures.check(hash: hash, filePath: path) {
                    event.threatInfo = threat
                    DispatchQueue.main.async {
                        self.realTimeThreatsDetected += 1
                    }
                    NotificationManager.shared.sendThreatNotification(threat: threat)
                }
            }

            // Check with behavioral rules
            if event.threatInfo == nil {
                if let match = BehavioralRules.scan(fileURL: url) {
                    let threat = ThreatInfo(
                        name: match.ruleName,
                        category: "Behavioral",
                        severity: match.severity,
                        description: match.description,
                        filePath: path,
                        fileHash: ""
                    )
                    event.threatInfo = threat
                    DispatchQueue.main.async {
                        self.realTimeThreatsDetected += 1
                    }
                    NotificationManager.shared.sendThreatNotification(threat: threat)
                }
            }
        }

        DispatchQueue.main.async {
            self.recentEvents.insert(event, at: 0)
            if self.recentEvents.count > 50 {
                self.recentEvents = Array(self.recentEvents.prefix(50))
            }
        }
    }
}

// C callback for FSEventStream
private func fileMonitorCallback(
    _ streamRef: ConstFSEventStreamRef,
    _ clientCallBackInfo: UnsafeMutableRawPointer?,
    _ numEvents: Int,
    _ eventPaths: UnsafeMutableRawPointer,
    _ eventFlags: UnsafePointer<FSEventStreamEventFlags>,
    _ eventIds: UnsafePointer<FSEventStreamEventId>
) {
    guard let clientCallBackInfo = clientCallBackInfo else { return }
    let monitor = Unmanaged<FileMonitor>.fromOpaque(clientCallBackInfo).takeUnretainedValue()
    let paths = unsafeBitCast(eventPaths, to: NSArray.self)

    for i in 0..<numEvents {
        guard let path = paths[i] as? String else { continue }
        monitor.handleEvent(path: path, flags: eventFlags[i])
    }
}
