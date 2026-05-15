import SwiftUI

struct ScanHistoryView: View {
    @Environment(AppState.self) private var appState

    var history: ScanHistory { appState.scanHistory }

    var body: some View {
        VStack(spacing: 16) {
            // Stats header
            HStack(spacing: 16) {
                historyStatCard(value: "\(history.totalScans)", label: "Total Scans", icon: "chart.bar.fill", color: AppTheme.cyan)
                historyStatCard(value: "\(history.totalThreatsEverFound)", label: "Threats Found", icon: "exclamationmark.triangle.fill", color: AppTheme.danger)
                historyStatCard(value: String(format: "%.0fs", history.averageDuration), label: "Avg Duration", icon: "timer", color: AppTheme.purple)
            }

            // History list
            if history.records.isEmpty {
                GlassmorphicCard(padding: 32) {
                    VStack(spacing: 12) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 32))
                            .foregroundStyle(AppTheme.textTertiary)
                        Text("No scan history yet")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(AppTheme.textSecondary)
                        Text("Run a scan to see results here")
                            .font(.system(size: 12))
                            .foregroundStyle(AppTheme.textTertiary)
                    }
                    .frame(maxWidth: .infinity)
                }
            } else {
                ForEach(history.records) { record in
                    GlassmorphicCard(padding: 14) {
                        HStack(spacing: 14) {
                            Image(systemName: record.threatsFound > 0 ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(record.threatsFound > 0 ? AppTheme.danger : AppTheme.success)

                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 8) {
                                    Text(record.scanType)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(AppTheme.textPrimary)
                                    StatusBadge(
                                        text: record.threatsFound > 0 ? "\(record.threatsFound) threat(s)" : "Clean",
                                        color: record.threatsFound > 0 ? AppTheme.danger : AppTheme.success
                                    )
                                }
                                HStack(spacing: 12) {
                                    Label(FormatUtils.shortDate(record.date), systemImage: "calendar")
                                    Label("\(FormatUtils.formatNumber(record.filesScanned)) files", systemImage: "doc.fill")
                                    Label(String(format: "%.1fs", record.duration), systemImage: "timer")
                                }
                                .font(.system(size: 11))
                                .foregroundStyle(AppTheme.textTertiary)
                            }

                            Spacer()

                            if !record.threatNames.isEmpty {
                                VStack(alignment: .trailing, spacing: 2) {
                                    ForEach(record.threatNames.prefix(2), id: \.self) { name in
                                        Text(name)
                                            .font(.system(size: 10, weight: .medium))
                                            .foregroundStyle(AppTheme.danger)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private func historyStatCard(value: String, label: String, icon: String, color: Color) -> some View {
        GlassmorphicCard(padding: 14) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(color)
                    .frame(width: 32, height: 32)
                    .background(color.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                VStack(alignment: .leading, spacing: 1) {
                    Text(value)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)
                    Text(label)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
        }
    }
}
