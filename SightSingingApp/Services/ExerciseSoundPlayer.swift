import Foundation

/// 练习音频播放器 — 封装 AudioEngineManager，为各练习页面提供方便的音频播放 API
struct ExerciseSoundPlayer {

    // MARK: - 基准音

    /// 播放标准音 A4 (440Hz)，用于音高校准
    static func playReference() {
        Task { await AudioEngineManager.shared.playMIDI(69, duration: 0.8) }
    }

    // MARK: - 单音

    /// 播放一个随机单音（C4-B4 范围内），返回播放的音符名称
    @discardableResult
    static func playRandomNote() -> String {
        let notes: [(name: String, midi: Int)] = [
            ("C", 60), ("D", 62), ("E", 64), ("F", 65), ("G", 67), ("A", 69), ("B", 71),
        ]
        let chosen = notes.randomElement()!
        Task { await AudioEngineManager.shared.playMIDI(chosen.midi, duration: 0.8) }
        return chosen.name
    }

    /// 播放指定音名的音符（自动解析八度和升降号，如 "C4" → C4, "E" → E4, "C#4" → C#4, "Eb3" → Eb3）
    static func playNote(name: String, octave: Int = 4, duration: TimeInterval = 0.8) {
        guard let midi = parseNoteNameToMIDI(name, defaultOctave: octave) else { return }
        Task { await AudioEngineManager.shared.playMIDI(midi, duration: duration) }
    }

    /// 解析音名字符串（如 "C#4", "Eb3", "F"）到 MIDI 音符号
    static func parseNoteNameToMIDI(_ name: String, defaultOctave: Int = 4) -> Int? {
        var noteName = name
        var noteOctave = defaultOctave
        var accidental: String? = nil

        // 提取八度数字
        if let lastChar = name.last, lastChar.isNumber {
            let digitStr = String(name.reversed().prefix(while: { $0.isNumber }).reversed())
            if let parsed = Int(digitStr) {
                noteOctave = parsed
                noteName = String(name.dropLast(digitStr.count))
            }
        }

        // 提取升降号
        if noteName.hasSuffix("#") || noteName.hasSuffix("♯") {
            accidental = "#"
            noteName = String(noteName.dropLast())
        } else if noteName.hasSuffix("b") || noteName.hasSuffix("♭") {
            accidental = "b"
            noteName = String(noteName.dropLast())
        }

        // 基础音名映射
        let mapping: [String: Int] = [
            "C": 0, "D": 2, "E": 4, "F": 5, "G": 7, "A": 9, "B": 11,
        ]
        guard let baseSemitone = mapping[noteName] else { return nil }

        // 应用升降号
        var semitone = baseSemitone
        if accidental == "#" { semitone += 1 }
        if accidental == "b" { semitone -= 1 }

        return (noteOctave + 1) * 12 + semitone
    }

    // MARK: - 音程（两个音先后播放）

    /// 播放音程 — 先播放低音，延迟后播放高音
    static func playInterval(_ interval: MusicTheoryInterval, from root: String? = nil) {
        let mapping: [String: Int] = ["C": 0, "D": 2, "E": 4, "F": 5, "G": 7, "A": 9, "B": 11]
        // 随机根音（避免总是 C）
        let chosenRoot = root ?? mapping.keys.randomElement() ?? "C"
        guard let rootSemitone = mapping[chosenRoot] else { return }
        let rootMidi = 60 + rootSemitone
        let upperMidi = rootMidi + interval.semitones

        Task {
            await AudioEngineManager.shared.playMIDI(rootMidi, duration: 0.6)
            try? await Task.sleep(nanoseconds: 500_000_000)
            await AudioEngineManager.shared.playMIDI(upperMidi, duration: 0.6)
        }
    }

    // MARK: - 和弦

    /// 播放三和弦
    static func playTriadQuality(_ quality: TriadQuality, root: String? = nil) {
        let intervals = quality.intervals
        let mapping: [String: Int] = ["C": 0, "D": 2, "E": 4, "F": 5, "G": 7, "A": 9, "B": 11]
        let chosenRoot = root ?? mapping.keys.randomElement() ?? "C"
        guard let rootSemitone = mapping[chosenRoot] else { return }
        let rootMidi = 60 + rootSemitone

        let midiNotes: [Int] = [rootMidi, rootMidi + intervals[0], rootMidi + intervals[1]]

        let chordNotes = midiNotes.map { midi -> (solfege: String, octave: Int) in
            let octave = (midi / 12) - 1
            let noteInOctave = midi % 12
            let solfegeMapping: [Int: String] = [
                0: "1", 2: "2", 4: "3", 5: "4", 7: "5", 9: "6", 11: "7",
            ]
            return (solfegeMapping[noteInOctave] ?? "1", octave)
        }

        Task { await AudioEngineManager.shared.playChord(chordNotes, duration: 1.2) }
    }

    // MARK: - 通用：播放问题音频序列

    /// 标准流程：播标准音 → 0.6s 延迟 → 播题目音
    static func playStandardSequence(noteName: String) {
        Task {
            await AudioEngineManager.shared.playMIDI(69, duration: 0.8)
            try? await Task.sleep(nanoseconds: 600_000_000)
            playNote(name: noteName)
        }
    }

    // MARK: - 按名称播放（确保音频与选项一致）

    /// 根据中文音程名称播放对应音程（兜底方法，用于 QuestionBank 中找不到的名称）
    static func fallbackPlayInterval(named name: String) {
        let target = MusicTheoryInterval.allCases.first { $0.chineseName == name || $0.chineseName.contains(name) || name.contains($0.chineseName) }
        if let interval = target {
            playInterval(interval)
        } else {
            // 最终兜底：播放纯一度
            playInterval(.unison)
        }
    }

    /// 根据中文名称播放对应和弦
    static func playChordNamed(_ name: String) {
        let target: TriadQuality?
        if name.contains("大三") { target = .major }
        else if name.contains("小三") { target = .minor }
        else if name.contains("减三") { target = .diminished }
        else if name.contains("增三") { target = .augmented }
        else if name.contains("大六") { target = .major }   // 大六和弦以大三为基础
        else if name.contains("小六") { target = .minor }   // 小六和弦以小三为基础
        else { target = nil }

        if let quality = target {
            playTriadQuality(quality)
        } else {
            playTriadQuality(.major)
        }
    }
}

// MARK: - 音程枚举

enum MusicTheoryInterval: CaseIterable {
    case unison, minorSecond, majorSecond, minorThird, majorThird,
         perfectFourth, tritone, perfectFifth, minorSixth, majorSixth,
         minorSeventh, majorSeventh, octave

    var semitones: Int {
        switch self {
        case .unison: return 0
        case .minorSecond: return 1
        case .majorSecond: return 2
        case .minorThird: return 3
        case .majorThird: return 4
        case .perfectFourth: return 5
        case .tritone: return 6
        case .perfectFifth: return 7
        case .minorSixth: return 8
        case .majorSixth: return 9
        case .minorSeventh: return 10
        case .majorSeventh: return 11
        case .octave: return 12
        }
    }

    var chineseName: String {
        switch self {
        case .unison: return "纯一度"
        case .minorSecond: return "小二度"
        case .majorSecond: return "大二度"
        case .minorThird: return "小三度"
        case .majorThird: return "大三度"
        case .perfectFourth: return "纯四度"
        case .tritone: return "增四减五度"
        case .perfectFifth: return "纯五度"
        case .minorSixth: return "小六度"
        case .majorSixth: return "大六度"
        case .minorSeventh: return "小七度"
        case .majorSeventh: return "大七度"
        case .octave: return "纯八度"
        }
    }
}

// MARK: - 三和弦枚举

enum TriadQuality: CaseIterable {
    case major, minor, diminished, augmented

    /// 根音到三音、三音到五音的 半音数
    var intervals: [Int] {
        switch self {
        case .major: return [4, 7]      // 大三度 + 纯五度
        case .minor: return [3, 7]      // 小三度 + 纯五度
        case .diminished: return [3, 6] // 小三度 + 减五度
        case .augmented: return [4, 8]  // 大三度 + 增五度
        }
    }

    var chineseName: String {
        switch self {
        case .major: return "大三和弦"
        case .minor: return "小三和弦"
        case .diminished: return "减三和弦"
        case .augmented: return "增三和弦"
        }
    }

    static var random: TriadQuality {
        allCases.randomElement()!
    }
}
