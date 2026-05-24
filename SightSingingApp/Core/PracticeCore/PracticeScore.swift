import Foundation

/// 练习成绩
struct PracticeScore: Codable, Sendable {
    let correctCount: Int
    let totalCount: Int
    let averageTiming: Int      // 0-100
    let averagePitch: Int?      // 视唱才有 0-100
    let totalDuration: TimeInterval
    let completedAt: Date

    // MARK: - Computed

    /// 正确率百分比
    var percentage: Int {
        guard totalCount > 0 else { return 0 }
        return correctCount * 100 / totalCount
    }

    /// 评级
    var grade: PracticeGrade {
        switch percentage {
        case 95...100: return .S
        case 85..<95:  return .A
        case 70..<85:  return .B
        case 50..<70:  return .C
        default:       return .D
        }
    }

    // MARK: - Init

    init(from session: PracticeSession) {
        self.correctCount = session.correctCount
        self.totalCount = session.answers.count
        self.averageTiming = session.answers.isEmpty ? 0 : session.answers.map(\.timingAccuracy).reduce(0, +) / session.answers.count

        let pitchAnswers = session.answers.compactMap(\.pitchAccuracy)
        self.averagePitch = pitchAnswers.isEmpty ? nil : pitchAnswers.reduce(0, +) / pitchAnswers.count

        self.totalDuration = 0  // Session handles duration tracking
        self.completedAt = Date()
    }

    init(
        correctCount: Int,
        totalCount: Int,
        averageTiming: Int = 100,
        averagePitch: Int? = nil,
        totalDuration: TimeInterval = 0,
        completedAt: Date = Date()
    ) {
        self.correctCount = correctCount
        self.totalCount = totalCount
        self.averageTiming = averageTiming
        self.averagePitch = averagePitch
        self.totalDuration = totalDuration
        self.completedAt = completedAt
    }
}

/// 练习评级
enum PracticeGrade: String, Codable, Sendable {
    case S = "S"  // 卓越 (95-100%)
    case A = "A"  // 优秀 (85-94%)
    case B = "B"  // 良好 (70-84%)
    case C = "C"  // 一般 (50-69%)
    case D = "D"  // 需努力 (< 50%)

    var color: String {
        switch self {
        case .S: return "gold"
        case .A: return "green"
        case .B: return "blue"
        case .C: return "orange"
        case .D: return "red"
        }
    }

    var emoji: String {
        switch self {
        case .S: return "🌟"
        case .A: return "🎯"
        case .B: return "👍"
        case .C: return "💪"
        case .D: return "📚"
        }
    }
}
