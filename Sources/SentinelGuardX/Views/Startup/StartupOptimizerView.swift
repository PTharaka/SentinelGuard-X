import SwiftUI

struct StartupOptimizerView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Startup Optimizer")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.textPrimary)
                        Text("Manage startup items and background services")
                            .font(.system(size: 14))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    Spacer()
                    GlowButton(title: "Analyze", icon: "bolt.fill", color: AppTheme.cyan) {
                        appState.startupAnalyzer.analyze()
                    }
                }

                if appState.startupAnalyzer.isAnalyzing {
                    GlassmorphicCard(padding: 32) {
                        VStack(spacing: 12) {
                            ProgressView()
                                .scaleEffect(1.2)
                                .tint(AppTheme.cyan)
                            Text("Analyzing startup items...")
                                .font(.system(size: 14))
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }

                if !appState.startupAnalyzer.items.isEmpty {
                    let agents = appState.startupAnalyzer.items.filter { $0.type == .launchAgent }
                    let daemons = appState.startupAnalyzer.items.filter { $0.type == .launchDaemon }

                    if !agents.isEmpty {
                        sectionHeader("Launch Agents", count: agents.count)
                        ForEach(agents) { item in startupRow(item) }
                    }
                    if !daemons.isEmpty {
                        sectionHeader("Launch Daemons", count: daemons.count)
                        ForEach(daemons) { item in startupRow(item) }
                    }
                } else if !appState.startupAnalyzer.isAnalyzing {
                    GlassmorphicCard(padding: 40) {
                        VStack(spacing: 12) {
                            Image(systemName: "bolt.circle.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(AppTheme.cyan)
                            Text("Click Analyze to scan startup items")
                                .font(.system(size: 14))
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(28)
        }
    }

    private func sectionHeader(_ title: String, count: Int) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppTheme.textPrimary)
            StatusBadge(text: "\(count)", color: AppTheme.cyanDim)
            Spacer()
        }
    }

    private func startupRow(_ item: StartupItem) -> some View {
        GlassmorphicCard(padding: 14) {
            HStack(spacing: 12) {
                Image(systemName: item.isSuspicious ? "exclamationmark.triangle.fill" : "gearshape.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(item.isSuspicious ? AppTheme.warning : AppTheme.textSecondary)

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AppTheme.textPrimary)
                        .lineLimit(1)
                    Text(item.path)
                        .font(.system(size: 11))
                        .foregroundStyle(AppTheme.textTertiary)
                        .lineLimit(1)
                }

                Spacer()

                if item.isSuspicious {
                    StatusBadge(text: "Suspicious", color: AppTheme.warning)
                }

                HStack(spacing: 4) {
                    Circle()
                        .fill(item.isEnabled ? AppTheme.success : AppTheme.textTertiary)
                        .frame(width: 6, height: 6)
                    Text(item.isEnabled ? "Active" : "Disabled")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(item.isEnabled ? AppTheme.success : AppTheme.textTertiary)
                }
            }
        }
    }
}
