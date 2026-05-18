import SwiftUI

/// 统一练习结果视图 — 支持普通练习和视唱练习
struct PracticeResultView: View {
    let totalScore: Int
    let pitchScore: Int?
    let rhythmScore: Int?
    let noteScores: [Int]?
    let melody: [MelodyNote]?

    let onNext: () -> Void
    let onRetry: () -> Void
    let onSave: (() -> Void)?

    init(
        totalScore: Int,
        pitchScore: Int? = nil,
        rhythmScore: Int? = nil,
        noteScores: [Int]? = nil,
        melody: [MelodyNote]? = nil,
        onNext: @escaping () -> Void,
        onRetry: @escaping () -> Void,
        onSave: (() -> Void)? = nil
    ) {
        self.totalScore = totalScore
        self.pitchScore = pitchScore
        self.rhythmScore = rhythmScore
        self.noteScores = noteScores
        self.melody = melody
        self.onNext = onNext
        self.onRetry = onRetry
        self.onSave = onSave
    }

    private var scoreGrade: ScoreGrade {
        switch totalScore {
        case 90...100: return .excellent
        case 70..<90: return .good
        case 60..<70: return .pass
        default: return .fail
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // MARK: - 头部总分
                VStack(spacing: 12) {
                    Image(systemName: scoreGrade.icon)
                        .font(.system(size: 56))
                        .foregroundStyle(scoreGrade.color)

                    Text("\(totalScore)")
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .foregroundStyle(scoreGrade.color)

                    Text(scoreGrade.label)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(scoreGrade.color)
                }
                .padding(.top, 32)

                // MARK: - 分项得分（视唱有音准+节奏，普通练习只有总分）
                if let pitch = pitchScore, let rhythm = rhythmScore {
                    HStack(spacing: 16) {
                        scoreItem(title: "音准", score: pitch, icon: "waveform.path", color: AppColors.primaryBlue)
                        scoreItem(title: "节奏", score: rhythm, icon: "metronome", color: .orange)
                    }
                    .padding(.horizontal)
                }

                // MARK: - 音符详情（视唱）
                if let scores = noteScores, let notes = melody, !notes.isEmpty {
                    noteScoresSection(scores: scores, notes: notes)
                        .padding(.horizontal)
                }

                Spacer(minLength: 24)

                // MARK: - 操作按钮
                VStack(spacing: 12) {
                    if let onSave {
                        Button {
                            onSave()
                        } label: {
                            Text("保存并退出")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(AppColors.primaryBlue)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }

                    Button {
                        onRetry()
                    } label: {
                        Text("再练一次")
                            .font(.headline)
                            .foregroundStyle(AppColors.primaryBlue)
                    }

                    Button {
                        onNext()
                    } label: {
                        Text("下一题")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(AppColors.primaryBlue)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .background(AppColors.pageBackground)
    }

    private func scoreItem(title: String, score: Int, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text("\(score)")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(scoreColor(score))

            Text(title)
                .font(.caption)
                .foregroundStyle(AppColors.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func noteScoresSection(scores: [Int], notes: [MelodyNote]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("各音得分")
                .font(.headline)
                .foregroundStyle(AppColors.primaryText)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(notes.enumerated()), id: \.offset) { index, note in
                        noteScoreItem(
                            solfege: note.solfege,
                            score: index < scores.count ? scores[index] : 0
                        )
                    }
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func noteScoreItem(solfege: String, score: Int) -> some View {
        VStack(spacing: 6) {
            Text(solfege)
                .font(.title3)
                .fontWeight(.semibold)

            Text("\(score)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(noteScoreColor(score))
        }
        .frame(width: 44, height: 60)
        .background(noteScoreColor(score).opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func scoreColor(_ score: Int) -> Color {
        if score >= 90 { return AppColors.success }
        else if score >= 70 { return .yellow }
        else if score >= 60 { return .orange }
        else { return AppColors.error }
    }

    private func noteScoreColor(_ score: Int) -> Color { scoreColor(score) }

    private func scoreLabel(_ score: Int) -> String {
        switch score {
        case 95...100: return "完美!"
        case 85..<95: return "优秀"
        case 70..<85: return "良好"
        case 60..<70: return "及格"
        default: return "继续加油"
        }
    }
}

// MARK: - 评分等级

private enum ScoreGrade {
    case excellent, good, pass, fail

    var label: String {
        switch self {
        case .excellent: return "优秀"
        case .good: return "良好"
        case .pass: return "及格"
        case .fail: return "继续努力"
        }
    }

    var icon: String {
        switch self {
        case .excellent: return "star.circle.fill"
        case .good: return "hand.thumbsup.circle.fill"
        case .pass: return "checkmark.circle.fill"
        case .fail: return "arrow.counterclockwise.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .excellent: return AppColors.success
        case .good: return .yellow
        case .pass: return .orange
        case .fail: return AppColors.error
        }
    }
}

// MARK: - 便利初始化（普通练习）

extension PracticeResultView {
    /// 普通练习结果（只有总分）
    static func simple(totalScore: Int, onNext: @escaping () -> Void, onRetry: @escaping () -> Void) -> PracticeResultView {
        PracticeResultView(
            totalScore: totalScore,
            pitchScore: nil,
            rhythmScore: nil,
            noteScores: nil,
            melody: nil,
            onNext: onNext,
            onRetry: onRetry,
            onSave: nil
        )
    }

    /// 视唱练习结果
    static func sightSinging(
        pitchScore: Int,
        rhythmScore: Int,
        noteScores: [Int],
        melody: [MelodyNote],
        onRetry: @escaping () -> Void,
        onSave: @escaping () -> Void
    ) -> PracticeResultView {
        let total = Int(Double(pitchScore) * 0.7 + Double(rhythmScore) * 0.3)
        return PracticeResultView(
            totalScore: total,
            pitchScore: pitchScore,
            rhythmScore: rhythmScore,
            noteScores: noteScores,
            melody: melody,
            onNext: {},
            onRetry: onRetry,
            onSave: onSave
        )
    }
}

#Preview {
    PracticeResultView.simple(totalScore: 92, onNext: {}, onRetry: {})
}
