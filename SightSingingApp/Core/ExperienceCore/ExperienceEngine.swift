import Foundation
import SwiftUI

/// 体验引擎 —— 产品的"灵魂层"。
///
/// 监听用户行为 → 计算体验状态 → 驱动 Motion + Haptic 反馈。
///
/// 职责：
/// - 聚合用户操作，计算 groove/accuracy/flow 状态
/// - 触发 MotionCore（动画）和 HapticCore（触觉）
/// - 提供练习体验的"有机感"和"音乐感"
@Observable
final class ExperienceEngine {

    // MARK: - Singleton

    static let shared = ExperienceEngine()

    // MARK: - State

    /// 节奏感 0.0~1.0
    private(set) var grooveLevel: Double = 0.0

    /// 准确度 0.0~1.0
    private(set) var accuracy: Double = 0.0

    /// 心流状态
    private(set) var flowState: FlowState = .idle

    /// 连续正确次数
    private(set) var streakCount: Int = 0

    /// 最佳连续正确次数
    private(set) var bestStreak: Int = 0

    // MARK: - Types

    enum FlowState: Sendable {
        case idle
        case finding        // 在找感觉
        case locked         // 进入状态
        case struggling     // 有困难
        case mastering      // 掌握中

        var label: String {
            switch self {
            case .idle: return "准备"
            case .finding: return "找感觉"
            case .locked: return "进入状态"
            case .struggling: return "有困难"
            case .mastering: return "掌握中"
            }
        }
    }

    // MARK: - History

    private var actionHistory: [ExperienceAction] = []
    private let maxHistorySize = 20

    // MARK: - Smoothing

    private let grooveDecayRate: Double = 0.05    // 无活动时衰减速率
    private let grooveRiseRate: Double = 0.15     // 有活动时上升速率

    // MARK: - Callback

    var onFlowChange: (@Sendable (FlowState) -> Void)?

    // MARK: - Init

    private init() {
        // 定期衰减 groove（无操作时自然回落）
        startDecayTimer()
    }

    // MARK: - Event Processing

    /// 处理用户行为
    func onUserAction(_ action: ExperienceAction) {
        actionHistory.append(action)
        if actionHistory.count > maxHistorySize {
            actionHistory.removeFirst(actionHistory.count - maxHistorySize)
        }

        updateStreak(action: action)
        updateGroove(action: action)
        updateAccuracy(action: action)
        evaluateFlow()

        // 驱动反馈
        triggerFeedback(for: action)
    }

    /// 处理音频反馈（来自 PitchDetector 等）
    func onAudioFeedback(_ result: AudioFeedbackResult) {
        // 从音频结果推导体验
        if result.confidence > 0.6 {
            accuracy = (accuracy * 0.7) + (result.confidence * 0.3)
        }
    }

    /// 手动触发心流重新评估
    func evaluateFlow() {
        let oldState = flowState

        if streakCount >= 5 && accuracy >= 0.85 {
            flowState = .mastering
        } else if streakCount >= 3 && accuracy >= 0.7 {
            flowState = .locked
        } else if streakCount >= 1 && grooveLevel >= 0.4 {
            flowState = .finding
        } else if !actionHistory.isEmpty && accuracy < 0.3 {
            flowState = .struggling
        } else {
            flowState = .idle
        }

        if flowState != oldState {
            onFlowChange?(flowState)
        }
    }

    /// 重置所有状态
    func reset() {
        grooveLevel = 0
        accuracy = 0
        flowState = .idle
        streakCount = 0
        actionHistory = []
    }

    // MARK: - Private

    private func updateStreak(action: ExperienceAction) {
        if action.isCorrect {
            streakCount += 1
            bestStreak = max(bestStreak, streakCount)
        } else {
            streakCount = 0
        }
    }

    private func updateGroove(action: ExperienceAction) {
        switch action {
        case .rhythmOnBeat(let acc):
            grooveLevel = min(1, grooveLevel + grooveRiseRate * acc)
        case .rhythmLocked:
            grooveLevel = min(1, grooveLevel + 0.2)
        case .noteCorrect, .chordStrummed:
            grooveLevel = min(1, grooveLevel + grooveRiseRate * 0.5)
        case .rhythmOffBeat, .noteMissed:
            grooveLevel = max(0, grooveLevel - grooveDecayRate * 2)
        default:
            break
        }
    }

    private func updateAccuracy(action: ExperienceAction) {
        switch action {
        case .noteCorrect(let deviation):
            let acc = max(0, 1 - abs(deviation) / 50.0)  // 偏差 0 cent = 1.0, 50 cents = 0.0
            accuracy = (accuracy * 0.7) + (acc * 0.3)
        case .noteClose(let deviation):
            let acc = max(0, 1 - abs(deviation) / 80.0)
            accuracy = (accuracy * 0.7) + (acc * 0.3)
        case .rhythmOnBeat(let acc):
            accuracy = (accuracy * 0.7) + (acc * 0.3)
        case .noteMissed, .rhythmOffBeat:
            accuracy = max(0, accuracy - 0.1)
        default:
            break
        }
    }

    private func triggerFeedback(for action: ExperienceAction) {
        let haptic = HapticEngine.shared

        switch action {
        case .noteCorrect:
            haptic.successPulse()
        case .noteMissed:
            haptic.mistakeNudge()
        case .rhythmOnBeat:
            haptic.grooveLock()
        case .rhythmLocked:
            haptic.rhythmAccent()
        case .chordStrummed(let velocity):
            haptic.chordHit(intensity: velocity)
        case .progressionResolved:
            haptic.progressionResolve()
        case .rhythmOffBeat:
            haptic.mistakeNudge()
        default:
            break
        }
    }

    private func startDecayTimer() {
        // 每秒衰减 groove，模拟"不弹就冷掉"
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                if self.grooveLevel > 0 {
                    self.grooveLevel = max(0, self.grooveLevel - self.grooveDecayRate)
                }
            }
        }
    }
}
