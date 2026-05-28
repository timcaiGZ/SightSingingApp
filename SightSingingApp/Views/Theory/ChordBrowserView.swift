import SwiftUI

// MARK: - 交互式和弦浏览器

struct ChordBrowserView: View {
    @State private var selectedMode: KeyMode = .major
    @State private var selectedKey: String = "C"
    @State private var selectedChord: ChordEntry?
    @State private var selectedSectionTypes: Set<ChordSectionType> = []
    @State private var showProgressionAnalyzer = false

    private var keys: [String] {
        selectedMode == .major ? MusicTheoryHelper.majorKeys : MusicTheoryHelper.minorKeys
    }

    private var triads: [ChordEntry] {
        ChordBuilder.buildDiatonicTriads(key: selectedKey, mode: selectedMode)
    }

    var body: some View {
        VStack(spacing: 0) {
            // 顶部：调性选择
            modeKeySelector

            // 顺阶和弦条
            diatonicBar

            Divider()

            // 和弦分类网格
            chordGrid
        }
        .background(AppTheme.background)
        .navigationTitle("和弦浏览器")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showProgressionAnalyzer = true
                } label: {
                    Image(systemName: "arrow.triangle.branch")
                        .font(.system(size: 16))
                }
            }
        }
        .sheet(isPresented: $showProgressionAnalyzer) {
            NavigationStack {
                ProgressionAnalyzerView(currentKey: selectedKey, currentMode: selectedMode)
            }
        }
    }

    // MARK: - 调性选择器

    private var modeKeySelector: some View {
        VStack(spacing: 10) {
            // 大调/小调切换
            Picker("模式", selection: $selectedMode) {
                ForEach(KeyMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .onChange(of: selectedMode) { _, newMode in
                selectedKey = newMode == .major ? "C" : "Am"
            }

            // 调性选择
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(keys, id: \.self) { key in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) { selectedKey = key }
                        } label: {
                            Text(key)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(selectedKey == key ? .white : AppTheme.secondaryText)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 7)
                                .background(selectedKey == key ? AppTheme.accent : AppTheme.mutedBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 12)
        .background(Color.white)
    }

    // MARK: - 顺阶和弦条

    private var diatonicBar: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(triads.enumerated()), id: \.element.id) { i, chord in
                        DiatonicChip(
                            chord: chord,
                            degree: chord.degree,
                            isSelected: selectedChord?.label == chord.label
                        )
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedChord = selectedChord?.label == chord.label ? nil : chord
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 10)
            .background(Color.white)
        }
    }

    // MARK: - 和弦分类网格

    private var chordGrid: some View {
        ScrollView {
            VStack(spacing: 0) {
                // 详情面板
                if let chord = selectedChord {
                    chordDetailPanel(chord)
                }

                // 分类筛选
                sectionFilter

                // 和弦列表
                LazyVStack(spacing: 16) {
                    ForEach(filteredSections, id: \.self) { section in
                        chordSectionView(section)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
        }
    }

    private var filteredSections: [ChordSectionType] {
        if selectedSectionTypes.isEmpty {
            return ChordSectionType.allCases.filter { chordsForSection($0).count > 0 }
        }
        return Array(selectedSectionTypes).filter { chordsForSection($0).count > 0 }
    }

    // MARK: - 和弦详情面板

    private func chordDetailPanel(_ chord: ChordEntry) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(chord.label)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(AppTheme.primaryText)
                    Text(chord.degree)
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.secondaryText)
                }
                Spacer()

                if let tsd = chord.tsd {
                    Text(tsd.rawValue)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(tsd.color)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(tsd.bgColor)
                        .clipShape(Capsule())
                }
            }

            // 组成音
            HStack(spacing: 6) {
                Text("组成音")
                    .font(.system(size: 12))
                    .foregroundStyle(AppTheme.tertiaryText)
                ForEach(Array(chord.notes.enumerated()), id: \.offset) { i, note in
                    Text(note)
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundStyle(i == 0 ? AppTheme.accent : AppTheme.secondaryText)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(i == 0 ? AppTheme.accent.opacity(0.1) : AppTheme.mutedBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }

            // 听感
            if !chord.earCharacter.isEmpty {
                HStack(spacing: 6) {
                    Text("👂")
                    Text(chord.earCharacter)
                        .font(.system(size: 13))
                        .foregroundStyle(AppTheme.secondaryText)
                }
                .padding(10)
                .background(AppTheme.mutedBackground)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            // 乐理说明
            if !chord.info.isEmpty {
                Text(chord.info)
                    .font(.system(size: 13))
                    .foregroundStyle(AppTheme.secondaryText)
                    .lineSpacing(4)
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 1)
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }

    // MARK: - 分类筛选

    private var sectionFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ChordSectionType.allCases, id: \.self) { type in
                    let count = chordsForSection(type).count
                    if count > 0 {
                        Button {
                            if selectedSectionTypes.contains(type) {
                                selectedSectionTypes.remove(type)
                            } else {
                                selectedSectionTypes.insert(type)
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(type.color)
                                    .frame(width: 6, height: 6)
                                Text(type.rawValue)
                                    .font(.system(size: 12))
                                Text("\(count)")
                                    .font(.system(size: 11))
                                    .foregroundStyle(.secondary)
                            }
                            .foregroundStyle(selectedSectionTypes.contains(type) ? .white : AppTheme.secondaryText)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(selectedSectionTypes.contains(type) ? type.color : AppTheme.mutedBackground)
                            .clipShape(Capsule())
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 10)
    }

    // MARK: - 和弦分类视图

    private func chordSectionView(_ type: ChordSectionType) -> some View {
        let chords = chordsForSection(type)
        guard !chords.isEmpty else { return AnyView(EmptyView()) }

        return AnyView(
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(type.rawValue)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(type.color)
                    Spacer()
                    Text("\(chords.count) 个")
                        .font(.system(size: 11))
                        .foregroundStyle(AppTheme.tertiaryText)
                }

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 3), spacing: 6) {
                    ForEach(chords) { chord in
                        chordCard(chord)
                    }
                }
            }
        )
    }

    // MARK: - 和弦卡片

    private func chordCard(_ chord: ChordEntry) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedChord = selectedChord?.label == chord.label ? nil : chord
            }
        } label: {
            VStack(spacing: 4) {
                Text(chord.label)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(selectedChord?.label == chord.label ? .white : AppTheme.primaryText)

                if let tsd = chord.tsd, selectedChord?.label != chord.label {
                    Text(tsd.rawValue)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(tsd.color)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(selectedChord?.label == chord.label ? AppTheme.accent : Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(selectedChord?.label == chord.label ? Color.clear : AppTheme.border, lineWidth: 1)
            )
        }
    }

    // MARK: - 分类和弦数据

    private func chordsForSection(_ type: ChordSectionType) -> [ChordEntry] {
        switch type {
        case .triad:
            return triads
        case .seventh:
            return triads.compactMap { c in
                let tag7: String = {
                    switch c.tag {
                    case "": return "maj7"
                    case "m": return "m7"
                    case "dim": return "m7b5"
                    default: return c.tag + "7"
                    }
                }()
                let notes = ChordBuilder.buildChordNotes(root: c.root, tag: tag7)
                return ChordEntry(root: c.root, tag: tag7, label: c.root + tag7, notes: notes,
                                  degree: c.degree.replacingOccurrences(of: "m", with: "m7"),
                                  degreeIndex: c.degreeIndex, info: ChordInfoData.info[tag7] ?? "",
                                  earCharacter: EarCharacterData.characters[tag7] ?? "", tsd: c.tsd)
            }
        case .sus:
            return triads.flatMap { c in
                ["sus2", "sus4"].compactMap { tag in
                    let notes = ChordBuilder.buildChordNotes(root: c.root, tag: tag)
                    return ChordEntry(root: c.root, tag: tag, label: c.root + tag, notes: notes,
                                      degree: c.degree + tag, degreeIndex: c.degreeIndex,
                                      info: ChordInfoData.info[tag] ?? "",
                                      earCharacter: EarCharacterData.characters[tag] ?? "", tsd: c.tsd)
                }
            }
        case .add:
            return triads.compactMap { c in
                let tag = c.tag == "m" ? "madd9" : "add9"
                let notes = ChordBuilder.buildChordNotes(root: c.root, tag: tag)
                return ChordEntry(root: c.root, tag: tag, label: c.root + tag, notes: notes,
                                  degree: c.degree + "add9", degreeIndex: c.degreeIndex,
                                  info: "加九和弦：三和弦+九音，不含七音，清新明亮。",
                                  earCharacter: "清新、明亮、通透", tsd: c.tsd)
            }
        case .ninth:
            return triads.prefix(5).compactMap { c in
                let tag: String = {
                    if c.tag == "m" { return "m9" }
                    if c.degreeIndex == 4 && selectedMode == .major { return "9" }
                    return "maj9"
                }()
                let notes = ChordBuilder.buildChordNotes(root: c.root, tag: tag)
                return ChordEntry(root: c.root, tag: tag, label: c.root + tag, notes: notes,
                                  degree: c.degree + "9", degreeIndex: c.degreeIndex,
                                  info: ChordInfoData.info[tag] ?? "",
                                  earCharacter: EarCharacterData.characters[tag] ?? "", tsd: c.tsd)
            }
        case .sixth:
            return triads.compactMap { c in
                let tag = c.tag == "m" ? "m6" : "6"
                let notes = ChordBuilder.buildChordNotes(root: c.root, tag: tag)
                return ChordEntry(root: c.root, tag: tag, label: c.root + tag, notes: notes,
                                  degree: c.degree + "6", degreeIndex: c.degreeIndex,
                                  info: ChordInfoData.info[tag] ?? "",
                                  earCharacter: EarCharacterData.characters[tag] ?? "", tsd: c.tsd)
            }
        default:
            return []
        }
    }
}

// MARK: - 顺阶和弦芯片

struct DiatonicChip: View {
    let chord: ChordEntry
    let degree: String
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 2) {
            Text(degree)
                .font(.system(size: 10))
                .foregroundStyle(isSelected ? .white.opacity(0.8) : AppTheme.tertiaryText)

            Text(chord.label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(isSelected ? .white : AppTheme.primaryText)

            if let tsd = chord.tsd, !isSelected {
                Text(tsd.rawValue)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(tsd.color)
            }
        }
        .frame(width: 64)
        .padding(.vertical, 8)
        .background(
            isSelected
                ? AppTheme.accent
                : (chord.tsd?.bgColor ?? AppTheme.mutedBackground)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? Color.clear : (chord.tsd?.color.opacity(0.3) ?? AppTheme.border), lineWidth: 1)
        )
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ChordBrowserView()
    }
}
