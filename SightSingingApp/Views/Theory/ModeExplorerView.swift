import SwiftUI

// MARK: - 调式探索器

struct ModeExplorerView: View {
    @State private var rootNote: String = "C"
    @State private var selectedMode: ModeInfo = ModeInfo.allModes[0]
    @State private var selectedChord: String?

    private let roots = MusicTheoryHelper.chromatic
    private let modes = ModeInfo.allModes

    var scaleNotes: [ScaleNote] {
        let ri = MusicTheoryHelper.noteIndex(rootNote)
        let preferFlat = ["F","Bb","Eb","Ab","Db","Gb"].contains(rootNote)
        return selectedMode.intervals.map { semi in
            let idx = (ri + semi + 12) % 12
            let note = preferFlat ? MusicTheoryHelper.flatNames[idx] : MusicTheoryHelper.chromatic[idx]
            let isRoot = semi == 0
            let isCharNote = semi == selectedMode.intervals[selectedMode.intervals.count > 3 ? 3 : 2]
            return ScaleNote(note: note, isRoot: isRoot, isCharacter: isCharNote && !isRoot)
        }
    }

    var diatonicChords: [(degree: String, chord: String, quality: String)] {
        let qualities: [String] = {
            switch selectedMode.id {
            case "major": return ["","m","m","","","m","dim"]
            case "dorian": return ["m","m","","","m","dim",""]
            case "phrygian": return ["m","","","m","dim","","m"]
            case "lydian": return ["","","m","dim","","m","m"]
            case "mixolydian": return ["","m","dim","","m","m",""]
            case "minor": return ["m","dim","","m","m","",""]
            case "locrian": return ["dim","","","m","","m","m"]
            default: return ["","m","m","","","m","dim"]
            }
        }()

        let degLabels: [String] = ["Ⅰ","Ⅱ","Ⅲ","Ⅳ","Ⅴ","Ⅵ","Ⅶ"]

        return zip(scaleNotes, qualities).enumerated().map { i, pair in
            let chord = pair.0.note + pair.1
            let deg = degLabels[i] + (pair.1.isEmpty ? "" : pair.1)
            return (deg, chord, pair.1)
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 根音选择
                rootSelector

                // 调式列表
                modeSelector

                // 音阶展示
                scaleDisplay

                // 调式信息
                modeInfoCard

                // 顺阶和弦
                diatonicChordsDisplay

                // 对比提示
                comparisonTip
            }
            .padding(16)
        }
        .background(AppTheme.background)
        .navigationTitle("调式探索器")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - 根音选择

    private var rootSelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("根音")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppTheme.secondaryText)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(roots, id: \.self) { root in
                        Button {
                            withAnimation { rootNote = root }
                        } label: {
                            Text(root)
                                .font(.system(size: 14, weight: .medium, design: .monospaced))
                                .foregroundStyle(rootNote == root ? .white : AppTheme.secondaryText)
                                .frame(width: 40, height: 36)
                                .background(rootNote == root ? AppTheme.accent : AppTheme.mutedBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
            }
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
    }

    // MARK: - 调式选择

    private var modeSelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("调式")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppTheme.secondaryText)

            ForEach(modes) { mode in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { selectedMode = mode }
                } label: {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(mode.color)
                            .frame(width: 10, height: 10)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(mode.name) \(mode.chineseName)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(selectedMode.id == mode.id ? mode.color : AppTheme.primaryText)
                            Text(mode.feel)
                                .font(.system(size: 12))
                                .foregroundStyle(AppTheme.tertiaryText)
                        }

                        Spacer()

                        if selectedMode.id == mode.id {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(mode.color)
                        }
                    }
                    .padding(10)
                    .background(selectedMode.id == mode.id ? mode.color.opacity(0.08) : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
    }

    // MARK: - 音阶展示

    private var scaleDisplay: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("\(rootNote) \(selectedMode.chineseName) 音阶")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(selectedMode.color)

            HStack(spacing: 6) {
                ForEach(scaleNotes) { note in
                    VStack(spacing: 3) {
                        Text(note.note)
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundStyle(note.isRoot ? .white : (note.isCharacter ? selectedMode.color : AppTheme.primaryText))
                            .frame(width: 42, height: 42)
                            .background(
                                note.isRoot ? selectedMode.color :
                                (note.isCharacter ? selectedMode.color.opacity(0.15) : AppTheme.mutedBackground)
                            )
                            .clipShape(Circle())

                        if note.isRoot {
                            Text("根")
                                .font(.system(size: 9))
                                .foregroundStyle(selectedMode.color)
                        } else if note.isCharacter {
                            Text("特")
                                .font(.system(size: 9))
                                .foregroundStyle(selectedMode.color.opacity(0.7))
                        }
                    }
                }
            }

            Text("音程规律: \(selectedMode.intervalPattern)")
                .font(.system(size: 12))
                .foregroundStyle(AppTheme.tertiaryText)
                .padding(.top, 4)
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
    }

    // MARK: - 调式信息卡

    private var modeInfoCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundStyle(selectedMode.color)
                Text("调式特征")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppTheme.secondaryText)
            }

            HStack(spacing: 6) {
                Text("色彩:")
                    .font(.system(size: 12))
                    .foregroundStyle(AppTheme.tertiaryText)
                Text(selectedMode.character)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(selectedMode.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(selectedMode.color.opacity(0.1))
                    .clipShape(Capsule())
            }

            Text(selectedMode.feel)
                .font(.system(size: 13))
                .foregroundStyle(AppTheme.secondaryText)
                .lineSpacing(4)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
    }

    // MARK: - 顺阶和弦

    private var diatonicChordsDisplay: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("顺阶和弦")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppTheme.secondaryText)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                ForEach(diatonicChords, id: \.chord) { item in
                    Button {
                        withAnimation { selectedChord = selectedChord == item.chord ? nil : item.chord }
                    } label: {
                        VStack(spacing: 4) {
                            Text(item.degree)
                                .font(.system(size: 11))
                                .foregroundStyle(selectedChord == item.chord ? .white.opacity(0.8) : AppTheme.tertiaryText)
                            Text(item.chord)
                                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                                .foregroundStyle(selectedChord == item.chord ? .white : AppTheme.primaryText)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(selectedChord == item.chord ? selectedMode.color : AppTheme.mutedBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
    }

    // MARK: - 对比提示

    private var comparisonTip: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(.yellow)
                Text("与自然大调对比")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppTheme.secondaryText)
            }

            if selectedMode.id == "major" {
                Text("这是最基础的调式，所有其他调式都是通过改变大调的某些音级而来。建议先掌握大调，再探索其他调式。")
                    .font(.system(size: 12))
                    .foregroundStyle(AppTheme.tertiaryText)
                    .lineSpacing(4)
            } else {
                let majorIntervals: Set<Int> = Set([0,2,4,5,7,9,11])
                let modeIntervals: Set<Int> = Set(selectedMode.intervals)
                let diff = modeIntervals.symmetricDifference(majorIntervals)
                let added = diff.filter { !majorIntervals.contains($0) }
                let removed = majorIntervals.filter { !modeIntervals.contains($0) }

                Text("与大调的区别：")
                    .font(.system(size: 12))
                    .foregroundStyle(AppTheme.tertiaryText)
                +
                Text(added.isEmpty ? "" : " 升\(added.map { "\($0)半音" }.joined(separator: "、"))")
                    .font(.system(size: 12))
                    .foregroundStyle(.orange)
                +
                Text(removed.isEmpty ? "" : " 降\(removed.map { "\($0)半音" }.joined(separator: "、"))")
                    .font(.system(size: 12))
                    .foregroundStyle(.blue)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
    }
}

// MARK: - 音阶音符模型

struct ScaleNote: Identifiable {
    let id = UUID()
    let note: String
    let isRoot: Bool
    let isCharacter: Bool
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ModeExplorerView()
    }
}
