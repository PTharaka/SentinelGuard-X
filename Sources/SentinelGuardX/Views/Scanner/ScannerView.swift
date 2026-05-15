import SwiftUI

struct ScannerView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedTab: ScannerTab = .scan

    enum ScannerTab: String, CaseIterable {
        case scan = "Scan"
        case history = "History"
    }

    var scanner: ScannerCore { appState.scannerEngine }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header with tab picker
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Malware Scanner")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.textPrimary)
                        Text("Scan your system for threats and vulnerabilities")
                            .font(.system(size: 14))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    Spacer()

                    // Tab picker
                    HStack(spacing: 0) {
                        ForEach(ScannerTab.allCases, id: \.self) { tab in
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) { selectedTab = tab }
                            } label: {
                                Text(tab.rawValue)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(selectedTab == tab ? .white : AppTheme.textSecondary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        selectedTab == tab ?
                                        AnyShapeStyle(AppTheme.cyan.gradient) :
                                        AnyShapeStyle(.clear)
                                    )
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(3)
                    .background(AppTheme.cardBackground)
                    .clipShape(Capsule())
                }

                // Content
                switch selectedTab {
                case .scan:
                    scanContent
                case .history:
                    ScanHistoryView()
                }
            }
            .padding(28)
        }
    }

    // MARK: - Scan Content
    @ViewBuilder
    private var scanContent: some View {
        if scanner.isScanning {
            scanningView
        } else if scanner.scanProgress >= 1.0 && !scanner.scanResults.isEmpty {
            resultsView
        } else {
            scanTypeSelector
        }
    }

    // MARK: - Scan Type Selector
    private var scanTypeSelector: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            ForEach(ScanType.allCases) { type in
                scanTypeCard(type)
            }
        }
    }

    private func scanTypeCard(_ type: ScanType) -> some View {
        GlassmorphicCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: type.icon)
                        .font(.system(size: 28))
                        .foregroundStyle(AppTheme.cyanGradient)
                    Spacer()
                }
                Text(type.rawValue)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                Text(type.description)
                    .font(.system(size: 13))
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineLimit(2)
                Spacer()
                GlowButton(title: "Start", icon: "play.fill") {
                    scanner.startScan(type: type)
                }
            }
            .frame(minHeight: 160)
        }
        .hoverScale()
    }

    // MARK: - Scanning View
    private var scanningView: some View {
        GlassmorphicCard(padding: 40) {
            VStack(spacing: 24) {
                AnimatedProgressRing(progress: scanner.scanProgress)

                VStack(spacing: 8) {
                    Text("Scanning: \(scanner.currentFile)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(AppTheme.textSecondary)
                        .lineLimit(1)
                        .truncationMode(.middle)

                    HStack(spacing: 24) {
                        Label("\(FormatUtils.formatNumber(scanner.filesScanned)) files", systemImage: "doc.fill")
                        Label("\(scanner.threatsFound.count) threats", systemImage: "exclamationmark.triangle.fill")
                    }
                    .font(.system(size: 13))
                    .foregroundStyle(AppTheme.textTertiary)
                }

                HStack(spacing: 12) {
                    GlowButton(title: scanner.isPaused ? "Resume" : "Pause", icon: scanner.isPaused ? "play.fill" : "pause.fill", color: AppTheme.warning) {
                        scanner.togglePause()
                    }
                    GlowButton(title: "Stop", icon: "stop.fill", color: AppTheme.danger) {
                        scanner.stopScan()
                    }
                }
            }
        }
    }

    // MARK: - Results View
    private var resultsView: some View {
        VStack(spacing: 16) {
            GlassmorphicCard(padding: 16) {
                HStack(spacing: 20) {
                    Image(systemName: scanner.threatsFound.isEmpty ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(scanner.threatsFound.isEmpty ? AppTheme.success : AppTheme.danger)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(scanner.threatsFound.isEmpty ? "No Threats Found" : "\(scanner.threatsFound.count) Threat(s) Detected")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(AppTheme.textPrimary)
                        Text("Scanned \(FormatUtils.formatNumber(scanner.filesScanned)) files in \(String(format: "%.1fs", scanner.elapsedTime))")
                            .font(.system(size: 13))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    Spacer()
                    GlowButton(title: "New Scan", icon: "arrow.clockwise") {
                        appState.updateStatsAfterScan()
                        appState.scannerEngine.scanProgress = 0
                        appState.scannerEngine.scanResults = []
                        appState.scannerEngine.threatsFound = []
                    }
                }
            }

            if !scanner.threatsFound.isEmpty {
                ForEach(scanner.threatsFound) { threat in
                    GlassmorphicCard(padding: 14) {
                        HStack {
                            Circle().fill(AppTheme.danger).frame(width: 8, height: 8)
                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 6) {
                                    Text(threat.name)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(AppTheme.textPrimary)
                                    if threat.category == "Behavioral" {
                                        StatusBadge(text: "Behavioral", color: AppTheme.purple)
                                    }
                                }
                                Text(threat.filePath)
                                    .font(.system(size: 11))
                                    .foregroundStyle(AppTheme.textTertiary)
                                    .lineLimit(1)
                            }
                            Spacer()
                            StatusBadge(text: threat.severity.rawValue, color: AppTheme.danger)
                            Button("Quarantine") {
                                appState.quarantineEngine.quarantine(filePath: threat.filePath, threat: threat)
                            }
                            .buttonStyle(.plain)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(AppTheme.warning)
                        }
                    }
                }
            }
        }
    }
}
