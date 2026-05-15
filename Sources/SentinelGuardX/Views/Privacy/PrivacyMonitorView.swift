import SwiftUI

struct PrivacyMonitorView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Privacy Monitor")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.textPrimary)
                        Text("Monitor and manage system privacy permissions")
                            .font(.system(size: 14))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    Spacer()
                    GlowButton(title: "Refresh", icon: "arrow.clockwise", color: AppTheme.cyan) {
                        appState.privacyMonitor.analyze()
                    }
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(appState.privacyMonitor.permissions) { perm in
                        permissionCard(perm)
                    }
                }
            }
            .padding(28)
        }
        .onAppear {
            if appState.privacyMonitor.permissions.isEmpty {
                appState.privacyMonitor.analyze()
            }
        }
    }

    private func permissionCard(_ perm: PrivacyPermission) -> some View {
        let color = statusColor(perm.status)
        return GlassmorphicCard {
            VStack(spacing: 14) {
                Image(systemName: perm.icon)
                    .font(.system(size: 28))
                    .foregroundStyle(color)
                    .frame(width: 52, height: 52)
                    .background(color.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                Text(perm.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)

                StatusBadge(text: perm.status.rawValue, color: color)

                if !perm.appsWithAccess.isEmpty {
                    Text(perm.appsWithAccess.joined(separator: ", "))
                        .font(.system(size: 11))
                        .foregroundStyle(AppTheme.textTertiary)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .hoverScale()
    }

    private func statusColor(_ status: PrivacyPermission.PermissionStatus) -> Color {
        switch status {
        case .granted: return AppTheme.warning
        case .denied: return AppTheme.success
        case .notDetermined: return AppTheme.textTertiary
        case .restricted: return AppTheme.danger
        }
    }
}
