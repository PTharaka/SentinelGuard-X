import Foundation
import Network
import Observation

@Observable
final class NetworkMonitorEngine {
    var isConnected = true
    var interfaceType: String = "Wi-Fi"
    var localIPAddress: String = "—"
    var connections: [NetworkConnection] = []
    var totalConnections: Int = 0
    var suspiciousConnections: Int = 0
    var uniqueProcesses: Int = 0

    private var pathMonitor: NWPathMonitor?
    private var timer: Timer?

    // Known suspicious ports
    private let suspiciousPorts: Set<Int> = [
        4444, 5555, 6666, 6667, 8080, 8888, 9999,
        1337, 31337, 12345, 54321, 65535
    ]

    func startMonitoring() {
        pathMonitor = NWPathMonitor()
        pathMonitor?.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                if path.usesInterfaceType(.wifi) {
                    self?.interfaceType = "Wi-Fi"
                } else if path.usesInterfaceType(.wiredEthernet) {
                    self?.interfaceType = "Ethernet"
                } else {
                    self?.interfaceType = "Other"
                }
            }
        }
        pathMonitor?.start(queue: DispatchQueue.global(qos: .utility))
        refreshConnections()
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.refreshConnections()
        }
    }

    func stopMonitoring() {
        pathMonitor?.cancel()
        timer?.invalidate()
    }

    func refreshConnections() {
        Task.detached(priority: .utility) {
            let parsed = await self.fetchRealConnections()
            await MainActor.run {
                self.connections = parsed
                self.totalConnections = parsed.count
                self.suspiciousConnections = parsed.filter { $0.isSuspicious }.count
                self.uniqueProcesses = Set(parsed.map { $0.processName }).count
            }
        }
    }

    private func fetchRealConnections() async -> [NetworkConnection] {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/sbin/lsof")
        process.arguments = ["-i", "-n", "-P", "+c", "0"]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            return []
        }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(data: data, encoding: .utf8) else { return [] }

        return parseLsofOutput(output)
    }

    private func parseLsofOutput(_ output: String) -> [NetworkConnection] {
        let lines = output.components(separatedBy: "\n")
        guard lines.count > 1 else { return [] }

        var results: [NetworkConnection] = []

        // Skip header line
        for line in lines.dropFirst() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }

            // lsof output columns vary; parse by splitting on whitespace
            let parts = trimmed.split(separator: " ", omittingEmptySubsequences: true).map(String.init)
            guard parts.count >= 9 else { continue }

            let processName = parts[0]
            let protocolType = parts.count > 7 ? parts[7] : "TCP"

            // Name field is typically the last column: "local->remote (state)"
            let nameField = parts.last ?? ""

            // Parse addresses
            var localAddr = ""
            var remoteAddr = ""
            var port = 0
            var state = "UNKNOWN"

            if nameField.contains("->") {
                let addrParts = nameField.components(separatedBy: "->")
                localAddr = addrParts[0]
                let remotePart = addrParts.count > 1 ? addrParts[1] : ""

                // Extract state in parentheses
                if let stateRange = remotePart.range(of: "\\((.+)\\)", options: .regularExpression) {
                    state = String(remotePart[stateRange]).replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")
                    remoteAddr = String(remotePart[remotePart.startIndex..<stateRange.lowerBound])
                } else {
                    remoteAddr = remotePart
                }

                // Extract port from remote address
                if let colonRange = remoteAddr.range(of: ":", options: .backwards) {
                    let portStr = String(remoteAddr[colonRange.upperBound...])
                    port = Int(portStr) ?? 0
                    remoteAddr = String(remoteAddr[..<colonRange.lowerBound])
                }
            } else if nameField.contains("*:") || nameField.contains(":") {
                localAddr = nameField
                state = "LISTEN"
            }

            let isSuspicious = suspiciousPorts.contains(port) ||
                remoteAddr.hasPrefix("10.") == false && remoteAddr.hasPrefix("192.168.") == false &&
                remoteAddr.hasPrefix("172.") == false && port != 443 && port != 80 && port != 993 &&
                port != 587 && port != 53 && port != 5353 && port != 0 && !remoteAddr.isEmpty &&
                state == "ESTABLISHED"

            let conn = NetworkConnection(
                processName: processName,
                localAddress: localAddr,
                remoteAddress: remoteAddr,
                port: port,
                state: state,
                protocol_: protocolType.hasPrefix("UDP") ? "UDP" : "TCP",
                isSuspicious: isSuspicious
            )
            results.append(conn)
        }

        return results
    }
}
