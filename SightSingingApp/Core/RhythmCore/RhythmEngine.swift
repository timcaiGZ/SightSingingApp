import Foundation

/// 节奏引擎 —— 纯计算引擎，不持有状态。
///
/// 被 PlaybackEngine 和 PracticeCore 调用。
/// 所有方法均为 static，无副作用。
struct RhythmEngine {

    // MARK: - Subdivision

    /// 将一拍等分为指定份数
    /// e.g. subdivide(beat: 0, division: 4) → [0.0, 0.25, 0.5, 0.75]
    static func subdivide(baseBeat: Double, division: Int) -> [Double] {
        guard division > 0 else { return [baseBeat] }
        let step = 1.0 / Double(division)
        return (0..<division).map { baseBeat + Double($0) * step }
    }

    /// 将多拍按指定份数等分
    static func subdivideRange(beatRange: ClosedRange<Double>, division: Int) -> [Double] {
        let start = beatRange.lowerBound
        let count = Int(beatRange.upperBound - beatRange.lowerBound) * division
        let step = 1.0 / Double(division)
        return (0..<count).map { start + Double($0) * step }
    }

    // MARK: - Swing

    /// 对拍点应用 swing
    /// amount: 0.0 = 完全平直, 0.5 = 典型 swing, 1.0 = 极端
    static func applySwing(beats: [Double], amount: Double) -> [Double] {
        guard amount > 0, beats.count > 1 else { return beats }

        return beats.enumerated().map { index, beat in
            let beatInt = Int(beat)
            let frac = beat - Double(beatInt)

            // 仅对偶数索引的八分音符位置应用 swing
            if index % 2 == 0 {
                return beat
            } else {
                // 将后半拍偏移
                let swingOffset = amount * 0.25
                let swingFrac = frac + swingOffset
                return Double(beatInt) + min(swingFrac, 0.95)
            }
        }
    }

    // MARK: - Beat Accent

    /// 计算拍强调值
    /// 强拍 = 1.0, 次强拍 = 0.85, 弱拍 = 0.7
    static func beatAccent(beatIndex: Int, beatsPerMeasure: Int) -> Double {
        guard beatsPerMeasure > 0 else { return 1.0 }
        let position = beatIndex % beatsPerMeasure

        switch position {
        case 0: return 1.0     // 强拍（每小节第一拍）
        case beatsPerMeasure / 2: return 0.85  // 次强拍（3/4的第三拍, 4/4的第三拍）
        default: return 0.7    // 弱拍
        }
    }

    // MARK: - Timing Evaluation

    /// 评估节奏准确度
    /// - Returns: 0-100 分
    static func evaluateTiming(
        actual: Double,        // 实际拍位
        expected: Double,      // 期望拍位
        tolerance: Double = 0.1 // 容忍偏差（拍）
    ) -> Int {
        let deviation = abs(actual - expected)

        if deviation <= tolerance * 0.3 {
            return 100   // 完美
        } else if deviation <= tolerance * 0.6 {
            return 85    // 很好
        } else if deviation <= tolerance {
            return 70    // 可以
        } else if deviation <= tolerance * 1.5 {
            return 50    // 偏差较大
        } else {
            return 0     // 脱拍
        }
    }

    /// 批量评估，返回平均分
    static func evaluateTimingBatch(
        actuals: [Double],
        expecteds: [Double],
        tolerance: Double = 0.1
    ) -> Int {
        guard !actuals.isEmpty, actuals.count == expecteds.count else { return 0 }

        let scores = zip(actuals, expecteds).map { a, e in
            evaluateTiming(actual: a, expected: e, tolerance: tolerance)
        }

        return scores.reduce(0, +) / scores.count
    }

    // MARK: - Syncopation

    /// 检测是否切分音
    static func isSyncopated(events: [Double], beatSpacing: Double = 1.0) -> Bool {
        for event in events {
            let remainder = event.truncatingRemainder(dividingBy: beatSpacing)
            // 如果事件不在正拍或半拍上，可能是切分音
            if remainder > 0.01 && abs(remainder - beatSpacing * 0.5) > 0.01 {
                // 进一步检查：偏移量在 0.25~0.45 或 0.55~0.75 之间
                let fracInUnit = remainder / beatSpacing
                if (0.2...0.45).contains(fracInUnit) || (0.55...0.8).contains(fracInUnit) {
                    return true
                }
            }
        }
        return false
    }

    // MARK: - Difficulty

    /// 估算节奏难度 (1-5)
    static func difficulty(for pattern: RhythmPattern) -> Int {
        var score = 1

        // 事件密度
        let density = Double(pattern.events.count) / Double(pattern.beatsPerMeasure)
        if density > 4 { score += 2 }
        else if density > 2 { score += 1 }

        // 切分音
        let eventBeats = pattern.events.map(\.beat)
        if isSyncopated(events: eventBeats) { score += 1 }

        // Swing
        if pattern.swingAmount != nil { score += 1 }

        // BPM
        if pattern.bpm > 140 { score += 1 }

        return min(score, 5)
    }

    // MARK: - Pattern Generation

    /// 生成均匀四分音符节奏
    static func quarterNotes(beats: Int) -> RhythmPattern {
        var slots: [RhythmSlot] = []
        for beat in 0..<beats {
            slots.append(RhythmSlot(strum: .down, vocal: true, foot: beat == 0))
            slots.append(RhythmSlot(strum: .rest, vocal: false, foot: false))
            slots.append(RhythmSlot(strum: .rest, vocal: false, foot: false))
            slots.append(RhythmSlot(strum: .rest, vocal: false, foot: false))
        }
        return RhythmPattern(
            name: "四分音符",
            recommendedBPM: 120,
            slots: slots
        )
    }

    /// 生成八分音符节奏
    static func eighthNotes(beats: Int) -> RhythmPattern {
        var slots: [RhythmSlot] = []
        for beat in 0..<beats {
            slots.append(RhythmSlot(strum: .down, vocal: true, foot: beat == 0))
            slots.append(RhythmSlot(strum: .rest, vocal: false, foot: false))
            slots.append(RhythmSlot(strum: .up, vocal: true, foot: false))
            slots.append(RhythmSlot(strum: .rest, vocal: false, foot: false))
        }
        return RhythmPattern(
            name: "八分音符",
            recommendedBPM: 120,
            slots: slots
        )
    }
}
