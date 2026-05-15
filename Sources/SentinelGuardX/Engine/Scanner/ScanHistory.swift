import Foundation
import Observation

struct ScanRecord: Identifiable, Codable {
    let id: UUID
    let date: Date
    let scanType: String
    let duration: TimeInterval
    let filesScanned: Int
    let threatsFound: Int
    let threatNames: [String]

    init(id: UUID = UUID(), date: Date = Date(), scanType: String, duration: TimeInterval,
         filesScanned: Int, threatsFound: Int, threatNames: [String] = []) {
        self.id = id
        self.date = date
        self.scanType = scanType
        self.duration = duration
        self.filesScanned = filesScanned
        self.threatsFound = threatsFound
        self.threatNames = threatNames
    }
}

@Observable
final class ScanHistory {
    var records: [ScanRecord] = []

    private var logFile: URL {
        FileUtils.appSupportDirectory().appendingPathComponent("scan_history.json")
    }

    init() { load() }

    func addRecord(_ record: ScanRecord) {
        records.insert(record, at: 0)
        if records.count > 50 { records = Array(records.prefix(50)) }
        save()
    }

    var totalScans: Int { records.count }
    var totalThreatsEverFound: Int { records.reduce(0) { $0 + $1.threatsFound } }

    var averageDuration: TimeInterval {
        guard !records.isEmpty else { return 0 }
        return records.reduce(0.0) { $0 + $1.duration } / Double(records.count)
    }

    var lastScanRecord: ScanRecord? { records.first }

    private func save() {
        if let data = try? JSONEncoder().encode(records) {
            try? data.write(to: logFile)
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: logFile),
              let loaded = try? JSONDecoder().decode([ScanRecord].self, from: data)
        else { return }
        records = loaded
    }
}
