import SwiftUI

struct GlassmorphicCard<Content: View>: View {
    let content: Content
    var padding: CGFloat = 20
    var cornerRadius: CGFloat = AppTheme.cardCornerRadius

    init(padding: CGFloat = 20, cornerRadius: CGFloat = AppTheme.cardCornerRadius, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.padding = padding
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        content
            .padding(padding)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.ultraThinMaterial)
                        .opacity(0.5)
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(AppTheme.cardBackground.opacity(0.7))
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(AppTheme.cardBorderColor, lineWidth: AppTheme.cardBorderWidth)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}

struct PulsingShield: View {
    let isActive: Bool
    @State private var pulse = false
    @State private var glowOpacity = 0.3

    var shieldColor: Color {
        isActive ? AppTheme.success : AppTheme.danger
    }

    var body: some View {
        ZStack {
            // Outer glow rings
            ForEach(0..<3) { i in
                Circle()
                    .stroke(shieldColor.opacity(0.1 - Double(i) * 0.03), lineWidth: 2)
                    .frame(width: 140 + CGFloat(i) * 30, height: 140 + CGFloat(i) * 30)
                    .scaleEffect(pulse ? 1.1 : 0.95)
                    .opacity(pulse ? 0.0 : 0.6)
                    .animation(
                        AppAnimations.pulseLoop.delay(Double(i) * 0.3),
                        value: pulse
                    )
            }

            // Glow background
            Circle()
                .fill(
                    RadialGradient(
                        colors: [shieldColor.opacity(0.3), shieldColor.opacity(0.0)],
                        center: .center, startRadius: 20, endRadius: 80
                    )
                )
                .frame(width: 160, height: 160)
                .opacity(glowOpacity)

            // Shield icon
            Image(systemName: isActive ? "checkmark.shield.fill" : "xmark.shield.fill")
                .font(.system(size: 64, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: isActive ? [AppTheme.success, AppTheme.cyan] : [AppTheme.danger, AppTheme.warning],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .shadow(color: shieldColor.opacity(0.5), radius: 12)
        }
        .onAppear {
            pulse = true
            withAnimation(AppAnimations.pulseLoop) {
                glowOpacity = 0.6
            }
        }
    }
}

struct AnimatedGauge: View {
    let value: Double // 0-100
    let label: String
    let icon: String
    var size: CGFloat = 80
    var lineWidth: CGFloat = 6

    @State private var animatedValue: Double = 0

    var gaugeColor: Color {
        if animatedValue < 50 { return AppTheme.success }
        if animatedValue < 80 { return AppTheme.warning }
        return AppTheme.danger
    }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Background track
                Circle()
                    .stroke(AppTheme.surfaceOverlay, lineWidth: lineWidth)

                // Value arc
                Circle()
                    .trim(from: 0, to: animatedValue / 100)
                    .stroke(
                        AngularGradient(
                            colors: [gaugeColor.opacity(0.5), gaugeColor],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                // Center content
                VStack(spacing: 2) {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundStyle(gaugeColor)
                    Text("\(Int(animatedValue))%")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)
                }
            }
            .frame(width: size, height: size)

            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(AppTheme.textSecondary)
        }
        .onChange(of: value, initial: true) { _, newVal in
            withAnimation(AppAnimations.progressFill) {
                animatedValue = newVal
            }
        }
    }
}

struct AnimatedProgressRing: View {
    let progress: Double // 0-1
    var size: CGFloat = 200
    var lineWidth: CGFloat = 12

    @State private var animatedProgress: Double = 0
    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            // Background
            Circle()
                .stroke(AppTheme.surfaceOverlay, lineWidth: lineWidth)

            // Progress arc
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    AngularGradient(
                        colors: [AppTheme.cyan, AppTheme.purple, AppTheme.cyan],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90 + rotation))
                .shadow(color: AppTheme.cyanGlow, radius: 8)

            // Center content
            VStack(spacing: 4) {
                Text("\(Int(animatedProgress * 100))%")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)
                Text("Complete")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(AppTheme.textTertiary)
            }
        }
        .frame(width: size, height: size)
        .onChange(of: progress, initial: true) { _, newVal in
            withAnimation(.easeInOut(duration: 0.5)) {
                animatedProgress = newVal
            }
        }
        .onAppear {
            if progress < 1 {
                withAnimation(AppAnimations.rotateLoop) {
                    rotation = 360
                }
            }
        }
    }
}

struct GlowButton: View {
    let title: String
    let icon: String
    var color: Color = AppTheme.cyan
    let action: () -> Void

    @State private var isHovered = false
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.gradient)
                    .shadow(color: color.opacity(isHovered ? 0.6 : 0.2), radius: isHovered ? 16 : 4)
            )
            .scaleEffect(isPressed ? 0.96 : 1.0)
        }
        .buttonStyle(.plain)
        .onHover { h in
            withAnimation(.easeOut(duration: 0.2)) { isHovered = h }
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

struct StatusBadge: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Capsule().fill(color.gradient))
            .shadow(color: color.opacity(0.3), radius: 4)
    }
}

struct StatCard: View {
    let value: String
    let label: String
    let icon: String
    var color: Color = AppTheme.cyan

    var body: some View {
        GlassmorphicCard(padding: 16) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundStyle(color)
                    .frame(width: 40, height: 40)
                    .background(color.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 2) {
                    Text(value)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)
                    Text(label)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(AppTheme.textSecondary)
                }
                Spacer()
            }
        }
        .hoverScale(1.02)
    }
}
