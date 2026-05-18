import Foundation
import SwiftUI
import SwiftData

/// 我的 Tab ViewModel
@Observable
final class ProfileViewModel {
    private var modelContext: ModelContext?

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    // MARK: - 主题设置

    var colorScheme: ColorScheme? {
        get {
            let rawValue = UserDefaults.standard.integer(forKey: "colorScheme")
            switch rawValue {
            case 1: return .light
            case 2: return .dark
            default: return nil
            }
        }
        set {
            let rawValue: Int
            switch newValue {
            case .light: rawValue = 1
            case .dark: rawValue = 2
            case nil: rawValue = 0
            @unknown default: rawValue = 0
            }
            UserDefaults.standard.set(rawValue, forKey: "colorScheme")
        }
    }

    var themeDisplayName: String {
        switch colorScheme {
        case .light: return "浅色模式"
        case .dark: return "深色模式"
        case nil: return "跟随系统"
        @unknown default: return "跟随系统"
        }
    }

    // MARK: - 音频设置

    var metronomeEnabled: Bool {
        get { UserDefaults.standard.object(forKey: "metronomeEnabled") as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: "metronomeEnabled") }
    }
    var metronomeVolume: Double {
        get { UserDefaults.standard.object(forKey: "metronomeVolume") as? Double ?? 0.5 }
        set { UserDefaults.standard.set(newValue, forKey: "metronomeVolume") }
    }

    // MARK: - 学习统计

    struct WeekOverview {
        let date: Date
        let practiceMinutes: Int
        let averageScore: Int
        let practiceCount: Int
    }

    func weekOverview(days: Int = 7) -> [WeekOverview] {
        guard let context = modelContext else { return [] }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        var result: [WeekOverview] = []

        for i in 0..<days {
            guard let date = calendar.date(byAdding: .day, value: -i, to: today) else { continue }
            let nextDate = calendar.date(byAdding: .day, value: 1, to: date)!

            let descriptor = FetchDescriptor<PracticeRecord>(
                predicate: #Predicate<PracticeRecord> { $0.date >= date && $0.date < nextDate }
            )
            let records = (try? context.fetch(descriptor)) ?? []

            let totalMinutes = records.reduce(0) { $0 + $1.durationSeconds } / 60
            let avgScore = records.isEmpty ? 0 : records.reduce(0) { $0 + $1.score } / records.count

            result.append(WeekOverview(
                date: date,
                practiceMinutes: totalMinutes,
                averageScore: avgScore,
                practiceCount: records.count
            ))
        }

        return result.reversed()
    }

    // MARK: - 模块得分趋势

    func moduleScoreTrend(module: ExerciseModule, days: Int = 30) -> [(date: Date, score: Int)] {
        guard let context = modelContext else { return [] }

        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()

        let descriptor = FetchDescriptor<PracticeRecord>(
            predicate: #Predicate<PracticeRecord> {
                $0.module == module.rawValue && $0.date >= thirtyDaysAgo
            },
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )

        let records = (try? context.fetch(descriptor)) ?? []
        return records.map { (date: $0.date, score: $0.score) }
    }

    // MARK: - 练习日历

    func practiceDates(in month: Date) -> Set<Date> {
        guard let context = modelContext else { return [] }

        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: month)
        guard let startOfMonth = calendar.date(from: components),
              let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else {
            return []
        }

        let descriptor = FetchDescriptor<PracticeRecord>(
            predicate: #Predicate<PracticeRecord> {
                $0.date >= startOfMonth && $0.date <= endOfMonth
            }
        )

        let records = (try? context.fetch(descriptor)) ?? []
        return Set(records.map { calendar.startOfDay(for: $0.date) })
    }

    // MARK: - 总计数据

    struct TotalStats {
        let totalPracticeMinutes: Int
        let totalPracticeCount: Int
        let averageScore: Int
        let testCount: Int
    }

    func totalStats() -> TotalStats {
        guard let context = modelContext else {
            return TotalStats(totalPracticeMinutes: 0, totalPracticeCount: 0, averageScore: 0, testCount: 0)
        }

        let practiceDescriptor = FetchDescriptor<PracticeRecord>()
        let records = (try? context.fetch(practiceDescriptor)) ?? []

        let testDescriptor = FetchDescriptor<TestHistory>()
        let tests = (try? context.fetch(testDescriptor)) ?? []

        let totalMinutes = records.reduce(0) { $0 + $1.durationSeconds } / 60
        let avgScore = records.isEmpty ? 0 : records.reduce(0) { $0 + $1.score } / records.count

        return TotalStats(
            totalPracticeMinutes: totalMinutes,
            totalPracticeCount: records.count,
            averageScore: avgScore,
            testCount: tests.count
        )
    }
}
