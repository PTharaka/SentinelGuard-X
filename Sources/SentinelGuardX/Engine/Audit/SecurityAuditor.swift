import Foundation
import Observation

@Observable
final class SecurityAuditor {
    var isFileVaultEnabled = false
    var isSIPEnabled = false
    var isFirewallEnabled = false
    
    var securityScore: Int {
        var score = 0
        if isFileVaultEnabled { score += 40 }
        if isSIPEnabled { score += 40 }
        if isFirewallEnabled { score += 20 }
        return score
    }
    
    init() {
        refreshAudit()
    }
    
    func refreshAudit() {
        Task.detached(priority: .background) {
            let fv = await self.checkFileVault()
            let sip = await self.checkSIP()
            let fw = await self.checkFirewall()
            
            await MainActor.run {
                self.isFileVaultEnabled = fv
                self.isSIPEnabled = sip
                self.isFirewallEnabled = fw
            }
        }
    }
    
    private func checkFileVault() async -> Bool {
        let output = await runCommand("/usr/bin/fdesetup", arguments: ["status"])
        return output.contains("FileVault is On")
    }
    
    private func checkSIP() async -> Bool {
        let output = await runCommand("/usr/bin/csrutil", arguments: ["status"])
        return output.contains("enabled") && !output.contains("disabled")
    }
    
    private func checkFirewall() async -> Bool {
        let output = await runCommand("/usr/libexec/ApplicationFirewall/socketfilterfw", arguments: ["--getglobalstate"])
        return output.contains("enabled")
    }
    
    private func runCommand(_ executablePath: String, arguments: [String]) async -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executablePath)
        process.arguments = arguments
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice
        
        do {
            try process.run()
            process.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            return String(data: data, encoding: .utf8)?.lowercased() ?? ""
        } catch {
            return ""
        }
    }
}
