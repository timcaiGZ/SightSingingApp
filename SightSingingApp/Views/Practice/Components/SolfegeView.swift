import SwiftUI

// MARK: - 简谱视图

/// 简谱音符
struct SolfegeNote: Identifiable {
    let id = UUID()
    let solfege: String      // 简谱数字：1-7
    let octave: Int          // 八度：低音3-高音7
    let duration: NoteValue // 时值
    var isRest: Bool = false  // 是否为休止符

    /// 显示文本
    var displayText: String {
        isRest ? "0" : solfege
    }

    /// 八度点位置
    var octaveDotPosition: OctaveDotPosition {
        if octave >= 5 {
            return .above
        } else if octave <= 3 {
            return .below
        }
        return .none
    }
}

/// 八度点位置
enum OctaveDotPosition {
    case above   // 高音点（在数字上方）
    case below   // 低音点（在数字下方）
    case none    // 无点
}

/// 简谱时值
enum NoteValue: String {
    case whole = "𝅝"       // 全音符
    case half = "𝅗𝅥"        // 二分音符
    case quarter = ""      // 四分音符
    case eighth = "𝅘𝅥𝅮"   // 八分音符
    case sixteenth = "𝅘𝅥𝅯" // 十六分音符

    var beatValue: Double {
        switch self {
        case .whole: return 4.0
        case .half: return 2.0
        case .quarter: return 1.0
        case .eighth: return 0.5
        case .sixteenth: return 0.25
        }
    }

    /// 添加减时线
    func withDash(count: Int) -> String {
        String(repeating: "-", count: count)
    }
    
    /// 转换为五线谱时值
    func toNoteDuration() -> NoteDuration {
        switch self {
        case .whole: return .whole
        case .half: return .half
        case .quarter: return .quarter
        case .eighth: return .eighth
        case .sixteenth: return .sixteenth
        }
    }
}

/// 简谱视图
struct SolfegeView: View {
    let notes: [SolfegeNote]
    let keySignature: String  // 调号（如 "1=C"）
    let timeSignature: String // 拍号（如 "4/4"）
    let highlightedIndex: Int?  // 高亮的音符索引

    init(
        notes: [SolfegeNote] = [],
        keySignature: String = "1=C",
        timeSignature: String = "4/4",
        highlightedIndex: Int? = nil
    ) {
        self.notes = notes
        self.keySignature = keySignature
        self.timeSignature = timeSignature
        self.highlightedIndex = highlightedIndex
    }

    var body: some View {
        VStack(spacing: 16) {
            // 调号和拍号
            headerView

            // 简谱行
            notesRow
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    /// 调号拍号头部
    private var headerView: some View {
        HStack {
            Text(keySignature)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(AppColors.primary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(AppColors.primary.opacity(0.1))
                .clipShape(Capsule())

            Spacer()

            Text(timeSignature)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(AppColors.secondaryText)
        }
    }

    /// 简谱音符行
    private var notesRow: some View {
        HStack(spacing: 0) {
            ForEach(Array(notes.enumerated()), id: \.offset) { tuple in
                let index = tuple.offset
                let note = tuple.element
                SolfegeNoteView(
                    note: note,
                    isHighlighted: index == highlightedIndex
                )

                // 音符间隔
                if index < notes.count - 1 {
                    Rectangle()
                        .fill(AppColors.separator)
                        .frame(width: 2, height: 40)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

/// 单个简谱音符视图
struct SolfegeNoteView: View {
    let note: SolfegeNote
    let isHighlighted: Bool

    var body: some View {
        VStack(spacing: 4) {
            // 高音点
            if note.octaveDotPosition == .above {
                HStack(spacing: 2) {
                    ForEach(0..<octaveDotCount, id: \.self) { _ in
                        Circle()
                            .fill(isHighlighted ? AppColors.primary : AppColors.secondaryText)
                            .frame(width: 4, height: 4)
                    }
                }
            }

            // 音符数字
            Text(note.displayText)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(
                    isHighlighted ? AppColors.primary :
                    note.isRest ? AppColors.secondaryText : AppColors.primaryText
                )
                .frame(minWidth: 44)
                .padding(.vertical, 8)
                .padding(.horizontal, 4)
                .background(
                    isHighlighted ?
                    AppColors.primary.opacity(0.1) :
                    Color.clear
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))

            // 低音点
            if note.octaveDotPosition == .below {
                HStack(spacing: 2) {
                    ForEach(0..<octaveDotCount, id: \.self) { _ in
                        Circle()
                            .fill(isHighlighted ? AppColors.primary : AppColors.secondaryText)
                            .frame(width: 4, height: 4)
                    }
                }
            }

            // 时值标记
            if !note.isRest {
                Text(durationText)
                    .font(.caption)
                    .foregroundStyle(AppColors.secondaryText)
            }
        }
    }

    private var octaveDotCount: Int {
        abs(note.octave - 4)
    }

    private var durationText: String {
        switch note.duration.beatValue {
        case 4.0: return "四拍"
        case 2.0: return "二拍"
        case 1.0: return "一拍"
        case 0.5: return "半拍"
        case 0.25: return "1/4拍"
        default: return "\(note.duration.beatValue)拍"
        }
    }
}

// MARK: - 紧凑版简谱行

/// 紧凑版简谱（用于视唱练习）
struct CompactSolfegeRow: View {
    let notes: [SolfegeNote]
    let highlightedIndex: Int?
    let compact: Bool

    init(notes: [SolfegeNote] = [], highlightedIndex: Int? = nil, compact: Bool = true) {
        self.notes = notes
        self.highlightedIndex = highlightedIndex
        self.compact = compact
    }

    var body: some View {
        HStack(spacing: compact ? 8 : 16) {
            ForEach(Array(notes.enumerated()), id: \.offset) { tuple in
                let index = tuple.offset
                let note = tuple.element
                CompactSolfegeNote(
                    note: note,
                    isHighlighted: index == highlightedIndex,
                    compact: compact
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

/// 紧凑版单音符
struct CompactSolfegeNote: View {
    let note: SolfegeNote
    let isHighlighted: Bool
    let compact: Bool

    var body: some View {
        VStack(spacing: 4) {
            Text(note.displayText)
                .font(compact ? .system(size: 28, weight: .bold, design: .rounded) : .system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(
                    isHighlighted ? AppColors.primary :
                    note.isRest ? AppColors.secondaryText : AppColors.primaryText
                )
                .scaleEffect(isHighlighted ? 1.2 : 1.0)
                .animation(.spring(response: 0.3), value: isHighlighted)

            // 八度标记
            if note.octave >= 5 {
                HStack(spacing: 1) {
                    ForEach(0..<min(note.octave - 4, 2), id: \.self) { _ in
                        Circle()
                            .fill(isHighlighted ? AppColors.primary : AppColors.secondaryText)
                            .frame(width: 4, height: 4)
                    }
                }
            } else if note.octave <= 3 {
                HStack(spacing: 1) {
                    ForEach(0..<min(4 - note.octave, 2), id: \.self) { _ in
                        Circle()
                            .fill(isHighlighted ? AppColors.primary : AppColors.secondaryText)
                            .frame(width: 4, height: 4)
                    }
                }
            }
        }
        .frame(minWidth: compact ? 28 : 44)
        .padding(.vertical, 4)
        .padding(.horizontal, 2)
        .background(
            isHighlighted ?
            AppColors.primary.opacity(0.1) :
            Color.clear
        )
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

// MARK: - 预览

#Preview {
    VStack(spacing: 20) {
        // 标准简谱
        SolfegeView(
            notes: [
                SolfegeNote(solfege: "1", octave: 4, duration: .quarter),
                SolfegeNote(solfege: "2", octave: 4, duration: .quarter),
                SolfegeNote(solfege: "3", octave: 4, duration: .half),
                SolfegeNote(solfege: "5", octave: 4, duration: .quarter),
                SolfegeNote(solfege: "5", octave: 4, duration: .quarter),
                SolfegeNote(solfege: "3", octave: 4, duration: .half),
            ],
            keySignature: "1=C",
            timeSignature: "4/4",
            highlightedIndex: 2
        )

        // 高音简谱
        CompactSolfegeRow(
            notes: [
                SolfegeNote(solfege: "1", octave: 5, duration: .quarter),
                SolfegeNote(solfege: "3", octave: 5, duration: .quarter),
                SolfegeNote(solfege: "5", octave: 5, duration: .half),
            ],
            highlightedIndex: 1
        )

        // 低音简谱
        CompactSolfegeRow(
            notes: [
                SolfegeNote(solfege: "6", octave: 3, duration: .quarter),
                SolfegeNote(solfege: "4", octave: 3, duration: .quarter),
                SolfegeNote(solfege: "2", octave: 3, duration: .half),
            ],
            highlightedIndex: 0
        )
    }
    .padding()
}
