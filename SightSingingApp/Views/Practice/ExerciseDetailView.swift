import SwiftUI
import SwiftData

/// 练习详情页（实际练习界面）
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

    // 题目结构：包含 question, answer, options, solfege, octave
    private struct QuestionItem {
        let question: String
        let answer: Int
        let options: [String]
        let solfege: String  // 用于音频播放
        let octave: Int      // 用于音频播放
    }

    // 从题库加载题目
    private var questions: [QuestionItem] {
        loadQuestions()
    }

    /// 加载题目
    private func loadQuestions() -> [QuestionItem] {
        switch exercise {
        // ── 音名模块 ─────────────────────────────────────────────
        case .singleNoteRecognition:
            // 单音辨认 → 实际走 SingleNoteListeningView，此处仅作后备
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
            // 空弦音辨认：吉他六根空弦 E2 A2 D3 G3 B3 E4
            let openStrings: [(stringNum: Int, solfege: String, noteName: String, octave: Int)] = [
                (6, "3", "E", 2), (5, "6", "A", 2), (4, "2", "D", 3),
                (3, "5", "G", 3), (2, "7", "B", 3), (1, "3", "E", 4)
            ]
            return openStrings.shuffled().prefix(10).map { string in
                let options = generateNoteNameOptions(correct: string.noteName)
                return QuestionItem(
                    question: "第 \(string.stringNum) 弦空弦是什么音？（简谱 \(string.solfege)）",
                    answer: options.firstIndex(of: string.noteName) ?? 0,
                    options: options,
                    solfege: string.solfege,
                    octave: string.octave
                )
            }

        case .rootNoteRecognition:
            // 根音听辨 → 实际走 RootNoteListeningView，此处仅作后备
            return QuestionBank.intervalQuestions.prefix(10).map { q in
                let rootNote = NoteNameQuestion(solfege: "1", noteName: "C", octave: 4, isSharp: false, difficulty: q.difficulty)
                let options = generateNoteNameOptions(correct: rootNote.noteName)
                return QuestionItem(
                    question: "这个音组的根音是什么？",
                    answer: 0,
                    options: options,
                    solfege: "1",
                    octave: 4
                )
            }

        case .tablatureNoteReading:
            // 六线谱音符识读：展示吉他指法图 + 简谱，用户辨认音符
            return [
                QuestionItem(question: "六线谱 第1弦 0格 → 简谱？", answer: 0, options: ["1", "3", "5", "7"], solfege: "1", octave: 6),
                QuestionItem(question: "六线谱 第2弦 0格 → 简谱？", answer: 1, options: ["2", "4", "6", "7"], solfege: "2", octave: 5),
                QuestionItem(question: "六线谱 第3弦 0格 → 简谱？", answer: 2, options: ["3", "5", "7", "2"], solfege: "3", octave: 4),
                QuestionItem(question: "六线谱 第4弦 0格 → 简谱？", answer: 3, options: ["4", "6", "1", "5"], solfege: "4", octave: 4),
                QuestionItem(question: "六线谱 第5弦 0格 → 简谱？", answer: 0, options: ["5", "7", "2", "6"], solfege: "5", octave: 3),
                QuestionItem(question: "六线谱 第6弦 0格 → 简谱？", answer: 1, options: ["6", "3", "5", "7"], solfege: "6", octave: 3),
                QuestionItem(question: "六线谱 第1弦 1格 → 简谱？", answer: 1, options: ["2", "4", "6", "1"], solfege: "2", octave: 6),
                QuestionItem(question: "六线谱 第2弦 1格 → 简谱？", answer: 2, options: ["3", "5", "7", "2"], solfege: "3", octave: 5),
                QuestionItem(question: "六线谱 第3弦 2格 → 简谱？", answer: 3, options: ["4", "6", "1", "5"], solfege: "4", octave: 4),
                QuestionItem(question: "六线谱 第5弦 2格 → 简谱？", answer: 2, options: ["6", "7", "2", "3"], solfege: "2", octave: 3),
            ]

        // ── 音程模块 ─────────────────────────────────────────────
        case .intervalRecognition, .intervalSinging:
            // 播放一个音程，辨认其名称
            let allIntervals = ["纯一度", "大二度", "小三度", "大三度", "纯四度", "纯五度", "小六度", "大六度", "小七度", "大七度", "增四度", "减五度"]
            return QuestionBank.intervalQuestions.prefix(10).map { q in
                let options = allIntervals.shuffled().prefix(4).map { String($0) }
                var mutableOptions = options
                if !mutableOptions.contains(q.name) {
                    mutableOptions = Array(options.prefix(3))
                    mutableOptions.append(q.name)
                    mutableOptions.shuffle()
                }
                return QuestionItem(
                    question: "这个音程是？",
                    answer: mutableOptions.firstIndex(of: q.name) ?? 0,
                    options: mutableOptions,
                    solfege: "1",
                    octave: 4
                )
            }

        case .fretboardIntervalComparison:
            // 把位音程比较：给定根音，在指板上找指定音程的位置
            return [
                QuestionItem(question: "C 在第 5 弦 3 品，向上大三度的位置在？", answer: 1, options: ["第4弦空弦", "第4弦2品", "第4弦3品", "第3弦空弦"], solfege: "3", octave: 4),
                QuestionItem(question: "G 在第 6 弦 3 品，向上纯五度的位置在？", answer: 2, options: ["第5弦5品", "第5弦7品", "第5弦3品", "第4弦2品"], solfege: "5", octave: 4),
                QuestionItem(question: "D 在第 4 弦 5 品，向下小三度的位置在？", answer: 0, options: ["第6弦3品", "第5弦1品", "第4弦3品", "第3弦5品"], solfege: "2", octave: 3),
                QuestionItem(question: "A 在第 5 弦 0 品，向上纯四度的位置在？", answer: 1, options: ["第6弦2品", "第5弦2品", "第4弦0品", "第4弦2品"], solfege: "4", octave: 3),
                QuestionItem(question: "E 在第 6 弦 0 品，向上大六度的位置在？", answer: 2, options: ["第4弦2品", "第4弦4品", "第4弦1品", "第3弦0品"], solfege: "6", octave: 3),
                QuestionItem(question: "B 在第 2 弦 0 品，向上增四度的位置在？", answer: 3, options: ["第1弦3品", "第1弦4品", "第1弦2品", "第1弦5品"], solfege: "5", octave: 5),
                QuestionItem(question: "F 在第 1 弦 1 品，向上小七度的位置在？", answer: 1, options: ["第6弦13品", "第6弦10品", "第5弦8品", "第4弦5品"], solfege: "7", octave: 4),
                QuestionItem(question: "D 在第 3 弦 0 品，向上大十度（十度）的位置在？", answer: 0, options: ["第1弦3品", "第1弦5品", "第1弦2品", "第2弦3品"], solfege: "3", octave: 5),
                QuestionItem(question: "G 在第 1 弦 3 品，向下纯四度的位置在？", answer: 2, options: ["第6弦5品", "第6弦3品", "第5弦5品", "第5弦3品"], solfege: "5", octave: 3),
                QuestionItem(question: "A 在第 4 弦 0 品，向上小三度的位置在？", answer: 3, options: ["第3弦4品", "第3弦2品", "第3弦3品", "第3弦5品"], solfege: "3", octave: 3),
            ]

        case .hammerPullInterval:
            // 击弦/勾弦音程：练习连音技巧中的音程
            return [
                QuestionItem(question: "第5弦 2品 → 4品（击弦），音程是？", answer: 2, options: ["纯一度", "大二度", "小三度", "纯四度"], solfege: "2", octave: 3),
                QuestionItem(question: "第4弦 0品 → 2品（击弦），音程是？", answer: 1, options: ["纯一度", "小三度", "大二度", "纯四度"], solfege: "4", octave: 4),
                QuestionItem(question: "第3弦 4品 → 2品（勾弦），音程是？", answer: 2, options: ["纯一度", "大二度", "小三度", "大二度"], solfege: "2", octave: 4),
                QuestionItem(question: "第2弦 3品 → 1品（勾弦），音程是？", answer: 1, options: ["纯一度", "小三度", "大二度", "纯四度"], solfege: "2", octave: 5),
                QuestionItem(question: "第1弦 5品 → 3品（勾弦），音程是？", answer: 0, options: ["大二度", "小三度", "纯四度", "纯五度"], solfege: "4", octave: 6),
                QuestionItem(question: "第6弦 0品 → 2品（击弦），音程是？", answer: 2, options: ["纯一度", "大二度", "大三度", "纯四度"], solfege: "2", octave: 3),
                QuestionItem(question: "第5弦 5品 → 3品（勾弦），音程是？", answer: 1, options: ["纯一度", "小三度", "大二度", "纯四度"], solfege: "4", octave: 3),
                QuestionItem(question: "第4弦 2品 → 4品（击弦），音程是？", answer: 2, options: ["纯一度", "大二度", "小三度", "纯四度"], solfege: "6", octave: 4),
                QuestionItem(question: "第3弦 0品 → 2品（击弦），音程是？", answer: 2, options: ["纯一度", "大二度", "大三度", "纯四度"], solfege: "4", octave: 4),
                QuestionItem(question: "第1弦 0品 → 2品（击弦），音程是？", answer: 1, options: ["纯一度", "大二度", "小三度", "纯四度"], solfege: "2", octave: 6),
            ]

        // ── 和弦模块 ─────────────────────────────────────────────
        case .barreChordRecognition:
            // 大横按辨认：给出指法图，辨认和弦名称
            return [
                QuestionItem(question: "六线谱：1品 大横按，根音在6弦 → 什么和弦？", answer: 0, options: ["F", "Bm", "Em", "Am"], solfege: "4", octave: 4),
                QuestionItem(question: "六线谱：2品 大横按，根音在5弦 → 什么和弦？", answer: 2, options: ["C", "A", "B", "G"], solfege: "2", octave: 4),
                QuestionItem(question: "六线谱：3品 大横按，根音在6弦 → 什么和弦？", answer: 1, options: ["F", "G", "A", "D"], solfege: "5", octave: 4),
                QuestionItem(question: "六线谱：5品 大横按，根音在6弦 → 什么和弦？", answer: 3, options: ["F", "G", "C", "A"], solfege: "1", octave: 5),
                QuestionItem(question: "六线谱：7品 大横按，根音在5弦 → 什么和弦？", answer: 1, options: ["D", "E", "F", "G"], solfege: "3", octave: 5),
                QuestionItem(question: "六线谱：1品 小横按，根音在5弦 → 什么和弦？", answer: 2, options: ["A", "B", "Bm", "Em"], solfege: "7", octave: 3),
                QuestionItem(question: "六线谱：2品 小横按，根音在5弦 → 什么和弦？", answer: 0, options: ["B", "C", "D", "E"], solfege: "2", octave: 4),
                QuestionItem(question: "六线谱：5品 大横按，根音在5弦 → 什么和弦？", answer: 3, options: ["A", "C", "D", "E"], solfege: "3", octave: 4),
                QuestionItem(question: "六线谱：3品 大横按，根音在5弦 → 什么和弦？", answer: 1, options: ["C", "D", "E", "G"], solfege: "2", octave: 4),
                QuestionItem(question: "六线谱：4品 大横按，根音在6弦 → 什么和弦？", answer: 0, options: ["G", "F", "A", "B"], solfege: "5", octave: 4),
            ]

        case .chordQualityRecognition:
            // 和弦性质辨认：辨认大三/小三/属七/减七等性质
            return [
                QuestionItem(question: "根音 C + E + G → 什么性质？", answer: 0, options: ["大三和弦", "小三和弦", "增三和弦", "减三和弦"], solfege: "1", octave: 4),
                QuestionItem(question: "根音 A + C + E → 什么性质？", answer: 1, options: ["大三和弦", "小三和弦", "减三和弦", "属七和弦"], solfege: "6", octave: 4),
                QuestionItem(question: "根音 G + B + D + F → 什么性质？", answer: 2, options: ["大七和弦", "小七和弦", "属七和弦", "减七和弦"], solfege: "5", octave: 4),
                QuestionItem(question: "根音 D + F# + A → 什么性质？", answer: 0, options: ["大三和弦", "小三和弦", "减三和弦", "增三和弦"], solfege: "2", octave: 4),
                QuestionItem(question: "根音 E + G + B → 什么性质？", answer: 1, options: ["大三和弦", "小三和弦", "属七和弦", "减三和弦"], solfege: "3", octave: 4),
                QuestionItem(question: "根音 F + A + C + E → 什么性质？", answer: 1, options: ["属七和弦", "大七和弦", "小七和弦", "减七和弦"], solfege: "4", octave: 4),
                QuestionItem(question: "根音 B + D + F → 什么性质？", answer: 3, options: ["大三和弦", "小三和弦", "增三和弦", "减三和弦"], solfege: "7", octave: 3),
                QuestionItem(question: "根音 C + E + G + Bb → 什么性质？", answer: 2, options: ["大七和弦", "小七和弦", "属七和弦", "减七和弦"], solfege: "1", octave: 4),
                QuestionItem(question: "根音 A + C + E + G → 什么性质？", answer: 4, options: ["大七和弦", "属七和弦", "减七和弦", "减三和弦", "小七和弦"], solfege: "6", octave: 4),
                QuestionItem(question: "根音 D + F# + A + C → 什么性质？", answer: 2, options: ["大七和弦", "小七和弦", "属七和弦", "减七和弦"], solfege: "2", octave: 4),
            ]

        case .chordTransitionSpeed:
            // 和弦转换速度：给定起始和弦和目标和弦，选择最短路径
            return [
                QuestionItem(question: "C → G，最少移动几根手指？", answer: 1, options: ["1根", "2根", "3根", "全部换"], solfege: "5", octave: 4),
                QuestionItem(question: "Am → F，最少移动几根手指？", answer: 2, options: ["1根", "2根", "3根", "全部换"], solfege: "4", octave: 4),
                QuestionItem(question: "G → Em，最少移动几根手指？", answer: 0, options: ["1根", "2根", "3根", "全部换"], solfege: "3", octave: 4),
                QuestionItem(question: "D → A，最少移动几根手指？", answer: 1, options: ["1根", "2根", "3根", "全部换"], solfege: "6", octave: 4),
                QuestionItem(question: "E → A，最少移动几根手指？", answer: 0, options: ["1根", "2根", "3根", "全部换"], solfege: "6", octave: 3),
                QuestionItem(question: "C → Am，最少移动几根手指？", answer: 2, options: ["1根", "2根", "3根", "全部换"], solfege: "6", octave: 4),
                QuestionItem(question: "G → D，最少移动几根手指？", answer: 1, options: ["1根", "2根", "3根", "全部换"], solfege: "2", octave: 4),
                QuestionItem(question: "D → G，最少移动几根手指？", answer: 2, options: ["1根", "2根", "3根", "全部换"], solfege: "5", octave: 4),
                QuestionItem(question: "F → G，最少移动几根手指？", answer: 1, options: ["1根", "2根", "3根", "全部换"], solfege: "5", octave: 4),
                QuestionItem(question: "Em → G，最少移动几根手指？", answer: 1, options: ["1根", "2根", "3根", "全部换"], solfege: "5", octave: 4),
            ]

        case .commonChordRecognition:
            // 常用开放和弦辨认
            let openChords = ["C", "D", "Em", "G", "Am", "E", "A", "F"]
            return QuestionBank.chordQuestions.filter { q in
                ["C", "D", "Em", "G", "Am", "E", "A"].contains(q.name.replacingOccurrences(of: "(大横按)", with: ""))
            }.prefix(10).map { q in
                let options = openChords.shuffled().prefix(4)
                let correctName = q.name.replacingOccurrences(of: "(大横按)", with: "")
                var mutableOptions = Array(options)
                if !mutableOptions.contains(correctName) {
                    mutableOptions = Array(options.prefix(3))
                    mutableOptions.append(correctName)
                    mutableOptions.shuffle()
                }
                return QuestionItem(
                    question: "这个六线谱指法是什么和弦？",
                    answer: mutableOptions.firstIndex(of: correctName) ?? 0,
                    options: mutableOptions,
                    solfege: "1",
                    octave: 4
                )
            }

        // ── 调式模块 ─────────────────────────────────────────────
        case .scaleRecognition:
            // 调式音阶辨认：播放或展示音阶，辨认调式
            return [
                QuestionItem(question: "C D E F G A B → 什么调式？", answer: 0, options: ["C大调", "C五声", "C小调", "C利底亚"], solfege: "1", octave: 4),
                QuestionItem(question: "G A B C D E F# → 什么调式？", answer: 0, options: ["G大调", "G五声", "G小调", "G利底亚"], solfege: "5", octave: 4),
                QuestionItem(question: "D E F# G A B C# → 什么调式？", answer: 0, options: ["D大调", "D五声", "D小调", "D利底亚"], solfege: "2", octave: 4),
                QuestionItem(question: "A B C# D E F# G# → 什么调式？", answer: 0, options: ["A大调", "A小调", "A五声", "A利底亚"], solfege: "6", octave: 3),
                QuestionItem(question: "C D E G A → 什么调式？", answer: 1, options: ["C大调", "C五声(宫)", "C小调", "C利底亚"], solfege: "1", octave: 4),
                QuestionItem(question: "A B C# E F# G# → 什么调式？", answer: 2, options: ["A大调", "A五声", "A小调(自然)", "A利底亚"], solfege: "6", octave: 3),
                QuestionItem(question: "C Eb F G Bb → 什么调式？", answer: 3, options: ["C大调", "C五声", "C小调", "C混合利底亚"], solfege: "1", octave: 4),
                QuestionItem(question: "E F# G# A B C# D# → 什么调式？", answer: 0, options: ["E大调", "E小调", "E五声", "E利底亚"], solfege: "3", octave: 4),
                QuestionItem(question: "D E F# G A B C → 什么调式？", answer: 3, options: ["D大调", "D五声", "D小调", "D混合利底亚"], solfege: "2", octave: 4),
                QuestionItem(question: "F G A Bb C D E → 什么调式？", answer: 0, options: ["F大调", "F五声", "F小调", "F利底亚"], solfege: "4", octave: 4),
            ]

        case .cagedSystemPractice:
            // CAGED 各调把位：给定调号，选择正确的 CAGED 把位
            return [
                QuestionItem(question: "C 大调，E 把位从几品开始？", answer: 1, options: ["空弦", "第8品", "第3品", "第5品"], solfege: "1", octave: 4),
                QuestionItem(question: "G 大调，C 把位在第几品？", answer: 2, options: ["第3品", "第5品", "第8品", "第10品"], solfege: "5", octave: 4),
                QuestionItem(question: "D 大调，D 把位（开放把位）在哪？", answer: 0, options: ["第5品", "空弦", "第7品", "第10品"], solfege: "2", octave: 4),
                QuestionItem(question: "A 大调，A 把位（开放把位）在哪？", answer: 0, options: ["空弦", "第2品", "第5品", "第7品"], solfege: "6", octave: 3),
                QuestionItem(question: "E 大调，E 把位（开放把位）在哪？", answer: 0, options: ["空弦", "第2品", "第4品", "第7品"], solfege: "3", octave: 4),
                QuestionItem(question: "D 大调，G 把位在第几品？", answer: 2, options: ["第2品", "第5品", "第8品", "第10品"], solfege: "2", octave: 4),
                QuestionItem(question: "A 大调，G 把位在第几品？", answer: 1, options: ["第3品", "第5品", "第8品", "第10品"], solfege: "6", octave: 3),
                QuestionItem(question: "G 大调，E 把位从几品开始？", answer: 1, options: ["空弦", "第3品", "第5品", "第8品"], solfege: "5", octave: 4),
                QuestionItem(question: "E 大调，C 把位在第几品？", answer: 3, options: ["第3品", "第5品", "第8品", "第12品"], solfege: "3", octave: 4),
                QuestionItem(question: "B 大调，哪个是把位最方便的起始位置？", answer: 2, options: ["E把位(空弦)", "A把位(第2品)", "E把位(第12品)", "G把位(第8品)"], solfege: "7", octave: 3),
            ]

        case .commonTuningRecognition:
            // 常用调式辨认
            return [
                QuestionItem(question: "E A D G B E → 标准调弦是什么调？", answer: 0, options: ["标准调弦(E)", "Drop D", "DADGAD", "Open G"], solfege: "3", octave: 4),
                QuestionItem(question: "D G C F A D → 是什么调弦方式？", answer: 2, options: ["标准调弦", "Drop D", "Open G", "DADGAD"], solfege: "5", octave: 4),
                QuestionItem(question: "E A D G B E，降D弦到C → 是什么调弦？", answer: 1, options: ["标准调弦", "Drop D", "Open G", "DADGAD"], solfege: "3", octave: 4),
                QuestionItem(question: "D A D G A D → 是什么调弦方式？", answer: 3, options: ["标准调弦", "Drop D", "Open G", "DADGAD"], solfege: "2", octave: 4),
                QuestionItem(question: "D G D G B D → 常用于什么风格？", answer: 1, options: ["古典", "指弹", "摇滚", "爵士"], solfege: "5", octave: 4),
                QuestionItem(question: "E A D #G B E → 升了几根弦？", answer: 2, options: ["空弦", "升1根", "升2根", "升3根"], solfege: "4", octave: 4),
                QuestionItem(question: "标准调弦中，5弦空弦是什么音？", answer: 1, options: ["E", "A", "D", "G"], solfege: "6", octave: 3),
                QuestionItem(question: "标准调弦中，4弦空弦比3弦空弦低几度？", answer: 2, options: ["纯四度", "大三度", "纯四度", "小二度"], solfege: "5", octave: 4),
                QuestionItem(question: "Open G 调弦： D G D G B D，根音是哪根弦？", answer: 0, options: ["6弦(D)", "5弦(G)", "1弦(D)", "4弦(G)"], solfege: "5", octave: 4),
                QuestionItem(question: "Half Step Down 调弦，6弦空弦是什么音？", answer: 1, options: ["E", "Eb", "D", "F"], solfege: "3", octave: 3),
            ]

        // ── 节奏模块 ─────────────────────────────────────────────
        case .strummingPattern:
            // 扫弦节奏型
            return [
                QuestionItem(question: "下  下  下  上 → 哪种扫弦？", answer: 1, options: ["↓↑↓↑", "↓↓↓↑", "↑↓↑↓", "↓↓↑↓"], solfege: "1", octave: 4),
                QuestionItem(question: "上  下  上  下 → 哪种扫弦？", answer: 2, options: ["↓↑↓↑", "↓↓↓↑", "↑↓↑↓", "↑↑↓↑"], solfege: "1", octave: 4),
                QuestionItem(question: "下  下  上  下 → 哪种扫弦？", answer: 3, options: ["↓↑↓↑", "↓↓↓↑", "↑↓↑↓", "↓↓↑↓"], solfege: "1", octave: 4),
                QuestionItem(question: "上  上  下  上 → 哪种扫弦？", answer: 2, options: ["↓↑↓↑", "↓↓↓↑", "↑↑↓↑", "↑↓↓↑"], solfege: "1", octave: 4),
                QuestionItem(question: "上  下  上  上  下 → 哪种扫弦？", answer: 1, options: ["↑↓↓↑", "↑↓↓↑", "↑↓↑↓", "↓↓↑↓"], solfege: "1", octave: 4),
                QuestionItem(question: "下  下  下  下 → 哪种扫弦？", answer: 0, options: ["全下", "↓↓↓↑", "↑↓↑↓", "↓↓↑↓"], solfege: "1", octave: 4),
                QuestionItem(question: "4/4 拍中最常用的是哪种扫弦？", answer: 0, options: ["↓↑↓↑", "↓↓↓↑", "↑↓↑↓", "↓↓↑↓"], solfege: "1", octave: 4),
                QuestionItem(question: "民谣歌曲中节奏「下下下上」常用于哪种风格？", answer: 1, options: ["抒情", "流行摇滚", "爵士", "蓝草"], solfege: "1", octave: 4),
                QuestionItem(question: "「上上下上」是哪种扫弦？", answer: 0, options: ["↑↑↓↑", "↑↓↑↓", "↓↑↓↑", "↓↓↓↑"], solfege: "1", octave: 4),
                QuestionItem(question: "「上下下上」是哪种扫弦？", answer: 2, options: ["↓↑↓↑", "↑↓↑↓", "↑↓↓↑", "↓↓↑↓"], solfege: "1", octave: 4),
            ]

        case .arpeggioPattern:
            // 分解和弦节奏型
            return [
                QuestionItem(question: "分解 T-3-2-3 属于哪种节奏型？", answer: 0, options: ["分解和弦", "扫弦节奏", "切分节奏", "复合节奏"], solfege: "1", octave: 4),
                QuestionItem(question: "分解 5-3-2-1-2-3 是哪种分解？", answer: 2, options: ["T323", "T1323", "532123", "135313"], solfege: "5", octave: 4),
                QuestionItem(question: "分解 1-3-5-3-1-3 是哪种分解？", answer: 1, options: ["T323", "135313", "532123", "54321"], solfege: "1", octave: 4),
                QuestionItem(question: "分解 T-1-3-2-3 和弦根音在哪根弦？", answer: 0, options: ["第4弦(T)", "第5弦", "第3弦", "第6弦"], solfege: "1", octave: 4),
                QuestionItem(question: "分解 5-4-3-2-1 属于哪种类型？", answer: 1, options: ["T323", "54321下行", "135313", "532123"], solfege: "5", octave: 4),
                QuestionItem(question: "分解 T323 中 T 代表哪个音？", answer: 1, options: ["三音", "根音(T)", "五音", "七音"], solfege: "1", octave: 4),
                QuestionItem(question: "分解和弦常用于哪种弹唱伴奏？", answer: 2, options: ["摇滚", "金属", "抒情民谣", "进行曲"], solfege: "1", octave: 4),
                QuestionItem(question: "分解 1-2-3-2-1 是哪种分解？", answer: 3, options: ["T323", "T1323", "532123", "1321"], solfege: "1", octave: 4),
                QuestionItem(question: "分解和弦中根音、三音、五音分别对应哪个手指？", answer: 0, options: ["拇指、食指、中指", "食指、中指、无名指", "中指、无名指、小指", "拇指、中指、无名指"], solfege: "1", octave: 4),
                QuestionItem(question: "分解 5-3-2-1 常用于哪个和弦？", answer: 2, options: ["C和弦", "G和弦", "G7和弦", "Am和弦"], solfege: "5", octave: 4),
            ]

        case .metronomeStability:
            // 节拍稳定性
            return [
                QuestionItem(question: "BPM = 60，每拍是多少秒？", answer: 1, options: ["0.5秒", "1秒", "2秒", "0.25秒"], solfege: "1", octave: 4),
                QuestionItem(question: "四分音符 = 120 BPM，一小节（四拍）多少秒？", answer: 2, options: ["1秒", "2秒", "2秒", "4秒"], solfege: "1", octave: 4),
                QuestionItem(question: "BPM = 80，每分钟多少拍？", answer: 0, options: ["80拍", "40拍", "120拍", "160拍"], solfege: "1", octave: 4),
                QuestionItem(question: "八分音符 = 100 BPM，八分音符每分钟多少个？", answer: 1, options: ["50个", "200个", "100个", "400个"], solfege: "1", octave: 4),
                QuestionItem(question: "节拍器调到 4/4 拍，1 小节有几拍？", answer: 0, options: ["4拍", "3拍", "6拍", "8拍"], solfege: "1", octave: 4),
                QuestionItem(question: "3/4 拍常用于哪种音乐体裁？", answer: 1, options: ["进行曲", "圆舞曲", "摇滚", "蓝调"], solfege: "1", octave: 4),
                QuestionItem(question: "BPM = 140，每拍约多少毫秒？", answer: 2, options: ["700ms", "140ms", "428ms", "857ms"], solfege: "1", octave: 4),
                QuestionItem(question: "6/8 拍，每小节有几拍？", answer: 1, options: ["6拍", "2拍(复拍)", "8拍", "3拍"], solfege: "1", octave: 4),
                QuestionItem(question: "四分音符 = 90 BPM，音符时值 0.5 秒对应几分音符？", answer: 2, options: ["四分音符", "八分音符", "四分音符", "全音符"], solfege: "1", octave: 4),
                QuestionItem(question: "节拍稳定性训练时，优先使用哪种速度？", answer: 0, options: ["60-80 BPM(慢速)", "120-140 BPM(中速)", "180+ BPM(快速)", "随机速度"], solfege: "1", octave: 4),
            ]

        case .syncopationRecognition:
            // 切分节奏辨认
            return [
                QuestionItem(question: "切分节奏的特点是什么？", answer: 1, options: ["强拍前置", "重音移位到弱拍", "加速演奏", "均匀分拍"], solfege: "1", octave: 4),
                QuestionItem(question: "「下-上」（下拍停顿上拍）属于哪种节奏？", answer: 0, options: ["切分节奏", "均分节奏", "三连音节奏", "复节奏"], solfege: "1", octave: 4),
                QuestionItem(question: "切分音通常出现在哪个位置？", answer: 2, options: ["强拍正位", "小节首拍", "弱拍或弱位", "休止符后"], solfege: "1", octave: 4),
                QuestionItem(question: "4/4 拍「下- -上」第三拍是什么节奏型？", answer: 0, options: ["切分节奏", "三连音", "均分节奏", "复合节奏"], solfege: "1", octave: 4),
                QuestionItem(question: "切分节奏在哪种音乐中常见？", answer: 1, options: ["进行曲", "爵士/布鲁斯", "圆舞曲", "古典协奏曲"], solfege: "1", octave: 4),
                QuestionItem(question: "「- - ↓↑」是什么节奏型？", answer: 2, options: ["均分节奏", "三连音", "切分节奏", "复合节奏"], solfege: "1", octave: 4),
                QuestionItem(question: "三连音均等分割了几等分？", answer: 1, options: ["2等分", "3等分", "4等分", "5等分"], solfege: "1", octave: 4),
                QuestionItem(question: "切分节奏的核心效果是？", answer: 0, options: ["打破常规重音", "加快速度", "减慢速度", "均匀时值"], solfege: "1", octave: 4),
                QuestionItem(question: "4/4 拍中「下上-下」第三拍是什么？", answer: 1, options: ["重音", "切分音(弱位)", "休止", "强拍"], solfege: "1", octave: 4),
                QuestionItem(question: "反拍节奏（弱拍重音）属于哪种节奏型？", answer: 2, options: ["均分节奏", "三连音", "切分节奏", "复合节奏"], solfege: "1", octave: 4),
            ]

        // ── 旋律模块 ─────────────────────────────────────────────
        case .tablatureMelodySinging, .guitarMelodyRecognition, .harmonicRecognition:
            // 旋律相关：使用题库旋律数据
            return QuestionBank.melodyQuestions.prefix(10).map { q in
                let notes = q.solfege.split(separator: " ").map { String($0) }
                return QuestionItem(
                    question: "\(q.description)，旋律：\(q.solfege)",
                    answer: 0,
                    options: notes,
                    solfege: notes.first ?? "1",
                    octave: 4
                )
            }

        case .intervalSinging:
            // 音程视唱：从题库取音程，展示旋律
            return QuestionBank.intervalQuestions.prefix(10).map { q in
                return QuestionItem(
                    question: "视唱音程：\(q.name) (\(q.semitones) 半音)",
                    answer: 0,
                    options: [q.name],
                    solfege: "1",
                    octave: 4
                )
            }

        // ── 兜底 ─────────────────────────────────────────────
        default:
            return [
                QuestionItem(question: "简谱 1 对应哪个音名？", answer: 0, options: ["C", "D", "E", "G"], solfege: "1", octave: 4),
                QuestionItem(question: "第6弦空弦是什么音？", answer: 2, options: ["A", "E", "D", "G"], solfege: "3", octave: 3),
                QuestionItem(question: "C 和弦包含哪些音？", answer: 0, options: ["C-E-G", "D-F-A", "E-G-B", "F-A-C"], solfege: "1", octave: 4),
            ]
        }
    }

    /// 生成音名选项
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

    var body: some View {
        VStack(spacing: 0) {
            // 顶部导航栏
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(exercise.rawValue)
                    .font(.headline)

                Spacer()

                // 得分
                Text("\(currentScore) 分")
                    .font(.headline)
                    .foregroundStyle(AppColors.primary)
            }
            .padding()
            .background(Color(.systemBackground))

            Divider()

            // 内容区
            Group {
                switch state {
                case .question:
                    questionView
                case .feedback:
                    feedbackView
                case .finished:
                    finishedView
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
        }
        .onAppear {
            viewModel.setModelContext(modelContext)
        }
    }

    private var questionView: some View {
        VStack(spacing: 24) {
            // 进度
            HStack {
                Text("第 \(questionCount + 1) / \(questions.count) 题")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                // 练习类型标签
                Text(exercise.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray5))
                    .clipShape(Capsule())
            }
            .padding(.horizontal)

            // 题目内容区（根据题型展示不同内容）
            let current = questions[questionCount % questions.count]
            VStack(spacing: 20) {
                // 播放按钮
                Button {
                    Task {
                        await AudioEngineManager.shared.playSolfege(current.solfege, octave: current.octave)
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(AppColors.primary)
                            .frame(width: 72, height: 72)
                            .shadow(color: AppColors.primary.opacity(0.3), radius: 8, x: 0, y: 4)

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
                    .foregroundStyle(.primary)

                // 六线谱展示（用于特定题型）
                if showTabForCurrentExercise {
                    TabAndSolfegeView(
                        notes: tabNotesForCurrent,
                        solfege: current.solfege,
                        solfegeOctave: current.octave
                    )
                    .padding(.horizontal)
                }
            }
            .padding(.vertical, 8)

            Spacer()

            // 选项
            VStack(spacing: 10) {
                ForEach(Array(current.options.enumerated()), id: \.offset) { index, option in
                    Button {
                        selectAnswer(index)
                    } label: {
                        HStack {
                            // 选项序号
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
                                .foregroundStyle(.primary)

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
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }

    /// 当前练习是否应展示六线谱
    private var showTabForCurrentExercise: Bool {
        switch exercise {
        case .tablatureNoteReading, .barreChordRecognition, .commonChordRecognition,
             .chordQualityRecognition, .scaleRecognition:
            return true
        default:
            return false
        }
    }

    /// 当前题对应的六线谱音符
    private var tabNotesForCurrent: [TabNote] {
        let current = questions[questionCount % questions.count]
        // 根据题型生成代表性指法
        switch exercise {
        case .tablatureNoteReading:
            // 六线谱音符识读：展示吉他指板
            return [
                TabNote(string: 6, fret: 0, solfege: current.solfege),
            ]
        case .barreChordRecognition:
            // 大横按和弦
            return [
                TabNote(string: 6, fret: 1, solfege: "4"),
                TabNote(string: 5, fret: 1, solfege: "6"),
                TabNote(string: 4, fret: 1, solfege: "1"),
                TabNote(string: 3, fret: 1, solfege: "3"),
            ]
        case .commonChordRecognition:
            // 开放和弦
            return [
                TabNote(string: 5, fret: 0, solfege: "6"),
                TabNote(string: 4, fret: 2, solfege: "1"),
                TabNote(string: 3, fret: 2, solfege: "3"),
                TabNote(string: 2, fret: 1, solfege: "5"),
            ]
        case .chordQualityRecognition:
            return [
                TabNote(string: 5, fret: 0, solfege: "6"),
                TabNote(string: 4, fret: 2, solfege: "1"),
                TabNote(string: 3, fret: 2, solfege: "3"),
            ]
        case .scaleRecognition:
            return [
                TabNote(string: 6, fret: 0, solfege: "1"),
                TabNote(string: 6, fret: 2, solfege: "2"),
                TabNote(string: 6, fret: 4, solfege: "3"),
                TabNote(string: 5, fret: 2, solfege: "4"),
            ]
        default:
            return []
        }
    }

    /// 选项字母 A/B/C/D
    private func optionLetter(_ index: Int) -> String {
        let letters = ["A", "B", "C", "D", "E", "F"]
        return index < letters.count ? letters[index] : "\(index + 1)"
    }

    private var feedbackView: some View {
        VStack(spacing: 24) {
            Spacer()

            // 结果图标
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
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // 继续按钮
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

    private var finishedView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "star.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.yellow, Color.orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text("练习完成！")
                .font(.title)
                .fontWeight(.bold)

            Text("得分：\(currentScore) / 100")
                .font(.title2)
                .foregroundStyle(AppColors.primary)

            Text("正确率：\(correctCount)/\(questions.count)")
                .font(.body)
                .foregroundStyle(.secondary)

            Spacer()

            VStack(spacing: 12) {
                Button {
                    // 保存记录
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
                    // 重新开始
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

        // 触觉反馈
        let generator = UIImpactFeedbackGenerator(style: correct ? .medium : .heavy)
        generator.impactOccurred()

        // 延迟进入反馈或完成
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 秒
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
}

// MARK: - 吉他六线谱 + 简谱展示视图

/// 六线谱音符格：显示某根弦某个品的音符
struct TabNote: Identifiable {
    let id = UUID()
    let string: Int      // 弦号 1-6（1=最细，6=最粗）
    let fret: Int       // 品号，0=空弦
    let solfege: String // 简谱音
}

/// 六线谱展示视图（不含时值）
struct GuitarTablatureView: View {
    let notes: [TabNote]
    let highlightFret: Int? // 高亮某品

    private let lineSpacing: CGFloat = 14
    private let stringSpacing: CGFloat = 12
    private let padding: CGFloat = 16

    var body: some View {
        VStack(spacing: 0) {
            // 六条弦线
            ForEach((1...6).reversed(), id: \.self) { stringNum in
                HStack(spacing: 0) {
                    // 弦号标签
                    Text("\(stringNum)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .frame(width: 14)

                    // 弦线
                    Rectangle()
                        .fill(Color.secondary.opacity(0.4))
                        .frame(height: 1)

                    // 品丝（粗竖线）
                    Rectangle()
                        .fill(Color.secondary.opacity(0.3))
                        .frame(width: 2)
                }
                .frame(height: stringSpacing)
            }

            // 品号标签行
            HStack(spacing: 0) {
                Spacer().frame(width: 14)

                ForEach(0..<5, id: \.self) { fret in
                    Text("\(fret)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .frame(width: stringSpacing + 2)
                }
            }
            .padding(.top, 2)
        }
        .padding(padding)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

/// 六线谱 + 简谱组合展示（用于答题展示）
struct TabAndSolfegeView: View {
    let notes: [TabNote]
    let solfege: String   // 简谱数字（如 "1 3 5"）
    let solfegeOctave: Int

    var body: some View {
        VStack(spacing: 16) {
            // 简谱行
            HStack(spacing: 8) {
                Text("简谱：")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                ForEach(solfege.split(separator: " ").map(String.init), id: \.self) { s in
                    Text(s)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(AppColors.primary)
                        .frame(minWidth: 28)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .background(AppColors.primary.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                Spacer()
            }

            // 六线谱
            GuitarTablatureView(notes: notes, highlightFret: nil)
        }
    }
}

// MARK: - 吉他指板标注视图（用于音程/和弦题）

/// 和弦指法展示（圆形品位图）
struct ChordFretView: View {
    let root: String      // 根音字母
    let barreFrom: Int?   // 大横按起始品，nil 表示无横按
    let barreTo: Int?     // 大横按结束品
    let positions: [(string: Int, fret: Int, finger: Int?)] // 各弦按法

    var body: some View {
        VStack(spacing: 8) {
            // 和弦名称
            Text(root)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(AppColors.primary)

            // 六线谱品格图
            VStack(spacing: 0) {
                // 品格区（5品）
                ForEach((1...5).reversed(), id: \.self) { fretNum in
                    HStack(spacing: 0) {
                        // 品号
                        Text(fretNum == 1 ? "Ⅰ" : "\(fretNum)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .frame(width: 16)

                        // 横线（弦）
                        ForEach((1...6).reversed(), id: \.self) { stringNum in
                            Rectangle()
                                .fill(Color.secondary.opacity(0.3))
                                .frame(height: 1)
                                .frame(maxWidth: .infinity)

                            if stringNum > 1 {
                                Rectangle()
                                    .fill(Color.secondary.opacity(0.15))
                                    .frame(width: 1)
                            }
                        }
                    }
                    .frame(height: 20)
                }

                // 空弦区
                HStack(spacing: 0) {
                    Text("○")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 16)

                    ForEach((1...6).reversed(), id: \.self) { stringNum in
                        Circle()
                            .stroke(Color.secondary.opacity(0.4), lineWidth: 1)
                            .frame(width: 10, height: 10)

                        if stringNum > 1 {
                            Spacer().frame(width: 2)
                        }
                    }
                }
                .frame(height: 20)
            }
            .padding(12)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

// MARK: - 预览

#Preview {
    ExerciseDetailView(
        exercise: .singleNoteRecognition,
        module: .noteName,
        viewModel: PracticeViewModel()
    )
}
