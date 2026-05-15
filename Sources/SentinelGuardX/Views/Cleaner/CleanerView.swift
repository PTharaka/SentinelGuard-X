import SwiftUI

struct CleanerView: View {
    @Environment(AppState.self) private var appState

    var cleaner: CleanerCore { appState.cleanerEngine }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("System Cleaner")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.textPrimary)
                        Text("Remove junk files and optimize your system")
                            .font(.system(size: 14))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    Spacer()
                    GlowButton(title: "Analyze", icon: "magnifyingglass", color: AppTheme.cyan) {
                        cleaner.analyze()
                    }
                }

                // Total cleanable
                if cleaner.totalCleanableSize > 0 {
                    GlassmorphicCard(padding: 24) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Total Cleanable Space")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(AppTheme.textSecondary)
                                Text(FormatUtils.formatBytes(cleaner.totalCleanableSize))
                                    .font(.system(size: 36, weight: .bold, design: .rounded))
                                    .foregroundStyle(AppTheme.cyanGradient)
                            }
                            Spacer()
                            GlowButton(title: "Clean All", icon: "sparkles", color: AppTheme.success) {
                                cleaner.clean()
                            }
                        }
                    }
                }

                // Cleaning progress
                if cleaner.isCleaning {
                    GlassmorphicCard(padding: 32) {
                        VStack(spacing: 16) {
                            AnimatedProgressRing(progress: cleaner.cleaningProgress, size: 120, lineWidth: 8)
                            Text("Cleaning: \(cleaner.currentCategory)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                    }
                }

                // Category cards
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(Array(cleaner.categories.enumerated()), id: \.element.id) { index, category in
                        categoryCard(category, index: index)
                    }
                }
            }
            .padding(28)
        }
    }

    private func categoryCard(_ cat: CleanerCategory, index: Int) -> some View {
        let colors: [Color] = [AppTheme.cyan, AppTheme.purple, AppTheme.warning, AppTheme.danger]
        let color = colors[index % colors.count]

        return GlassmorphicCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: cat.icon)
                        .font(.system(size: 24))
                        .foregroundStyle(color)
                        .frame(width: 40, height: 40)
                        .background(color.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                    Spacer()

                    if cat.isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(AppTheme.success)
                    }
                }

                Text(cat.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)

                Text(cat.description)
                    .font(.system(size: 12))
                    .foregroundStyle(AppTheme.textTertiary)
                    .lineLimit(2)

                if cat.size > 0 {
                    Text(FormatUtils.formatBytes(cat.size))
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(color)
                } else {
                    Text("Not analyzed")
                        .font(.system(size: 13))
                        .foregroundStyle(AppTheme.textTertiary)
                }
            }
        }
        .hoverScale()
        .onTapGesture {
            cleaner.toggleCategory(cat.name)
        }
    }
}
