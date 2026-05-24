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

    // MARK: - 吉他指板半音图

    @ViewBuilder
    static func fretboardGraphic(audio: TheoryTapAudio?) -> some View {
        VStack(spacing: 4) {
            Text("吉他指板上的半音（点击任意位置试听）")
                .font(.system(size: 12))
                .foregroundStyle(AppTheme.secondaryText)
                .padding(.bottom, 4)

            GeometryReader { _ in
                Canvas { ctx, size in
                    for i in 0..<6 {
                        let y = 8 + CGFloat(i) * 8
                        let path = Path { p in
                            p.move(to: CGPoint(x: 20, y: y))
                            p.addLine(to: CGPoint(x: size.width - 20, y: y))
                        }
                        ctx.stroke(path, with: .color(Color(hex: "94A3B8")), lineWidth: 0.5 + CGFloat(i) * 0.1)
                    }
                    for i in 0..<6 {
                        let x = 20 + CGFloat(i) * 48
                        let path = Path { p in
                            p.move(to: CGPoint(x: x, y: 5))
                            p.addLine(to: CGPoint(x: x, y: 52))
                        }
                        ctx.stroke(path, with: .color(Color(hex: "94A3B8")), lineWidth: 1)
                    }
                }
            }
            .frame(height: 60)
            .contentShape(Rectangle())
            .onTapGesture {
                audio?.playFretboardNote(string: 2, fret: 3)
            }

            Text("相邻品位 = 半音")
                .font(.system(size: 11))
                .foregroundStyle(AppTheme.secondaryText)
        }
        .padding(12)
        .background(AppTheme.secondaryBg)
        .clipShape(RoundedRectangle(cornerRadius: 12))
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
}
