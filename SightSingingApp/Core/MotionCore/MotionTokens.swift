import SwiftUI

/// 统一动画语言 —— 整个 App 使用 MotionToken 替代随意的 .animation() 调用。
///
/// 禁止：在 View 中使用裸 .animation() / .spring() 调用。
/// 必须：所有动画通过 MotionToken 或 motion* 修饰器声明。
enum MotionToken: Sendable {
    // MARK: - Pulse (脉冲类)

    /// 轻柔脉冲（呼吸感）
    case pulseSoft
    /// 强劲脉冲（节拍强调）
    case pulseStrong

    // MARK: - Waveform (波形类)

    /// 波形呼吸（音量可视化）
    case waveformBreath
    /// 弦线振动
    case stringBounce
    /// 和声绽放（正确反馈）
    case harmonicBloom

    // MARK: - Transition (过渡类)

    /// 和弦解决（从紧张到松弛）
    case progressionResolve
    /// 节奏击打
    case rhythmSnap

    // MARK: - Feedback (反馈类)

    /// 正确发光
    case successGlow
    /// 错误抖动
    case mistakeShake

    // MARK: - Groove (节奏类)

    /// Groove 呼吸（BPM 同步）
    case grooveBreathing(bpm: Double)
    /// Playhead 流动
    case playheadFlow
    /// 背景环境漂移
    case ambientDrift
    /// 细分发光
    case subdivisionGlow(bpm: Double)
    /// Count-in 脉冲
    case countInPulse(bpm: Double)
    /// 节拍击打（轻）
    case beatSnap

    // MARK: - Properties

    var animation: Animation {
        switch self {
        case .pulseSoft:
            return .easeInOut(duration: 0.6).repeatForever(autoreverses: true)
        case .pulseStrong:
            return .easeInOut(duration: 0.3).repeatForever(autoreverses: true)
        case .waveformBreath:
            return .easeInOut(duration: 1.2).repeatForever(autoreverses: true)
        case .stringBounce:
            return .interpolatingSpring(stiffness: 300, damping: 15)
        case .harmonicBloom:
            return .spring(response: 0.4, dampingFraction: 0.6)
        case .progressionResolve:
            return .easeOut(duration: 0.8)
        case .rhythmSnap:
            return .interpolatingSpring(stiffness: 500, damping: 12)
        case .successGlow:
            return .spring(response: 0.3, dampingFraction: 0.5)
        case .mistakeShake:
            return .default.speed(3)
        case .grooveBreathing(let bpm):
            let interval = 60.0 / bpm
            return .easeInOut(duration: interval).repeatForever(autoreverses: true)
        case .playheadFlow:
            return .easeInOut(duration: 0.08)
        case .ambientDrift:
            return .easeInOut(duration: 4.0).repeatForever(autoreverses: true)
        case .subdivisionGlow(let bpm):
            let interval = 60.0 / bpm / 2  // 半拍周期
            return .easeInOut(duration: interval).repeatForever(autoreverses: true)
        case .countInPulse(let bpm):
            let interval = 60.0 / bpm
            return .spring(response: interval * 0.4, dampingFraction: 0.5)
        case .beatSnap:
            return .interpolatingSpring(stiffness: 400, damping: 10)
        }
    }

    var duration: TimeInterval {
        switch self {
        case .pulseSoft: return 0.6
        case .pulseStrong: return 0.3
        case .waveformBreath: return 1.2
        case .stringBounce: return 0.35
        case .harmonicBloom: return 0.4
        case .progressionResolve: return 0.8
        case .rhythmSnap: return 0.2
        case .successGlow: return 0.3
        case .mistakeShake: return 0.15
        case .grooveBreathing(let bpm): return 60.0 / bpm
        case .playheadFlow: return 0.08
        case .ambientDrift: return 4.0
        case .subdivisionGlow(let bpm): return 60.0 / bpm / 2
        case .countInPulse(let bpm): return 60.0 / bpm * 0.4
        case .beatSnap: return 0.15
        }
    }
}
