import SwiftUI

enum AppTheme {
    // MARK: - Backgrounds
    static let background = Color(red: 0.04, green: 0.055, blue: 0.102)
    static let backgroundSecondary = Color(red: 0.078, green: 0.106, blue: 0.176)
    static let cardBackground = Color(red: 0.102, green: 0.133, blue: 0.212)
    static let cardBackgroundHover = Color(red: 0.12, green: 0.16, blue: 0.25)
    static let surfaceOverlay = Color.white.opacity(0.04)

    // MARK: - Accent Colors
    static let cyan = Color(red: 0.0, green: 0.831, blue: 1.0)
    static let cyanDim = Color(red: 0.0, green: 0.706, blue: 0.847)
    static let cyanGlow = Color(red: 0.0, green: 0.831, blue: 1.0).opacity(0.3)
    static let purple = Color(red: 0.545, green: 0.361, blue: 1.0)
    static let purpleGlow = Color(red: 0.545, green: 0.361, blue: 1.0).opacity(0.3)

    // MARK: - Status Colors
    static let success = Color(red: 0.18, green: 0.835, blue: 0.451)
    static let successDim = Color(red: 0.18, green: 0.835, blue: 0.451).opacity(0.15)
    static let warning = Color(red: 1.0, green: 0.647, blue: 0.008)
    static let warningDim = Color(red: 1.0, green: 0.647, blue: 0.008).opacity(0.15)
    static let danger = Color(red: 1.0, green: 0.278, blue: 0.341)
    static let dangerDim = Color(red: 1.0, green: 0.278, blue: 0.341).opacity(0.15)

    // MARK: - Text Colors
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.7)
    static let textTertiary = Color.white.opacity(0.4)

    // MARK: - Gradients
    static let cyanGradient = LinearGradient(
        colors: [cyan, cyanDim],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let shieldGradient = LinearGradient(
        colors: [success, Color(red: 0.0, green: 0.831, blue: 1.0)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let dangerGradient = LinearGradient(
        colors: [danger, Color(red: 1.0, green: 0.4, blue: 0.2)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let cardGradient = LinearGradient(
        colors: [cardBackground, cardBackground.opacity(0.6)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let backgroundGradient = LinearGradient(
        colors: [background, backgroundSecondary],
        startPoint: .top, endPoint: .bottom
    )

    // MARK: - Card Style
    static let cardCornerRadius: CGFloat = 16
    static let cardShadowRadius: CGFloat = 10
    static let cardBorderWidth: CGFloat = 0.5
    static let cardBorderColor = Color.white.opacity(0.08)
}
