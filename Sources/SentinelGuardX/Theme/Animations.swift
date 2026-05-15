import SwiftUI

enum AppAnimations {
    static let springBounce = Animation.spring(response: 0.5, dampingFraction: 0.7)
    static let springSmooth = Animation.spring(response: 0.4, dampingFraction: 0.85)
    static let easeOutQuick = Animation.easeOut(duration: 0.25)
    static let easeInOutMedium = Animation.easeInOut(duration: 0.5)
    static let pulseLoop = Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)
    static let rotateLoop = Animation.linear(duration: 3.0).repeatForever(autoreverses: false)
    static let shimmer = Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true)
    static let progressFill = Animation.easeInOut(duration: 0.8)
}

// MARK: - Glow Modifier
struct GlowModifier: ViewModifier {
    let color: Color
    let radius: CGFloat
    var isActive: Bool = true

    func body(content: Content) -> some View {
        content
            .shadow(color: isActive ? color.opacity(0.6) : .clear, radius: radius)
            .shadow(color: isActive ? color.opacity(0.3) : .clear, radius: radius * 2)
    }
}

// MARK: - Hover Scale Modifier
struct HoverScaleModifier: ViewModifier {
    @State private var isHovered = false
    let scale: CGFloat

    func body(content: Content) -> some View {
        content
            .scaleEffect(isHovered ? scale : 1.0)
            .animation(AppAnimations.springSmooth, value: isHovered)
            .onHover { hovering in
                isHovered = hovering
            }
    }
}

// MARK: - Shimmer Modifier
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [.clear, .white.opacity(0.08), .clear],
                    startPoint: .init(x: phase - 0.5, y: 0.5),
                    endPoint: .init(x: phase + 0.5, y: 0.5)
                )
                .mask(content)
            )
            .onAppear {
                withAnimation(Animation.linear(duration: 2.5).repeatForever(autoreverses: false)) {
                    phase = 1.5
                }
            }
    }
}

extension View {
    func glowEffect(color: Color, radius: CGFloat = 8, isActive: Bool = true) -> some View {
        modifier(GlowModifier(color: color, radius: radius, isActive: isActive))
    }

    func hoverScale(_ scale: CGFloat = 1.03) -> some View {
        modifier(HoverScaleModifier(scale: scale))
    }

    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}
