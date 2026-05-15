import Foundation

enum AppIntegrityChecker {
    
    enum IntegrityStatus {
        case valid
        case unsigned
        case modified
        case revoked
        case error(String)
        
        var description: String {
            switch self {
            case .valid: return "Valid Apple Signature"
            case .unsigned: return "Unsigned Application"
            case .modified: return "Modified or Broken Signature"
            case .revoked: return "Signature Revoked"
            case .error(let msg): return "Error: \(msg)"
            }
        }
        
        var severity: ThreatSeverity {
            switch self {
            case .valid: return .low // Shouldn't be flagged as threat
            case .unsigned: return .medium
            case .modified: return .critical
            case .revoked: return .high
            case .error: return .low
            }
        }
    }
    
    static func check(appURL: URL) async -> IntegrityStatus {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/codesign")
        // -v verifies, --strict performs strict validation
        process.arguments = ["-v", "--strict", appURL.path]
        
        let pipe = Pipe()
        process.standardError = pipe // codesign outputs to stderr
        
        do {
            try process.run()
            process.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8)?.lowercased() ?? ""
            
            if process.terminationStatus == 0 {
                return .valid
            } else {
                if output.contains("code object is not signed at all") {
                    return .unsigned
                } else if output.contains("invalid signature") || output.contains("a sealed resource is missing or invalid") {
                    return .modified
                } else if output.contains("revoked") {
                    return .revoked
                } else {
                    return .error(output.trimmingCharacters(in: .whitespacesAndNewlines))
                }
            }
        } catch {
            return .error(error.localizedDescription)
        }
    }
}
