import SwiftUI

struct QuarantineView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Quarantine")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.textPrimary)
                        Text("Isolated threats are safely contained here")
                            .font(.system(size: 14))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    Spacer()
                    StatusBadge(text: "\(appState.quarantineEngine.items.count) items", color: AppTheme.warning)
                }

                if appState.quarantineEngine.items.isEmpty {
                    emptyState
                } else {
                    ForEach(appState.quarantineEngine.items) { item in
                        quarantineRow(item)
                    }
                }
            }
            .padding(28)
        }
    }

    private var emptyState: some View {
        GlassmorphicCard(padding: 48) {
            VStack(spacing: 16) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(AppTheme.success)
                Text("Quarantine is Empty")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                Text("No threats have been quarantined. Your system is clean!")
                    .font(.system(size: 14))
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func quarantineRow(_ item: QuarantineItem) -> some View {
        GlassmorphicCard(padding: 16) {
            HStack(spacing: 14) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(AppTheme.danger)

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.fileName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppTheme.textPrimary)
                    Text(item.originalPath)
                        .font(.system(size: 11))
                        .foregroundStyle(AppTheme.textTertiary)
                        .lineLimit(1)
                    HStack(spacing: 8) {
                        StatusBadge(text: item.severity.rawValue, color: AppTheme.danger)
                        Text(FormatUtils.shortDate(item.quarantinedAt))
                            .font(.system(size: 11))
                            .foregroundStyle(AppTheme.textTertiary)
                    }
                }

                Spacer()

                VStack(spacing: 6) {
                    Button("Restore") { appState.quarantineEngine.restore(item: item) }
                        .buttonStyle(.plain)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(AppTheme.warning)
                    Button("Delete") { appState.quarantineEngine.deletePermanently(item: item) }
                        .buttonStyle(.plain)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(AppTheme.danger)
                }
            }
        }
    }
}
