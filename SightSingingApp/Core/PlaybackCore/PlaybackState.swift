import Foundation

/// 统一播放状态机 —— 全 App 只有一个 PlaybackEngine，使用此状态枚举。
enum PlaybackState: Equatable, Sendable {
    /// 空闲，未准备任何音频
    case idle

    /// 正在准备音频 buffer
    case preparing

    /// 倒计时中（remainingBeats 剩余拍数）
    case countIn(remainingBeats: Int)

    /// 播放中
    case playing

    /// 暂停
    case paused

    /// 循环播放指定拍号范围
    case looping(region: ClosedRange<Double>)

    /// 手动拖动进度中
    case scrubbing

    /// 录音中
    case recording

    /// 正在评估/评分
    case evaluating

    /// 播放完成
    case completed

    // MARK: - Convenience

    var isActive: Bool {
        switch self {
        case .playing, .looping, .recording, .countIn, .scrubbing:
            return true
        default:
            return false
        }
    }

    var isIdle: Bool {
        self == .idle
    }

    var isPlaying: Bool {
        switch self {
        case .playing, .looping:
            return true
        default:
            return false
        }
    }

    var label: String {
        switch self {
        case .idle: return "就绪"
        case .preparing: return "准备中"
        case .countIn(let n): return "\(n)拍倒计时"
        case .playing: return "播放中"
        case .paused: return "已暂停"
        case .looping: return "循环中"
        case .scrubbing: return "拖动中"
        case .recording: return "录音中"
        case .evaluating: return "评估中"
        case .completed: return "完成"
        }
    }
}
