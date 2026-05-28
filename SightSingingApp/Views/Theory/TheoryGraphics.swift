import SwiftUI

/// 乐理详情页全部图形渲染器
/// 从 TheoryDetailView 抽离，保持视图纯净
enum TheoryGraphics {

    // MARK: - 图形分发展示

    @ViewBuilder
    static func graphicView(for section: TheorySection, audio: TheoryTapAudio?) -> some View {
        if let data = section.graphicData {
            switch section.graphicType {
            case .solfegeNotes:
                solfegeGraphic(notes: data.notes, labels: data.labels, audio: audio)
            case .intervalList:
                intervalListGraphic(intervals: data.intervals, audio: audio)
            case .chordDiagram:
                chordDiagramGrid(chords: data.chords, audio: audio)
            case .fretboardHalfNotes:
                fretboardGraphic(audio: audio)
            case .scaleStructure:
                scaleStructureGraphic(audio: audio)
            case .noteDuration:
                noteDurationGraphic(audio: audio)
            case .wholeHalfFlow:
                wholeHalfFlowGraphic(items: data.flowItems, highlights: data.highlightIndices, audio: audio)
            case .beatSignature:
                beatSignatureGraphic(audio: audio)
            case .rhythmPattern:
                rhythmPatternGraphic(audio: audio)
            case .cagedShapes:
                cagedShapesGraphic(chordName: data.cagedChordName, audio: audio)
            case .cagedScaleChords:
                cagedScaleGraphic(scaleName: data.cagedScaleName, audio: audio)
            case .chordConstruction:
                chordConstructionGraphic(
                    formula: data.chordFormula,
                    notes: data.chordNotes,
                    intervals: data.chordIntervals,
                    roles: data.chordNoteRoles,
                    audio: audio
                )
            case .chordProgression:
                chordProgressionGraphic(
                    chords: data.progressionChords,
                    degrees: data.progressionDegrees,
                    tsdLabels: data.progressionLabels,
                    audio: audio
                )
            case .tsdFunctionalGroup:
                tsdFunctionalGroupGraphic(audio: audio)
            case .bassLine:
                bassLineGraphic(
                    bassNotes: data.bassNotes,
                    bassChords: data.bassChords,
                    audio: audio
                )
            case .chordComparison:
                chordComparisonGraphic(
                    leftTitle: data.comparisonLeft.first ?? "",
                    leftItems: data.comparisonLeft,
                    rightTitle: data.comparisonRight.first ?? "",
                    rightItems: data.comparisonRight,
                    diff: data.comparisonDiff,
                    audio: audio
                )
            case .modulationPath:
                modulationPathGraphic(
                    from: data.modulationFrom,
                    to: data.modulationTo,
                    diffNotes: data.modulationDiffNotes,
                    unchangedNotes: data.modulationUnchangedNotes,
                    audio: audio
                )
            case .colorChordTable:
                colorChordTableGraphic(
                    baseChord: data.colorChordBase,
                    variants: data.colorChordVariants,
                    feelings: data.colorChordFeelings,
                    audio: audio
                )
            // HarmonyCore 新图形
            case .harmonyFretboard:
                harmonyFretboardGraphic(audio: audio)
            case .harmonyChordDiagram:
                harmonyChordConstructionGraphic(
                    formula: data.chordFormula,
                    notes: data.chordNotes,
                    intervals: data.chordIntervals,
                    roles: data.chordNoteRoles,
                    chordName: data.harmonyChordName,
                    audio: audio
                )
            case .harmonyScaleFretboard:
                let mode = ScaleMode.allCases.first { data.harmonyScaleMode.isEmpty || $0.rawValue == data.harmonyScaleMode } ?? .major
                harmonyScaleGraphic(
                    root: data.harmonyScaleRoot,
                    mode: mode,
                    audio: audio
                )
            case .harmonyChordProgression:
                let prog = ChordProgressionEngine.builtInProgressions.first { $0.name == data.harmonyProgressionName } ?? .popCanon
                harmonyChordProgressionGraphic(
                    progression: prog,
                    key: data.harmonyProgressionKey,
                    audio: audio
                )
            case .harmonyAllKeys:
                harmonyAllKeysGraphic(
                    progressionName: data.harmonyAllKeysProgressionName,
                    audio: audio
                )
            case .harmonyDiatonicChords:
                let mode = ScaleMode.allCases.first { $0.rawValue == data.harmonyDiatonicMode } ?? .major
                harmonyDiatonicChordsGraphic(
                    root: data.harmonyDiatonicRoot,
                    mode: mode,
                    chordType: data.harmonyDiatonicType,
                    audio: audio
                )
            case .harmonyChordTypeBrowser:
                harmonyChordTypeBrowserGraphic(audio: audio)
            case .harmonyChordCards:
                harmonyChordCardsGraphic(
                    cards: data.harmonyChordCards,
                    title: data.harmonyChordCardsTitle,
                    columns: data.harmonyChordCardsColumns,
                    audio: audio
                )
            default:
                EmptyView()
            }
        }
    }

    // MARK: - 简谱/音符展示

    @ViewBuilder
    static func solfegeGraphic(notes: [String], labels: [String], audio: TheoryTapAudio?) -> some View {
        VStack(spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 24) {
                ForEach(Array(notes.enumerated()), id: \.offset) { index, note in
                    VStack(spacing: 4) {
                        Text(note)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.accent)
                        if index < labels.count {
                            Text(labels[index])
                                .font(.system(size: 11))
                                .foregroundStyle(AppTheme.secondaryText)
                        }
                    }
                    .onTapGesture {
                        audio?.playNoteByName(notes[index])
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .background(AppTheme.secondaryBg)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - 音程列表

    @ViewBuilder
    static func intervalListGraphic(intervals: [IntervalItem], audio: TheoryTapAudio?) -> some View {
        VStack(spacing: 8) {
            ForEach(intervals) { interval in
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.accent.opacity(0.1))
                            .frame(width: 40, height: 40)
                        Text("\(interval.semitones)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(AppTheme.accent)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(interval.name)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(AppTheme.primaryText)
                        Text(interval.notes)
                            .font(.system(size: 12))
                            .foregroundStyle(AppTheme.secondaryText)
                    }

                    Spacer()

                    Text("\(interval.semitones)个半音")
                        .font(.system(size: 12))
                        .foregroundStyle(AppTheme.secondaryText)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .contentShape(Rectangle())
                .onTapGesture {
                    audio?.playInterval(interval.semitones)
                }
            }
        }
        .padding(8)
        .background(AppTheme.secondaryBg)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - 和弦指法图

    @ViewBuilder
    static func chordDiagramGrid(chords: [ChordGraphicItem], audio: TheoryTapAudio?) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(chords) { chord in
                    VStack(spacing: 4) {
                        chordGrid(name: chord.name, frets: chord.frets, fingers: chord.fingers)
                        Text(chord.name)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(AppTheme.primaryText)
                    }
                    .onTapGesture {
                        audio?.playChord(named: chord.name)
                    }
                }
            }
        }
    }

    static func chordGrid(name: String, frets: [Int?], fingers: [Int?]) -> some View {
        VStack(spacing: 0) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let stringSpacing = h / 6

                ZStack {
                    ForEach(0..<6, id: \.self) { i in
                        Rectangle()
                            .fill(Color(hex: "94A3B8"))
                            .frame(width: 0.8 + CGFloat(5 - i) * 0.15)
                            .position(x: w / 2, y: stringSpacing * CGFloat(i) + stringSpacing / 2)
                    }

                    Rectangle()
                        .fill(Color(hex: "64748B"))
                        .frame(width: w, height: 2)
                        .position(x: w / 2, y: 0)

                    ForEach(Array(frets.enumerated()), id: \.offset) { i, fret in
                        if let f = fret {
                            let y = stringSpacing * CGFloat(i) + stringSpacing / 2
                            if f == 0 {
                                Circle()
                                    .stroke(AppTheme.primaryText, lineWidth: 1.5)
                                    .frame(width: 14, height: 14)
                                    .position(x: w / 2, y: y - 8)
                            } else {
                                Circle()
                                    .fill(AppTheme.primaryText)
                                    .frame(width: 14, height: 14)
                                    .position(x: w / 2, y: y + 8)
                                if i < (fingers.count), let finger = fingers[i] {
                                    Text("\(finger)")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundStyle(.white)
                                        .position(x: w / 2, y: y + 8)
                                }
                            }
                        } else {
                            let y = stringSpacing * CGFloat(i) + stringSpacing / 2
                            Text("×")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(AppTheme.secondaryText)
                                .position(x: w / 2, y: y - 6)
                        }
                    }
                }
            }
            .frame(width: 40, height: 70)
        }
    }

    // MARK: - 吉他指板半音图（使用 HarmonyCore 动态生成）

    @ViewBuilder
    static func fretboardGraphic(audio: TheoryTapAudio?) -> some View {
        harmonyFretboardGraphic(audio: audio)
    }

    // MARK: - 音阶结构图

    @ViewBuilder
    static func scaleStructureGraphic(audio: TheoryTapAudio?) -> some View {
        let notes = ["C", "D", "E", "F", "G", "A", "B", "C"]
        let steps = ["全", "全", "半", "全", "全", "全", "半"]

        VStack(spacing: 4) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(Array(notes.enumerated()), id: \.offset) { i, note in
                        ZStack {
                            Circle()
                                .fill(AppTheme.accent.opacity(0.1))
                                .frame(width: 36, height: 36)
                            Text(note)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(AppTheme.accent)
                        }
                        .onTapGesture {
                            audio?.playNoteByName(note)
                        }
                        if i < steps.count {
                            Text(steps[i])
                                .font(.system(size: 10))
                                .foregroundStyle(steps[i] == "半" ? AppTheme.error : AppTheme.secondaryText)
                                .padding(.horizontal, 4)
                        }
                    }
                }
            }

            HStack(spacing: 8) {
                Text("点击音符试听 · 红色标记为半音位置 (E-F, B-C)")
                    .font(.system(size: 11))
                    .foregroundStyle(AppTheme.secondaryText)
                Spacer()
                Button {
                    audio?.playScale(notes)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 10))
                        Text("弹音阶")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundStyle(AppTheme.accent)
                }
            }
        }
        .padding(12)
        .background(AppTheme.secondaryBg)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - 音符时值关系图

    @ViewBuilder
    static func noteDurationGraphic(audio: TheoryTapAudio?) -> some View {
        let items: [(type: NoteSymbolType, label: String, midiNote: Int)] = [
            (.whole, "全音符", 60),
            (.half, "二分", 62),
            (.quarter, "四分", 64),
            (.eighth, "八分", 65),
            (.sixteenth, "十六分", 67),
        ]
        NoteDurationRow(items: items, audio: audio)
    }

    // MARK: - 全音半音流向图

    @ViewBuilder
    static func wholeHalfFlowGraphic(
        items: [String], highlights: Set<Int>, audio: TheoryTapAudio?
    ) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 2) {
                ForEach(Array(items.enumerated()), id: \.offset) { i, item in
                    if highlights.contains(i) {
                        Text(item)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(AppTheme.error)
                            .onTapGesture {
                                audio?.playNoteByName(item)
                            }
                    } else if item == "全" || item == "半" {
                        Text(item)
                            .font(.system(size: 13))
                            .foregroundStyle(item == "半" ? AppTheme.error : AppTheme.secondaryText)
                    } else {
                        Text(item)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(AppTheme.accent)
                            .onTapGesture {
                                audio?.playNoteByName(item)
                            }
                    }
                }
            }
            .padding(12)
            .background(AppTheme.secondaryBg)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .frame(maxWidth: .infinity)

            Text("红色标记为半音位置 (E-F, B-C)")
                .font(.system(size: 11))
                .foregroundStyle(AppTheme.secondaryText)
                .padding(.top, 2)
        }
    }

    // MARK: - 拍号展示

    @ViewBuilder
    static func beatSignatureGraphic(audio: TheoryTapAudio?) -> some View {
        let beats: [(String, String, String)] = [
            ("4/4", "强-弱-次强-弱", "流行、摇滚标配"),
            ("3/4", "强-弱-弱", "圆舞曲"),
            ("6/8", "强-弱-弱-次强-弱-弱", "慢摇、抒情"),
        ]
        VStack(spacing: 10) {
            ForEach(beats, id: \.0) { beat in
                HStack(spacing: 12) {
                    Text(beat.0)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.accent)
                        .frame(width: 48)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(beat.1)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(AppTheme.primaryText)
                        Text(beat.2)
                            .font(.system(size: 11))
                            .foregroundStyle(AppTheme.secondaryText)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    audio?.playRhythmHint()
                }
            }
        }
        .padding(12)
        .background(AppTheme.secondaryBg)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - 节奏型展示

    @ViewBuilder
    static func rhythmPatternGraphic(audio: TheoryTapAudio?) -> some View {
        VStack(spacing: 12) {
            Text("通过'哒'唱出节奏型来练习 · 点击试听")
                .font(.system(size: 12))
                .foregroundStyle(AppTheme.secondaryText)

            HStack(spacing: 16) {
                rhythmItem(title: "基本节奏", pattern: "哒 哒 哒 哒", audio: audio)
                rhythmItem(title: "八分节奏", pattern: "哒哒 哒哒 哒哒 哒哒", audio: audio)
                rhythmItem(title: "切分节奏", pattern: "哒 哒哒 哒 哒", audio: audio)
            }
        }
        .padding(12)
        .background(AppTheme.secondaryBg)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private static func rhythmItem(title: String, pattern: String, audio: TheoryTapAudio?) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(AppTheme.accent)
            Text(pattern)
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundStyle(AppTheme.primaryText)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            audio?.playRhythmHint()
        }
    }

    // MARK: - CAGED 五大形状

    /// 单个和弦的 CAGED 五形图
    @ViewBuilder
    static func cagedShapesGraphic(chordName: String, audio: TheoryTapAudio?) -> some View {
        let data = cagedChordData(for: chordName)
        CAGEDShapesRow(chordData: data, audio: audio)
    }

    /// 调性各级和弦的 CAGED 图
    @ViewBuilder
    static func cagedScaleGraphic(scaleName: String, audio: TheoryTapAudio?) -> some View {
        let chords = cagedScaleChords(for: scaleName)
        CAGEDScaleChordView(scaleName: scaleName, chords: chords, audio: audio)
    }

    // MARK: - CAGED 数据映射

    private static func cagedChordData(for name: String) -> CAGEDChordData {
        switch name.uppercased() {
        case "C":  return CAGEDDatabase.cMajor
        case "A":  return CAGEDDatabase.aMajor
        case "G":  return CAGEDDatabase.gMajor
        case "E":  return CAGEDDatabase.eMajor
        case "D":  return CAGEDDatabase.dMajor
        case "F":  return CAGEDDatabase.fMajor
        case "AM": return CAGEDDatabase.aMinor
        case "EM": return CAGEDDatabase.eMinor
        case "DM": return CAGEDDatabase.dMinor
        default:   return CAGEDDatabase.cMajor
        }
    }

    private static func cagedScaleChords(for key: String) -> [(degree: String, data: CAGEDChordData)] {
        switch key.uppercased() {
        case "C": return CAGEDDatabase.cMajorScaleChords()
        default:  return CAGEDDatabase.cMajorScaleChords()
        }
    }

    // MARK: - 和弦构成公式 + 指板对照

    @ViewBuilder
    static func chordConstructionGraphic(
        formula: String, notes: [String], intervals: [String], roles: [String], audio: TheoryTapAudio?
    ) -> some View {
        HStack(spacing: 20) {
            // 左侧：构成公式
            VStack(spacing: 6) {
                Text(formula)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.accent)
                    .padding(.bottom, 2)

                ForEach(Array(notes.enumerated()), id: \.offset) { i, note in
                    HStack(spacing: 8) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(AppTheme.accent.opacity(0.12))
                                .frame(width: 36, height: 28)
                            Text(note)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(AppTheme.accent)
                                .onTapGesture { audio?.playNoteByName(note) }
                        }

                        VStack(alignment: .leading, spacing: 1) {
                            Text(i < roles.count ? roles[i] : "")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(AppTheme.primaryText)
                            Text(i < intervals.count ? intervals[i] : "")
                                .font(.system(size: 10))
                                .foregroundStyle(AppTheme.secondaryText)
                        }
                    }
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.border, lineWidth: 0.5))

            // 右侧：动态指板高亮（HarmonyCore）
            VStack(spacing: 4) {
                Text("指板位置")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(AppTheme.secondaryText)

                HarmonyFretboardView(
                    fretboard: FretboardModel(),
                    highlightNotes: Set(notes),
                    highlightColor: AppTheme.accent,
                    showNoteLabels: true,
                    fretRange: 0..<6,
                    audio: audio
                )
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.border, lineWidth: 0.5))
        }
        .padding(8)
        .background(AppTheme.secondaryBg)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - 和弦进行流程图

    @ViewBuilder
    static func chordProgressionGraphic(
        chords: [String], degrees: [String], tsdLabels: [String], audio: TheoryTapAudio?
    ) -> some View {
        let tsdColor: (String) -> Color = { label in
            switch label.uppercased() {
            case "T": return Color(hex: "3B82F6") // 蓝
            case "S": return Color(hex: "10B981") // 绿
            case "D": return Color(hex: "EF4444") // 红
            default: return AppTheme.accent
            }
        }

        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(Array(chords.enumerated()), id: \.offset) { i, chord in
                    if i > 0 {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12))
                            .foregroundStyle(AppTheme.secondaryText)
                            .padding(.horizontal, 6)
                    }

                    VStack(spacing: 4) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill((i < tsdLabels.count ? tsdColor(tsdLabels[i]) : AppTheme.accent).opacity(0.12))
                                .frame(width: 52, height: 36)
                            Text(chord)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(i < tsdLabels.count ? tsdColor(tsdLabels[i]) : AppTheme.accent)
                        }
                        .onTapGesture { audio?.playChord(named: chord) }

                        if i < degrees.count {
                            Text(degrees[i])
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(AppTheme.secondaryText)
                        }
                        if i < tsdLabels.count {
                            Text(tsdLabels[i])
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundStyle(i < tsdLabels.count ? tsdColor(tsdLabels[i]) : AppTheme.accent)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 1)
                                .background((i < tsdLabels.count ? tsdColor(tsdLabels[i]) : AppTheme.accent).opacity(0.15))
                                .clipShape(RoundedRectangle(cornerRadius: 3))
                        }
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .padding(8)
        .background(AppTheme.secondaryBg)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - TSD 功能组色彩图

    @ViewBuilder
    static func tsdFunctionalGroupGraphic(audio: TheoryTapAudio?) -> some View {
        let groups: [(name: String, color: Color, desc: String, chords: [String])] = [
            ("T 主功能", Color(hex: "3B82F6"), "家 · 稳定", ["C", "Em", "Am"]),
            ("S 下属", Color(hex: "10B981"), "出发 · 展开", ["Dm", "F"]),
            ("D 属功能", Color(hex: "EF4444"), "紧张 · 想回家", ["G", "Bdim"]),
        ]

        HStack(spacing: 10) {
            ForEach(groups, id: \.name) { group in
                VStack(spacing: 6) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(group.color)
                            .frame(width: 8, height: 8)
                        Text(group.name)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(group.color)
                    }

                    Text(group.desc)
                        .font(.system(size: 10))
                        .foregroundStyle(AppTheme.secondaryText)

                    VStack(spacing: 4) {
                        ForEach(group.chords, id: \.self) { chord in
                            Text(chord)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(group.color)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 4)
                                .background(group.color.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .onTapGesture { audio?.playChord(named: chord) }
                        }
                    }
                }
                .padding(10)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(group.color.opacity(0.2), lineWidth: 1))
            }
        }
        .padding(8)
        .background(AppTheme.secondaryBg)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Bass 低音线图

    @ViewBuilder
    static func bassLineGraphic(bassNotes: [String], bassChords: [String], audio: TheoryTapAudio?) -> some View {
        VStack(spacing: 8) {
            // 和弦名行
            if !bassChords.isEmpty {
                HStack(spacing: 0) {
                    ForEach(Array(bassChords.enumerated()), id: \.offset) { i, chord in
                        if i > 0 {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 10))
                                .foregroundStyle(AppTheme.secondaryText)
                                .padding(.horizontal, 4)
                        }
                        Text(chord)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(AppTheme.accent)
                            .onTapGesture { audio?.playChord(named: chord) }
                    }
                }
            }

            // 低音线
            HStack(spacing: 0) {
                ForEach(Array(bassNotes.enumerated()), id: \.offset) { i, note in
                    if i > 0 {
                        Rectangle()
                            .fill(AppTheme.border)
                            .frame(width: 12, height: 1)
                    }
                    ZStack {
                        Circle()
                            .fill(AppTheme.accent.opacity(0.15))
                            .frame(width: 28, height: 28)
                        Text(note)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(AppTheme.accent)
                            .onTapGesture { audio?.playNoteByName(note) }
                    }
                }
            }

            Text("低音" + (bassNotes.count > 2 && bassNotes[0] > bassNotes[1] ? "逐步下行" : "走向"))
                .font(.system(size: 11))
                .foregroundStyle(AppTheme.secondaryText)
        }
        .padding(12)
        .background(AppTheme.secondaryBg)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - 和弦对比图

    @ViewBuilder
    static func chordComparisonGraphic(
        leftTitle: String, leftItems: [String],
        rightTitle: String, rightItems: [String],
        diff: String, audio: TheoryTapAudio?
    ) -> some View {
        HStack(spacing: 16) {
            // 左边
            VStack(spacing: 6) {
                Text(leftTitle)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color(hex: "3B82F6"))

                ForEach(leftItems, id: \.self) { item in
                    Text(item)
                        .font(.system(size: 12))
                        .foregroundStyle(AppTheme.primaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                        .background(Color(hex: "3B82F6").opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }
            .padding(10)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(hex: "3B82F6").opacity(0.2), lineWidth: 1))

            // 中间差异
            VStack(spacing: 4) {
                Image(systemName: "arrow.left.and.right")
                    .font(.system(size: 16))
                    .foregroundStyle(AppTheme.accent)
                if !diff.isEmpty {
                    Text(diff)
                        .font(.system(size: 10))
                        .foregroundStyle(AppTheme.secondaryText)
                        .multilineTextAlignment(.center)
                        .frame(width: 60)
                }
            }

            // 右边
            VStack(spacing: 6) {
                Text(rightTitle)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color(hex: "EF4444"))

                ForEach(rightItems, id: \.self) { item in
                    Text(item)
                        .font(.system(size: 12))
                        .foregroundStyle(AppTheme.primaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                        .background(Color(hex: "EF4444").opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }
            .padding(10)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(hex: "EF4444").opacity(0.2), lineWidth: 1))
        }
        .padding(8)
        .background(AppTheme.secondaryBg)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - 转调路径图

    @ViewBuilder
    static func modulationPathGraphic(
        from: String, to: String, diffNotes: [String], unchangedNotes: [String], audio: TheoryTapAudio?
    ) -> some View {
        VStack(spacing: 10) {
            // 调名
            HStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text(from)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color(hex: "3B82F6"))
                    Text("原调")
                        .font(.system(size: 10))
                        .foregroundStyle(AppTheme.secondaryText)
                }

                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(AppTheme.accent)

                VStack(spacing: 4) {
                    Text(to)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color(hex: "EF4444"))
                    Text("目标调")
                        .font(.system(size: 10))
                        .foregroundStyle(AppTheme.secondaryText)
                }
            }

            // 变化音 vs 不变音
            HStack(spacing: 12) {
                if !diffNotes.isEmpty {
                    VStack(spacing: 4) {
                        Text("变")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color(hex: "EF4444"))
                        HStack(spacing: 4) {
                            ForEach(diffNotes, id: \.self) { note in
                                Text(note)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(Color(hex: "EF4444"))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(Color(hex: "EF4444").opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                            }
                        }
                    }
                    .padding(8)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                if !unchangedNotes.isEmpty {
                    VStack(spacing: 4) {
                        Text("不变")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(AppTheme.secondaryText)
                        HStack(spacing: 4) {
                            ForEach(unchangedNotes, id: \.self) { note in
                                Text(note)
                                    .font(.system(size: 12))
                                    .foregroundStyle(AppTheme.primaryText)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(AppTheme.secondaryBg)
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                            }
                        }
                    }
                    .padding(8)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding(12)
        .background(AppTheme.secondaryBg)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - 色彩和弦对照表

    @ViewBuilder
    static func colorChordTableGraphic(
        baseChord: String, variants: [String], feelings: [String], audio: TheoryTapAudio?
    ) -> some View {
        HStack(spacing: 0) {
            // 基础和弦
            VStack(spacing: 4) {
                Text(baseChord)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(AppTheme.accent)
                Text("基础")
                    .font(.system(size: 9))
                    .foregroundStyle(AppTheme.secondaryText)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .onTapGesture { audio?.playChord(named: baseChord) }

            // 箭头
            ForEach(Array(variants.enumerated()), id: \.offset) { i, variant in
                Image(systemName: "arrow.right")
                    .font(.system(size: 10))
                    .foregroundStyle(AppTheme.secondaryText)
                    .padding(.horizontal, 4)

                VStack(spacing: 4) {
                    Text(variant)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AppTheme.primaryText)
                        .onTapGesture { audio?.playChord(named: variant) }
                    if i < feelings.count {
                        Text(feelings[i])
                            .font(.system(size: 9))
                            .foregroundStyle(AppTheme.secondaryText)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(AppTheme.secondaryBg)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(12)
        .background(AppTheme.secondaryBg)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
