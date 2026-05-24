import Foundation

/// 体验动作 —— 用户与音乐交互的事件模型。
///
/// 由 ViewModel / PracticeSession 产生，由 ExperienceEngine 消费。
enum ExperienceAction: Sendable {
    // MARK: - Pitch

    /// 音高正确（cents 偏差）
    case noteCorrect(deviation: Double)
    /// 音高错误
    case noteMissed
    /// 接近正确（偏差稍大）
    case noteClose(deviation: Double)

    // MARK: - Rhythm

    /// 节奏准确
    case rhythmOnBeat(accuracy: Double)
    /// 节奏脱拍
    case rhythmOffBeat
    /// 节拍锁定（连续多次准确）
    case rhythmLocked

    // MARK: - Chord

    /// 和弦扫弦
    case chordStrummed(velocity: Double)
    /// 和弦解决
    case progressionResolved

    // MARK: - Practice

    /// 练习开始
    case practiceStarted
    /// 练习暂停
    case practicePaused
    /// 练习恢复
    case practiceResumed
    /// 练习完成
    case practiceCompleted(accuracy: Double)

    // MARK: - Helpers

    var isPositive: Bool {
        switch self {
        case .noteCorrect, .rhythmOnBeat, .rhythmLocked, .chordStrummed, .progressionResolved, .practiceCompleted:
            return true
        default:
            return false
        }
    }

    var isCorrect: Bool {
        switch self {
        case .noteCorrect: return true
        case .noteClose: return true
        case .rhythmOnBeat: return true
        default: return false
        }
    }
}

/// 音频反馈结果
struct AudioFeedbackResult: Sendable {
    let timestamp: Date
    let frequency: Double?
    let amplitude: Double
    let confidence: Double
    let nearestNote: Int?
    let deviation: Double?
}
