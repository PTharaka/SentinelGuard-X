import Foundation

enum ReportGenerator {
    
    static func generateHTMLReport(appState: AppState) -> URL? {
        let dateString = FormatUtils.formatDate(Date())
        let score = appState.securityAuditor.securityScore
        
        let scoreColor = score >= 80 ? "#34C759" : (score >= 50 ? "#FF9F0A" : "#FF3B30")
        
        var recentThreatsHTML = ""
        if appState.scannerEngine.threatsFound.isEmpty {
            recentThreatsHTML = "<p>No threats detected recently. System is clean.</p>"
        } else {
            recentThreatsHTML = "<ul>"
            for threat in appState.scannerEngine.threatsFound.prefix(10) {
                let color = threat.severity == .critical || threat.severity == .high ? "#FF3B30" : (threat.severity == .medium ? "#FF9F0A" : "#34C759")
                recentThreatsHTML += """
                <li>
                    <strong><span style="color: \(color)">[\(threat.severity.rawValue)]</span> \(threat.name)</strong><br>
                    <small>\(threat.filePath)</small>
                </li>
                """
            }
            recentThreatsHTML += "</ul>"
        }
        
        let html = """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>SentinelGuard X - Security Audit Report</title>
            <style>
                body {
                    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
                    background-color: #0A0A0C;
                    color: #EBEBF5;
                    line-height: 1.6;
                    padding: 40px;
                    max-width: 800px;
                    margin: 0 auto;
                }
                h1, h2, h3 { color: #FFFFFF; }
                .header {
                    text-align: center;
                    border-bottom: 1px solid #333;
                    padding-bottom: 20px;
                    margin-bottom: 30px;
                }
                .score-card {
                    background-color: #1C1C1E;
                    border-radius: 12px;
                    padding: 20px;
                    text-align: center;
                    margin-bottom: 30px;
                }
                .score-value {
                    font-size: 48px;
                    font-weight: bold;
                    color: \(scoreColor);
                }
                .section {
                    background-color: #1C1C1E;
                    border-radius: 12px;
                    padding: 20px;
                    margin-bottom: 20px;
                }
                .status-row {
                    display: flex;
                    justify-content: space-between;
                    border-bottom: 1px solid #333;
                    padding: 10px 0;
                }
                .status-row:last-child { border-bottom: none; }
                .success { color: #34C759; font-weight: bold; }
                .danger { color: #FF3B30; font-weight: bold; }
                ul { padding-left: 20px; }
                li { margin-bottom: 10px; }
                .footer {
                    text-align: center;
                    font-size: 12px;
                    color: #8E8E93;
                    margin-top: 50px;
                }
            </style>
        </head>
        <body>

        <div class="header">
            <h1>🛡️ SentinelGuard X</h1>
            <h2>System Security Audit Report</h2>
            <p>Generated on \(dateString)</p>
        </div>

        <div class="score-card">
            <h3>Overall Security Posture</h3>
            <div class="score-value">\(score)%</div>
        </div>

        <div class="section">
            <h3>System Defenses</h3>
            <div class="status-row">
                <span>FileVault Encryption</span>
                <span class="\(appState.securityAuditor.isFileVaultEnabled ? "success" : "danger")">
                    \(appState.securityAuditor.isFileVaultEnabled ? "Enabled" : "Disabled")
                </span>
            </div>
            <div class="status-row">
                <span>System Integrity Protection (SIP)</span>
                <span class="\(appState.securityAuditor.isSIPEnabled ? "success" : "danger")">
                    \(appState.securityAuditor.isSIPEnabled ? "Enabled" : "Disabled")
                </span>
            </div>
            <div class="status-row">
                <span>macOS Firewall</span>
                <span class="\(appState.securityAuditor.isFirewallEnabled ? "success" : "danger")">
                    \(appState.securityAuditor.isFirewallEnabled ? "Enabled" : "Disabled")
                </span>
            </div>
        </div>

        <div class="section">
            <h3>Protection Statistics</h3>
            <div class="status-row">
                <span>Real-Time Guard</span>
                <span class="\(appState.fileMonitor.isMonitoring ? "success" : "danger")">
                    \(appState.fileMonitor.isMonitoring ? "Active" : "Inactive")
                </span>
            </div>
            <div class="status-row">
                <span>Total Files Scanned</span>
                <span>\(FormatUtils.formatNumber(appState.filesScanned))</span>
            </div>
            <div class="status-row">
                <span>Threats Blocked</span>
                <span>\(FormatUtils.formatNumber(appState.threatsBlocked))</span>
            </div>
            <div class="status-row">
                <span>Database Version</span>
                <span>\(appState.databaseVersion)</span>
            </div>
        </div>

        <div class="section">
            <h3>Recent Threats</h3>
            \(recentThreatsHTML)
        </div>

        <div class="footer">
            <p>SentinelGuard X Security Platform • Confidential Audit Report</p>
        </div>

        </body>
        </html>
        """
        
        let desktopURL = FileUtils.homeDirectory().appendingPathComponent("Desktop")
        let fileURL = desktopURL.appendingPathComponent("SentinelGuardX_Audit.html")
        
        do {
            try html.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Failed to write report: \(error)")
            return nil
        }
    }
}
