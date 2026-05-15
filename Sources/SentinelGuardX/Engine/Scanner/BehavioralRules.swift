import Foundation

enum BehavioralRules {
    struct RuleMatch {
        let ruleName: String
        let severity: ThreatSeverity
        let description: String
        let matchedPattern: String
    }

    private static let scannableExtensions: Set<String> = [
        "sh", "command", "bash", "zsh", "csh", "fish",
        "py", "rb", "pl", "php",
        "scpt", "applescript",
        "txt", "cfg", "conf", "ini"
    ]

    private static let rules: [(name: String, pattern: String, severity: ThreatSeverity, description: String)] = [
        // Download & Execute
        ("Download-And-Execute", "curl.*\\|.*(?:ba)?sh", .high,
         "Downloads and executes remote code via curl pipe"),
        ("Download-And-Execute", "wget.*\\|.*(?:ba)?sh", .high,
         "Downloads and executes remote code via wget pipe"),

        // Privilege Escalation
        ("Password-Phishing", "osascript.*(?:password|passphrase)", .critical,
         "AppleScript attempting to steal admin password"),
        ("Sudo-Escalation", "echo.*\\|.*sudo", .high,
         "Automated privilege escalation attempt"),

        // Reverse Shells
        ("Reverse-Shell", "bash.*-i.*>/dev/tcp", .critical,
         "Bash reverse shell to remote server"),
        ("Reverse-Shell", "nc.*-e.*/bin/(?:ba)?sh", .critical,
         "Netcat reverse shell attempt"),
        ("Reverse-Shell", "python.*socket.*connect", .high,
         "Python-based reverse shell attempt"),

        // Obfuscation
        ("Obfuscated-Execution", "base64.*(?:--decode|-d).*\\|.*(?:ba)?sh", .high,
         "Base64-obfuscated code execution"),
        ("Obfuscated-Execution", "eval.*\\$\\(.*base64", .high,
         "Eval with base64 decode payload"),

        // Persistence
        ("Persistence-Install", "LaunchAgents.*\\.plist", .medium,
         "Installs LaunchAgent for persistence"),
        ("Persistence-Install", "LaunchDaemons.*\\.plist", .high,
         "Installs LaunchDaemon for system persistence"),
        ("Crontab-Install", "crontab.*-", .medium,
         "Modifies crontab for persistence"),

        // Credential Theft
        ("Keychain-Access", "security.*find-.*-password", .high,
         "Attempts to extract keychain passwords"),
        ("SSH-Key-Theft", "cp.*\\.ssh/id_", .high,
         "Attempts to copy SSH private keys"),

        // System Manipulation
        ("SIP-Disable", "csrutil.*disable", .critical,
         "Attempts to disable System Integrity Protection"),
        ("Gatekeeper-Disable", "spctl.*--master-disable", .critical,
         "Attempts to disable Gatekeeper"),
        ("Firewall-Disable", "pfctl.*-d", .high,
         "Attempts to disable the firewall"),
    ]

    static func scan(fileURL: URL) -> RuleMatch? {
        let ext = fileURL.pathExtension.lowercased()
        guard scannableExtensions.contains(ext) || ext.isEmpty else { return nil }

        guard let handle = try? FileHandle(forReadingFrom: fileURL) else { return nil }
        defer { handle.closeFile() }

        let data = handle.readData(ofLength: 8192)
        guard let content = String(data: data, encoding: .utf8) else { return nil }

        let lowered = content.lowercased()

        for rule in rules {
            if lowered.range(of: rule.pattern, options: .regularExpression) != nil {
                return RuleMatch(
                    ruleName: rule.name,
                    severity: rule.severity,
                    description: rule.description,
                    matchedPattern: rule.pattern
                )
            }
        }
        return nil
    }
}
