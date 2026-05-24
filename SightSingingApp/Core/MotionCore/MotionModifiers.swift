import SwiftUI

// MARK: - Motion ViewModifiers

/// 脉冲动画修饰器
struct MotionPulseModifier: ViewModifier {
    let isActive: Bool
    let token: MotionToken
    let scale: CGFloat

    @State private var animating = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isActive && animating ? scale : 1.0)
            .opacity(isActive && animating ? 0.85 : 1.0)
            .onAppear {
                guard isActive else { return }
                withAnimation(token.animation) {
                    animating = true
                }
            }
            .onChange(of: isActive) { _, newValue in
                withAnimation(newValue ? token.animation : .default) {
                    animating = newValue
                }
            }
    }
}

/// 呼吸动画修饰器（缩放 + 透明度）
struct MotionBreatheModifier: ViewModifier {
    let isActive: Bool

    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .scaleEffect(isActive ? 1.0 + 0.03 * sin(phase) : 1.0)
            .opacity(isActive ? 0.7 + 0.3 * sin(phase + CGFloat.pi / 2) : 1.0)
            .onAppear {
                guard isActive else { return }
                withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: false)) {
                    phase = CGFloat.pi * 2
                }
            }
            .onChange(of: isActive) { _, newValue in
                if newValue {
                    withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: false)) {
                        phase = .pi * 2
                    }
                } else {
                    withAnimation(.default) {
                        phase = 0
                    }
                }
            }
    }
}

/// 成功动画修饰器
struct MotionSuccessModifier: ViewModifier {
    let isActive: Bool

    @State private var scale: CGFloat = 1.0
    @State private var glow: Double = 0

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .shadow(color: .green.opacity(glow), radius: glow * 20)
            .onChange(of: isActive) { _, newValue in
                guard newValue else { return }
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    scale = 1.08
                    glow = 0.6
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                        scale = 1.0
                        glow = 0
                    }
                }
            }
    }
}

/// 错误抖动修饰器
struct MotionMistakeModifier: ViewModifier {
    let isActive: Bool

    func body(content: Content) -> some View {
        content
            .modifier(ShakeEffect(shakes: isActive ? 3 : 0))
            .animation(isActive ? .default.speed(3) : .default, value: isActive)
    }
}

struct ShakeEffect: GeometryEffect {
    var shakes: Int
    var amplitude: CGFloat = 6

    var animatableData: CGFloat {
        get { CGFloat(shakes) }
        set { shakes = Int(newValue) }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let offset = shakes > 0 ? sin(CGFloat(shakes) * .pi * 2) * amplitude : 0
        return ProjectionTransform(CGAffineTransform(translationX: offset, y: 0))
    }
}

/// 节奏按击修饰器
struct MotionRhythmSnapModifier: ViewModifier {
    let isActive: Bool

    @State private var scale: CGFloat = 1.0

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onChange(of: isActive) { _, newValue in
                guard newValue else { return }
                withAnimation(.interpolatingSpring(stiffness: 500, damping: 12)) {
                    scale = 1.06
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    withAnimation(.interpolatingSpring(stiffness: 400, damping: 15)) {
                        scale = 1.0
                    }
                }
            }
    }
}

// MARK: - Groove Breathing Modifier

/// Groove 呼吸效果 — 与 BPM 同步的缩放 + 透明度波动
struct MotionGrooveBreathingModifier: ViewModifier {
    let isActive: Bool
    let bpm: Double

    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .scaleEffect(isActive ? 1.0 + 0.025 * sin(phase) : 1.0)
            .opacity(isActive ? 0.75 + 0.25 * sin(phase + CGFloat.pi / 3) : 1.0)
            .onAppear {
                guard isActive else { return }
                let interval = 60.0 / bpm
                withAnimation(.easeInOut(duration: interval).repeatForever(autoreverses: false)) {
                    phase = CGFloat.pi * 2
                }
            }
            .onChange(of: isActive) { _, newValue in
                if newValue {
                    let interval = 60.0 / bpm
                    withAnimation(.easeInOut(duration: interval).repeatForever(autoreverses: false)) {
                        phase = CGFloat.pi * 2
                    }
                } else {
                    withAnimation(.default) { phase = 0 }
                }
            }
            .onChange(of: bpm) { _, newBPM in
                guard isActive else { return }
                let interval = 60.0 / newBPM
                withAnimation(.easeInOut(duration: interval).repeatForever(autoreverses: false)) {
                    phase = CGFloat.pi * 2
                }
            }
    }
}

// MARK: - Count-in Pulse Modifier

/// Count-in 脉冲效果 — 每拍缩放弹跳
struct MotionCountInPulseModifier: ViewModifier {
    let beatNumber: Int
    let bpm: Double

    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 0.6

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .opacity(opacity)
            .onChange(of: beatNumber) { _, _ in
                let interval = 60.0 / bpm
                withAnimation(.spring(response: interval * 0.35, dampingFraction: 0.5)) {
                    scale = 1.25
                    opacity = 1.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + interval * 0.35) {
                    withAnimation(.easeOut(duration: interval * 0.65)) {
                        scale = 1.0
                        opacity = 0.6
                    }
                }
            }
    }
}

// MARK: - Beat Snap Modifier

/// 节拍击打效果 — 轻量弹性缩放
struct MotionBeatSnapModifier: ViewModifier {
    let isActive: Bool

    @State private var scale: CGFloat = 1.0

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onChange(of: isActive) { _, newValue in
                guard newValue else { return }
                withAnimation(.interpolatingSpring(stiffness: 400, damping: 10)) {
                    scale = 1.04
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    withAnimation(.interpolatingSpring(stiffness: 300, damping: 12)) {
                        scale = 1.0
                    }
                }
            }
    }
}

// MARK: - Subdivision Glow Modifier

/// 细分节奏发光 — BPM 同步的光晕脉冲
struct MotionSubdivisionGlowModifier: ViewModifier {
    let isActive: Bool
    let bpm: Double
    let color: Color

    @State private var glowRadius: CGFloat = 0
    @State private var glowOpacity: Double = 0

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(glowOpacity), radius: glowRadius)
            .onAppear {
                guard isActive else { return }
                let interval = 60.0 / bpm / 2
                withAnimation(.easeInOut(duration: interval).repeatForever(autoreverses: true)) {
                    glowRadius = 12
                    glowOpacity = 0.35
                }
            }
            .onChange(of: isActive) { _, newValue in
                if newValue {
                    let interval = 60.0 / bpm / 2
                    withAnimation(.easeInOut(duration: interval).repeatForever(autoreverses: true)) {
                        glowRadius = 12
                        glowOpacity = 0.35
                    }
                } else {
                    withAnimation(.default) {
                        glowRadius = 0
                        glowOpacity = 0
                    }
                }
            }
    }
}

// MARK: - Playhead Flow Modifier

/// Playhead 平滑流动
struct MotionPlayheadFlowModifier: ViewModifier {
    let position: Double  // 0.0 ~ 1.0

    func body(content: Content) -> some View {
        content
            .animation(.easeInOut(duration: 0.08), value: position)
    }
}

// MARK: - Ambient Drift Modifier

/// 背景环境漂移 — 慢速平移
struct MotionAmbientDriftModifier: ViewModifier {
    let isActive: Bool

    @State private var offset: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .offset(x: offset)
            .onAppear {
                guard isActive else { return }
                withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
                    offset = 6
                }
            }
            .onChange(of: isActive) { _, newValue in
                if newValue {
                    withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
                        offset = 6
                    }
                } else {
                    withAnimation(.default) { offset = 0 }
                }
            }
    }
}

// MARK: - View Extension

extension View {

    /// 脉冲动画（呼吸感或节拍强调）
    func motionPulse(isActive: Bool, strength: MotionToken = .pulseSoft, scale: CGFloat = 1.04) -> some View {
        modifier(MotionPulseModifier(isActive: isActive, token: strength, scale: scale))
    }

    /// 呼吸动画（持续波动）
    func motionBreathe(isActive: Bool) -> some View {
        modifier(MotionBreatheModifier(isActive: isActive))
    }

    /// 正确反馈动画
    func motionSuccess(isActive: Bool) -> some View {
        modifier(MotionSuccessModifier(isActive: isActive))
    }

    /// 错误抖动动画
    func motionMistake(isActive: Bool) -> some View {
        modifier(MotionMistakeModifier(isActive: isActive))
    }

    /// 节奏按击反馈
    func motionRhythmSnap(isActive: Bool) -> some View {
        modifier(MotionRhythmSnapModifier(isActive: isActive))
    }

    /// Groove 呼吸（BPM 同步）
    func motionGrooveBreathing(isActive: Bool, bpm: Double) -> some View {
        modifier(MotionGrooveBreathingModifier(isActive: isActive, bpm: bpm))
    }

    /// Count-in 脉冲
    func motionCountInPulse(beatNumber: Int, bpm: Double) -> some View {
        modifier(MotionCountInPulseModifier(beatNumber: beatNumber, bpm: bpm))
    }

    /// 节拍击打
    func motionBeatSnap(isActive: Bool) -> some View {
        modifier(MotionBeatSnapModifier(isActive: isActive))
    }

    /// 细分发光
    func motionSubdivisionGlow(isActive: Bool, bpm: Double, color: Color = AppTheme.Category.rhythm) -> some View {
        modifier(MotionSubdivisionGlowModifier(isActive: isActive, bpm: bpm, color: color))
    }

    /// Playhead 流动
    func motionPlayheadFlow(position: Double) -> some View {
        modifier(MotionPlayheadFlowModifier(position: position))
    }

    /// 环境漂移
    func motionAmbientDrift(isActive: Bool) -> some View {
        modifier(MotionAmbientDriftModifier(isActive: isActive))
    }

    /// 通用动画（使用 MotionToken 直接驱动特定属性）
    func motion(_ token: MotionToken, value: some Equatable) -> some View {
        animation(token.animation, value: value)
    }
}
