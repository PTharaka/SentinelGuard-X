import Foundation
import Observation

@Observable
final class QuarantineCore {
    var items: [QuarantineItem] = []

    private var quarantineDir: URL {
        FileUtils.appSupportDirectory().appendingPathComponent("Quarantine")
    }

    private var logFile: URL {
        FileUtils.appSupportDirectory().appendingPathComponent("quarantine_log.json")
    }

    init() {
        try? FileManager.default.createDirectory(at: quarantineDir, withIntermediateDirectories: true)
        loadItems()
    }

    func quarantine(filePath: String, threat: ThreatInfo) {
        let sourceURL = URL(fileURLWithPath: filePath)
        let fileName = sourceURL.lastPathComponent
        let quarantinedName = "\(UUID().uuidString)_\(fileName)"
        let destURL = quarantineDir.appendingPathComponent(quarantinedName)

        do {
            let size = (try? sourceURL.resourceValues(forKeys: [.fileSizeKey]).fileSize).map { UInt64($0) } ?? 0
            try FileManager.default.moveItem(at: sourceURL, to: destURL)

            // Remove execute permission
            try FileManager.default.setAttributes(
                [.posixPermissions: 0o400],
                ofItemAtPath: destURL.path
            )

            let item = QuarantineItem(
                originalPath: filePath,
                quarantinedPath: destURL.path,
                fileName: fileName,
                threatName: threat.name,
                severity: threat.severity,
                fileSize: size,
                fileHash: threat.fileHash
            )
            items.append(item)
            saveItems()
        } catch {
            // Silently fail for now
        }
    }

    func restore(item: QuarantineItem) {
        let source = URL(fileURLWithPath: item.quarantinedPath)
        let dest = URL(fileURLWithPath: item.originalPath)

        do {
            try FileManager.default.moveItem(at: source, to: dest)
            items.removeAll { $0.id == item.id }
            saveItems()
        } catch {
            // Silently fail
        }
    }

    func deletePermanently(item: QuarantineItem) {
        let url = URL(fileURLWithPath: item.quarantinedPath)
        try? FileManager.default.removeItem(at: url)
        items.removeAll { $0.id == item.id }
        saveItems()
    }

    private func saveItems() {
        if let data = try? JSONEncoder().encode(items) {
            try? data.write(to: logFile)
        }
    }

    private func loadItems() {
        guard let data = try? Data(contentsOf: logFile),
              let loaded = try? JSONDecoder().decode([QuarantineItem].self, from: data)
        else { return }
        items = loaded
    }
}
