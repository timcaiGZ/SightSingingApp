import SwiftUI

// MARK: - 五线谱视图

/// 五线谱音符
struct StaffNote: Identifiable {
    let id = UUID()
    let pitch: StaffPitch    // 音高位置
    let duration: NoteDuration  // 时值
    var accidental: Accidental?  // 临时升降号

    /// 相对C4的位置（用于计算音符Y坐标）
    var c4Offset: Int {
        var base = pitch.c4Offset
        if let acc = accidental {
            base += acc.semitoneOffset
        }
        return base
    }
}

/// 音高位置（相对于C4）
struct StaffPitch: Hashable {
    let line: Int  // 五线谱线位置，C4 = 0

    /// 在五线谱上是否在线上
    var isOnLine: Bool {
        line % 2 == 0
    }

    /// 相对C4的半音数
    var c4Offset: Int {
        line
    }

    /// 添加八度
    static func +(lhs: StaffPitch, rhs: Int) -> StaffPitch {
        StaffPitch(line: lhs.line + rhs * 7)
    }
}

/// 升降号
enum Accidental: String {
    case sharp = "♯"
    case flat = "♭"
    case natural = "♮"

    var semitoneOffset: Int {
        switch self {
        case .sharp: return 1
        case .flat: return -1
        case .natural: return 0
        }
    }
}

/// 音符时值
enum NoteDuration: String {
    case whole = "𝅝"        // 全音符
    case half = "𝅗𝅥"       // 二分音符
    case quarter = "𝅘𝅥"    // 四分音符
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

    var displaySymbol: String {
        rawValue
    }
}

/// 五线谱视图
struct StaffNotationView: View {
    let notes: [StaffNote]
    let clef: Clef  // 谱号
    let keySignature: KeySignature  // 调号
    let timeSignature: TimeSignature  // 拍号

    enum Clef: String {
        case treble = "𝄞"   // 高音谱号
        case bass = "𝄢"    // 低音谱号

        var displaySymbol: String { rawValue }
    }

    struct KeySignature {
        let root: String   // 根音
        let isSharp: Bool  // true=升号, false=降号

        static let cMajor = KeySignature(root: "C", isSharp: false)
    }

    struct TimeSignature {
        let beats: Int
        let beatType: Int

        static let fourFour = TimeSignature(beats: 4, beatType: 4)
        static let threeFour = TimeSignature(beats: 3, beatType: 4)
        static let sixEight = TimeSignature(beats: 6, beatType: 8)
    }

    init(
        notes: [StaffNote] = [],
        clef: Clef = .treble,
        keySignature: KeySignature = .cMajor,
        timeSignature: TimeSignature = .fourFour
    ) {
        self.notes = notes
        self.clef = clef
        self.keySignature = keySignature
        self.timeSignature = timeSignature
    }

    private let lineSpacing: CGFloat = 10
    private var staffHeight: CGFloat { lineSpacing * 4 }
    private let clefWidth: CGFloat = 40
    private let timeSignatureWidth: CGFloat = 30
    private let noteSpacing: CGFloat = 40
    private let marginTop: CGFloat = 60

    var body: some View {
        VStack(spacing: 0) {
            // 五线
            staffLines

            // 音符
            notesRow
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    /// 五线
    private var staffLines: some View {
        VStack(spacing: lineSpacing) {
            ForEach(0..<5, id: \.self) { _ in
                Rectangle()
                    .fill(Color(.black))
                    .frame(height: 1)
            }
        }
        .frame(height: staffHeight)
        .overlay(alignment: .leading) {
            // 谱号
            Text(clef.displaySymbol)
                .font(.system(size: 48))
                .foregroundStyle(Color(.black))
                .offset(y: clef == .treble ? -8 : 4)
        }
        .overlay(alignment: .leading) {
            // 拍号
            VStack(spacing: 0) {
                Text("\(timeSignature.beats)")
                    .font(.system(size: 16, weight: .bold))
                Text("\(timeSignature.beatType)")
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundStyle(Color(.black))
            .offset(x: clefWidth - 5, y: -2)
        }
    }

    /// 音符行
    private var notesRow: some View {
        GeometryReader { geometry in
            HStack(alignment: .center, spacing: noteSpacing) {
                ForEach(Array(notes.enumerated()), id: \.offset) { index, note in
                    noteHead(note: note)
                        .offset(y: yOffset(for: note))
                }
            }
            .padding(.leading, clefWidth + timeSignatureWidth + 10)
            .frame(maxWidth: .infinity)
        }
        .frame(height: marginTop * 2)
    }

    /// 单个音符头
    private func noteHead(note: StaffNote) -> some View {
        VStack(spacing: 2) {
            // 升降号
            if let accidental = note.accidental {
                Text(accidental.rawValue)
                    .font(.system(size: 12))
                    .foregroundStyle(Color(.black))
                    .offset(x: -12)
            }

            // 音符
            ZStack {
                // 符头
                Ellipse()
                    .fill(Color(.black))
                    .frame(width: 12, height: 9)
                    .rotationEffect(.degrees(-20))

                // 时值标记（符干）
                if note.duration != .whole {
                    Rectangle()
                        .fill(Color(.black))
                        .frame(width: 2, height: 30)
                        .offset(x: 6, y: -15)
                }
            }
        }
    }

    /// 计算音符Y偏移（相对于中线）
    private func yOffset(for note: StaffNote) -> CGFloat {
        // C4 在中线下两格
        let c4LinePosition = 2  // 中线位置
        let noteLinePosition = c4LinePosition - note.c4Offset

        return CGFloat(noteLinePosition) * (lineSpacing / 2)
    }
}

// MARK: - 音符名称标注

/// 带音符名称标注的五线谱
struct LabeledStaffNotationView: View {
    let notes: [StaffNote]
    let showNoteNames: Bool

    init(notes: [StaffNote] = [], showNoteNames: Bool = true) {
        self.notes = notes
        self.showNoteNames = showNoteNames
    }

    var body: some View {
        VStack(spacing: 8) {
            // 音符名称
            if showNoteNames {
                noteNamesRow
            }

            // 五线谱
            StaffNotationView(notes: notes)
        }
    }

    private var noteNamesRow: some View {
        HStack(spacing: 40) {
            ForEach(notes) { note in
                Text(noteName(for: note))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(AppColors.primary)
            }
        }
        .padding(.leading, 70)
    }

    private func noteName(for note: StaffNote) -> String {
        let names = ["C", "D", "E", "F", "G", "A", "B"]
        let index = ((note.c4Offset % 7) + 7) % 7
        var name = names[index]
        if let acc = note.accidental {
            name += acc.rawValue
        }
        return name
    }
}

// MARK: - 预览

#Preview {
    VStack(spacing: 30) {
        // 高音谱五线谱
        StaffNotationView(
            notes: [
                StaffNote(pitch: StaffPitch(line: 0), duration: .quarter, accidental: nil),  // C4
                StaffNote(pitch: StaffPitch(line: 2), duration: .quarter, accidental: nil),  // E4
                StaffNote(pitch: StaffPitch(line: 4), duration: .quarter, accidental: nil),  // G4
                StaffNote(pitch: StaffPitch(line: 5), duration: .half, accidental: nil),    // C5
            ]
        )

        // 带升降号
        StaffNotationView(
            notes: [
                StaffNote(pitch: StaffPitch(line: 0), duration: .quarter, accidental: .sharp),
                StaffNote(pitch: StaffPitch(line: 2), duration: .quarter, accidental: .flat),
                StaffNote(pitch: StaffPitch(line: 4), duration: .half, accidental: nil),
            ]
        )
    }
    .padding()
}
