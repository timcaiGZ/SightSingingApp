import Foundation
import SwiftUI
import SwiftData

/// 练习 Tab ViewModel
@Observable
final class PracticeViewModel {
    private var modelContext: ModelContext?

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    /// 获取指定模块的所有练习类型
    func exercises(for module: ExerciseModule) -> [ExerciseType] {
        ExerciseType.allCases.filter { $0.module == module }
    }

    /// 获取某练习类型的最佳得分
    func bestScore(for exerciseType: ExerciseType) -> Int? {
        guard let context = modelContext else { return nil }
        let descriptor = FetchDescriptor<PracticeRecord>(
            predicate: #Predicate<PracticeRecord> { $0.exerciseType == exerciseType.rawValue },
            sortBy: [SortDescriptor(\.score, order: .reverse)]
        )
        let records = (try? context.fetch(descriptor)) ?? []
        return records.first?.score
    }

    /// 获取某练习类型的练习次数
    func practiceCount(for exerciseType: ExerciseType) -> Int {
        guard let context = modelContext else { return 0 }
        let descriptor = FetchDescriptor<PracticeRecord>(
            predicate: #Predicate<PracticeRecord> { $0.exerciseType == exerciseType.rawValue }
        )
        return (try? context.fetch(descriptor))?.count ?? 0
    }

    /// 获取某模块的练习次数
    func practiceCount(for module: ExerciseModule) -> Int {
        guard let context = modelContext else { return 0 }
        let descriptor = FetchDescriptor<PracticeRecord>(
            predicate: #Predicate<PracticeRecord> { $0.module == module.rawValue }
        )
        return (try? context.fetch(descriptor))?.count ?? 0
    }

    /// 获取最近 7 天的练习记录
    func recentRecords(days: Int = 7) -> [PracticeRecord] {
        guard let context = modelContext else { return [] }
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        let descriptor = FetchDescriptor<PracticeRecord>(
            predicate: #Predicate<PracticeRecord> { $0.date >= sevenDaysAgo },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    /// 保存练习记录
    func savePracticeRecord(
        module: ExerciseModule,
        exerciseType: ExerciseType,
        score: Int,
        durationSeconds: Int
    ) {
        guard let context = modelContext else { return }
        let record = PracticeRecord(
            module: module,
            exerciseType: exerciseType,
            score: score,
            durationSeconds: durationSeconds
        )
        context.insert(record)
        try? context.save()
    }
}
