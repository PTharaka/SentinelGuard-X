import SwiftUI

@main
struct SentinelGuardXApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .frame(minWidth: 1100, minHeight: 700)
                .preferredColorScheme(.dark)
                .onAppear {
                    setupServices()
                }
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 1280, height: 800)

        // Menu Bar Extra
        MenuBarExtra {
            MenuBarView()
                .environment(appState)
        } label: {
            Image(systemName: appState.isProtectionActive ? "shield.checkered" : "xmark.shield")
        }
    }

    private func setupServices() {
        // Start system monitor
        appState.systemMonitor.startMonitoring()

        // Start network monitor
        appState.networkMonitorEngine.startMonitoring()

        // Request notification permissions (deferred until bundle is ready)
        NotificationManager.shared.setup()

        // Start real-time file monitoring if protection is active
        if appState.isProtectionActive {
            appState.fileMonitor.startMonitoring()
        }

        // Start scan scheduler
        appState.scanScheduler.start()

        // Start USB Monitor
        appState.usbMonitor.startMonitoring()
    }
}

struct ContentView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationSplitView {
            SidebarView()
        } detail: {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()

                switch appState.selectedSection {
                case .dashboard:
                    DashboardView()
                case .scanner:
                    ScannerView()
                case .cleaner:
                    CleanerView()
                case .quarantine:
                    QuarantineView()
                case .startup:
                    StartupOptimizerView()
                case .network:
                    NetworkMonitorView()
                case .privacy:
                    PrivacyMonitorView()
                case .settings:
                    SettingsView()
                }
            }
        }
        .navigationSplitViewStyle(.prominentDetail)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("TriggerExternalScan"))) { _ in
            appState.selectedSection = .scanner
            appState.scannerEngine.startScan(type: .external)
        }
    }
}

// MARK: - Menu Bar View
struct MenuBarView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(spacing: 0) {
            Button {
                appState.isProtectionActive.toggle()
            } label: {
                HStack {
                    Image(systemName: appState.isProtectionActive ? "shield.checkered" : "xmark.shield")
                        .foregroundStyle(appState.isProtectionActive ? .green : .red)
                    Text(appState.isProtectionActive ? "Protection Active" : "Protection Off")
                }
            }

            Divider()

            if let lastScan = appState.lastScanDate {
                Text("Last scan: \(FormatUtils.timeAgo(from: lastScan))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 4)
            }

            Button {
                appState.scannerEngine.startScan(type: .quick)
                NSApp.activate(ignoringOtherApps: true)
                appState.selectedSection = .scanner
            } label: {
                HStack {
                    Image(systemName: "hare.fill")
                    Text("Quick Scan")
                }
            }

            Button {
                NSApp.activate(ignoringOtherApps: true)
            } label: {
                HStack {
                    Image(systemName: "macwindow")
                    Text("Open SentinelGuard X")
                }
            }

            Divider()

            HStack {
                Image(systemName: "eye.fill")
                    .foregroundStyle(.green)
                Text("Real-Time: \(appState.fileMonitor.recentEvents.count) events")
                    .font(.caption)
            }
            .padding(.vertical, 4)

            Divider()

            Button {
                if let url = ReportGenerator.generateHTMLReport(appState: appState) {
                    NSWorkspace.shared.open(url)
                }
            } label: {
                HStack {
                    Image(systemName: "doc.text.fill")
                    Text("Export Security Report")
                }
            }

            Divider()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
        .padding(4)
    }
}
