import SwiftUI

// MARK: - 吉他六线谱视图（真实精度版）

/// 六线谱音符
struct GuitarTabNote: Identifiable {
    let id = UUID()
    let string: Int      // 弦号 1-6（1=最细，6=最粗）
    let fret: Int        // 品号，0=空弦
    let technique: GuitarTechnique?  // 演奏技法
}

/// 演奏技法
enum GuitarTechnique: String {
    case hammerOn = "h"    // 击弦
    case pullOff = "p"     // 勾弦
    case slide = "s"       // 滑音
    case bend = "b"        // 推弦
    case vibrato = "v"     // 揉弦
    case tap = "t"        // 点弦
    case harmonic = "H"    // 泛音
    case muted = "x"       // 哑音

    var displaySymbol: String {
        switch self {
        case .hammerOn: return "h"
        case .pullOff: return "p"
        case .slide: return "/"
        case .bend: return "b"
        case .vibrato: return "~"
        case .tap: return "t"
        case .harmonic: return "<>"
        case .muted: return "x"
        }
    }
}

/// 吉他六线谱视图（真实精度版）
struct GuitarTablatureView: View {
    let notes: [GuitarTabNote]
    let stringCount: Int  // 弦数，默认6弦
    let fretRange: ClosedRange<Int>  // 显示的品范围
    let highlightFret: Int?  // 高亮某品

    init(
        notes: [GuitarTabNote] = [],
        stringCount: Int = 6,
        fretRange: ClosedRange<Int> = 0...5,
        highlightFret: Int? = nil
    ) {
        self.notes = notes
        self.stringCount = stringCount
        self.fretRange = fretRange
        self.highlightFret = highlightFret
    }

    private let stringSpacing: CGFloat = 18
    private let fretSpacing: CGFloat = 32
    private let padding: CGFloat = 12
    private let stringLabelWidth: CGFloat = 20

    var body: some View {
        VStack(spacing: 0) {
            // 品号行
            fretNumberRow

            // 六条弦线
            ForEach((1...stringCount).reversed(), id: \.self) { stringNum in
                stringRow(stringNumber: stringNum)
            }

            // 品格指示
            fretIndicatorsRow
        }
        .padding(padding)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    /// 品号行
    private var fretNumberRow: some View {
        HStack(spacing: 0) {
            // 空出弦号标签区域
            Color.clear
                .frame(width: stringLabelWidth, height: 16)

            ForEach(fretRange, id: \.self) { fret in
                Text(fret == 0 ? "○" : "\(fret)")
                    .font(.caption2)
                    .foregroundStyle(AppColors.secondaryText)
                    .frame(width: fretSpacing)
            }
        }
        .padding(.bottom, 4)
    }

    /// 单根弦
    private func stringRow(stringNumber: Int) -> some View {
        HStack(spacing: 0) {
            // 弦号标签
            Text("\(stringNumber)")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(stringColor(for: stringNumber))
                .frame(width: stringLabelWidth)

            // 弦线 + 音符
            ZStack(alignment: .leading) {
                // 弦线
                Rectangle()
                    .fill(stringColor(for: stringNumber))
                    .frame(height: stringThickness(for: stringNumber))

                // 音符/品位标记
                ForEach(notes.filter { $0.string == stringNumber }) { note in
                    noteMarker(note: note, stringNumber: stringNumber)
                        .offset(x: CGFloat(note.fret) * fretSpacing + fretSpacing / 2)
                }
            }
            .frame(height: stringSpacing)
        }
    }

    /// 音符/品位标记
    private func noteMarker(note: GuitarTabNote, stringNumber: Int) -> some View {
        ZStack {
            if note.fret == 0 {
                // 空弦标记 - 圆圈
                Circle()
                    .stroke(stringColor(for: stringNumber), lineWidth: 2)
                    .frame(width: 14, height: 14)
            } else {
                // 品内音符 - 实心圆点 + 品位数字
                VStack(spacing: 2) {
                    // 品位数字
                    Text("\(note.fret)")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(AppColors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 3))

                    // 技法标记（如果有）
                    if let technique = note.technique {
                        Text(technique.displaySymbol)
                            .font(.system(size: 8, weight: .medium))
                            .foregroundStyle(AppColors.secondaryText)
                    }
                }
            }
        }
        .offset(x: -7) // 居中偏移
    }

    /// 品格指示行（显示把位）
    private var fretIndicatorsRow: some View {
        HStack(spacing: 0) {
            Color.clear
                .frame(width: stringLabelWidth, height: 16)

            ForEach(fretRange, id: \.self) { fret in
                // 品丝线
                Rectangle()
                    .fill(Color(.systemGray3))
                    .frame(width: 1, height: 12)

                if fret < fretRange.upperBound {
                    Spacer()
                        .frame(width: fretSpacing - 1)
                }
            }
        }
        .padding(.top, 4)
    }

    /// 弦号对应颜色（1=最细到6=最粗）
    private func stringColor(for stringNumber: Int) -> Color {
        let colors: [Color] = [
            Color(.systemGray),      // 1弦 - E
            Color(.systemGray2),     // 2弦 - B
            Color(.systemGray),      // 3弦 - G
            Color(.systemGray2),     // 4弦 - D
            Color(.systemGray),      // 5弦 - A
            Color(.systemGray2)      // 6弦 - E
        ]
        return colors[stringNumber - 1]
    }

    /// 弦粗细（高音弦细，低音弦粗）
    private func stringThickness(for stringNumber: Int) -> CGFloat {
        let thickness: [CGFloat] = [0.5, 0.7, 0.9, 1.1, 1.3, 1.5]
        return thickness[stringNumber - 1]
    }
}

// MARK: - 简化的六线谱行（用于视唱练习）

/// 简化六线谱行（单音符）
struct SimpleGuitarTabRow: View {
    let notes: [GuitarTabNote]
    let highlightedString: Int?
    let highlightedFret: Int?

    init(
        notes: [GuitarTabNote] = [],
        highlightedString: Int? = nil,
        highlightedFret: Int? = nil
    ) {
        self.notes = notes
        self.highlightedString = highlightedString
        self.highlightedFret = highlightedFret
    }

    private let stringSpacing: CGFloat = 14
    private let noteSize: CGFloat = 20

    var body: some View {
        HStack(spacing: 0) {
            ForEach((1...6).reversed(), id: \.self) { stringNum in
                ZStack {
                    // 弦线
                    Rectangle()
                        .fill(Color(.systemGray3))
                        .frame(height: 0.8)

                    // 音符
                    if let note = notes.first(where: { $0.string == stringNum }) {
                        noteCircle(note: note, stringNumber: stringNum)
                    }
                }
                .frame(width: stringSpacing)
            }
        }
        .frame(height: stringSpacing * 6)
        .padding(.horizontal, 8)
    }

    private func noteCircle(note: GuitarTabNote, stringNumber: Int) -> some View {
        ZStack {
            if note.fret == 0 {
                // 空弦
                Circle()
                    .stroke(AppColors.primary, lineWidth: 1.5)
                    .frame(width: noteSize, height: noteSize)
            } else {
                // 按弦
                Circle()
                    .fill(
                        highlightedFret == note.fret ?
                        AppColors.success : AppColors.primary
                    )
                    .frame(width: noteSize, height: noteSize)

                if note.technique != nil {
                    Text(note.technique!.displaySymbol)
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
        }
    }
}

// MARK: - 和弦指法图

/// 和弦指法展示
struct GuitarChordDiagram: View {
    let chordName: String
    let notes: [GuitarTabNote]
    let BarreInfo: BarreInfo?

    struct BarreInfo {
        let fromFret: Int
        let fromString: Int
        let toString: Int
    }

    init(chordName: String, notes: [GuitarTabNote], barreInfo: BarreInfo? = nil) {
        self.chordName = chordName
        self.notes = notes
        self.BarreInfo = barreInfo
    }

    var body: some View {
        VStack(spacing: 8) {
            // 和弦名
            Text(chordName)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(AppColors.primary)

            // 六线谱图
            GuitarTablatureView(
                notes: notes,
                stringCount: 6,
                fretRange: 0...5
            )
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
