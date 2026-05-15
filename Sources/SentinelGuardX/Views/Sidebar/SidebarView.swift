import SwiftUI

struct SidebarView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var state = appState

        VStack(spacing: 0) {
            // Logo Area
            VStack(spacing: 8) {
                Image(systemName: "shield.checkered")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(AppTheme.cyanGradient)
                    .shadow(color: AppTheme.cyanGlow, radius: 8)

                Text("SentinelGuard X")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)

                Text("Advanced Protection")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(AppTheme.textTertiary)
                    .textCase(.uppercase)
                    .tracking(1.5)
            }
            .padding(.top, 24)
            .padding(.bottom, 20)

            Divider().opacity(0.2)

            // Navigation Items
            ScrollView {
                VStack(spacing: 4) {
                    ForEach(NavigationSection.allCases) { section in
                        if section == .settings {
                            Divider().opacity(0.1).padding(.vertical, 8)
                        }

                        SidebarItem(
                            section: section,
                            isSelected: appState.selectedSection == section
                        ) {
                            withAnimation(AppAnimations.springSmooth) {
                                state.selectedSection = section
                            }
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 12)
            }

            Spacer()

            // Bottom Status
            VStack(spacing: 12) {
                Divider().opacity(0.2)

                HStack(spacing: 8) {
                    Circle()
                        .fill(appState.isProtectionActive ? AppTheme.success : AppTheme.danger)
                        .frame(width: 8, height: 8)
                        .shadow(color: appState.isProtectionActive ? AppTheme.success.opacity(0.6) : AppTheme.danger.opacity(0.6), radius: 4)

                    Text(appState.isProtectionActive ? "Protected" : "Inactive")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(appState.isProtectionActive ? AppTheme.success : AppTheme.danger)

                    Spacer()

                    Text("v2.0.0")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(AppTheme.textTertiary)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .frame(width: 220)
        .background(AppTheme.backgroundSecondary)
    }
}

struct SidebarItem: View {
    let section: NavigationSection
    let isSelected: Bool
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: section.icon)
                    .font(.system(size: 16, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? AppTheme.cyan : AppTheme.textSecondary)
                    .frame(width: 24)

                Text(section.rawValue)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? AppTheme.textPrimary : AppTheme.textSecondary)

                Spacer()

                if section == .quarantine {
                    Text("0")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(AppTheme.textTertiary))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        isSelected ? AppTheme.cyan.opacity(0.12) :
                            (isHovered ? AppTheme.surfaceOverlay : .clear)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? AppTheme.cyan.opacity(0.2) : .clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .onHover { h in
            withAnimation(.easeOut(duration: 0.15)) { isHovered = h }
        }
    }
}
