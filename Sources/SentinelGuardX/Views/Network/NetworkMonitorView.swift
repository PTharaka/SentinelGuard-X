import SwiftUI

struct NetworkMonitorView: View {
    @Environment(AppState.self) private var appState

    var net: NetworkMonitorEngine { appState.networkMonitorEngine }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Network Monitor")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.textPrimary)
                        Text("Monitor network connections and activity")
                            .font(.system(size: 14))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    Spacer()
                    GlowButton(title: "Refresh", icon: "arrow.clockwise", color: AppTheme.cyan) {
                        net.refreshConnections()
                    }
                }

                // Status cards
                HStack(spacing: 16) {
                    StatCard(
                        value: net.isConnected ? "Connected" : "Offline",
                        label: "Status",
                        icon: net.isConnected ? "wifi" : "wifi.slash",
                        color: net.isConnected ? AppTheme.success : AppTheme.danger
                    )
                    StatCard(
                        value: net.interfaceType,
                        label: "Interface",
                        icon: "network",
                        color: AppTheme.cyan
                    )
                    StatCard(
                        value: "\(net.totalConnections)",
                        label: "Connections",
                        icon: "arrow.left.arrow.right",
                        color: AppTheme.purple
                    )
                    StatCard(
                        value: "\(net.suspiciousConnections)",
                        label: "Suspicious",
                        icon: "exclamationmark.triangle.fill",
                        color: net.suspiciousConnections > 0 ? AppTheme.danger : AppTheme.success
                    )
                }

                // Connections list
                GlassmorphicCard {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text("Active Connections")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(AppTheme.textPrimary)
                            StatusBadge(text: "\(net.uniqueProcesses) processes", color: AppTheme.cyanDim)
                            Spacer()
                            Circle()
                                .fill(AppTheme.success)
                                .frame(width: 6, height: 6)
                            Text("Live")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(AppTheme.success)
                        }

                        // Header
                        HStack {
                            Text("Process").frame(width: 120, alignment: .leading)
                            Text("Remote Address").frame(maxWidth: .infinity, alignment: .leading)
                            Text("Port").frame(width: 60)
                            Text("Protocol").frame(width: 60)
                            Text("State").frame(width: 110)
                        }
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(AppTheme.textTertiary)

                        Divider().opacity(0.2)

                        if net.connections.isEmpty {
                            HStack {
                                Spacer()
                                VStack(spacing: 8) {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .tint(AppTheme.cyan)
                                    Text("Loading connections...")
                                        .font(.system(size: 12))
                                        .foregroundStyle(AppTheme.textTertiary)
                                }
                                Spacer()
                            }
                            .padding(.vertical, 20)
                        } else {
                            ForEach(net.connections) { conn in
                                HStack {
                                    Text(conn.processName)
                                        .frame(width: 120, alignment: .leading)
                                        .foregroundStyle(conn.isSuspicious ? AppTheme.danger : AppTheme.textPrimary)
                                    Text(conn.remoteAddress.isEmpty ? "—" : conn.remoteAddress)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundStyle(AppTheme.textSecondary)
                                    Text(conn.port > 0 ? "\(conn.port)" : "—")
                                        .frame(width: 60)
                                        .foregroundStyle(AppTheme.textSecondary)
                                    Text(conn.protocol_)
                                        .frame(width: 60)
                                        .foregroundStyle(AppTheme.textTertiary)
                                    StatusBadge(
                                        text: conn.state,
                                        color: conn.isSuspicious ? AppTheme.danger :
                                            (conn.state == "ESTABLISHED" ? AppTheme.success :
                                                (conn.state == "LISTEN" ? AppTheme.cyan : AppTheme.warning))
                                    )
                                    .frame(width: 110)
                                }
                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                .padding(.vertical, 2)
                                .padding(.horizontal, 4)
                                .background(
                                    conn.isSuspicious ?
                                    RoundedRectangle(cornerRadius: 4).fill(AppTheme.danger.opacity(0.08)) :
                                    RoundedRectangle(cornerRadius: 4).fill(.clear)
                                )
                            }
                        }
                    }
                }
            }
            .padding(28)
        }
        .onAppear { net.startMonitoring() }
    }
}
