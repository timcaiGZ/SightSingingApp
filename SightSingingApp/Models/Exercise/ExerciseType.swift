import Foundation

/// 具体练习类型枚举，围绕民谣吉他弹唱场景设计
enum ExerciseType: String, CaseIterable, Identifiable, Codable {
    // MARK: - 音名模块
    case singleNoteRecognition = "单音辨认"
    case openStringRecognition = "空弦音辨认"
    case rootNoteRecognition = "根音听辨"
    case tablatureNoteReading = "六线谱音符识读"

    // MARK: - 音程模块
    case intervalRecognition = "音程辨认"
    case fretboardIntervalComparison = "把位音程比较"
    case hammerPullInterval = "击弦/勾弦音程"

    // MARK: - 和弦模块
    case barreChordRecognition = "大横按辨认"
    case chordQualityRecognition = "和弦性质辨认"
    case chordTransitionSpeed = "和弦转换速度"
    case commonChordRecognition = "常用开放和弦辨认"

    // MARK: - 调式模块
    case scaleRecognition = "调式音阶辨认"
    case cagedSystemPractice = "CAGED各调把位"
    case commonTuningRecognition = "常用调式辨认"

    // MARK: - 节奏模块
    case strummingPattern = "扫弦节奏型"
    case arpeggioPattern = "分解和弦节奏型"
    case metronomeStability = "节拍稳定性"
    case syncopationRecognition = "切分节奏辨认"

    // MARK: - 旋律模块
    case tablatureMelodySinging = "简谱旋律视唱"
    case guitarMelodyRecognition = "吉他旋律音辨认"
    case harmonicRecognition = "泛音旋律辨认"
    case intervalSinging = "音程视唱"

    var id: String { rawValue }

    /// 所属模块
    var module: ExerciseModule {
        switch self {
        case .singleNoteRecognition, .openStringRecognition, .rootNoteRecognition, .tablatureNoteReading:
            return .noteName
        case .intervalRecognition, .fretboardIntervalComparison, .hammerPullInterval:
            return .interval
        case .barreChordRecognition, .chordQualityRecognition, .chordTransitionSpeed, .commonChordRecognition:
            return .chord
        case .scaleRecognition, .cagedSystemPractice, .commonTuningRecognition:
            return .scale
        case .strummingPattern, .arpeggioPattern, .metronomeStability, .syncopationRecognition:
            return .rhythm
        case .tablatureMelodySinging, .guitarMelodyRecognition, .harmonicRecognition, .intervalSinging:
            return .melody
        }
    }

    /// 难度等级
    var difficulty: Difficulty {
        switch self {
        case .openStringRecognition, .commonChordRecognition, .strummingPattern, .arpeggioPattern:
            return .easy
        case .singleNoteRecognition, .rootNoteRecognition, .intervalRecognition,
             .chordQualityRecognition, .scaleRecognition, .metronomeStability,
             .tablatureMelodySinging, .guitarMelodyRecognition:
            return .medium
        case .tablatureNoteReading, .fretboardIntervalComparison, .hammerPullInterval,
             .barreChordRecognition, .chordTransitionSpeed, .cagedSystemPractice,
             .commonTuningRecognition, .syncopationRecognition, .harmonicRecognition,
             .intervalSinging:
            return .hard
        }
    }
}

/// 难度等级
enum Difficulty: String, CaseIterable, Codable {
    case easy = "初级"
    case medium = "中级"
    case hard = "高级"
}

/// 题型
enum QuestionType: String, CaseIterable, Codable {
    case recognition = "辨认"        // 听辨这是什么
    case comparison = "比较"          // 比较两个音的关系
    case singing = "视唱"            // 看谱演唱
    case identification = "辨识"      // 识别节奏型/和弦类型
}
