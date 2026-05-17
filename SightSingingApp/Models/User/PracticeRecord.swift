import Foundation
import SwiftData

/// 练习记录，SwiftData 持久化
@Model
final class PracticeRecord {
    var id: UUID
    var date: Date
    var module: String       // ExerciseModule.rawValue
    var exerciseType: String  // ExerciseType.rawValue
    var score: Int           // 0-100
    var durationSeconds: Int // 练习时长（秒）

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        module: ExerciseModule,
        exerciseType: ExerciseType,
        score: Int,
        durationSeconds: Int
    ) {
        self.id = id
        self.date = date
        self.module = module.rawValue
        self.exerciseType = exerciseType.rawValue
        self.score = score
        self.durationSeconds = durationSeconds
    }

    var exerciseModule: ExerciseModule? {
        ExerciseModule(rawValue: module)
    }

    var exerciseTypeValue: ExerciseType? {
        ExerciseType(rawValue: exerciseType)
    }
}
