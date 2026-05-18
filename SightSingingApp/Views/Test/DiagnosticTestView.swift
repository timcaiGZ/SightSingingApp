import SwiftUI

/// 诊断测试答题界面
struct DiagnosticTestView: View {
    @Bindable var viewModel: TestViewModel

    var body: some View {
        VStack(spacing: 0) {
            // 顶部进度条
            VStack(spacing: 8) {
                HStack {
                    Text("第 \(viewModel.currentQuestionIndex + 1) 题")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(viewModel.currentQuestion?.dimensionValue?.rawValue ?? "")")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(AppColors.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppColors.primary.opacity(0.12))
                        .clipShape(Capsule())
                }

                ProgressView(value: viewModel.progress)
                    .tint(AppColors.primary)
            }
            .padding()
            .background(Color(.systemBackground))

            Divider()

            // 答题区
            if let question = viewModel.currentQuestion {
                ScrollView {
                    VStack(spacing: 32) {
                        Spacer(minLength: 40)

                        // 播放音频按钮
                        VStack(spacing: 16) {
                            Button {
                                playAudio(for: question)
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [AppColors.primary, AppColors.info],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 100, height: 100)
                                        .shadow(color: AppColors.primary.opacity(0.4), radius: 12, x: 0, y: 6)

                                    Image(systemName: "speaker.wave.2.fill")
                                        .font(.title)
                                        .foregroundStyle(.white)
                                }
                            }
                            .buttonStyle(.plain)

                            Text("点击播放音频")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Text(question.prompt)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.center)
                        }

                        Spacer(minLength: 24)

                        // 选项列表
                        LazyVStack(spacing: 12) {
                            ForEach(Array(question.options.enumerated()), id: \.element.id) { index, option in
                                AnswerOptionButton(
                                    option: option,
                                    index: index,
                                    isSelected: viewModel.answers[question.id] == index,
                                    isCorrect: viewModel.isCorrect(questionID: question.id),
                                    showResult: viewModel.answers[question.id] != nil
                                ) {
                                    viewModel.selectAnswer(questionID: question.id, answerIndex: index)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 32)
                    }
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .fullScreenCover(item: Binding(
            get: { viewModel.result.map { $0 } },
            set: { _ in }
        )) { result in
            TestResultView(result: result)
        }
    }

    private func playAudio(for question: TestQuestion) {
        Task {
            switch question.questionTypeValue {
            case .recognition:
                // 播放音符音频
                await AudioEngineManager.shared.playSolfege(question.audioNote, octave: 4)
            case .comparison:
                // 播放音程（两个音符）
                if let firstNote = question.audioNote.split(separator: "-").first,
                   let secondNote = question.audioNote.split(separator: "-").last {
                    await AudioEngineManager.shared.playSolfege(String(firstNote), octave: 4)
                    try? await Task.sleep(nanoseconds: 500_000_000)
                    await AudioEngineManager.shared.playSolfege(String(secondNote), octave: 4)
                } else {
                    await AudioEngineManager.shared.playSolfege(question.audioNote, octave: 4)
                }
            case .singing:
                // 播放和弦
                let notes = question.audioNote.split(separator: "-").map { String($0) }
                let chordNotes: [(solfege: String, octave: Int)] = notes.map { ($0, 4) }
                await AudioEngineManager.shared.playChord(chordNotes)
            case .identification:
                // 播放节奏型（简化的节拍音）
                await AudioEngineManager.shared.playNote(frequency: 440, duration: 0.3)
            case .none, .some:
                // 播放旋律（多个音符）
                let notes = question.audioNote.split(separator: "-").map { String($0) }
                for (index, note) in notes.enumerated() {
                    let delay = Double(index) * 0.5
                    Task {
                        try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                        await AudioEngineManager.shared.playSolfege(note, octave: 4)
                    }
                }
            }
        }
    }
}

/// 答案选项按钮
struct AnswerOptionButton: View {
    let option: TestOption
    let index: Int
    let isSelected: Bool
    let isCorrect: Bool?
    let showResult: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // 选项标签
                Text(String(UnicodeScalar(65 + index).map(Character.init) ?? "?")) // A, B, C, D
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
                    .background(backgroundForLabel)
                    .clipShape(Circle())

                // 六线谱图示（如果有）
                if let tabData = option.tabData {
                    GuitarTabView(tabData: tabData)
                        .frame(width: 120, height: 60)
                }

                Text(option.label)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)

                Spacer()

                // 结果图标
                if showResult {
                    Image(systemName: resultIcon)
                        .font(.title3)
                        .foregroundStyle(resultColor)
                }
            }
            .padding(16)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(borderColor, lineWidth: showResult && isSelected ? 2 : 0)
            )
        }
        .buttonStyle(.plain)
        .disabled(showResult)
    }

    private var backgroundForLabel: Color {
        if showResult && isSelected {
            if isCorrect == true { return AppColors.success }
            if isCorrect == false { return AppColors.error }
        }
        return AppColors.primary
    }

    private var backgroundColor: Color {
        if showResult && isSelected {
            if isCorrect == true { return AppColors.success.opacity(0.1) }
            if isCorrect == false { return AppColors.error.opacity(0.1) }
        }
        return Color(.systemBackground)
    }

    private var borderColor: Color {
        if showResult && isSelected {
            if isCorrect == true { return AppColors.success }
            if isCorrect == false { return AppColors.error }
        }
        return .clear
    }

    private var resultIcon: String {
        if isCorrect == true { return "checkmark.circle.fill" }
        if isCorrect == false { return "xmark.circle.fill" }
        return ""
    }

    private var resultColor: Color {
        if isCorrect == true { return AppColors.success }
        if isCorrect == false { return AppColors.error }
        return .clear
    }
}

/// 六线谱绘制视图
struct GuitarTabView: View {
    let tabData: TabData

    var body: some View {
        Canvas { context, size in
            let width = size.width
            let height = size.height
            let stringSpacing = height / 7

            // 绘制6根弦（横线）
            for i in 1...6 {
                let y = stringSpacing * Double(i)
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: width, y: y))
                context.stroke(path, with: .color(.gray.opacity(0.6)), lineWidth: i == 1 || i == 6 ? 1.5 : 1)
            }

            // 绘制品位标记（如果有）
            if let markers = tabData.markers.isEmpty ? nil : tabData.markers.first {
                // 品位的起始线
                let markerY = stringSpacing * 1.1
                var path = Path()
                path.move(to: CGPoint(x: 0, y: markerY))
                path.addLine(to: CGPoint(x: width, y: markerY))
                context.stroke(path, with: .color(.black), lineWidth: 3)
            }

            // 绘制品位数字或圆点
            let fretNumbers = tabData.frets.enumerated().compactMap { (index, fret) -> (string: Int, fret: Int)? in
                guard let fret = fret else { return nil }
                return (string: index, fret: fret)
            }

            for (stringIndex, fret) in fretNumbers {
                let y = stringSpacing * Double(stringIndex + 1)
                let x = width * 0.5

                if fret == 0 {
                    // 空弦标记
                    var path = Path()
                    path.addEllipse(in: CGRect(x: x - 6, y: y - 6, width: 12, height: 12))
                    context.fill(path, with: .color(.primary))
                } else {
                    // 品位数字
                    var text = Text("\(fret)").font(.caption)
                    text = text.foregroundColor(.primary)
                    context.draw(text, at: CGPoint(x: x, y: y))
                }
            }
        }
    }
}

/// 测试结果展示
struct TestResultView: View {
    let result: TestResult
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 总分
                    VStack(spacing: 8) {
                        Text("\(result.totalScore)")
                            .font(.system(size: 72, weight: .bold))
                            .foregroundStyle(AppColors.primary)

                        Text("综合得分")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text("用时 \(result.totalDurationSeconds / 60) 分 \(result.totalDurationSeconds % 60) 秒")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 32)

                    // 维度得分柱状图
                    VStack(alignment: .leading, spacing: 12) {
                        Text("各维度得分")
                            .font(.headline)

                        ForEach(Array(result.dimensionScores.values.sorted { $0.score > $1.score }), id: \.module) { dimScore in
                            DimensionScoreBar(dimScore: dimScore)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 16)

                    // 推荐
                    if !result.recommendations.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("推荐练习")
                                .font(.headline)

                            ForEach(result.recommendations) { rec in
                                RecommendationCard(recommendation: rec)
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 16)
                    }

                    Spacer(minLength: 32)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("测试结果")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

/// 维度得分条
struct DimensionScoreBar: View {
    let dimScore: DimensionScore

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(dimScore.module.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("\(dimScore.score) 分")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [dimScore.module.gradientStart, dimScore.module.gradientEnd],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * CGFloat(dimScore.score) / 100, height: 8)
                }
            }
            .frame(height: 8)
        }
    }
}

/// 推荐卡片
struct RecommendationCard: View {
    let recommendation: Recommendation

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(recommendation.exerciseTypeValue?.rawValue ?? recommendation.exerciseType)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(recommendation.reason)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                Text("建议练习 \(recommendation.suggestedMinutes) 分钟")
                    .font(.caption)
                    .foregroundStyle(AppColors.primary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(AppColors.primary.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    let vm = TestViewModel()
    vm.startTest()
    return DiagnosticTestView(viewModel: vm)
}
