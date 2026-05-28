import SwiftUI

// MARK: - 和弦进行分析器

struct ProgressionAnalyzerView: View {
    let currentKey: String
    let currentMode: KeyMode

    @State private var inputText: String = ""
    @State private var analyzedChords: [AnalyzedChord] = []
    @State private var selectedProgression: ProgressionInfo?
    @State private var detectedKey: String = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 输入区域
                inputSection

                // 经典模板
                templateSection

                // 分析结果
                if !analyzedChords.isEmpty {
                    analysisResult
                }

                // TSD 运动说明
                tsdMotionLegend
            }
            .padding(16)
        }
        .background(AppTheme.background)
        .navigationTitle("和弦进行分析")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            inputText = ProgressionInfo.classics.first?.chords.joined(separator: " ") ?? ""
            analyze()
        }
    }

    // MARK: - 输入区域

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("输入和弦序列")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppTheme.secondaryText)

            HStack(spacing: 8) {
                TextField("如: C Am F G", text: $inputText)
                    .font(.system(size: 15, design: .monospaced))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppTheme.border, lineWidth: 1))

                Button(action: analyze) {
                    Text("分析")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(AppTheme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
    }

    // MARK: - 模板

    private var templateSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("经典和弦进行模板")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppTheme.secondaryText)

            ForEach(ProgressionInfo.classics) { prog in
                Button {
                    selectedProgression = prog
                    inputText = prog.chords.joined(separator: " ")
                    analyze()
                } label: {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(prog.name)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(AppTheme.primaryText)

                            Spacer()

                            Text(prog.style)
                                .font(.system(size: 11))
                                .foregroundStyle(AppTheme.accent)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(AppTheme.accent.opacity(0.1))
                                .clipShape(Capsule())
                        }

                        Text(prog.degrees.joined(separator: " → "))
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundStyle(AppTheme.secondaryText)

                        Text(prog.description)
                            .font(.system(size: 12))
                            .foregroundStyle(AppTheme.tertiaryText)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(selectedProgression?.id == prog.id ? AppTheme.accent.opacity(0.05) : Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(RoundedRectangle(cornerRadius: 10)
                        .stroke(selectedProgression?.id == prog.id ? AppTheme.accent.opacity(0.3) : AppTheme.border, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
    }

    // MARK: - 分析结果

    private var analysisResult: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(AppTheme.accent)
                Text("分析结果")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppTheme.secondaryText)
                Spacer()
                Text("调性: \(detectedKey)")
                    .font(.system(size: 12))
                    .foregroundStyle(AppTheme.accent)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 3)
                    .background(AppTheme.accent.opacity(0.1))
                    .clipShape(Capsule())
            }

            VStack(spacing: 0) {
                ForEach(Array(analyzedChords.enumerated()), id: \.offset) { i, chord in
                    analyzedChordRow(chord, index: i)
                    if i < analyzedChords.count - 1 {
                        Divider().padding(.leading, 60)
                    }
                }
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func analyzedChordRow(_ chord: AnalyzedChord, index: Int) -> some View {
        HStack(spacing: 12) {
            // 序号
            Text("\(index + 1)")
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .foregroundStyle(AppTheme.tertiaryText)
                .frame(width: 24)

            // 和弦名
            Text(chord.name)
                .font(.system(size: 16, weight: .semibold, design: .monospaced))
                .foregroundStyle(chord.tsd?.color ?? AppTheme.primaryText)
                .frame(width: 60, alignment: .leading)

            // TSD 标签
            if let tsd = chord.tsd {
                Text(tsd.rawValue)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(tsd.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(tsd.bgColor)
                    .clipShape(Capsule())
            }

            // 功能
            Text(chord.function)
                .font(.system(size: 13))
                .foregroundStyle(AppTheme.secondaryText)
                .lineLimit(1)

            Spacer()

            // 运动方向
            if let motion = chord.motion {
                Text("→ \(motion)")
                    .font(.system(size: 11))
                    .foregroundStyle(AppTheme.tertiaryText)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    // MARK: - TSD 运动图例

    private var tsdMotionLegend: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("TSD 和声运动规则")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppTheme.secondaryText)

            VStack(spacing: 8) {
                ForEach(TSDFunction.allCases, id: \.self) { tsd in
                    HStack(spacing: 10) {
                        Text(tsd.rawValue)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(tsd.color)
                            .frame(width: 24)
                            .padding(6)
                            .background(tsd.bgColor)
                            .clipShape(Circle())

                        Text(tsd.displayName)
                            .font(.system(size: 13))
                            .foregroundStyle(AppTheme.primaryText)

                        Spacer()
                    }
                }
            }
            .padding(12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
    }

    // MARK: - 分析逻辑

    private func analyze() {
        let chordNames = inputText
            .components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }

        detectedKey = detectKey(chordNames)
        analyzedChords = chordNames.map { name in
            let (root, tag) = parseChord(name)
            let degIdx = findDegree(root: root, tag: tag)
            let tsd = findTSD(degIdx: degIdx)
            let function = describeFunction(degIdx: degIdx, tsd: tsd)

            return AnalyzedChord(name: name, root: root, tag: tag,
                                 degreeIndex: degIdx, tsd: tsd, function: function)
        }

        // 计算运动
        for i in 0..<analyzedChords.count {
            if i < analyzedChords.count - 1 {
                let from = analyzedChords[i].tsd
                let to = analyzedChords[i + 1].tsd
                if let f = from, let t = to {
                    analyzedChords[i].motion = TSDMotion.allMotions
                        .first { $0.from == f && $0.to == t }?.name
                }
            }
        }
    }

    private func detectKey(_ chords: [String]) -> String {
        guard !chords.isEmpty else { return currentKey }
        // 简单启发：统计根音出现频率
        var rootCount: [String: Int] = [:]
        for c in chords {
            let (root, _) = parseChord(c)
            rootCount[root, default: 0] += 1
        }
        // 检查是否在已知调性中
        let candidateKey = rootCount.max(by: { $0.value < $1.value })?.key ?? "C"
        let keyNotes = MusicTheoryHelper.keyNotes(for: candidateKey)
        let matchCount = rootCount.keys.filter { keyNotes.contains($0) }.count
        return matchCount >= chords.count / 2 ? candidateKey : currentKey
    }

    private func parseChord(_ name: String) -> (root: String, tag: String) {
        let cleaned = name.trimmingCharacters(in: .whitespaces)
        if let match = cleaned.range(of: "^[A-G][#b]?", options: .regularExpression) {
            let root = String(cleaned[match])
            let tag = String(cleaned[match.upperBound...])
            return (root, tag)
        }
        return ("C", "")
    }

    private func findDegree(root: String, tag: String) -> Int? {
        let keyNotes = MusicTheoryHelper.keyNotes(for: detectedKey)
        guard let idx = keyNotes.firstIndex(of: root) else { return nil }
        return idx
    }

    private func findTSD(degIdx: Int?) -> TSDFunction? {
        guard let idx = degIdx else { return nil }
        return currentMode == .major ? MusicTheoryHelper.tsdMajor[idx] : MusicTheoryHelper.tsdMinor[idx]
    }

    private func describeFunction(degIdx: Int?, tsd: TSDFunction?) -> String {
        guard let idx = degIdx, let t = tsd else { return "借用/变化和弦" }
        let deg = currentMode == .major ? MusicTheoryHelper.majorDegrees[idx] : MusicTheoryHelper.minorDegrees[idx]
        return "\(deg) · \(t.displayName)"
    }
}

// MARK: - 分析结果模型

struct AnalyzedChord: Identifiable {
    let id = UUID()
    let name: String
    let root: String
    let tag: String
    let degreeIndex: Int?
    let tsd: TSDFunction?
    let function: String
    var motion: String? = nil
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ProgressionAnalyzerView(currentKey: "C", currentMode: .major)
    }
}
