import SwiftUI

// MARK: - 基于 HarmonyCore 的全新交互式图形组件
// 借鉴 Buitar 核心能力：指板动态生成 + 和弦自动求解 + 音阶可视化 + 和弦进行播放

// MARK: - 1. 交互式指板视图（取代 fretboardGraphic）

/// 完整的吉他指板网格，支持点击发音和高亮
struct HarmonyFretboardView: View {
    let fretboard: FretboardModel
    let highlightNotes: Set<String>       // 高亮的音名（如 ["C","E","G"]）
    let highlightColor: Color
    var showNoteLabels: Bool = true
    var fretRange: Range<Int> = 0..<12    // 可配置品位范围
    var audio: TheoryTapAudio? = nil

    @State private var playedNote: Int? = nil  // 动画反馈

    // 音名 → 颜色映射（调内音程色彩）
    private let intervalColors: [String: Color] = [
        "R": Color(hex: "EF4444"),
        "3": Color(hex: "F59E0B"),
        "5": Color(hex: "10B981"),
    ]

    var body: some View {
        VStack(spacing: 6) {
            // 弦名标签
            HStack(spacing: 0) {
                ForEach(Array(fretboard.tuningNotes.reversed().enumerated()), id: \.offset) { idx, note in
                    Text(note.rawValue)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(AppTheme.secondaryText)
                        .frame(width: 22)
                }
                .padding(.horizontal, 4)
            }
            .padding(.horizontal, 14)

            // 指板主体
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(spacing: 0) {
                    // 品位数字
                    HStack(spacing: 0) {
                        ForEach(fretRange, id: \.self) { fret in
                            Text(fret == 0 ? "" : "\(fret)")
                                .font(.system(size: 8))
                                .foregroundStyle(AppTheme.tertiaryText)
                                .frame(width: 24, height: 12)
                        }
                    }
                    .padding(.leading, 14)

                    // 弦 × 品 网格
                    ForEach(Array((0..<6).reversed()), id: \.self) { si in
                        HStack(spacing: 0) {
                            ForEach(fretRange, id: \.self) { fret in
                                if let point = fretboard.point(at: si, fret: fret) {
                                    let isHighlighted = highlightNotes.contains(point.note.rawValue)
                                    let isPlayed = playedNote == point.id

                                    ZStack {
                                        // 高亮背景
                                        if isHighlighted {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(highlightColor.opacity(0.15))
                                                .frame(width: 22, height: 22)
                                        }
                                        // 发音动画
                                        if isPlayed {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(AppTheme.accent.opacity(0.3))
                                                .frame(width: 22, height: 22)
                                                .scaleEffect(isPlayed ? 1.2 : 1.0)
                                                .animation(.easeOut(duration: 0.3), value: isPlayed)
                                        }

                                        // 音名
                                        if showNoteLabels {
                                            Text(point.note.rawValue)
                                                .font(.system(size: 8, weight: isHighlighted ? .bold : .regular))
                                                .foregroundStyle(
                                                    isHighlighted ? highlightColor : AppTheme.secondaryText
                                                )
                                        } else {
                                            Circle()
                                                .fill(isHighlighted ? highlightColor : Color.clear)
                                                .frame(width: 6, height: 6)
                                        }
                                    }
                                    .frame(width: 24, height: 24)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        audio?.playFretboardNote(string: si, fret: fret)
                                        playedNote = point.id
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            playedNote = nil
                                        }
                                    }
                                }
                            }
                        }
                        // 弦线
                        .overlay(alignment: .bottom) {
                            Rectangle()
                                .fill(Color(hex: "94A3B8"))
                                .frame(height: 0.4 + CGFloat(si) * 0.06)
                        }
                    }

                    // 品位线
                }
                .padding(.horizontal, 14)
            }

            // 图例
            if !highlightNotes.isEmpty {
                HStack(spacing: 12) {
                    Circle()
                        .fill(highlightColor)
                        .frame(width: 8, height: 8)
                    Text("高亮音：\(highlightNotes.sorted().joined(separator: "、"))")
                        .font(.system(size: 11))
                        .foregroundStyle(AppTheme.secondaryText)
                }
                .padding(.top, 2)
            }
        }
        .padding(.vertical, 12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.border, lineWidth: 0.5))
    }
}

// MARK: - 2. 动态和弦指法视图（取代 chordGrid + CAGEDDatabase 硬编码）

/// 自动求解和弦指法并展示多个把位的指板图
struct DynamicChordDiagramView: View {
    let chordName: String
    var maxVoicings: Int = 5
    var audio: TheoryTapAudio? = nil

    @State private var voicings: [ChordVoicing] = []
    @State private var selectedIndex: Int = 0

    private let difficultyColors: [VoicingDifficulty: Color] = [
        .beginner: Color(hex: "10B981"),
        .intermediate: Color(hex: "F59E0B"),
        .advanced: Color(hex: "EF4444"),
    ]

    private let difficultyLabels: [VoicingDifficulty: String] = [
        .beginner: "入门",
        .intermediate: "进阶",
        .advanced: "高级",
    ]

    var body: some View {
        VStack(spacing: 10) {
            // 和弦名称 + 类型
            if let voicing = voicings.element(at: selectedIndex) {
                HStack(spacing: 8) {
                    Text(chordName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(AppTheme.primaryText)

                    Text(voicing.chordType.nameCN)
                        .font(.system(size: 12))
                        .foregroundStyle(AppTheme.secondaryText)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(AppTheme.accent.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 4))

                    Spacer()

                    // 难度标签
                    Text(difficultyLabels[voicing.difficulty] ?? "")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(difficultyColors[voicing.difficulty] ?? AppTheme.secondaryText)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background((difficultyColors[voicing.difficulty] ?? AppTheme.secondaryText).opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }

                // 指板图
                voicingFretboardView(voicing)
                    .frame(height: 120)

                // 把位选择器
                if voicings.count > 1 {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(voicings.enumerated()), id: \.offset) { i, v in
                                VStack(spacing: 2) {
                                    Text("\(v.lowestFret)品")
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundStyle(i == selectedIndex ? AppTheme.accent : AppTheme.secondaryText)
                                    if v.isBarre {
                                        Text("B")
                                            .font(.system(size: 8, weight: .bold))
                                            .foregroundStyle(i == selectedIndex ? AppTheme.accent : AppTheme.tertiaryText)
                                    }
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    i == selectedIndex
                                        ? AppTheme.accent.opacity(0.1)
                                        : Color.clear
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedIndex = i
                                    }
                                }
                            }
                        }
                    }
                }

                // 音名说明
                HStack(spacing: 4) {
                    ForEach(Array(voicing.taps.compactMap { $0.note }.enumerated()), id: \.offset) { _, note in
                        Text(note.rawValue)
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundStyle(AppTheme.accent)
                            .padding(.horizontal, 4)
                    }
                }
            } else {
                Text("未找到指法")
                    .font(.system(size: 13))
                    .foregroundStyle(AppTheme.secondaryText)
            }
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppTheme.border, lineWidth: 0.5))
        .onAppear {
            let model = FretboardModel()
            voicings = ChordFingeringSolver.solve(
                chordName: chordName,
                on: model,
                maxVoicings: maxVoicings
            )
            selectedIndex = 0
        }
    }

    // MARK: - 指板 CV 绘制

    @ViewBuilder
    private func voicingFretboardView(_ voicing: ChordVoicing) -> some View {
        Canvas { ctx, size in
            let w = size.width
            let h = size.height
            let stringCount = 6
            let stringSpacing = w / CGFloat(stringCount + 1)
            let startX = stringSpacing / 2
            let topY: CGFloat = 12
            let maxVisibleFrets = 5
            let fretSpacing = (h - topY - 8) / CGFloat(maxVisibleFrets)

            // 品位线
            for i in 0...maxVisibleFrets {
                let y = topY + CGFloat(i) * fretSpacing
                let path = Path { p in
                    p.move(to: CGPoint(x: startX, y: y))
                    p.addLine(to: CGPoint(x: startX + stringSpacing * 5, y: y))
                }
                ctx.stroke(path, with: .color(i == 0 ? AppTheme.primaryText.opacity(0.4) : AppTheme.border), lineWidth: i == 0 ? 1.5 : 0.6)
            }

            // 起始品位标记
            if voicing.lowestFret > 1 {
                let label = "\(voicing.lowestFret)fr"
                let text = Text(label).font(.system(size: 8)).foregroundStyle(AppTheme.secondaryText)
                ctx.draw(text, at: CGPoint(x: startX - 18, y: topY + fretSpacing / 2))
            }

            // 弦线
            for i in 0..<stringCount {
                let x = startX + CGFloat(i) * stringSpacing
                let path = Path { p in
                    p.move(to: CGPoint(x: x, y: topY))
                    p.addLine(to: CGPoint(x: x, y: topY + CGFloat(maxVisibleFrets) * fretSpacing))
                }
                let lineW = 0.5 + CGFloat(5 - i) * 0.1
                ctx.stroke(path, with: .color(Color(hex: "94A3B8")), lineWidth: lineW)
            }

            // 横按条
            if let barre = voicing.barreFret {
                let adjustedBarre = barre - max(0, voicing.lowestFret - 1)
                if adjustedBarre >= 0 && adjustedBarre <= maxVisibleFrets {
                    let y = topY + CGFloat(adjustedBarre) * fretSpacing - fretSpacing / 2 + 2
                    let barreStrings = voicing.taps.filter { ($0.fret ?? 0) > 0 || $0.fret == 0 }.count
                    let barreW = stringSpacing * CGFloat(max(1, barreStrings - 1))
                    let rect = CGRect(x: startX, y: y - 4, width: barreW, height: 8)
                    let path = Path(roundedRect: rect, cornerRadius: 3)
                    ctx.fill(path, with: .color(AppTheme.accent.opacity(0.25)))
                }
            }

            // 品位点
            let baseFret = max(0, voicing.lowestFret - 1)
            for (si, tap) in voicing.taps.enumerated() {
                let x = startX + CGFloat(si) * stringSpacing
                if let fret = tap.fret {
                    if fret == 0 {
                        // 空弦 — 顶部空心圆
                        let circleRect = CGRect(x: x - 5, y: topY - 16, width: 10, height: 10)
                        ctx.stroke(Path(ellipseIn: circleRect), with: .color(AppTheme.primaryText), lineWidth: 1.2)
                        let text = Text("0").font(.system(size: 7, weight: .bold)).foregroundStyle(AppTheme.secondaryText)
                        ctx.draw(text, at: CGPoint(x: x, y: topY - 11))
                    } else {
                        let relativeFret = fret - baseFret
                        if relativeFret > 0 && relativeFret <= maxVisibleFrets {
                            let y = topY + CGFloat(relativeFret) * fretSpacing - fretSpacing / 2
                            let isRoot = tap.note?.rawValue == voicing.root.rawValue
                            let r: CGFloat = isRoot ? 7 : 5.5
                            let circleRect = CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)
                            ctx.fill(Path(ellipseIn: circleRect), with: .color(isRoot ? AppTheme.accent : AppTheme.primaryText))

                            // 指法数字
                            if let finger = tap.finger {
                                let text = Text("\(finger)")
                                    .font(.system(size: 7, weight: .bold))
                                    .foregroundStyle(.white)
                                ctx.draw(text, at: CGPoint(x: x, y: y))
                            }

                            // 根音 R 标记
                            if isRoot {
                                let text = Text("R")
                                    .font(.system(size: 6, weight: .black))
                                    .foregroundStyle(AppTheme.accent)
                                ctx.draw(text, at: CGPoint(x: x + 9, y: y - 9))
                            }
                        }
                    }
                } else {
                    // 不弹 ×
                    let text = Text("×")
                        .font(.system(size: 7, weight: .medium))
                        .foregroundStyle(AppTheme.secondaryText)
                    ctx.draw(text, at: CGPoint(x: x, y: topY - 10))
                }
            }
        }
        .onTapGesture {
            audio?.playChord(named: chordName)
        }
    }
}

// MARK: - 3. 指板音阶可视化（取代 scaleStructureGraphic）

/// 在指板上高亮显示指定调式音阶
struct ScaleOnFretboardView: View {
    let root: String          // 主音名（如 "C" "A"）
    let mode: ScaleMode       // 调式
    var highlightRange: Range<Int> = 0..<12
    var audio: TheoryTapAudio? = nil

    @State private var fretboard: FretboardModel = FretboardModel()
    @State private var scaleNotes: Set<String> = []
    @State private var degreeLabels: [Int: String] = [:]

    var body: some View {
        VStack(spacing: 8) {
            // 调式说明
            HStack(spacing: 8) {
                Text("\(root) \(mode.nameCN)")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(AppTheme.primaryText)

                Spacer()

                // 音阶音
                HStack(spacing: 2) {
                    ForEach(Array(scaleNotes.sorted()), id: \.self) { note in
                        Text(note)
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundStyle(AppTheme.accent)
                            .padding(.horizontal, 3)
                            .padding(.vertical, 1)
                            .background(AppTheme.accent.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                    }
                }
            }

            // 指板
            HarmonyFretboardView(
                fretboard: fretboard,
                highlightNotes: scaleNotes,
                highlightColor: AppTheme.accent,
                showNoteLabels: true,
                fretRange: highlightRange,
                audio: audio
            )

            // 半音结构说明
            let offsets = mode.semitoneOffsets
            HStack(spacing: 3) {
                Text("半音间距：")
                    .font(.system(size: 10))
                    .foregroundStyle(AppTheme.secondaryText)
                ForEach(Array(zip(offsets, offsets.dropFirst()).enumerated()), id: \.offset) { i, pair in
                    let gap = pair.1 - pair.0
                    Text(gap == 2 ? "全" : "半")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(gap == 1 ? AppTheme.error : AppTheme.primaryText)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background((gap == 1 ? AppTheme.error : AppTheme.accent).opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                    if i < offsets.count - 2 {
                        Text("→")
                            .font(.system(size: 8))
                            .foregroundStyle(AppTheme.tertiaryText)
                    }
                }
            }
            .padding(.top, 2)

            // 播放音阶
            Button {
                let notes = Array(scaleNotes)
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
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppTheme.border, lineWidth: 0.5))
        .onAppear {
            guard let rootNote = NoteName.fromString(root) else { return }
            scaleNotes = Set(ScaleEngine.scaleNotes(root: rootNote, mode: mode).map { $0.rawValue })
            var board = FretboardModel()
            board.applyScale(root: rootNote, mode: mode)
            fretboard = board
        }
    }
}

// MARK: - 4. 和弦进行播放器（取代 chordProgressionGraphic）

/// 交互式和弦进行播放器，支持切换调、调速、指板联动
struct ChordProgressionPlayerView: View {
    let progression: ChordProgression
    var initialKey: String = "C"
    var audio: TheoryTapAudio? = nil

    @State private var selectedKey: NoteName = .C
    @State private var bpm: Double = 80
    @State private var context: ProgressionContext?
    @State private var activeChordIndex: Int = -1
    @State private var isPlaying: Bool = false
    @State private var currentBeat: Int = 0

    private let tsdColors: [TSDFunction: Color] = [
        .tonic: Color(hex: "3B82F6"),
        .subdominant: Color(hex: "10B981"),
        .dominant: Color(hex: "EF4444"),
    ]

    private let tsdLabels: [TSDFunction: String] = [
        .tonic: "T",
        .subdominant: "S",
        .dominant: "D",
    ]

    var body: some View {
        VStack(spacing: 10) {
            // 标题行
            HStack(spacing: 6) {
                Text(progression.name)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(AppTheme.primaryText)
                Text("·")
                    .foregroundStyle(AppTheme.secondaryText)
                Text(progression.style.rawValue)
                    .font(.system(size: 11))
                    .foregroundStyle(AppTheme.secondaryText)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(AppTheme.secondaryBg)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                Spacer()
            }

            Text(progression.description)
                .font(.system(size: 12))
                .foregroundStyle(AppTheme.secondaryText)
                .frame(maxWidth: .infinity, alignment: .leading)

            // 和弦进行可视化
            if let ctx = context {
                // 进行流程图
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(Array(ctx.chords.enumerated()), id: \.offset) { i, chord in
                            if i > 0 {
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 10))
                                    .foregroundStyle(AppTheme.secondaryText)
                                    .padding(.horizontal, 4)
                            }

                            VStack(spacing: 4) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(chordColor(chord, index: i).opacity(0.12))
                                        .frame(width: 56, height: 40)
                                    Text(chord.chordName)
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundStyle(chordColor(chord, index: i))
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(
                                            activeChordIndex == i ? AppTheme.accent : Color.clear,
                                            lineWidth: 2
                                        )
                                )
                                .onTapGesture {
                                    audio?.playChord(named: chord.chordName)
                                }

                                // 级数
                                Text(chord.function.map { tsdLabels[$0] ?? "" } ?? "")
                                    .font(.system(size: 8, weight: .semibold))
                                    .foregroundStyle(chord.function.map { tsdColors[$0] ?? AppTheme.accent } ?? AppTheme.accent)
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 1)
                                    .background((chord.function.map { tsdColors[$0] ?? Color.clear } ?? Color.clear).opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 3))
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                }

                // 和弦构成音预览
                if activeChordIndex >= 0, activeChordIndex < ctx.chords.count {
                    let chord = ctx.chords[activeChordIndex]
                    VStack(spacing: 4) {
                        HStack(spacing: 6) {
                            Text(chord.chordName)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(AppTheme.primaryText)
                            Text("构成音：")
                                .font(.system(size: 10))
                                .foregroundStyle(AppTheme.secondaryText)
                            ForEach(chord.voices, id: \.self) { note in
                                Text(note.rawValue)
                                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                                    .foregroundStyle(AppTheme.accent)
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 1)
                                    .background(AppTheme.accent.opacity(0.08))
                                    .clipShape(RoundedRectangle(cornerRadius: 3))
                                    .onTapGesture { audio?.playNoteByName(note.rawValue) }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(AppTheme.secondaryBg)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }

                // 进度条
                if isPlaying {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(AppTheme.border)
                                .frame(height: 4)

                            RoundedRectangle(cornerRadius: 2)
                                .fill(AppTheme.accent)
                                .frame(
                                    width: max(4, geo.size.width * CGFloat(currentBeat) / CGFloat(max(1, ctx.totalBeats))),
                                    height: 4
                                )
                                .animation(.linear(duration: 60.0 / bpm), value: currentBeat)
                        }
                    }
                    .frame(height: 4)
                    .padding(.horizontal, 8)
                }
            }

            // 控制栏
            HStack(spacing: 12) {
                // 调选择
                Picker("调", selection: $selectedKey) {
                    ForEach(NoteName.allCases, id: \.self) { note in
                        Text(note.rawValue).tag(note)
                    }
                }
                .pickerStyle(.menu)
                .font(.system(size: 12))
                .onChange(of: selectedKey) { _, newKey in
                    updateContext(key: newKey)
                }

                Spacer()

                // BPM
                HStack(spacing: 4) {
                    Button { bpm = max(40, bpm - 10) } label: {
                        Image(systemName: "minus.circle")
                            .font(.system(size: 14))
                            .foregroundStyle(AppTheme.secondaryText)
                    }

                    Text("\(Int(bpm))")
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundStyle(AppTheme.primaryText)
                        .frame(width: 32)

                    Button { bpm = min(200, bpm + 10) } label: {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 14))
                            .foregroundStyle(AppTheme.secondaryText)
                    }
                }

                Spacer()

                // 播放/停止
                Button {
                    if isPlaying {
                        stopPlayback()
                    } else {
                        startPlayback()
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                            .font(.system(size: 12))
                        Text(isPlaying ? "停止" : "播放")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(AppTheme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(.top, 4)
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppTheme.border, lineWidth: 0.5))
        .onAppear {
            if let note = NoteName.fromString(initialKey) {
                selectedKey = note
            }
            updateContext(key: selectedKey)
        }
    }

    private func chordColor(_ chord: ProgressionChord, index: Int) -> Color {
        if let fn = chord.function {
            return tsdColors[fn] ?? AppTheme.accent
        }
        return AppTheme.accent
    }

    private func updateContext(key: NoteName) {
        context = ProgressionContext.create(progression: progression, key: key, bpm: bpm)
        activeChordIndex = -1
    }

    private func startPlayback() {
        guard let ctx = context else { return }
        isPlaying = true
        currentBeat = 0
        activeChordIndex = 0
        playNextBeat(ctx: ctx)
    }

    private func playNextBeat(ctx: ProgressionContext) {
        guard isPlaying, currentBeat < ctx.totalBeats else {
            isPlaying = false
            activeChordIndex = -1
            return
        }

        let idx = ctx.chordIndex(at: currentBeat)
        activeChordIndex = idx
        if idx < ctx.chords.count {
            audio?.playChord(named: ctx.chords[idx].chordName)
        }

        currentBeat += 1
        let interval = 60.0 / bpm
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            playNextBeat(ctx: ctx)
        }
    }

    private func stopPlayback() {
        isPlaying = false
        activeChordIndex = -1
        currentBeat = 0
    }
}

// MARK: - 辅助扩展

private extension Array {
    func element(at index: Int) -> Element? {
        guard index >= 0, index < count else { return nil }
        return self[index]
    }
}

// MARK: - 图形分发（整合到 TheoryGraphics）

extension TheoryGraphics {

    /// 指板半音图（使用 HarmonyFretboardView 替代静态版本）
    @ViewBuilder
    static func harmonyFretboardGraphic(audio: TheoryTapAudio?) -> some View {
        VStack(spacing: 6) {
            Text("吉他指板上的半音（点击任意位置试听）")
                .font(.system(size: 12))
                .foregroundStyle(AppTheme.secondaryText)

            HarmonyFretboardView(
                fretboard: FretboardModel(),
                highlightNotes: [],
                highlightColor: AppTheme.accent,
                fretRange: 0..<6,
                audio: audio
            )

            Text("相邻品位 = 半音")
                .font(.system(size: 11))
                .foregroundStyle(AppTheme.secondaryText)
                .padding(.top, 4)
        }
        .padding(12)
        .background(AppTheme.secondaryBg)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    /// 和弦构成指板对照（使用 DynamicChordDiagramView）
    @ViewBuilder
    static func harmonyChordConstructionGraphic(
        formula: String, notes: [String], intervals: [String], roles: [String],
        chordName: String, audio: TheoryTapAudio?
    ) -> some View {
        HStack(alignment: .top, spacing: 16) {
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
            .padding(10)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppTheme.border, lineWidth: 0.5))

            // 右侧：动态指板
            DynamicChordDiagramView(
                chordName: chordName,
                maxVoicings: 3,
                audio: audio
            )
            .frame(maxWidth: .infinity)
        }
        .padding(8)
        .background(AppTheme.secondaryBg)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    /// 指板音阶视图
    @ViewBuilder
    static func harmonyScaleGraphic(
        root: String, mode: ScaleMode, audio: TheoryTapAudio?
    ) -> some View {
        ScaleOnFretboardView(
            root: root,
            mode: mode,
            highlightRange: 0..<12,
            audio: audio
        )
    }

    /// 和弦进行播放器
    @ViewBuilder
    static func harmonyChordProgressionGraphic(
        progression: ChordProgression, key: String, audio: TheoryTapAudio?
    ) -> some View {
        ChordProgressionPlayerView(
            progression: progression,
            initialKey: key,
            audio: audio
        )
    }

    /// 十二调速查
    @ViewBuilder
    static func harmonyAllKeysGraphic(
        progressionName: String, audio: TheoryTapAudio?
    ) -> some View {
        AllKeysGridView(
            progressionName: progressionName,
            audio: audio
        )
    }

    /// 顺阶和弦表
    @ViewBuilder
    static func harmonyDiatonicChordsGraphic(
        root: String, mode: ScaleMode, chordType: String, audio: TheoryTapAudio?
    ) -> some View {
        DiatonicChordTableView(
            root: root,
            mode: mode,
            chordType: chordType,
            audio: audio
        )
    }

    /// 和弦类型浏览器
    @ViewBuilder
    static func harmonyChordTypeBrowserGraphic(audio: TheoryTapAudio?) -> some View {
        ChordTypeBrowserView(audio: audio)
    }

    /// 和弦信息卡片组
    @ViewBuilder
    static func harmonyChordCardsGraphic(
        cards: [ChordCardItem], title: String, columns: Int, audio: TheoryTapAudio?
    ) -> some View {
        HarmonyChordCardsView(
            cards: cards,
            title: title,
            columns: columns,
            audio: audio
        )
    }
}

// MARK: - 5. 和弦信息卡片组（ChordCardItem 自动渲染）

/// 使用 HarmonyCore API 自动生成的紧凑和弦信息卡片
/// 每张卡片包含：和弦名+级数+TSD标识+构成音+微型指法图
struct HarmonyChordCardsView: View {
    let cards: [ChordCardItem]
    var title: String = ""
    var columns: Int = 2
    var audio: TheoryTapAudio? = nil

    @State private var voicingCache: [String: ChordVoicing] = [:]
    @State private var identityCache: [String: ChordIdentity] = [:]
    @State private var notesCache: [String: [String]] = [:]

    private let tsdColors: [String: Color] = [
        "T": Color(hex: "3B82F6"),
        "S": Color(hex: "10B981"),
        "D": Color(hex: "EF4444"),
    ]

    var body: some View {
        VStack(spacing: 8) {
            // 标题
            if !title.isEmpty {
                HStack {
                    Text(title)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(AppTheme.primaryText)
                    Spacer()
                    Text("\(cards.count)个和弦")
                        .font(.system(size: 11))
                        .foregroundStyle(AppTheme.secondaryText)
                }
            }

            // 卡片网格
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: columns), spacing: 8) {
                ForEach(cards) { card in
                    chordCard(card)
                }
            }
        }
        .padding(10)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.border, lineWidth: 0.5))
        .onAppear {
            let board = FretboardModel()
            for card in cards {
                let voicings = ChordFingeringSolver.solve(
                    chordName: card.chordName, on: board, maxVoicings: 1
                )
                if let voicing = voicings.first {
                    voicingCache[card.chordName] = voicing
                }
                if let (_, identity) = ChordIdentity.parse(card.chordName) {
                    identityCache[card.chordName] = identity
                    let tones = identity.tones(inRoot: identity.tones.first?.note ?? .C)
                    notesCache[card.chordName] = tones.map { $0.note.rawValue }
                }
            }
        }
    }

    @ViewBuilder
    private func chordCard(_ card: ChordCardItem) -> some View {
        let tsdColor = tsdColors[card.tsdFunction] ?? AppTheme.accent
        let voicing = voicingCache[card.chordName]
        let notes = notesCache[card.chordName] ?? []
        let identity = identityCache[card.chordName]

        VStack(spacing: 4) {
            // 顶部：级数 + 和弦名
            HStack(spacing: 6) {
                // 级数
                if !card.degree.isEmpty {
                    Text(card.degree)
                        .font(.system(size: 12, weight: .bold, design: .serif))
                        .foregroundStyle(AppTheme.primaryText)
                        .frame(width: 24)
                }

                // 和弦名
                Text(card.chordName)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundStyle(AppTheme.accent)

                Spacer()

                // TSD功能标
                if !card.tsdFunction.isEmpty {
                    Text(card.tsdFunction)
                        .font(.system(size: 9, weight: .black))
                        .foregroundStyle(tsdColor)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(tsdColor.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                }
            }

            // 中部：微型指法图（Canvas）
            if let voicing = voicing {
                miniVoicingView(voicing)
                    .frame(height: 70)
            } else {
                // 备用：构成音标签
                HStack(spacing: 2) {
                    ForEach(notes, id: \.self) { note in
                        Text(note)
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundStyle(AppTheme.secondaryText)
                            .onTapGesture { audio?.playNoteByName(note) }
                    }
                }
                .frame(height: 50)
            }

            // 底部：构成音
            HStack(spacing: 2) {
                ForEach(notes, id: \.self) { note in
                    Text(note)
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundStyle(AppTheme.primaryText)
                        .padding(.horizontal, 2)
                        .onTapGesture { audio?.playNoteByName(note) }
                }
            }

            // 标签
            if !card.label.isEmpty {
                Text(card.label)
                    .font(.system(size: 9))
                    .foregroundStyle(AppTheme.secondaryText)
                    .lineLimit(1)
            }
        }
        .padding(8)
        .background((card.tsdFunction.isEmpty ? AppTheme.secondaryBg : tsdColor.opacity(0.04)))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(tsdColor.opacity(0.15), lineWidth: 1))
        .contentShape(Rectangle())
        .onTapGesture {
            audio?.playChord(named: card.chordName)
        }
    }

    /// 微型指法图 (Canvas)
    @ViewBuilder
    private func miniVoicingView(_ voicing: ChordVoicing) -> some View {
        Canvas { ctx, size in
            let w = size.width
            let h = size.height
            let stringCount = 6
            let stringSpacing = w / CGFloat(stringCount + 1)
            let startX = stringSpacing / 2
            let topY: CGFloat = 8
            let maxVisibleFrets = 5
            let fretSpacing = (h - topY - 4) / CGFloat(maxVisibleFrets)

            // 品位线
            for i in 0...maxVisibleFrets {
                let y = topY + CGFloat(i) * fretSpacing
                let path = Path { p in
                    p.move(to: CGPoint(x: startX, y: y))
                    p.addLine(to: CGPoint(x: startX + stringSpacing * 5, y: y))
                }
                ctx.stroke(path, with: .color(i == 0 ? AppTheme.primaryText.opacity(0.3) : AppTheme.border), lineWidth: i == 0 ? 1 : 0.4)
            }

            // 弦线
            for i in 0..<stringCount {
                let x = startX + CGFloat(i) * stringSpacing
                let path = Path { p in
                    p.move(to: CGPoint(x: x, y: topY))
                    p.addLine(to: CGPoint(x: x, y: topY + CGFloat(maxVisibleFrets) * fretSpacing))
                }
                ctx.stroke(path, with: .color(Color(hex: "94A3B8")), lineWidth: 0.3 + CGFloat(5 - i) * 0.06)
            }

            // 品位标记
            let baseFret = max(0, voicing.lowestFret - 1)
            for (si, tap) in voicing.taps.enumerated() {
                let x = startX + CGFloat(si) * stringSpacing
                if let fret = tap.fret {
                    if fret == 0 {
                        let circleRect = CGRect(x: x - 3.5, y: topY - 10, width: 7, height: 7)
                        ctx.stroke(Path(ellipseIn: circleRect), with: .color(AppTheme.primaryText), lineWidth: 0.8)
                    } else {
                        let relativeFret = fret - baseFret
                        if relativeFret > 0 && relativeFret <= maxVisibleFrets {
                            let y = topY + CGFloat(relativeFret) * fretSpacing - fretSpacing / 2
                            let isRoot = tap.note?.rawValue == voicing.root.rawValue
                            let r: CGFloat = isRoot ? 5 : 4
                            let circleRect = CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)
                            ctx.fill(Path(ellipseIn: circleRect), with: .color(isRoot ? AppTheme.accent : AppTheme.primaryText))
                        }
                    }
                } else {
                    let text = Text("×")
                        .font(.system(size: 6, weight: .medium))
                        .foregroundStyle(AppTheme.tertiaryText)
                    ctx.draw(text, at: CGPoint(x: x, y: topY - 7))
                }
            }
        }
    }
}

// MARK: - 6. 十二调速查（allKeys 将和弦进行转12个调展示）

/// 将指定和弦进行在所有12个调中展开，每行一个调
struct AllKeysGridView: View {
    let progressionName: String
    var audio: TheoryTapAudio? = nil

    @State private var allKeysData: [(key: NoteName, chords: [ProgressionChord])] = []
    @State private var selectedKeyNote: NoteName? = nil

    var body: some View {
        VStack(spacing: 6) {
            // 标题
            HStack {
                if let first = allKeysData.first {
                    Text("\(first.chords.count)个和弦 × 12个调")
                        .font(.system(size: 12))
                        .foregroundStyle(AppTheme.secondaryText)
                }
                Spacer()
                Text("点击任意调试听")
                    .font(.system(size: 11))
                    .foregroundStyle(AppTheme.tertiaryText)
            }

            // 12个调
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 6) {
                    ForEach(allKeysData, id: \.key) { entry in
                        allKeysRow(key: entry.key, chords: entry.chords)
                    }
                }
            }
            .frame(maxHeight: 260)
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppTheme.border, lineWidth: 0.5))
        .onAppear {
            guard let prog = ChordProgressionEngine.builtInProgressions.first(where: { $0.name == progressionName })
            else { return }
            allKeysData = ChordProgressionEngine.allKeys(prog)
        }
    }

    @ViewBuilder
    private func allKeysRow(key: NoteName, chords: [ProgressionChord]) -> some View {
        let isHighlighted = selectedKeyNote == key
        HStack(spacing: 0) {
            // 调名标签
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(isHighlighted ? AppTheme.accent : AppTheme.accent.opacity(0.08))
                    .frame(width: 36, height: 30)
                Text(key.rawValue)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(isHighlighted ? .white : AppTheme.accent)
            }
            .onTapGesture {
                selectedKeyNote = key
                // 播放该调第一个和弦
                if let first = chords.first {
                    audio?.playChord(named: first.chordName)
                }
            }

            // 和弦序列
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(Array(chords.enumerated()), id: \.offset) { i, chord in
                        if i > 0 {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 8))
                                .foregroundStyle(AppTheme.tertiaryText)
                        }
                        Text(chord.chordName)
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundStyle(chordFunctionColor(chord.function))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background((chord.function.map { chordFunctionFill($0) } ?? AppTheme.accent).opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                            .onTapGesture {
                                audio?.playChord(named: chord.chordName)
                            }
                    }
                }
                .padding(.leading, 8)
            }
        }
        .padding(.vertical, 2)
    }

    private func chordFunctionColor(_ fn: TSDFunction?) -> Color {
        guard let fn else { return AppTheme.accent }
        switch fn {
        case .tonic: return Color(hex: "3B82F6")
        case .subdominant: return Color(hex: "10B981")
        case .dominant: return Color(hex: "EF4444")
        }
    }

    private func chordFunctionFill(_ fn: TSDFunction) -> Color {
        switch fn {
        case .tonic: return Color(hex: "3B82F6")
        case .subdominant: return Color(hex: "10B981")
        case .dominant: return Color(hex: "EF4444")
        }
    }
}

// MARK: - 6. 顺阶和弦表（diatonicTriads/SeventhChords）

/// 展示指定调式下的顺阶三和弦/七和弦表格
struct DiatonicChordTableView: View {
    let root: String           // 主音名
    let mode: ScaleMode        // 调式
    let chordType: String      // "triad" 或 "seventh"
    var audio: TheoryTapAudio? = nil

    @State private var chords: [DiatonicChord] = []
    @State private var scaleNoteMap: [String] = []

    private let tsdColors: [TSDFunction: Color] = [
        .tonic: Color(hex: "3B82F6"),
        .subdominant: Color(hex: "10B981"),
        .dominant: Color(hex: "EF4444"),
    ]

    private let tsdNames: [TSDFunction: String] = [
        .tonic: "主 T",
        .subdominant: "下属 S",
        .dominant: "属 D",
    ]

    var body: some View {
        VStack(spacing: 8) {
            // 标题
            HStack {
                Text("\(root) \(mode.nameCN)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(AppTheme.primaryText)
                Text(chordType == "seventh" ? "顺阶七和弦" : "顺阶三和弦")
                    .font(.system(size: 12))
                    .foregroundStyle(AppTheme.secondaryText)
                Spacer()
                Text("点击试听")
                    .font(.system(size: 11))
                    .foregroundStyle(AppTheme.tertiaryText)
            }

            // 表头
            HStack(spacing: 0) {
                headerCell("级数", 36)
                headerCell("和弦", 64)
                headerCell("构成音", 100)
                headerCell("功能", 56)
            }

            // 和弦行
            VStack(spacing: 4) {
                ForEach(Array(chords.enumerated()), id: \.offset) { _, chord in
                    HStack(spacing: 0) {
                        // 级数
                        Text(chord.roman)
                            .font(.system(size: 13, weight: .bold, design: .serif))
                            .foregroundStyle(AppTheme.primaryText)
                            .frame(width: 36)

                        // 和弦名
                        let chordName = "\(chord.rootNote.rawValue)\(qualityTag(chord.quality))"
                        Text(chordName)
                            .font(.system(size: 13, weight: .semibold, design: .monospaced))
                            .foregroundStyle(AppTheme.accent)
                            .frame(width: 64)
                            .onTapGesture { audio?.playChord(named: chordName) }

                        // 构成音
                        HStack(spacing: 2) {
                            ForEach(chord.tones, id: \.self) { note in
                                Text(note.rawValue)
                                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                                    .foregroundStyle(AppTheme.primaryText)
                            }
                        }
                        .frame(width: 100)

                        // 功能
                        let fnColor = tsdColors[chord.function] ?? AppTheme.secondaryText
                        Text(tsdNames[chord.function] ?? "")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(fnColor)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(fnColor.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                            .frame(width: 56)
                    }
                    .padding(.vertical, 3)
                    .padding(.horizontal, 4)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }

            // 图例
            HStack(spacing: 16) {
                funcLegend("T 主功能", Color(hex: "3B82F6"))
                funcLegend("S 下属", Color(hex: "10B981"))
                funcLegend("D 属", Color(hex: "EF4444"))
            }
            .padding(.top, 2)
        }
        .padding(12)
        .background(AppTheme.secondaryBg)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .onAppear {
            guard let rootNote = NoteName.fromString(root) else { return }
            if chordType == "seventh" {
                chords = ScaleEngine.diatonicSeventhChords(root: rootNote, mode: mode)
            } else {
                chords = ScaleEngine.diatonicTriads(root: rootNote, mode: mode)
            }
        }
    }

    private func headerCell(_ text: String, _ width: CGFloat) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .medium))
            .foregroundStyle(AppTheme.secondaryText)
            .frame(width: width, alignment: .leading)
    }

    private func funcLegend(_ label: String, _ color: Color) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 6, height: 6)
            Text(label).font(.system(size: 10)).foregroundStyle(AppTheme.secondaryText)
        }
    }

    private func qualityTag(_ q: ChordQuality) -> String {
        switch q {
        case .major: return ""
        case .minor: return "m"
        case .diminished: return "dim"
        case .augmented: return "aug"
        case .major7: return "maj7"
        case .dominant7: return "7"
        case .minor7: return "m7"
        case .halfDiminished7: return "m7♭5"
        case .diminished7: return "dim7"
        case .minorMajor7: return "mMaj7"
        }
    }
}

// MARK: - 7. 和弦类型浏览器（ChordIdentity.allTypes）

/// 浏览全部 24 种和弦类型，查看音程构成和以C为根的构成音
struct ChordTypeBrowserView: View {
    var audio: TheoryTapAudio? = nil

    @State private var selectedType: ChordIdentity? = nil

    var body: some View {
        VStack(spacing: 10) {
            // 标题
            HStack {
                Text("和弦类型大全")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(AppTheme.primaryText)
                Spacer()
                Text("\(ChordIdentity.allTypes.count)种类型")
                    .font(.system(size: 11))
                    .foregroundStyle(AppTheme.secondaryText)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(AppTheme.accent.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }

            // 分类标签
            let triads = ChordIdentity.allTypes.filter { $0.toneCount == 3 }
            let sevenths = ChordIdentity.allTypes.filter { $0.toneCount == 4 }
            let ninths = ChordIdentity.allTypes.filter { $0.toneCount == 5 }

            // 三和弦
            if !triads.isEmpty {
                typeGroupHeader("三和弦（\(triads.count)种）")
                chordTypeGrid(triads)
            }

            // 七和弦
            if !sevenths.isEmpty {
                typeGroupHeader("七和弦（\(sevenths.count)种）")
                chordTypeGrid(sevenths)
            }

            // 九和弦 / 扩展
            if !ninths.isEmpty {
                typeGroupHeader("扩展和弦（\(ninths.count)种）")
                chordTypeGrid(ninths)
            }

            // 选中类型的详细构成
            if let sel = selectedType {
                selectedDetail(sel)
            }
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppTheme.border, lineWidth: 0.5))
    }

    @ViewBuilder
    private func typeGroupHeader(_ text: String) -> some View {
        HStack {
            Text(text)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(AppTheme.secondaryText)
            Spacer()
        }
        .padding(.top, 2)
    }

    @ViewBuilder
    private func chordTypeGrid(_ types: [ChordIdentity]) -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 3), spacing: 6) {
            ForEach(types, id: \.tag) { type in
                let isSel = selectedType?.tag == type.tag
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedType = isSel ? nil : type
                    }
                    if let tones = ChordIdentity.tonesFor("C\(type.tag)") {
                        let names = tones.map { $0.note.rawValue }
                        audio?.playScale(names)
                    }
                } label: {
                    VStack(spacing: 3) {
                        Text("C\(type.tag)")
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                            .foregroundStyle(isSel ? .white : AppTheme.primaryText)
                        Text(type.nameCN)
                            .font(.system(size: 9))
                            .foregroundStyle(isSel ? .white.opacity(0.8) : AppTheme.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(isSel ? AppTheme.accent : AppTheme.secondaryBg)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder
    private func selectedDetail(_ type: ChordIdentity) -> some View {
        VStack(spacing: 8) {
            Divider().background(AppTheme.border)

            HStack(spacing: 6) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("C\(type.tag) \(type.nameCN)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AppTheme.primaryText)
                    Text("指纹key: \(type.key) · 音数: \(type.toneCount)")
                        .font(.system(size: 10))
                        .foregroundStyle(AppTheme.tertiaryText)
                }
                Spacer()
            }

            // 构成音程
            HStack(spacing: 6) {
                Text("音程:")
                    .font(.system(size: 11))
                    .foregroundStyle(AppTheme.secondaryText)
                ForEach(type.intervals, id: \.self) { interval in
                    Text(interval.chineseName)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(AppTheme.accent)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(AppTheme.accent.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                }
            }

            // 以C为根的构成音
            HStack(spacing: 6) {
                Text("C\(type.tag) =")
                    .font(.system(size: 11))
                    .foregroundStyle(AppTheme.secondaryText)
                ForEach(type.tones, id: \.note) { tone in
                    Text(tone.note.rawValue)
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundStyle(AppTheme.primaryText)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(AppTheme.accent.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                        .onTapGesture { audio?.playNoteByName(tone.note.rawValue) }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("HarmonyFretboardView") {
    ScrollView {
        VStack(spacing: 20) {
            HarmonyFretboardView(
                fretboard: FretboardModel(),
                highlightNotes: ["C", "E", "G"],
                highlightColor: AppTheme.accent,
                fretRange: 0..<8
            )
            .padding()
        }
    }
    .background(AppTheme.background)
}

#Preview("DynamicChordDiagramView") {
    ScrollView {
        VStack(spacing: 20) {
            DynamicChordDiagramView(chordName: "Cm7")
        }
        .padding()
    }
    .background(AppTheme.background)
}

#Preview("ScaleOnFretboardView") {
    ScrollView {
        VStack(spacing: 20) {
            ScaleOnFretboardView(root: "C", mode: .major)
        }
        .padding()
    }
    .background(AppTheme.background)
}

#Preview("ChordProgressionPlayerView") {
    ScrollView {
        VStack(spacing: 20) {
            ChordProgressionPlayerView(
                progression: .popCanon,
                initialKey: "C"
            )
        }
        .padding()
    }
    .background(AppTheme.background)
}
