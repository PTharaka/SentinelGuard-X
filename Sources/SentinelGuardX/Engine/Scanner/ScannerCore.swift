import Foundation
import Observation

enum ScanType: String, CaseIterable, Identifiable {
    case quick = "Quick Scan"
    case full = "Full Scan"
    case custom = "Custom Scan"
    case external = "External Drive"
    var id: String { rawValue }

    var icon: String {
        switch self {
        case .quick: return "hare.fill"
        case .full: return "shield.checkered"
        case .custom: return "folder.fill"
        case .external: return "externaldrive.fill"
        }
    }

    var description: String {
        switch self {
        case .quick: return "Scans Downloads, Applications, and common threat locations"
        case .full: return "Deep scan of all user-accessible files on the system"
        case .custom: return "Scan a specific folder of your choice"
        case .external: return "Scan connected external drives"
        }
    }
}

@Observable
final class ScannerCore {
    var isScanning = false
    var isPaused = false
    var scanProgress: Double = 0
    var filesScanned: Int = 0
    var totalFiles: Int = 0
    var threatsFound: [ThreatInfo] = []
    var currentFile: String = ""
    var scanResults: [ScanResult] = []
    var scanType: ScanType = .quick
    var customScanURL: URL? = nil
    var scanStartTime: Date? = nil

    // Phase 2: history reference
    var scanHistory: ScanHistory?

    private var scanTask: Task<Void, Never>?

    var elapsedTime: TimeInterval {
        guard let start = scanStartTime else { return 0 }
        return Date().timeIntervalSince(start)
    }

    func startScan(type: ScanType) {
        self.scanType = type
        isScanning = true
        isPaused = false
        scanProgress = 0
        filesScanned = 0
        totalFiles = 0
        threatsFound = []
        scanResults = []
        currentFile = "Preparing..."
        scanStartTime = Date()

        scanTask = Task {
            let directories = getDirectories(for: type)
            let files = await collectFilesAsync(in: directories)
            await MainActor.run { self.totalFiles = files.count }

            for (index, file) in files.enumerated() {
                if Task.isCancelled { break }
                while isPaused { try? await Task.sleep(for: .milliseconds(200)) }

                let fileName = file.lastPathComponent
                await MainActor.run { self.currentFile = fileName }

                // Hash-based scan
                if let hash = HashEngine.sha256(of: file) {
                    let threat = ThreatSignatures.check(hash: hash, filePath: file.path)
                    let size = (try? file.resourceValues(forKeys: [.fileSizeKey]).fileSize).map { UInt64($0) } ?? 0
                    var finalThreat = threat

                    // Behavioral scan if no hash match
                    if finalThreat == nil {
                        if let match = BehavioralRules.scan(fileURL: file) {
                            finalThreat = ThreatInfo(
                                name: match.ruleName,
                                category: "Behavioral",
                                severity: match.severity,
                                description: match.description,
                                filePath: file.path,
                                fileHash: hash
                            )
                        }
                    }

                    let capturedThreat = finalThreat
                    let result = ScanResult(fileURL: file, threat: capturedThreat, hash: hash, fileSize: size)
                    await MainActor.run {
                        self.scanResults.append(result)
                        if let t = capturedThreat {
                            self.threatsFound.append(t)
                        }
                    }
                }

                await MainActor.run {
                    self.filesScanned = index + 1
                    self.scanProgress = self.totalFiles > 0 ? Double(index + 1) / Double(self.totalFiles) : 0
                }

                if index % 10 == 0 {
                    try? await Task.sleep(for: .milliseconds(5))
                }
            }

            let duration = Date().timeIntervalSince(self.scanStartTime ?? Date())
            let threatCount = self.threatsFound.count
            let fileCount = self.filesScanned
            let threatNames = self.threatsFound.map { $0.name }

            await MainActor.run {
                self.isScanning = false
                self.currentFile = "Scan Complete"
                self.scanProgress = 1.0

                // Save to scan history
                let record = ScanRecord(
                    scanType: type.rawValue,
                    duration: duration,
                    filesScanned: fileCount,
                    threatsFound: threatCount,
                    threatNames: threatNames
                )
                self.scanHistory?.addRecord(record)

                // Send notification
                NotificationManager.shared.sendScanCompleteNotification(
                    filesScanned: fileCount,
                    threatsFound: threatCount,
                    duration: duration
                )
            }
        }
    }

    func stopScan() {
        scanTask?.cancel()
        isScanning = false
        currentFile = "Scan Cancelled"
    }

    func togglePause() {
        isPaused.toggle()
    }

    private func getDirectories(for type: ScanType) -> [URL] {
        let home = FileUtils.homeDirectory()
        switch type {
        case .quick:
            return [
                home.appendingPathComponent("Downloads"),
                URL(fileURLWithPath: "/Applications"),
                home.appendingPathComponent("Desktop"),
            ]
        case .full:
            return [
                home,
                URL(fileURLWithPath: "/Applications"),
            ]
        case .custom:
            if let url = customScanURL { return [url] }
            return [home.appendingPathComponent("Downloads")]
        case .external:
            return [URL(fileURLWithPath: "/Volumes")]
        }
    }

    private func collectFilesAsync(in directories: [URL]) async -> [URL] {
        return FileUtils.collectFiles(in: directories)
    }
}
