import SwiftUI
import SwiftData

/// 练习详情页（集成谱式切换器和多谱式展示）
struct ExerciseDetailView: View {
    let exercise: ExerciseType
    let module: ExerciseModule
    let viewModel: PracticeViewModel

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var state: ExerciseState = .question
    @State private var currentScore: Int = 0
    @State private var questionCount: Int = 0
    @State private var correctCount: Int = 0
    @State private var selectedAnswer: Int?
    @State private var isCorrect: Bool?
    @State private var startTime: Date = Date()

    enum ExerciseState {
        case question
        case feedback
        case finished
    }

    private struct QuestionItem {
        let question: String
        let answer: Int
        let options: [String]
        let solfege: String
        let octave: Int
        /// 需要按顺序播放的 MIDI 音符（如音程的两个音）
        let midiNotes: [Int]?

        init(question: String, answer: Int, options: [String], solfege: String, octave: Int, midiNotes: [Int]? = nil) {
            self.question = question
            self.answer = answer
            self.options = options
            self.solfege = solfege
            self.octave = octave
            self.midiNotes = midiNotes
        }
    }

    private var questions: [QuestionItem] { loadQuestions() }

    var body: some View {
        VStack(spacing: 0) {
            headerView
            Divider()
            contentView
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            viewModel.setModelContext(modelContext)
        }
    }

    // MARK: - Header

    private var headerView: some View {
        VStack(spacing: 0) {
            // 顶部导航栏
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .foregroundStyle(AppColors.secondaryText)
                }

                Spacer()

                Text(exercise.rawValue)
                    .font(.headline)

                Spacer()

                Text("\(currentScore) 分")
                    .font(.headline)
                    .foregroundStyle(AppColors.primary)
            }
            .padding()


        }
        .background(Color(.systemBackground))
    }

    // MARK: - Content

    @ViewBuilder
    private var contentView: some View {
        switch state {
        case .question:
            questionView
        case .feedback:
            feedbackView
        case .finished:
            finishedView
        }
    }

    // MARK: - Question View

    private var questionView: some View {
        VStack(spacing: 20) {
            // 进度圆点
            progressDots

            Spacer()

            // 题目内容
            let current = questions[questionCount % questions.count]

            // 谱式展示区
            notationDisplayArea(for: current)
                .padding(.horizontal, 24)

            // 播放按钮
            Button {
                Task {
                    if let midiNotes = current.midiNotes, !midiNotes.isEmpty {
                        // 按顺序播放多个音（如音程的两个音）
                        for midi in midiNotes {
                            await AudioEngineManager.shared.playMIDI(midi, duration: 0.8)
                            try? await Task.sleep(nanoseconds: 200_000_000)
                        }
                    } else {
                        await AudioEngineManager.shared.playSolfege(current.solfege, octave: current.octave)
                    }
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(AppColors.primary)
                        .frame(width: 72, height: 72)

                    Image(systemName: "speaker.wave.2.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                }
            }

            // 题目文字
            Text(current.question)
                .font(.body)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundStyle(AppColors.primaryText)
                .padding(.horizontal)

            Spacer()

            // 选项
            optionsList(current: current)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
        }
    }

    /// 进度圆点
    private var progressDots: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                ForEach(0..<questions.count, id: \.self) { index in
                    Circle()
                        .fill(dotColor(for: index))
                        .frame(width: 8, height: 8)
                }
            }

            Text("\(questionCount + 1) / \(questions.count)")
                .font(.subheadline)
                .foregroundStyle(AppColors.secondaryText)
        }
        .padding(.top, 16)
    }

    private func dotColor(for index: Int) -> Color {
        if index < questionCount {
            return isCorrect == true ? AppColors.success : AppColors.error
        } else if index == questionCount {
            return AppColors.primary
        }
        return AppColors.tertiaryText
    }

    /// 谱式展示区（答题前不显示答案，根据练习类型展示不同提示）
    @ViewBuilder
    private func notationDisplayArea(for current: QuestionItem) -> some View {
        switch exercise {
        case .tablatureNoteReading:
            // 六线谱识读：显示把位题目，不显示简谱答案
            tablatureQuestionHint(question: current.question)
        case .singleNoteRecognition, .openStringRecognition, .rootNoteRecognition,
                .intervalRecognition, .fretboardIntervalComparison, .hammerPullInterval,
                .commonChordRecognition, .chordQualityRecognition, .barreChordRecognition,
                .scaleRecognition, .cagedSystemPractice, .commonTuningRecognition,
                .tablatureMelodySinging, .guitarMelodyRecognition, .harmonicRecognition,
                .intervalSinging:
            // 听辨/识读类：答题前不显示简谱答案
            listenHintView
        case .strummingPattern, .arpeggioPattern, .metronomeStability, .syncopationRecognition,
                .chordTransitionSpeed:
            // 节奏类不显示谱式
            EmptyView()
        }
    }

    /// 六线谱识读提示
    private func tablatureQuestionHint(question: String) -> some View {
        VStack(spacing: 12) {
            Text("识读题目")
                .font(.caption)
                .foregroundStyle(AppColors.secondaryText)

            Text(question)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(AppColors.primaryText)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    /// 听辨提示（不显示答案）
    private var listenHintView: some View {
        VStack(spacing: 12) {
            Image(systemName: "ear.fill")
                .font(.system(size: 40))
                .foregroundStyle(AppColors.primary.opacity(0.3))

            Text("仔细聆听或阅读题目")
                .font(.body)
                .foregroundStyle(AppColors.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    /// 选项列表
    private func optionsList(current: QuestionItem) -> some View {
        VStack(spacing: 10) {
            Text("请选择")
                .font(.subheadline)
                .foregroundStyle(AppColors.secondaryText)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(Array(current.options.enumerated()), id: \.offset) { index, option in
                Button {
                    selectAnswer(index)
                } label: {
                    HStack {
                        Text(optionLetter(index))
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .frame(width: 24, height: 24)
                            .background(AppColors.primary.opacity(0.7))
                            .clipShape(Circle())

                        Text(option)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundStyle(AppColors.primaryText)

                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func optionLetter(_ index: Int) -> String {
        let letters = ["A", "B", "C", "D", "E", "F"]
        return index < letters.count ? letters[index] : "\(index + 1)"
    }

    // MARK: - Feedback View

    private var feedbackView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: isCorrect == true ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(isCorrect == true ? AppColors.success : AppColors.error)

            Text(isCorrect == true ? "正确！" : "错误")
                .font(.title)
                .fontWeight(.bold)

            if isCorrect == false {
                let correct = questions[questionCount % questions.count].options[
                    questions[questionCount % questions.count].answer
                ]
                Text("正确答案：\(correct)")
                    .font(.body)
                    .foregroundStyle(AppColors.secondaryText)
            }

            Spacer()

            Button {
                nextQuestion()
            } label: {
                Text("下一题")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppColors.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }

    // MARK: - Finished View

    private var finishedView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "star.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.yellow)

            Text("练习完成！")
                .font(.title)
                .fontWeight(.bold)

            Text("得分：\(currentScore) / 100")
                .font(.title2)
                .foregroundStyle(AppColors.primary)

            Text("正确率：\(correctCount)/\(questions.count)")
                .font(.body)
                .foregroundStyle(AppColors.secondaryText)

            Spacer()

            VStack(spacing: 12) {
                Button {
                    viewModel.savePracticeRecord(
                        module: module,
                        exerciseType: exercise,
                        score: currentScore,
                        durationSeconds: Int(Date().timeIntervalSince(startTime))
                    )
                    dismiss()
                } label: {
                    Text("保存并退出")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppColors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                Button {
                    questionCount = 0
                    correctCount = 0
                    currentScore = 0
                    state = .question
                    startTime = Date()
                } label: {
                    Text("再练一次")
                        .font(.headline)
                        .foregroundStyle(AppColors.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(.systemGray5))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }

    // MARK: - Actions

    private func selectAnswer(_ index: Int) {
        let current = questions[questionCount % questions.count]
        let correct = index == current.answer
        selectedAnswer = index
        isCorrect = correct
        questionCount += 1

        if correct {
            correctCount += 1
            currentScore = Int(Double(correctCount) / Double(questionCount) * 100)
        }

        let generator = UIImpactFeedbackGenerator(style: correct ? .medium : .heavy)
        generator.impactOccurred()

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 300_000_000)
            if questionCount >= questions.count {
                state = .finished
            } else {
                state = .feedback
            }
        }
    }

    private func nextQuestion() {
        selectedAnswer = nil
        isCorrect = nil
        state = .question
    }

    // MARK: - Helpers

    /// 将音程字符串（如 "C4-E4"）解析为两个 MIDI 音符
    private func parseIntervalToMIDIs(_ intervalString: String) -> [Int] {
        let parts = intervalString.split(separator: "-")
        guard parts.count == 2 else { return [] }
        return parts.compactMap { parseNoteToMIDI(String($0)) }
    }

    /// 将音符字符串（如 "C4"、"F#5"）解析为 MIDI note
    private func parseNoteToMIDI(_ noteString: String) -> Int? {
        let noteNames: [String: Int] = [
            "C": 0, "C#": 1, "Db": 1, "D": 2, "D#": 3, "Eb": 3,
            "E": 4, "F": 5, "F#": 6, "Gb": 6, "G": 7, "G#": 8, "Ab": 8,
            "A": 9, "A#": 10, "Bb": 10, "B": 11
        ]

        // 提取音符名和八度
        var noteName = ""
        var octaveStr = ""
        for char in noteString {
            if char.isLetter || char == "#" || char == "b" {
                noteName.append(char)
            } else if char.isNumber || char == "-" {
                octaveStr.append(char)
            }
        }

        guard let semitone = noteNames[noteName],
              let octave = Int(octaveStr) else { return nil }
        return (octave + 1) * 12 + semitone
    }

    // MARK: - Data Loading

    private func loadQuestions() -> [QuestionItem] {
        switch exercise {
        case .singleNoteRecognition:
            return QuestionBank.noteNameQuestions.prefix(10).map { q in
                let options = generateNoteNameOptions(correct: q.noteName)
                return QuestionItem(
                    question: "简谱 \(q.solfege) 对应哪个音名？",
                    answer: options.firstIndex(of: q.noteName) ?? 0,
                    options: options,
                    solfege: q.solfege,
                    octave: q.octave
                )
            }
        case .openStringRecognition:
            let openStrings = [
                (6, "3", "E", 2), (5, "6", "A", 2), (4, "2", "D", 3),
                (3, "5", "G", 3), (2, "7", "B", 3), (1, "3", "E", 4)
            ]
            return openStrings.shuffled().prefix(10).map { string in
                let options = generateNoteNameOptions(correct: string.2)
                return QuestionItem(
                    question: "第 \(string.0) 弦空弦是什么音？",
                    answer: options.firstIndex(of: string.2) ?? 0,
                    options: options,
                    solfege: string.1,
                    octave: string.3
                )
            }
        case .tablatureNoteReading:
            // 六线谱音符识读：只包含有品位的题目（空弦音有专门的 openStringRecognition）
            let tabNotes = [
                ("五弦2品", "B", "7", 3), ("四弦2品", "E", "3", 3),
                ("三弦2品", "A", "6", 3), ("二弦3品", "D", "2", 3),
                ("六弦3品", "G", "5", 3), ("五弦3品", "C", "1", 4),
                ("四弦3品", "F", "4", 4), ("三弦3品", "B", "7", 3),
                ("二弦1品", "C", "1", 4), ("一弦1品", "F", "4", 4),
                ("六弦1品", "F", "4", 3), ("五弦1品", "A#", "#6", 2),
                ("四弦1品", "D#", "#2", 3), ("三弦1品", "G#", "#5", 3)
            ]
            return tabNotes.shuffled().prefix(10).map { note in
                let options = generateNoteNameOptions(correct: note.1)
                return QuestionItem(
                    question: "吉他 \(note.0) 是什么音？",
                    answer: options.firstIndex(of: note.1) ?? 0,
                    options: options,
                    solfege: note.2,
                    octave: note.3
                )
            }
        case .rootNoteRecognition:
            let roots = [
                ("C", "1", 4), ("G", "5", 4), ("D", "2", 4), ("A", "6", 3),
                ("E", "3", 3), ("F", "4", 4), ("B", "7", 3), ("A", "6", 4)
            ]
            return roots.shuffled().prefix(10).map { root in
                let options = generateNoteNameOptions(correct: root.0)
                return QuestionItem(
                    question: "哪个音是 \(root.0) 和弦的根音？",
                    answer: options.firstIndex(of: root.0) ?? 0,
                    options: options,
                    solfege: root.1,
                    octave: root.2
                )
            }
        case .intervalRecognition, .fretboardIntervalComparison, .hammerPullInterval:
            // 音程题库：(两个音的音符名, 正确答案音程度数)
            let intervals = [
                ("C4-E4", "大三度"), ("D4-F4", "小三度"), ("C4-G4", "纯五度"),
                ("E4-G4", "小三度"), ("F4-A4", "大三度"), ("G4-B4", "大三度"),
                ("A4-C5", "小三度"), ("C4-F4", "纯四度"), ("D4-G4", "纯四度"),
                ("E4-A4", "纯四度"), ("G4-D5", "纯五度"), ("A4-E5", "纯五度")
            ]
            return intervals.shuffled().prefix(10).map { data in
                let allIntervals = ["大二度", "小二度", "大三度", "小三度", "纯四度", "纯五度", "大六度", "小六度"]
                var options = [data.1]
                while options.count < 4 {
                    if let random = allIntervals.randomElement(), !options.contains(random) {
                        options.append(random)
                    }
                }
                options.shuffle()
                let midiNotes = parseIntervalToMIDIs(data.0)
                return QuestionItem(
                    question: "听辨以下两个音的音程关系",
                    answer: options.firstIndex(of: data.1) ?? 0,
                    options: options,
                    solfege: "1",
                    octave: 4,
                    midiNotes: midiNotes
                )
            }
        case .commonChordRecognition, .chordQualityRecognition, .barreChordRecognition, .chordTransitionSpeed:
            let chords = [
                ("C-E-G", "C大三和弦", "1"), ("A-C-E", "Am小三和弦", "6"),
                ("G-B-D", "G大三和弦", "5"), ("E-G-B", "Em小三和弦", "3"),
                ("D-F#-A", "D大三和弦", "2"), ("F-A-C", "F大三和弦", "4")
            ]
            return chords.shuffled().prefix(10).map { data in
                let allChords = ["C大三和弦", "Am小三和弦", "G大三和弦", "Em小三和弦", "D大三和弦", "F大三和弦", "B大三和弦", "Cm小三和弦"]
                var options = [data.1]
                while options.count < 4 {
                    if let random = allChords.randomElement(), !options.contains(random) {
                        options.append(random)
                    }
                }
                options.shuffle()
                return QuestionItem(
                    question: "和弦 \(data.0) 是什么和弦？",
                    answer: options.firstIndex(of: data.1) ?? 0,
                    options: options,
                    solfege: data.2,
                    octave: 4
                )
            }
        case .scaleRecognition, .cagedSystemPractice, .commonTuningRecognition:
            let scales = [
                ("C-D-E-F-G-A-B-C", "C大调", "1"), ("G-A-B-C-D-E-F#-G", "G大调", "5"),
                ("D-E-F#-G-A-B-C#-D", "D大调", "2"), ("A-B-C#-D-E-F#-G#-A", "A大调", "6"),
                ("E-F#-G#-A-B-C#-D#-E", "E大调", "3"), ("F-G-A-Bb-C-D-E-F", "F大调", "4")
            ]
            return scales.shuffled().prefix(10).map { data in
                let allScales = ["C大调", "G大调", "D大调", "A大调", "E大调", "F大调", "B大调", "Bb大调"]
                var options = [data.1]
                while options.count < 4 {
                    if let random = allScales.randomElement(), !options.contains(random) {
                        options.append(random)
                    }
                }
                options.shuffle()
                return QuestionItem(
                    question: "音阶 \(data.0) 是什么调式？",
                    answer: options.firstIndex(of: data.1) ?? 0,
                    options: options,
                    solfege: data.2,
                    octave: 4
                )
            }
        case .strummingPattern, .arpeggioPattern, .metronomeStability, .syncopationRecognition:
            let rhythms = [
                ("| 哒 | 哒 | 哒 | 哒 |", "四分音符节奏"), ("| 哒哒 | 哒哒 | 哒哒 | 哒哒 |", "八分音符节奏"),
                ("| 哒 | 哒哒 | 哒 | 哒哒 |", "混合节奏"), ("| 哒—— | 哒 | 哒—— | 哒 |", "二分音符节奏"),
                ("| 哒 | 哒 | X | 哒 |", "切分节奏")
            ]
            return rhythms.shuffled().prefix(10).map { data in
                let allRhythms = ["四分音符节奏", "八分音符节奏", "混合节奏", "二分音符节奏", "切分节奏", "三连音节奏"]
                var options = [data.1]
                while options.count < 4 {
                    if let random = allRhythms.randomElement(), !options.contains(random) {
                        options.append(random)
                    }
                }
                options.shuffle()
                return QuestionItem(
                    question: "节奏型 \(data.0) 是什么？",
                    answer: options.firstIndex(of: data.1) ?? 0,
                    options: options,
                    solfege: "1",
                    octave: 4
                )
            }
        case .tablatureMelodySinging, .guitarMelodyRecognition, .harmonicRecognition:
            let melodies = [
                ("1-2-3-4-5", "上行音阶", "1"), ("5-4-3-2-1", "下行音阶", "5"),
                ("1-3-5-3-1", "分解和弦", "1"), ("3-5-3-1-3", "波浪旋律", "3"),
                ("1-2-3-5-3-2-1", "级进旋律", "1"), ("1-3-5-1-5-3-1", "跳跃旋律", "1")
            ]
            return melodies.shuffled().prefix(10).map { data in
                let allMelodies = ["上行音阶", "下行音阶", "分解和弦", "波浪旋律", "级进旋律", "跳跃旋律"]
                var options = [data.1]
                while options.count < 4 {
                    if let random = allMelodies.randomElement(), !options.contains(random) {
                        options.append(random)
                    }
                }
                options.shuffle()
                return QuestionItem(
                    question: "旋律 \(data.0) 是什么类型？",
                    answer: options.firstIndex(of: data.1) ?? 0,
                    options: options,
                    solfege: data.2,
                    octave: 4
                )
            }
        case .intervalSinging:
            let intervals = [
                ("C-D", "大二度", "1"), ("E-F", "小二度", "3"), ("C-E", "大三度", "1"),
                ("D-F", "小三度", "2"), ("C-F", "纯四度", "1"), ("C-G", "纯五度", "1")
            ]
            return intervals.shuffled().prefix(10).map { data in
                let allIntervals = ["大二度", "小二度", "大三度", "小三度", "纯四度", "纯五度"]
                var options = [data.1]
                while options.count < 4 {
                    if let random = allIntervals.randomElement(), !options.contains(random) {
                        options.append(random)
                    }
                }
                options.shuffle()
                return QuestionItem(
                    question: "音程 \(data.0) 是多少度？",
                    answer: options.firstIndex(of: data.1) ?? 0,
                    options: options,
                    solfege: data.2,
                    octave: 4
                )
            }
        }
    }

    private func generateNoteNameOptions(correct: String) -> [String] {
        let allNotes = ["C", "D", "E", "F", "G", "A", "B"]
        var options = [correct]
        while options.count < 4 {
            let note = allNotes.randomElement() ?? "C"
            if !options.contains(note) {
                options.append(note)
            }
        }
        return options.shuffled()
    }
}

#Preview {
    ExerciseDetailView(
        exercise: .singleNoteRecognition,
        module: .noteName,
        viewModel: PracticeViewModel()
    )
}
