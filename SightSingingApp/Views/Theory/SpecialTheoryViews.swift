import SwiftUI

/// 七和弦详情页
struct SeventhChordsView: View {
    @State private var selectedKey = "C"
    @Environment(\.dismiss) private var dismiss
    
    private let keys = ["C", "G", "D", "A", "E", "F", "Bb", "Eb", "Ab", "Db"]
    
    private let chords: [String: [String]] = [
        "C": ["Cmaj7", "Dm7", "Em7", "Fmaj7", "G7", "Am7", "Bm7b5"],
        "G": ["Gmaj7", "Am7", "Bm7", "Cmaj7", "D7", "Em7", "F#m7b5"],
        "D": ["Dmaj7", "Em7", "F#m7", "Gmaj7", "A7", "Bm7", "C#m7b5"],
        "A": ["Amaj7", "Bm7", "C#m7", "Dmaj7", "E7", "F#m7", "G#m7b5"],
        "E": ["Emaj7", "F#m7", "G#m7", "Amaj7", "B7", "C#m7", "D#m7b5"],
        "F": ["Fmaj7", "Gm7", "Am7", "Bbmaj7", "C7", "Dm7", "Em7b5"],
        "Bb": ["Bbmaj7", "Cm7", "Dm7", "Ebmaj7", "F7", "Gm7", "Am7b5"],
        "Eb": ["Ebmaj7", "Fm7", "Gm7", "Abmaj7", "Bb7", "Cm7", "Dm7b5"],
        "Ab": ["Abmaj7", "Bbm7", "Cm7", "Dbmaj7", "Eb7", "Fm7", "Gm7b5"],
        "Db": ["Dbmaj7", "Ebm7", "Fm7", "Gbmaj7", "Ab7", "Bbm7", "Cm7b5"]
    ]
    
    private let chordTypes = ["maj7", "m7", "m7", "maj7", "7", "m7", "m7b5"]
    private let chordColors: [String: Color] = [
        "maj7": Color(hex: "3B82F6"),
        "m7": Color(hex: "8B5CF6"),
        "7": Color(hex: "F59E0B"),
        "m7b5": Color(hex: "EF4444")
    ]
    private let degrees = ["Ⅰ", "Ⅱ", "Ⅲ", "Ⅳ", "Ⅴ", "Ⅵ", "Ⅶ"]
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部导航
            HStack {
                Button("← 返回") {
                    dismiss()
                }
                .foregroundStyle(AppTheme.accent)
                Spacer()
                Text("七和弦")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Color.clear.frame(width: 50)
            }
            .padding(16)
            .background(Color.white)
            
            // 调选择器
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(keys, id: \.self) { key in
                        Button {
                            selectedKey = key
                        } label: {
                            Text(key)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(selectedKey == key ? .white : AppTheme.primaryText)
                                .padding(.horizontal, 11)
                                .padding(.vertical, 6)
                                .background(selectedKey == key ? AppTheme.primary : Color.white)
                                .clipShape(Capsule())
                                .overlay {
                                    Capsule()
                                        .stroke(selectedKey == key ? AppTheme.primary : AppTheme.border, lineWidth: 1.5)
                                }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            
            // 和弦列表
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(Array((chords[selectedKey] ?? chords["C"]!).enumerated()), id: \.offset) { index, chord in
                        HStack {
                            Text(degrees[index])
                                .font(.system(size: 12))
                                .foregroundStyle(AppTheme.secondaryText)
                                .frame(width: 26)
                            
                            Text(chord)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(AppTheme.primaryText)
                            
                            Spacer()
                            
                            Text(chordTypes[index])
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(chordColors[chordTypes[index]] ?? AppTheme.secondaryText)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background((chordColors[chordTypes[index]] ?? AppTheme.secondaryText).opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 7))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        
                        if index < 6 {
                            Rectangle()
                                .fill(AppTheme.border)
                                .frame(height: 1)
                        }
                    }
                }
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
                .padding(16)
            }
        }
        .background(AppTheme.background)
        .toolbar(.hidden, for: .navigationBar)
    }
}

/// 五度圈视图
struct CircleOfFifthsView: View {
    @State private var selectedKey = "C"
    @Environment(\.dismiss) private var dismiss
    
    private let majorKeys = ["C", "G", "D", "A", "E", "B", "F#", "Db", "Ab", "Eb", "Bb", "F"]
    private let minorKeys = ["Am", "Em", "Bm", "F#m", "C#m", "G#m", "D#m", "Bbm", "Fm", "Cm", "Gm", "Dm"]
    
    private let sharpCounts: [String: Int] = [
        "C": 0, "G": 1, "D": 2, "A": 3, "E": 4, "B": 5, "F#": 6,
        "Db": 5, "Ab": 4, "Eb": 3, "Bb": 2, "F": 1
    ]
    
    private let sharpKeys = ["F#", "C#", "G#", "D#", "A#", "E#"]
    private let flatKeys = ["Bb", "Eb", "Ab", "Db", "Gb", "Cb"]
    
    private var keySignature: String {
        let count = sharpCounts[selectedKey] ?? 0
        if count == 0 { return "无升降号" }
        let keys = majorKeys.firstIndex(of: selectedKey)! < 7 ? sharpKeys : flatKeys
        let sig = Array(keys.prefix(count)).joined(separator: ", ")
        return "\(count)个升号: \(sig)"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部导航
            HStack {
                Button("← 返回") {
                    dismiss()
                }
                .foregroundStyle(AppTheme.accent)
                Spacer()
                Text("五度圈")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Color.clear.frame(width: 50)
            }
            .padding(16)
            .background(Color.white)
            
            ScrollView {
                VStack(spacing: 16) {
                    // 五度圈 SVG
                    ZStack {
                        // 外圈 - 大调
                        ForEach(Array(majorKeys.enumerated()), id: \.element) { index, key in
                            let angle = Double(index) * 30 - 90
                            let radians = angle * .pi / 180
                            let x = 140 + 92 * cos(radians)
                            let y = 140 + 92 * sin(radians)
                            
                            Button {
                                selectedKey = key
                            } label: {
                                VStack(spacing: 2) {
                                    Text(key)
                                        .font(.system(size: selectedKey == key ? 13 : 12, weight: selectedKey == key ? .bold : .regular))
                                        .foregroundStyle(selectedKey == key ? .white : AppTheme.primary)
                                }
                                .frame(width: 32, height: 32)
                                .background(
                                    selectedKey == key ? AppTheme.primary : Color(hex: "EFF6FF")
                                )
                                .clipShape(Circle())
                            }
                            .offset(x: x - 156, y: y - 156)
                        }
                        
                        // 内圈 - 小调
                        ForEach(Array(minorKeys.enumerated()), id: \.element) { index, key in
                            let angle = Double(index) * 30 - 90
                            let radians = angle * .pi / 180
                            let x = 140 + 56 * cos(radians)
                            let y = 140 + 56 * sin(radians)
                            
                            Text(key)
                                .font(.system(size: 10))
                                .foregroundStyle(AppTheme.primary)
                                .frame(width: 28, height: 28)
                                .background(Color(hex: "DBEAFE"))
                                .clipShape(Circle())
                                .offset(x: x - 156, y: y - 156)
                        }
                        
                        // 中心
                        Text(selectedKey)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(AppTheme.primaryText)
                            .frame(width: 60, height: 60)
                            .background(AppTheme.mutedBackground)
                            .clipShape(Circle())
                    }
                    .frame(width: 268, height: 268)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .padding(.top, 16)
                    
                    // 升降号信息
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(selectedKey) 大调")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(AppTheme.accent)
                            Text(keySignature)
                                .font(.system(size: 13))
                                .foregroundStyle(AppTheme.primaryText)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppTheme.accent.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
        .background(AppTheme.background)
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    CircleOfFifthsView()
}

/// 乐理知识点详情页 - 四级页面
struct TheoryDetailView: View {
    let topic: TheoryTopicData
    @Environment(\.dismiss) private var dismiss
    @State private var detailData: TheoryDetailData?
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部导航
            HStack {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("返回")
                            .font(.system(size: 15))
                    }
                    .foregroundStyle(AppTheme.accent)
                }
                Spacer()
                Text(detailData?.title ?? topic.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppTheme.primaryText)
                Spacer()
                Color.clear.frame(width: 50)
            }
            .padding(16)
            .background(Color.white)
            
            ScrollView {
                VStack(spacing: 16) {
                    // === 音频示例卡片 ===
                    audioExampleCard
                    
                    // === 五度圈（如果需要）===
                    if detailData?.showCircleOfFifths == true {
                        CircleOfFifthsCompact()
                    }
                    
                    // === 内容章节 ===
                    if let details = detailData {
                        ForEach(details.sections) { section in
                            sectionCard(section)
                        }
                    } else {
                        // 加载中
                        VStack(spacing: 12) {
                            ProgressView()
                            Text("加载内容...")
                                .font(.system(size: 13))
                                .foregroundStyle(AppTheme.secondaryText)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 48)
                    }
                    
                    // === 关联练习 ===
                    relatedPracticeCard
                }
                .padding(16)
            }
        }
        .background(AppTheme.background)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            detailData = TheoryDetailDatabase.getDetail(for: topic.id)
        }
    }
    
    // MARK: - 音频示例卡片
    @ViewBuilder
    private var audioExampleCard: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("音频示例")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AppTheme.primaryText)
                    Text(detailData?.audioExample ?? "点击播放相关示例")
                        .font(.system(size: 13))
                        .foregroundStyle(AppTheme.secondaryText)
                }
                Spacer()
                Button(action: {
                    playTheoryExample()
                }) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.accent)
                            .frame(width: 48, height: 48)
                        Image(systemName: "play.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.white)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.border, lineWidth: 0.5))
    }
    
    // MARK: - 内容章节卡片
    @ViewBuilder
    private func sectionCard(_ section: TheorySection) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 6) {
                Rectangle()
                    .fill(AppTheme.accent)
                    .frame(width: 3, height: 18)
                    .clipShape(RoundedRectangle(cornerRadius: 1.5))
                Text(section.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppTheme.primaryText)
            }
            .padding(.bottom, 8)
            
            Text(section.content)
                .font(.system(size: 14))
                .foregroundStyle(AppTheme.secondaryText)
                .lineSpacing(4)
            
            // 图形内容
            if section.graphicType != .none {
                graphicView(for: section)
                    .padding(.top, 12)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.border, lineWidth: 0.5))
    }
    
    // MARK: - 关联练习卡片
    @ViewBuilder
    private var relatedPracticeCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "figure.run")
                    .font(.system(size: 14))
                    .foregroundStyle(AppTheme.accent)
                Text("关联练习")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppTheme.primaryText)
                Spacer()
            }
            
            Button(action: {
                dismiss()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 18))
                    Text("开始练习")
                        .font(.system(size: 15, weight: .medium))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(AppTheme.accent)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.border, lineWidth: 0.5))
    }
    
    // MARK: - 图形视图分发
    
    @ViewBuilder
    private func graphicView(for section: TheorySection) -> some View {
        if let data = section.graphicData {
            switch section.graphicType {
            case .solfegeNotes:
                solfegeGraphic(notes: data.notes, labels: data.labels)
            case .intervalList:
                intervalListGraphic(intervals: data.intervals)
            case .chordDiagram:
                chordDiagramGrid(chords: data.chords)
            case .fretboardHalfNotes:
                fretboardGraphic()
            case .scaleStructure:
                scaleStructureGraphic()
            case .noteDuration:
                noteDurationGraphic()
            case .wholeHalfFlow:
                wholeHalfFlowGraphic(items: data.flowItems, highlights: data.highlightIndices)
            case .beatSignature:
                beatSignatureGraphic()
            case .rhythmPattern:
                rhythmPatternGraphic()
            default:
                EmptyView()
            }
        }
    }
    
    // MARK: - 简谱/音符展示
    
    @ViewBuilder
    private func solfegeGraphic(notes: [String], labels: [String]) -> some View {
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
    private func intervalListGraphic(intervals: [IntervalItem]) -> some View {
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
            }
        }
        .padding(8)
        .background(AppTheme.secondaryBg)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - 和弦指法图
    
    @ViewBuilder
    private func chordDiagramGrid(chords: [ChordGraphicItem]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(chords) { chord in
                    VStack(spacing: 4) {
                        chordGrid(name: chord.name, frets: chord.frets, fingers: chord.fingers)
                        Text(chord.name)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(AppTheme.primaryText)
                    }
                }
            }
        }
    }
    
    private func chordGrid(name: String, frets: [Int?], fingers: [Int?]) -> some View {
        VStack(spacing: 0) {
            // 横按标记
            // 弦网格
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let stringSpacing = h / 6
                
                ZStack {
                    // 六条竖线（弦）
                    ForEach(0..<6, id: \.self) { i in
                        Rectangle()
                            .fill(Color(hex: "94A3B8"))
                            .frame(width: 0.8 + CGFloat(5 - i) * 0.15)
                            .position(x: w / 2, y: stringSpacing * CGFloat(i) + stringSpacing / 2)
                    }
                    
                    // 品位横线（顶线加粗）
                    Rectangle()
                        .fill(Color(hex: "64748B"))
                        .frame(width: w, height: 2)
                        .position(x: w / 2, y: 0)
                    
                    // 品位标记位置
                    ForEach(Array(frets.enumerated()), id: \.offset) { i, fret in
                        if let f = fret {
                            let y = stringSpacing * CGFloat(i) + stringSpacing / 2
                            if f == 0 {
                                // 空弦 - 圆圈
                                Circle()
                                    .stroke(AppTheme.primaryText, lineWidth: 1.5)
                                    .frame(width: 14, height: 14)
                                    .position(x: w / 2, y: y - 8)
                            } else {
                                // 按弦 - 实心圆
                                Circle()
                                    .fill(AppTheme.primaryText)
                                    .frame(width: 14, height: 14)
                                    .position(x: w / 2, y: y + 8)
                                // 手指标记
                                if i < (fingers.count), let finger = fingers[i] {
                                    Text("\(finger)")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundStyle(.white)
                                        .position(x: w / 2, y: y + 8)
                                }
                            }
                        } else {
                            // 不弹 - X标记
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
    private func fretboardGraphic() -> some View {
        VStack(spacing: 4) {
            Text("吉他指板上的半音")
                .font(.system(size: 12))
                .foregroundStyle(AppTheme.secondaryText)
                .padding(.bottom, 4)
            
            GeometryReader { geo in
                Canvas { ctx, size in
                    // 6条弦
                    for i in 0..<6 {
                        let y = 8 + CGFloat(i) * 8
                        let path = Path { p in
                            p.move(to: CGPoint(x: 20, y: y))
                            p.addLine(to: CGPoint(x: size.width - 20, y: y))
                        }
                        ctx.stroke(path, with: .color(Color(hex: "94A3B8")), lineWidth: 0.5 + CGFloat(i) * 0.1)
                    }
                    // 品丝
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
    private func scaleStructureGraphic() -> some View {
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
                        if i < steps.count {
                            Text(steps[i])
                                .font(.system(size: 10))
                                .foregroundStyle(steps[i] == "半" ? AppTheme.error : AppTheme.secondaryText)
                                .padding(.horizontal, 4)
                        }
                    }
                }
            }
            Text("红色标记为半音位置 (E-F, B-C)")
                .font(.system(size: 11))
                .foregroundStyle(AppTheme.secondaryText)
        }
        .padding(12)
        .background(AppTheme.secondaryBg)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - 音符时值关系图
    
    @ViewBuilder
    private func noteDurationGraphic() -> some View {
        HStack(spacing: 12) {
            ForEach(Array([("𝅝", "全音符"), ("𝅗𝅥", "二分"), ("♩", "四分"), ("♪", "八分"), ("𝅘𝅥𝅮", "十六分")].enumerated()), id: \.offset) { _, item in
                VStack(spacing: 4) {
                    Text(item.0)
                        .font(.system(size: 32))
                        .foregroundStyle(AppTheme.primaryText)
                    Text(item.1)
                        .font(.system(size: 11))
                        .foregroundStyle(AppTheme.secondaryText)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(12)
        .background(AppTheme.secondaryBg)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - 全音半音流向图
    
    @ViewBuilder
    private func wholeHalfFlowGraphic(items: [String], highlights: Set<Int>) -> some View {
        HStack(spacing: 2) {
            ForEach(Array(items.enumerated()), id: \.offset) { i, item in
                if highlights.contains(i) {
                    Text(item)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(AppTheme.error)
                } else if item == "全" || item == "半" {
                    Text(item)
                        .font(.system(size: 13))
                        .foregroundStyle(item == "半" ? AppTheme.error : AppTheme.secondaryText)
                } else {
                    Text(item)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(AppTheme.accent)
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
    
    // MARK: - 拍号展示
    
    @ViewBuilder
    private func beatSignatureGraphic() -> some View {
        VStack(spacing: 10) {
            ForEach([("4/4", "强-弱-次强-弱", "流行、摇滚标配"),
                     ("3/4", "强-弱-弱", "圆舞曲"),
                     ("6/8", "强-弱-弱-次强-弱-弱", "慢摇、抒情")], id: \.0) { beat in
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
            }
        }
        .padding(12)
        .background(AppTheme.secondaryBg)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - 节奏型展示
    
    @ViewBuilder
    private func rhythmPatternGraphic() -> some View {
        VStack(spacing: 12) {
            Text("通过'哒'唱出节奏型来练习")
                .font(.system(size: 12))
                .foregroundStyle(AppTheme.secondaryText)
            
            HStack(spacing: 16) {
                VStack(spacing: 6) {
                    Text("基本节奏")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(AppTheme.accent)
                    Text("哒 哒 哒 哒")
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .foregroundStyle(AppTheme.primaryText)
                }
                VStack(spacing: 6) {
                    Text("八分节奏")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(AppTheme.accent)
                    Text("哒哒 哒哒 哒哒 哒哒")
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundStyle(AppTheme.primaryText)
                }
                VStack(spacing: 6) {
                    Text("切分节奏")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(AppTheme.accent)
                    Text("哒 哒哒 哒 哒")
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundStyle(AppTheme.primaryText)
                }
            }
        }
        .padding(12)
        .background(AppTheme.secondaryBg)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - 音频播放
    
    private func playTheoryExample() {
        guard let topicId = detailData?.topicId else { return }
        switch topicId {
        case "notes", "note-duration":
            ExerciseSoundPlayer.playReference()
        case "interval-concept", "guitar-intervals":
            if let interval = MusicTheoryInterval.allCases.randomElement() {
                ExerciseSoundPlayer.playInterval(interval)
            }
        case "triads", "guitar-chords":
            ExerciseSoundPlayer.playTriadQuality(TriadQuality.random)
        default:
            ExerciseSoundPlayer.playReference()
        }
    }
}

// MARK: - 紧凑五度圈（用于乐理详情内嵌）

struct CircleOfFifthsCompact: View {
    @State private var selectedKey = "C"
    
    private let majorKeys = ["C", "G", "D", "A", "E", "B", "F#", "Db", "Ab", "Eb", "Bb", "F"]
    private let minorKeys = ["Am", "Em", "Bm", "F#m", "C#m", "G#m", "D#m", "Bbm", "Fm", "Cm", "Gm", "Dm"]
    
    private let sharpCounts: [String: Int] = [
        "C": 0, "G": 1, "D": 2, "A": 3, "E": 4, "B": 5, "F#": 6,
        "Db": 5, "Ab": 4, "Eb": 3, "Bb": 2, "F": 1
    ]
    
    private let sharpKeys = ["F#", "C#", "G#", "D#", "A#", "E#"]
    private let flatKeys = ["Bb", "Eb", "Ab", "Db", "Gb", "Cb"]
    
    private var keySignature: String {
        let count = sharpCounts[selectedKey] ?? 0
        if count == 0 { return "无升降号" }
        let keys = majorKeys.firstIndex(of: selectedKey)! < 7 ? sharpKeys : flatKeys
        let sig = Array(keys.prefix(count)).joined(separator: ", ")
        return "\(count)个升降号: \(sig)"
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "circle.circle")
                    .font(.system(size: 14))
                    .foregroundStyle(AppTheme.Theory.mode)
                Text("五度圈")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppTheme.primaryText)
                Spacer()
            }
            
            ZStack {
                // 外圈大调
                ForEach(Array(majorKeys.enumerated()), id: \.element) { index, key in
                    let angle = Double(index) * 30 - 90
                    let radians = angle * .pi / 180
                    let x = 110 + 72 * cos(radians)
                    let y = 110 + 72 * sin(radians)
                    
                    Button(action: { selectedKey = key }) {
                        Text(key)
                            .font(.system(size: selectedKey == key ? 11 : 10, weight: selectedKey == key ? .bold : .regular))
                            .foregroundStyle(selectedKey == key ? .white : AppTheme.Theory.mode)
                            .frame(width: 28, height: 28)
                            .background(selectedKey == key ? AppTheme.Theory.mode : Color(hex: "EFF6FF"))
                            .clipShape(Circle())
                    }
                    .offset(x: x - 110, y: y - 110)
                }
                
                // 内圈小调
                ForEach(Array(minorKeys.enumerated()), id: \.element) { index, key in
                    let angle = Double(index) * 30 - 90
                    let radians = angle * .pi / 180
                    let x = 110 + 44 * cos(radians)
                    let y = 110 + 44 * sin(radians)
                    
                    Text(key)
                        .font(.system(size: 9))
                        .foregroundStyle(AppTheme.Theory.mode)
                        .frame(width: 24, height: 24)
                        .background(Color(hex: "DBEAFE"))
                        .clipShape(Circle())
                        .offset(x: x - 110, y: y - 110)
                }
                
                // 中心
                Text(selectedKey)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(AppTheme.primaryText)
                    .frame(width: 48, height: 48)
                    .background(AppTheme.mutedBackground)
                    .clipShape(Circle())
            }
            .frame(width: 220, height: 220)
            
            // 调号信息
            VStack(alignment: .leading, spacing: 4) {
                Text("\(selectedKey) 大调")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppTheme.Theory.mode)
                Text(keySignature)
                    .font(.system(size: 13))
                    .foregroundStyle(AppTheme.primaryText)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.Theory.mode.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.border, lineWidth: 0.5))
    }
}
