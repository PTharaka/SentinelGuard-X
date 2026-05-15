import SwiftUI

struct DashboardView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Hero Section
                heroSection

                // Stats Row
                statsRow

                // Cards Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    systemHealthCard
                    liveActivityCard
                    securityPostureCard
                    recentThreatsCard
                }
            }
            .padding(28)
        }
    }

    // MARK: - Hero Section
    private var heroSection: some View {
        GlassmorphicCard(padding: 32) {
            HStack(spacing: 32) {
                PulsingShield(isActive: appState.isProtectionActive)

                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        Text(appState.isProtectionActive ? "System Protected" : "Protection Inactive")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.textPrimary)

                        StatusBadge(
                            text: appState.isProtectionActive ? "ACTIVE" : "PAUSED",
                            color: appState.isProtectionActive ? AppTheme.success : AppTheme.danger
                        )
                    }

                    Text("Last scan: \(FormatUtils.timeAgo(from: appState.lastScanDate))")
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.textSecondary)

                    Text("Database: \(appState.databaseVersion)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(AppTheme.textTertiary)

                    HStack(spacing: 12) {
                        GlowButton(title: "Quick Scan", icon: "hare.fill") {
                            appState.selectedSection = .scanner
                        }
                        GlowButton(title: "Full Scan", icon: "shield.checkered", color: AppTheme.purple) {
                            appState.selectedSection = .scanner
                        }
                    }
                    .padding(.top, 4)
                }

                Spacer()
            }
        }
    }

    // MARK: - Stats Row
    private var statsRow: some View {
        HStack(spacing: 16) {
            StatCard(
                value: FormatUtils.formatNumber(appState.threatsBlocked + appState.fileMonitor.realTimeThreatsDetected),
                label: "Threats Blocked",
                icon: "xmark.shield.fill",
                color: AppTheme.danger
            )
            StatCard(
                value: FormatUtils.formatNumber(appState.filesScanned),
                label: "Files Scanned",
                icon: "doc.viewfinder.fill",
                color: AppTheme.cyan
            )
            StatCard(
                value: appState.fileMonitor.isMonitoring ? "Active" : "Off",
                label: "Real-Time Guard",
                icon: "eye.fill",
                color: appState.fileMonitor.isMonitoring ? AppTheme.success : AppTheme.danger
            )
            StatCard(
                value: "\(appState.scanHistory.totalScans)",
                label: "Total Scans",
                icon: "chart.bar.fill",
                color: AppTheme.purple
            )
        }
    }

    // MARK: - System Health Card
    private var systemHealthCard: some View {
        GlassmorphicCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "heart.text.clipboard.fill")
                        .foregroundStyle(AppTheme.cyan)
                    Text("System Health")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppTheme.textPrimary)
                    Spacer()
                }

                HStack(spacing: 24) {
                    AnimatedGauge(value: appState.systemMonitor.cpuUsage, label: "CPU", icon: "cpu")
                    AnimatedGauge(value: appState.systemMonitor.memoryUsage, label: "RAM", icon: "memorychip")
                    AnimatedGauge(value: appState.systemMonitor.diskUsage, label: "Disk", icon: "internaldrive")
                }
                .frame(maxWidth: .infinity)

                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Memory")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(AppTheme.textTertiary)
                        Text(String(format: "%.1f / %.1f GB", appState.systemMonitor.usedMemoryGB, appState.systemMonitor.totalMemoryGB))
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Disk")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(AppTheme.textTertiary)
                        Text(String(format: "%.0f / %.0f GB", appState.systemMonitor.usedDiskGB, appState.systemMonitor.totalDiskGB))
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }
            }
        }
        .hoverScale()
    }

    // MARK: - Live Activity Card
    private var liveActivityCard: some View {
        GlassmorphicCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "waveform.path.ecg")
                        .foregroundStyle(AppTheme.success)
                    Text("Live Activity")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppTheme.textPrimary)
                    Spacer()
                    Circle()
                        .fill(AppTheme.success)
                        .frame(width: 6, height: 6)
                }

                VStack(spacing: 12) {
                    activityRow(icon: "gearshape.2.fill", label: "Active Processes", value: "\(appState.systemMonitor.processCount)", color: AppTheme.cyan)
                    activityRow(icon: "network", label: "Network Connections", value: "\(appState.networkMonitorEngine.totalConnections)", color: AppTheme.purple)
                    activityRow(icon: "exclamationmark.triangle.fill", label: "Suspicious Connections", value: "\(appState.networkMonitorEngine.suspiciousConnections)", color: appState.networkMonitorEngine.suspiciousConnections > 0 ? AppTheme.danger : AppTheme.warning)
                    activityRow(icon: "eye.fill", label: "File Events (RT)", value: "\(appState.fileMonitor.recentEvents.count)", color: AppTheme.success)
                    activityRow(icon: "shield.checkered", label: "RT Threats", value: "\(appState.fileMonitor.realTimeThreatsDetected)", color: appState.fileMonitor.realTimeThreatsDetected > 0 ? AppTheme.danger : AppTheme.success)
                }
            }
        }
        .hoverScale()
    }

    private func activityRow(icon: String, label: String, value: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(color)
                .frame(width: 24)
            Text(label)
                .font(.system(size: 13))
                .foregroundStyle(AppTheme.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundStyle(AppTheme.textPrimary)
        }
    }

    // MARK: - Recent Threats Card
    private var recentThreatsCard: some View {
        GlassmorphicCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "exclamationmark.shield.fill")
                        .foregroundStyle(AppTheme.warning)
                    Text("Recent Threats")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppTheme.textPrimary)
                    Spacer()
                    Text("Last 24h")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(AppTheme.textTertiary)
                }

                if appState.scannerEngine.threatsFound.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(AppTheme.success)
                        Text("No threats detected")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(AppTheme.textSecondary)
                        Text("Your system is clean")
                            .font(.system(size: 12))
                            .foregroundStyle(AppTheme.textTertiary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                } else {
                    ForEach(appState.scannerEngine.threatsFound.prefix(4)) { threat in
                        threatRow(threat)
                    }
                }
            }
        }
        .hoverScale()
    }

    private func threatRow(_ threat: ThreatInfo) -> some View {
        HStack(spacing: 10) {
            Circle()
                .fill(severityColor(threat.severity))
                .frame(width: 8, height: 8)
            VStack(alignment: .leading, spacing: 2) {
                Text(threat.name)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(AppTheme.textPrimary)
                Text(FormatUtils.timeAgo(from: threat.detectedAt))
                    .font(.system(size: 11))
                    .foregroundStyle(AppTheme.textTertiary)
            }
            Spacer()
            StatusBadge(text: threat.severity.rawValue, color: severityColor(threat.severity))
        }
    }

    private func severityColor(_ severity: ThreatSeverity) -> Color {
        switch severity {
        case .low: return AppTheme.success
        case .medium: return AppTheme.warning
        case .high: return AppTheme.danger
        case .critical: return AppTheme.danger
        }
    }

    // MARK: - Security Posture Card
    private var securityPostureCard: some View {
        GlassmorphicCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "lock.shield.fill")
                        .foregroundStyle(AppTheme.cyan)
                    Text("Security Posture")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppTheme.textPrimary)
                    Spacer()
                    
                    Text("\(appState.securityAuditor.securityScore)%")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(scoreColor(appState.securityAuditor.securityScore))
                }

                VStack(spacing: 12) {
                    postureRow(
                        icon: "key.fill",
                        label: "FileVault Encryption",
                        isEnabled: appState.securityAuditor.isFileVaultEnabled
                    )
                    postureRow(
                        icon: "shield.righthalf.filled",
                        label: "System Integrity (SIP)",
                        isEnabled: appState.securityAuditor.isSIPEnabled
                    )
                    postureRow(
                        icon: "network.badge.shield.half.filled",
                        label: "System Firewall",
                        isEnabled: appState.securityAuditor.isFirewallEnabled
                    )
                }

                GlowButton(title: "Refresh Audit", icon: "arrow.clockwise", color: AppTheme.cyan) {
                    appState.securityAuditor.refreshAudit()
                }
                .frame(maxWidth: .infinity)
            }
        }
        .hoverScale()
    }
    
    private func postureRow(icon: String, label: String, isEnabled: Bool) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(isEnabled ? AppTheme.success : AppTheme.danger)
                .frame(width: 24)
            Text(label)
                .font(.system(size: 13))
                .foregroundStyle(AppTheme.textSecondary)
            Spacer()
            StatusBadge(
                text: isEnabled ? "Enabled" : "Disabled",
                color: isEnabled ? AppTheme.success : AppTheme.danger
            )
        }
    }
    
    private func scoreColor(_ score: Int) -> Color {
        if score >= 80 { return AppTheme.success }
        if score >= 50 { return AppTheme.warning }
        return AppTheme.danger
    }
}
