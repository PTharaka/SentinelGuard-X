import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var state = appState

        ScrollView {
            VStack(spacing: 24) {
                HStack {
                    Text("Settings")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)
                    Spacer()
                }

                // Real-Time Protection
                GlassmorphicCard {
                    VStack(alignment: .leading, spacing: 16) {
                        sectionTitle("Real-Time Protection", icon: "shield.checkered")

                        Toggle(isOn: $state.isProtectionActive) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("24/7 Protection")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(AppTheme.textPrimary)
                                Text("Monitors Downloads, Desktop, and Applications for new threats")
                                    .font(.system(size: 12))
                                    .foregroundStyle(AppTheme.textTertiary)
                            }
                        }
                        .tint(AppTheme.cyan)

                        HStack {
                            Image(systemName: appState.fileMonitor.isMonitoring ? "eye.fill" : "eye.slash.fill")
                                .foregroundStyle(appState.fileMonitor.isMonitoring ? AppTheme.success : AppTheme.danger)
                            Text(appState.fileMonitor.isMonitoring ? "File monitor active" : "File monitor inactive")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(AppTheme.textSecondary)
                            Spacer()
                            Text("\(appState.fileMonitor.recentEvents.count) events")
                                .font(.system(size: 11, weight: .medium, design: .monospaced))
                                .foregroundStyle(AppTheme.textTertiary)
                        }
                    }
                }

                // Scheduled Scans
                GlassmorphicCard {
                    VStack(alignment: .leading, spacing: 16) {
                        sectionTitle("Scheduled Scans", icon: "calendar.badge.clock")

                        Toggle(isOn: Binding(
                            get: { appState.scanScheduler.isEnabled },
                            set: { _ in appState.scanScheduler.toggle() }
                        )) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Automatic Scanning")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(AppTheme.textPrimary)
                                Text("Automatically scan your system on a schedule")
                                    .font(.system(size: 12))
                                    .foregroundStyle(AppTheme.textTertiary)
                            }
                        }
                        .tint(AppTheme.cyan)

                        if appState.scanScheduler.isEnabled {
                            // Frequency picker
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Frequency")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(AppTheme.textSecondary)

                                HStack(spacing: 8) {
                                    ForEach(ScanScheduler.ScanFrequency.allCases) { freq in
                                        Button {
                                            appState.scanScheduler.updateFrequency(freq)
                                        } label: {
                                            Text(freq.rawValue)
                                                .font(.system(size: 11, weight: .semibold))
                                                .foregroundStyle(appState.scanScheduler.frequency == freq ? .white : AppTheme.textSecondary)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(
                                                    appState.scanScheduler.frequency == freq ?
                                                    AnyShapeStyle(AppTheme.cyan.gradient) :
                                                    AnyShapeStyle(AppTheme.surfaceOverlay)
                                                )
                                                .clipShape(Capsule())
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }

                            // Scan type picker
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Scan Type")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(AppTheme.textSecondary)

                                HStack(spacing: 8) {
                                    ForEach([ScanType.quick, ScanType.full], id: \.self) { type in
                                        Button {
                                            appState.scanScheduler.updateScanType(type)
                                        } label: {
                                            HStack(spacing: 4) {
                                                Image(systemName: type.icon)
                                                Text(type.rawValue)
                                            }
                                            .font(.system(size: 11, weight: .semibold))
                                            .foregroundStyle(appState.scanScheduler.scanType == type ? .white : AppTheme.textSecondary)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(
                                                appState.scanScheduler.scanType == type ?
                                                AnyShapeStyle(AppTheme.purple.gradient) :
                                                AnyShapeStyle(AppTheme.surfaceOverlay)
                                            )
                                            .clipShape(Capsule())
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }

                            // Next scan
                            if let next = appState.scanScheduler.nextScanDate {
                                HStack {
                                    Image(systemName: "clock.fill")
                                        .foregroundStyle(AppTheme.cyan)
                                    Text("Next scan: \(FormatUtils.timeAgo(from: next))")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundStyle(AppTheme.textSecondary)
                                }
                            }
                        }
                    }
                }

                // Scan Settings
                GlassmorphicCard {
                    VStack(alignment: .leading, spacing: 16) {
                        sectionTitle("Scan Settings", icon: "magnifyingglass.circle.fill")
                        settingRow("Hash Algorithm", value: "SHA-256")
                        settingRow("Behavioral Analysis", value: "Enabled")
                        settingRow("Max File Size", value: "500 MB")
                        settingRow("Scan Archives", value: "Enabled")
                    }
                }

                // Database
                GlassmorphicCard {
                    VStack(alignment: .leading, spacing: 16) {
                        sectionTitle("Threat Database", icon: "cylinder.fill")
                        settingRow("Version", value: appState.databaseVersion)
                        settingRow("Hash Signatures", value: "\(ThreatSignatures.signatureCount)")
                        settingRow("Behavioral Rules", value: "17")
                        settingRow("Allowlist Patterns", value: "\(ThreatSignatures.allowedFileNames.count)")
                        settingRow("Last Updated", value: "Today")
                        settingRow("Auto-Update", value: "Every 30 min")
                    }
                }

                // Notifications
                GlassmorphicCard {
                    VStack(alignment: .leading, spacing: 16) {
                        sectionTitle("Notifications", icon: "bell.fill")
                        settingRow("Threat Alerts", value: "Critical")
                        settingRow("Scan Completion", value: "Enabled")
                        settingRow("Scheduled Scan Start", value: "Enabled")
                        settingRow("Real-Time Alerts", value: "Enabled")
                    }
                }

                // About
                GlassmorphicCard {
                    VStack(alignment: .leading, spacing: 16) {
                        sectionTitle("About", icon: "info.circle.fill")
                        HStack(spacing: 16) {
                            Image(systemName: "shield.checkered")
                                .font(.system(size: 36))
                                .foregroundStyle(AppTheme.cyanGradient)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("SentinelGuard X")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(AppTheme.textPrimary)
                                Text("Version 2.0.0 (Phase 2)")
                                    .font(.system(size: 13))
                                    .foregroundStyle(AppTheme.textSecondary)
                                Text("Advanced Endpoint Security Platform for macOS")
                                    .font(.system(size: 12))
                                    .foregroundStyle(AppTheme.textTertiary)
                            }
                        }
                    }
                }
            }
            .padding(28)
        }
    }

    private func sectionTitle(_ title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(AppTheme.cyan)
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppTheme.textPrimary)
        }
    }

    private func settingRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundStyle(AppTheme.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .foregroundStyle(AppTheme.textPrimary)
        }
    }
}
