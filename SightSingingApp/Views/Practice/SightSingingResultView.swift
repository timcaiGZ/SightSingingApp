import SwiftUI

/// 视唱结果页 — 展示音准分、节奏分、总分，以及每个音符的得分详情
struct SightSingingResultView: View {
    let pitchScore: Int
    let rhythmScore: Int
    let noteScores: [Int]
    let melody: [MelodyNote]

    let onRetry: () -> Void
    let onSave: () -> Void

    private var totalScore: Int {
        Int(Double(pitchScore) * 0.7 + Double(rhythmScore) * 0.3)
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
            VStack(spacing: 32) {
                // MARK: - 头部：总分
                VStack(spacing: 16) {
                    Image(systemName: scoreGrade.icon)
                        .font(.system(size: 64))
                        .foregroundStyle(scoreGrade.color)
                        .padding(.top, 32)

                    Text("\(totalScore)")
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .foregroundStyle(scoreGrade.color)

                    Text(scoreGrade.label)
                        .font(.title2)
                        .fontWeight(.semibold)
                }

                // MARK: - 两项分数组件
                HStack(spacing: 24) {
                    ScoreCard(
                        title: "音准分",
                        score: pitchScore,
                        subtitle: "× 0.7",
                        icon: "waveform.path",
                        color: AppTheme.accent
                    )

                    ScoreCard(
                        title: "节奏分",
                        score: rhythmScore,
                        subtitle: "× 0.3",
                        icon: "metronome",
                        color: .orange
                    )
                }
                .padding(.horizontal)

                // MARK: - 音符详情
                VStack(alignment: .leading, spacing: 16) {
                    Text("各音得分")
                        .font(.headline)
                        .padding(.horizontal)

                    HStack(spacing: 0) {
                        ForEach(Array(melody.enumerated()), id: \.offset) { index, note in
                            NoteScoreView(
                                solfege: note.solfege,
                                score: index < noteScores.count ? noteScores[index] : 0
                            )

                            if index < melody.count - 1 {
                                Spacer()
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)
                }

                // MARK: - 评分说明
                VStack(alignment: .leading, spacing: 12) {
                    Text("评分标准")
                        .font(.headline)

                    VStack(alignment: .leading, spacing: 8) {
                        ScoreLegendItem(color: AppTheme.success, label: "≤ 10 音分 — 优秀（90-100分）")
                        ScoreLegendItem(color: .yellow, label: "10-30 音分 — 良好（70-89分）")
                        ScoreLegendItem(color: .orange, label: "30-50 音分 — 及格（60-69分）")
                        ScoreLegendItem(color: AppTheme.error, label: "> 50 音分 — 不及格（0-59分）")
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)

                Spacer(minLength: 24)

                // MARK: - 操作按钮
                VStack(spacing: 12) {
                    Button {
                        onSave()
                    } label: {
                        Text("保存并退出")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(AppTheme.accent)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                    .buttonStyle(.plain)

                    Button {
                        onRetry()
                    } label: {
                        Text("再练一次")
                            .font(.headline)
                            .foregroundStyle(AppTheme.accent)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(.systemGray5))
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - 分数卡片

private struct ScoreCard: View {
    let title: String
    let score: Int
    let subtitle: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text("\(score)")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(color)

            VStack(spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - 单音得分视图

private struct NoteScoreView: View {
    let solfege: String
    let score: Int

    private var scoreColor: Color {
        switch score {
        case 90...100: return AppTheme.success
        case 70..<90: return .yellow
        case 60..<70: return .orange
        default: return AppTheme.error
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            Text(solfege)
                .font(.title2)
                .fontWeight(.bold)

            // 迷你进度环
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 4)
                    .frame(width: 44, height: 44)

                Circle()
                    .trim(from: 0, to: CGFloat(score) / 100)
                    .stroke(scoreColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 44, height: 44)
                    .rotationEffect(.degrees(-90))

                Text("\(score)")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(scoreColor)
            }
        }
    }
}

// MARK: - 评分图例项

private struct ScoreLegendItem: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
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
        case .excellent: return AppTheme.success
        case .good: return .yellow
        case .pass: return .orange
        case .fail: return AppTheme.error
        }
    }
}
