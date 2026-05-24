import UIKit

/// 触觉引擎 —— 轻量、克制、有音乐感的触觉反馈。
///
/// 通过 ExperienceEngine 驱动，不直接在 View 中调用。
///
/// 禁止：游戏式高频震动、过度使用。
final class HapticEngine {

    // MARK: - Singleton

    static let shared = HapticEngine()

    // MARK: - Generators

    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let rigidGenerator = UIImpactFeedbackGenerator(style: .rigid)
    private let softGenerator = UIImpactFeedbackGenerator(style: .soft)

    private let selectionGenerator = UISelectionFeedbackGenerator()

    private let notificationGenerator = UINotificationFeedbackGenerator()

    // MARK: - Cooldown

    private var lastTriggerTime: Date = .distantPast
    private let minCooldown: TimeInterval = 0.08  // 最短触发间隔

    // MARK: - Init

    private init() {
        // 预热所有 generator
        lightGenerator.prepare()
        mediumGenerator.prepare()
        heavyGenerator.prepare()
        rigidGenerator.prepare()
        softGenerator.prepare()
        selectionGenerator.prepare()
        notificationGenerator.prepare()
    }

    // MARK: - Music Haptics

    /// 节拍锁定 —— 微弱的节奏确认脉冲
    func grooveLock() {
        guard canTrigger else { return }
        softGenerator.impactOccurred()
    }

    /// 和弦击打 —— 随力度变化
    func chordHit(intensity: Double) {
        guard canTrigger else { return }
        let clamped = max(0, min(1, intensity))
        switch clamped {
        case 0..<0.35:
            lightGenerator.impactOccurred()
        case 0.35..<0.65:
            mediumGenerator.impactOccurred()
        default:
            heavyGenerator.impactOccurred()
        }
    }

    /// 节拍重音
    func rhythmAccent() {
        guard canTrigger else { return }
        rigidGenerator.impactOccurred()
    }

    /// 和弦解决 —— 释放感
    func progressionResolve() {
        guard canTrigger else { return }
        softGenerator.impactOccurred()
        // 双重轻触模拟解决感
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { [weak self] in
            self?.softGenerator.impactOccurred(intensity: 0.5)
        }
    }

    /// 正确反馈 —— 温暖的轻触
    func successPulse() {
        guard canTrigger else { return }
        selectionGenerator.selectionChanged()
    }

    /// 错误提醒 —— 轻柔 nudge
    func mistakeNudge() {
        guard canTrigger else { return }
        notificationGenerator.notificationOccurred(.warning)
    }

    /// 页面切换 / 选择
    func selection() {
        guard canTrigger else { return }
        selectionGenerator.selectionChanged()
    }

    /// 按钮点击
    func tap() {
        guard canTrigger else { return }
        lightGenerator.impactOccurred()
    }

    // MARK: - Private

    private var canTrigger: Bool {
        let now = Date()
        guard now.timeIntervalSince(lastTriggerTime) >= minCooldown else {
            return false
        }
        lastTriggerTime = now
        return true
    }
}
