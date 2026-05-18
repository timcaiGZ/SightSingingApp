import Foundation

/// 难度属性协议
protocol DifficultyProvidable {
    var difficulty: Difficulty { get }
}

// MARK: - Array 扩展

extension Array where Element: Hashable {
    /// 去除重复元素，保持原有顺序
    func removingDuplicates() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}

final class TestEngine {
    
    /// 生成一套完整的诊断测试（30题，每维度5题）
    static func generateDiagnosticTest() -> [TestQuestion] {
        var allQuestions: [TestQuestion] = []
        
        for module in ExerciseModule.allCases {
            let questions = generateQuestionsForModule(module, count: 5)
            allQuestions.append(contentsOf: questions)
        }
        
        // 打乱题目顺序
        return allQuestions.shuffled()
    }
    
    /// 为指定模块生成测试题
    private static func generateQuestionsForModule(_ module: ExerciseModule, count: Int) -> [TestQuestion] {
        var questions: [TestQuestion] = []
        
        switch module {
        case .noteName:
            questions = generateNoteNameQuestions(count: count)
        case .interval:
            questions = generateIntervalQuestions(count: count)
        case .chord:
            questions = generateChordQuestions(count: count)
        case .scale:
            questions = generateScaleQuestions(count: count)
        case .rhythm:
            questions = generateRhythmQuestions(count: count)
        case .melody:
            questions = generateMelodyQuestions(count: count)
        }
        
        return Array(questions.prefix(count))
    }
    
    // MARK: - 各模块题目生成（按难度均衡抽取）

    /// 按难度均衡随机抽取（使用泛型约束，编译时类型安全）
    private static func balancedRandom抽取<T: DifficultyProvidable>(
        from questions: [T],
        difficulty: Difficulty,
        count: Int
    ) -> [T] {
        Array(questions.filter { $0.difficulty == difficulty }
                .shuffled()
                .prefix(count))
    }
    
    /// 组合抽取（按比例：初级1题:中级2题:高级2题）
    private static func generateBalancedQuestions<T: DifficultyProvidable>(
        from questions: [T],
        total: Int = 5
    ) -> [T] {
        let easy = balancedRandom抽取(from: questions, difficulty: .easy, count: 1)
        let medium = balancedRandom抽取(from: questions, difficulty: .medium, count: 2)
        let hard = balancedRandom抽取(from: questions, difficulty: .hard, count: 2)
        return (easy + medium + hard).shuffled()
    }
    
    private static func generateNoteNameQuestions(count: Int) -> [TestQuestion] {
        let questions = generateBalancedQuestions(from: QuestionBank.noteNameQuestions, total: count)
        
        return questions.enumerated().map { index, question in
            let allNotes = QuestionBank.noteNameQuestions
                .map { $0.noteName }
                .removingDuplicates()
            
            let targetNote = question.noteName
            let wrongNotes = allNotes.filter { $0 != targetNote }.shuffled().prefix(3)
            var options = wrongNotes.map { TestOption(label: $0) }
            options.append(TestOption(label: targetNote))
            options.shuffle()
            
            let correctIndex = options.firstIndex { $0.label == targetNote } ?? 0
            
            return TestQuestion(
                dimension: .noteName,
                difficulty: question.difficulty,
                questionType: .recognition,
                prompt: "听辨这个音（简谱 \(question.solfege)）",
                audioNote: question.solfege,
                options: options,
                correctAnswerIndex: correctIndex
            )
        }
    }
    
    private static func generateIntervalQuestions(count: Int) -> [TestQuestion] {
        let questions = generateBalancedQuestions(from: QuestionBank.intervalQuestions, total: count)
        
        return questions.map { question in
            let allIntervals = QuestionBank.intervalQuestions
                .map { $0.name }
                .removingDuplicates()
            
            let targetInterval = question.name
            let wrongIntervals = allIntervals.filter { $0 != targetInterval }.shuffled().prefix(3)
            var options = wrongIntervals.map { TestOption(label: $0) }
            options.append(TestOption(label: targetInterval))
            options.shuffle()
            
            let correctIndex = options.firstIndex { $0.label == targetInterval } ?? 0
            
            return TestQuestion(
                dimension: .interval,
                difficulty: question.difficulty,
                questionType: .recognition,
                prompt: "听辨这个音程（\(question.shortName)）",
                audioNote: question.shortName,
                options: options,
                correctAnswerIndex: correctIndex
            )
        }
    }
    
    private static func generateChordQuestions(count: Int) -> [TestQuestion] {
        let questions = generateBalancedQuestions(from: QuestionBank.chordQuestions, total: count)
        
        return questions.map { question in
            let allChords = QuestionBank.chordQuestions
                .map { $0.name }
                .removingDuplicates()
            
            let targetChord = question.name
            let wrongChords = allChords.filter { $0 != targetChord }.shuffled().prefix(3)
            
            var options: [TestOption] = wrongChords.map { chordName in
                // 尝试获取六线谱数据
                if let tab = MusicTheory.openChords.first(where: { $0.name == chordName.replacingOccurrences(of: "(大横按)", with: "") }) {
                    return TestOption(label: chordName, tabData: tab.tab)
                }
                return TestOption(label: chordName)
            }
            
            if let tab = MusicTheory.openChords.first(where: { $0.name == targetChord.replacingOccurrences(of: "(大横按)", with: "") }) {
                options.append(TestOption(label: targetChord, tabData: tab.tab))
            } else {
                options.append(TestOption(label: targetChord))
            }
            
            options.shuffle()
            let correctIndex = options.firstIndex { $0.label == targetChord } ?? 0
            
            return TestQuestion(
                dimension: .chord,
                difficulty: question.difficulty,
                questionType: .recognition,
                prompt: "听辨这个和弦（\(targetChord)）",
                audioNote: targetChord,
                options: options,
                correctAnswerIndex: correctIndex
            )
        }
    }
    
    private static func generateScaleQuestions(count: Int) -> [TestQuestion] {
        let questions = generateBalancedQuestions(from: QuestionBank.scaleQuestions, total: count)
        
        return questions.map { question in
            let allScales = QuestionBank.scaleQuestions
                .map { $0.name }
                .removingDuplicates()
            
            let targetScale = question.name
            let wrongScales = allScales.filter { $0 != targetScale }.shuffled().prefix(3)
            var options = wrongScales.map { TestOption(label: $0) }
            options.append(TestOption(label: targetScale))
            options.shuffle()
            
            let correctIndex = options.firstIndex { $0.label == targetScale } ?? 0
            
            return TestQuestion(
                dimension: .scale,
                difficulty: question.difficulty,
                questionType: .identification,
                prompt: "这是哪个调式？（根音: \(question.root)）",
                audioNote: targetScale,
                options: options,
                correctAnswerIndex: correctIndex
            )
        }
    }
    
    private static func generateRhythmQuestions(count: Int) -> [TestQuestion] {
        let questions = generateBalancedQuestions(from: QuestionBank.rhythmQuestions, total: count)
        
        return questions.map { question in
            let allPatterns = QuestionBank.rhythmQuestions
                .map { $0.name }
                .removingDuplicates()
            
            let targetPattern = question.name
            let wrongPatterns = allPatterns.filter { $0 != targetPattern }.shuffled().prefix(3)
            var options = wrongPatterns.map { TestOption(label: $0) }
            options.append(TestOption(label: targetPattern))
            options.shuffle()
            
            let correctIndex = options.firstIndex { $0.label == targetPattern } ?? 0
            
            return TestQuestion(
                dimension: .rhythm,
                difficulty: question.difficulty,
                questionType: .identification,
                prompt: "这是什么节奏型？（\(question.notation)）",
                audioNote: targetPattern,
                options: options,
                correctAnswerIndex: correctIndex
            )
        }
    }
    
    private static func generateMelodyQuestions(count: Int) -> [TestQuestion] {
        let questions = generateBalancedQuestions(from: QuestionBank.melodyQuestions, total: count)
        
        return questions.map { question in
            let allMelodies = QuestionBank.melodyQuestions
                .map { $0.solfege }
                .removingDuplicates()
            
            let targetMelody = question.solfege
            let wrongMelodies = allMelodies.filter { $0 != targetMelody }.shuffled().prefix(3)
            var options = wrongMelodies.map { TestOption(label: $0) }
            options.append(TestOption(label: targetMelody))
            options.shuffle()
            
            let correctIndex = options.firstIndex { $0.label == targetMelody } ?? 0
            
            return TestQuestion(
                dimension: .melody,
                difficulty: question.difficulty,
                questionType: .recognition,
                prompt: "听辨这段旋律（\(question.description)）",
                audioNote: targetMelody,
                options: options,
                correctAnswerIndex: correctIndex
            )
        }
    }
    
    // MARK: - 结果计算
    
    /// 计算测试结果
    static func calculateResult(
        questions: [TestQuestion],
        answers: [UUID: Int],
        responseTimes: [UUID: Double]
    ) -> TestResult {
        var dimensionStats: [ExerciseModule: (correct: Int, total: Int, totalTime: Double)] = [:]
        
        // 初始化
        for module in ExerciseModule.allCases {
            dimensionStats[module] = (correct: 0, total: 0, totalTime: 0)
        }
        
        // 统计每维度
        for question in questions {
            guard let module = question.dimensionValue else { continue }
            guard var stats = dimensionStats[module] else { continue }
            
            stats.total += 1
            
            if let selectedIndex = answers[question.id],
               selectedIndex == question.correctAnswerIndex {
                stats.correct += 1
            }
            
            if let responseTime = responseTimes[question.id] {
                stats.totalTime += responseTime
            }
            
            dimensionStats[module] = stats
        }
        
        // 计算维度得分
        var dimensionScores: [ExerciseModule: DimensionScore] = [:]
        for (module, stats) in dimensionStats {
            let correctRate = stats.total > 0 ? Double(stats.correct) / Double(stats.total) : 0
            let avgTime = stats.total > 0 ? stats.totalTime / Double(stats.total) : 0
            
            // 综合得分 = 正确率×0.7 + (1-归一化反应时间)×0.3
            let normalizedTime = min(avgTime / 3.0, 1.0) // 3秒为满分反应时间
            let score = Int((correctRate * 0.7 + (1 - normalizedTime) * 0.3) * 100)
            
            dimensionScores[module] = DimensionScore(
                module: module,
                correctRate: correctRate,
                avgResponseTime: avgTime,
                score: score,
                questionCount: stats.total,
                correctCount: stats.correct
            )
        }
        
        // 计算总分
        let totalScore = dimensionScores.isEmpty ? 0 :
            dimensionScores.values.reduce(0) { $0 + $1.score } / dimensionScores.count
        
        // 生成推荐
        let recommendations = RecommendationEngine.generateRecommendations(dimensionScores: dimensionScores)
        
        // 总耗时
        let totalDuration = responseTimes.values.reduce(0, +)
        
        return TestResult(
            totalScore: totalScore,
            dimensionScores: dimensionScores,
            recommendations: recommendations,
            totalDurationSeconds: Int(totalDuration)
        )
    }
}
