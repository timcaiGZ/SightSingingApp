import Foundation

/// 题目库 - 包含所有练习模块的题目数据
struct QuestionBank {
    
    // MARK: - 音名模块题库（100+ 题）
    static let noteNameQuestions: [NoteNameQuestion] = [
        // ========== 初级（34 题）==========
        // 自然音阶音符 - C大调音阶
        NoteNameQuestion(solfege: "1", noteName: "C", octave: 4, isSharp: false, difficulty: .easy),
        NoteNameQuestion(solfege: "2", noteName: "D", octave: 4, isSharp: false, difficulty: .easy),
        NoteNameQuestion(solfege: "3", noteName: "E", octave: 4, isSharp: false, difficulty: .easy),
        NoteNameQuestion(solfege: "4", noteName: "F", octave: 4, isSharp: false, difficulty: .easy),
        NoteNameQuestion(solfege: "5", noteName: "G", octave: 4, isSharp: false, difficulty: .easy),
        NoteNameQuestion(solfege: "6", noteName: "A", octave: 4, isSharp: false, difficulty: .easy),
        NoteNameQuestion(solfege: "7", noteName: "B", octave: 4, isSharp: false, difficulty: .easy),
        
        // 高音区
        NoteNameQuestion(solfege: "1", noteName: "C", octave: 5, isSharp: false, difficulty: .easy),
        NoteNameQuestion(solfege: "2", noteName: "D", octave: 5, isSharp: false, difficulty: .easy),
        NoteNameQuestion(solfege: "3", noteName: "E", octave: 5, isSharp: false, difficulty: .easy),
        NoteNameQuestion(solfege: "5", noteName: "G", octave: 5, isSharp: false, difficulty: .easy),
        NoteNameQuestion(solfege: "6", noteName: "A", octave: 5, isSharp: false, difficulty: .easy),
        
        // 低音区
        NoteNameQuestion(solfege: "1", noteName: "C", octave: 3, isSharp: false, difficulty: .easy),
        NoteNameQuestion(solfege: "2", noteName: "D", octave: 3, isSharp: false, difficulty: .easy),
        NoteNameQuestion(solfege: "5", noteName: "G", octave: 3, isSharp: false, difficulty: .easy),
        NoteNameQuestion(solfege: "6", noteName: "A", octave: 3, isSharp: false, difficulty: .easy),
        
        // G大调音阶
        NoteNameQuestion(solfege: "1", noteName: "G", octave: 4, isSharp: false, difficulty: .easy),
        NoteNameQuestion(solfege: "2", noteName: "A", octave: 4, isSharp: false, difficulty: .easy),
        NoteNameQuestion(solfege: "3", noteName: "B", octave: 4, isSharp: false, difficulty: .easy),
        NoteNameQuestion(solfege: "5", noteName: "D", octave: 5, isSharp: false, difficulty: .easy),
        NoteNameQuestion(solfege: "6", noteName: "E", octave: 5, isSharp: false, difficulty: .easy),
        
        // D大调音阶
        NoteNameQuestion(solfege: "1", noteName: "D", octave: 4, isSharp: false, difficulty: .easy),
        NoteNameQuestion(solfege: "2", noteName: "E", octave: 4, isSharp: false, difficulty: .easy),
        NoteNameQuestion(solfege: "#4", noteName: "G", octave: 4, isSharp: true, difficulty: .easy),
        NoteNameQuestion(solfege: "5", noteName: "A", octave: 4, isSharp: false, difficulty: .easy),
        NoteNameQuestion(solfege: "6", noteName: "B", octave: 4, isSharp: false, difficulty: .easy),
        
        // A大调音阶
        NoteNameQuestion(solfege: "1", noteName: "A", octave: 3, isSharp: false, difficulty: .easy),
        NoteNameQuestion(solfege: "2", noteName: "B", octave: 3, isSharp: false, difficulty: .easy),
        NoteNameQuestion(solfege: "#4", noteName: "D", octave: 4, isSharp: true, difficulty: .easy),
        NoteNameQuestion(solfege: "5", noteName: "E", octave: 4, isSharp: false, difficulty: .easy),
        
        // ========== 中级（33 题）==========
        // 升降号音符
        NoteNameQuestion(solfege: "#1", noteName: "C#", octave: 4, isSharp: true, difficulty: .medium),
        NoteNameQuestion(solfege: "#2", noteName: "D#", octave: 4, isSharp: true, difficulty: .medium),
        NoteNameQuestion(solfege: "#4", noteName: "F#", octave: 4, isSharp: true, difficulty: .medium),
        NoteNameQuestion(solfege: "#5", noteName: "G#", octave: 4, isSharp: true, difficulty: .medium),
        NoteNameQuestion(solfege: "#6", noteName: "A#", octave: 4, isSharp: true, difficulty: .medium),
        
        NoteNameQuestion(solfege: "♭2", noteName: "Db", octave: 4, isSharp: false, difficulty: .medium),
        NoteNameQuestion(solfege: "♭3", noteName: "Eb", octave: 4, isSharp: false, difficulty: .medium),
        NoteNameQuestion(solfege: "♭5", noteName: "Gb", octave: 4, isSharp: false, difficulty: .medium),
        NoteNameQuestion(solfege: "♭6", noteName: "Ab", octave: 4, isSharp: false, difficulty: .medium),
        NoteNameQuestion(solfege: "♭7", noteName: "Bb", octave: 4, isSharp: false, difficulty: .medium),
        
        // 高音区升降号
        NoteNameQuestion(solfege: "#1", noteName: "C#", octave: 5, isSharp: true, difficulty: .medium),
        NoteNameQuestion(solfege: "#4", noteName: "F#", octave: 5, isSharp: true, difficulty: .medium),
        NoteNameQuestion(solfege: "#5", noteName: "G#", octave: 5, isSharp: true, difficulty: .medium),
        NoteNameQuestion(solfege: "♭3", noteName: "Eb", octave: 5, isSharp: false, difficulty: .medium),
        NoteNameQuestion(solfege: "♭7", noteName: "Bb", octave: 5, isSharp: false, difficulty: .medium),
        
        // 低音区升降号
        NoteNameQuestion(solfege: "#1", noteName: "C#", octave: 3, isSharp: true, difficulty: .medium),
        NoteNameQuestion(solfege: "#4", noteName: "F#", octave: 3, isSharp: true, difficulty: .medium),
        NoteNameQuestion(solfege: "♭7", noteName: "Bb", octave: 3, isSharp: false, difficulty: .medium),
        NoteNameQuestion(solfege: "♭3", noteName: "Eb", octave: 3, isSharp: false, difficulty: .medium),
        
        // E大调升降号
        NoteNameQuestion(solfege: "#4", noteName: "G#", octave: 4, isSharp: true, difficulty: .medium),
        NoteNameQuestion(solfege: "#1", noteName: "B", octave: 4, isSharp: false, difficulty: .medium),
        NoteNameQuestion(solfege: "#5", noteName: "C#", octave: 5, isSharp: true, difficulty: .medium),
        NoteNameQuestion(solfege: "#2", noteName: "F#", octave: 4, isSharp: true, difficulty: .medium),
        
        // B大调升降号
        NoteNameQuestion(solfege: "#4", noteName: "D#", octave: 4, isSharp: true, difficulty: .medium),
        NoteNameQuestion(solfege: "#1", noteName: "C#", octave: 5, isSharp: true, difficulty: .medium),
        NoteNameQuestion(solfege: "#5", noteName: "F#", octave: 5, isSharp: true, difficulty: .medium),
        NoteNameQuestion(solfege: "#2", noteName: "G#", octave: 4, isSharp: true, difficulty: .medium),
        
        // 八度扩展
        NoteNameQuestion(solfege: "1", noteName: "C", octave: 6, isSharp: false, difficulty: .medium),
        NoteNameQuestion(solfege: "5", noteName: "G", octave: 6, isSharp: false, difficulty: .medium),
        NoteNameQuestion(solfege: "1", noteName: "C", octave: 2, isSharp: false, difficulty: .medium),
        NoteNameQuestion(solfege: "6", noteName: "A", octave: 2, isSharp: false, difficulty: .medium),
        
        // ========== 高级（33 题）==========
        // 重升音
        NoteNameQuestion(solfege: "×4", noteName: "Fx", octave: 4, isSharp: true, difficulty: .hard),
        NoteNameQuestion(solfege: "×5", noteName: "Gx", octave: 4, isSharp: true, difficulty: .hard),
        NoteNameQuestion(solfege: "×1", noteName: "Cx", octave: 5, isSharp: true, difficulty: .hard),
        NoteNameQuestion(solfege: "×2", noteName: "Dx", octave: 5, isSharp: true, difficulty: .hard),
        NoteNameQuestion(solfege: "×6", noteName: "Ax", octave: 4, isSharp: true, difficulty: .hard),
        
        // 重降音
        NoteNameQuestion(solfege: "♭♭3", noteName: "Ebb", octave: 4, isSharp: false, difficulty: .hard),
        NoteNameQuestion(solfege: "♭♭5", noteName: "Gbb", octave: 4, isSharp: false, difficulty: .hard),
        NoteNameQuestion(solfege: "♭♭7", noteName: "Bbb", octave: 4, isSharp: false, difficulty: .hard),
        NoteNameQuestion(solfege: "♭♭2", noteName: "Dbb", octave: 4, isSharp: false, difficulty: .hard),
        NoteNameQuestion(solfege: "♭♭6", noteName: "Abb", octave: 4, isSharp: false, difficulty: .hard),
        
        // 跨八度音程
        NoteNameQuestion(solfege: "1", noteName: "C", octave: 7, isSharp: false, difficulty: .hard),
        NoteNameQuestion(solfege: "3", noteName: "E", octave: 6, isSharp: false, difficulty: .hard),
        NoteNameQuestion(solfege: "5", noteName: "G", octave: 7, isSharp: false, difficulty: .hard),
        NoteNameQuestion(solfege: "1", noteName: "C", octave: 1, isSharp: false, difficulty: .hard),
        NoteNameQuestion(solfege: "2", noteName: "D", octave: 2, isSharp: false, difficulty: .hard),
        
        // 非标准八度位置
        NoteNameQuestion(solfege: "4", noteName: "F", octave: 6, isSharp: false, difficulty: .hard),
        NoteNameQuestion(solfege: "7", noteName: "B", octave: 6, isSharp: false, difficulty: .hard),
        NoteNameQuestion(solfege: "6", noteName: "A", octave: 1, isSharp: false, difficulty: .hard),
        NoteNameQuestion(solfege: "3", noteName: "E", octave: 2, isSharp: false, difficulty: .hard),
        
        // 复杂和声音程
        NoteNameQuestion(solfege: "#1", noteName: "C#", octave: 6, isSharp: true, difficulty: .hard),
        NoteNameQuestion(solfege: "♭5", noteName: "Gb", octave: 5, isSharp: false, difficulty: .hard),
        NoteNameQuestion(solfege: "#4", noteName: "F#", octave: 7, isSharp: true, difficulty: .hard),
        NoteNameQuestion(solfege: "♭2", noteName: "Db", octave: 3, isSharp: false, difficulty: .hard),
        NoteNameQuestion(solfege: "#6", noteName: "A#", octave: 5, isSharp: true, difficulty: .hard),
        
        // 混合复杂音
        NoteNameQuestion(solfege: "×4", noteName: "Fx", octave: 5, isSharp: true, difficulty: .hard),
        NoteNameQuestion(solfege: "♭♭5", noteName: "Gbb", octave: 6, isSharp: false, difficulty: .hard),
        NoteNameQuestion(solfege: "#2", noteName: "D#", octave: 7, isSharp: true, difficulty: .hard),
        NoteNameQuestion(solfege: "♭♭1", noteName: "Cbb", octave: 4, isSharp: false, difficulty: .hard),
        NoteNameQuestion(solfege: "×5", noteName: "Gx", octave: 2, isSharp: true, difficulty: .hard),
        NoteNameQuestion(solfege: "♭♭4", noteName: "Fbb", octave: 5, isSharp: false, difficulty: .hard),
        NoteNameQuestion(solfege: "#7", noteName: "B#", octave: 4, isSharp: true, difficulty: .hard),
        NoteNameQuestion(solfege: "♭1", noteName: "Cb", octave: 5, isSharp: false, difficulty: .hard),
    ]
    
    // MARK: - 音程模块题库（100+ 题）
    static let intervalQuestions: [IntervalQuestion] = [
        // ========== 初级（34 题）==========
        // 纯一度
        IntervalQuestion(name: "纯一度", shortName: "P1", semitones: 0, difficulty: .easy),
        IntervalQuestion(name: "纯一度", shortName: "P1", semitones: 0, difficulty: .easy),
        IntervalQuestion(name: "纯一度", shortName: "P1", semitones: 0, difficulty: .easy),
        IntervalQuestion(name: "纯一度", shortName: "P1", semitones: 0, difficulty: .easy),
        IntervalQuestion(name: "纯一度", shortName: "P1", semitones: 0, difficulty: .easy),
        IntervalQuestion(name: "纯一度", shortName: "P1", semitones: 0, difficulty: .easy),
        IntervalQuestion(name: "纯一度", shortName: "P1", semitones: 0, difficulty: .easy),
        IntervalQuestion(name: "纯一度", shortName: "P1", semitones: 0, difficulty: .easy),
        IntervalQuestion(name: "纯一度", shortName: "P1", semitones: 0, difficulty: .easy),
        IntervalQuestion(name: "纯一度", shortName: "P1", semitones: 0, difficulty: .easy),
        
        // 纯八度
        IntervalQuestion(name: "纯八度", shortName: "P8", semitones: 12, difficulty: .easy),
        IntervalQuestion(name: "纯八度", shortName: "P8", semitones: 12, difficulty: .easy),
        IntervalQuestion(name: "纯八度", shortName: "P8", semitones: 12, difficulty: .easy),
        IntervalQuestion(name: "纯八度", shortName: "P8", semitones: 12, difficulty: .easy),
        IntervalQuestion(name: "纯八度", shortName: "P8", semitones: 12, difficulty: .easy),
        IntervalQuestion(name: "纯八度", shortName: "P8", semitones: 12, difficulty: .easy),
        IntervalQuestion(name: "纯八度", shortName: "P8", semitones: 12, difficulty: .easy),
        IntervalQuestion(name: "纯八度", shortName: "P8", semitones: 12, difficulty: .easy),
        IntervalQuestion(name: "纯八度", shortName: "P8", semitones: 12, difficulty: .easy),
        IntervalQuestion(name: "纯八度", shortName: "P8", semitones: 12, difficulty: .easy),
        
        // 大二度
        IntervalQuestion(name: "大二度", shortName: "M2", semitones: 2, difficulty: .easy),
        IntervalQuestion(name: "大二度", shortName: "M2", semitones: 2, difficulty: .easy),
        IntervalQuestion(name: "大二度", shortName: "M2", semitones: 2, difficulty: .easy),
        IntervalQuestion(name: "大二度", shortName: "M2", semitones: 2, difficulty: .easy),
        IntervalQuestion(name: "大二度", shortName: "M2", semitones: 2, difficulty: .easy),
        
        // 大三度
        IntervalQuestion(name: "大三度", shortName: "M3", semitones: 4, difficulty: .easy),
        IntervalQuestion(name: "大三度", shortName: "M3", semitones: 4, difficulty: .easy),
        IntervalQuestion(name: "大三度", shortName: "M3", semitones: 4, difficulty: .easy),
        IntervalQuestion(name: "大三度", shortName: "M3", semitones: 4, difficulty: .easy),
        IntervalQuestion(name: "大三度", shortName: "M3", semitones: 4, difficulty: .easy),
        
        // 小三度
        IntervalQuestion(name: "小三度", shortName: "m3", semitones: 3, difficulty: .easy),
        IntervalQuestion(name: "小三度", shortName: "m3", semitones: 3, difficulty: .easy),
        IntervalQuestion(name: "小三度", shortName: "m3", semitones: 3, difficulty: .easy),
        IntervalQuestion(name: "小三度", shortName: "m3", semitones: 3, difficulty: .easy),
        
        // ========== 中级（33 题）==========
        // 纯四度
        IntervalQuestion(name: "纯四度", shortName: "P4", semitones: 5, difficulty: .medium),
        IntervalQuestion(name: "纯四度", shortName: "P4", semitones: 5, difficulty: .medium),
        IntervalQuestion(name: "纯四度", shortName: "P4", semitones: 5, difficulty: .medium),
        IntervalQuestion(name: "纯四度", shortName: "P4", semitones: 5, difficulty: .medium),
        IntervalQuestion(name: "纯四度", shortName: "P4", semitones: 5, difficulty: .medium),
        IntervalQuestion(name: "纯四度", shortName: "P4", semitones: 5, difficulty: .medium),
        IntervalQuestion(name: "纯四度", shortName: "P4", semitones: 5, difficulty: .medium),
        IntervalQuestion(name: "纯四度", shortName: "P4", semitones: 5, difficulty: .medium),
        IntervalQuestion(name: "纯四度", shortName: "P4", semitones: 5, difficulty: .medium),
        IntervalQuestion(name: "纯四度", shortName: "P4", semitones: 5, difficulty: .medium),
        
        // 纯五度
        IntervalQuestion(name: "纯五度", shortName: "P5", semitones: 7, difficulty: .medium),
        IntervalQuestion(name: "纯五度", shortName: "P5", semitones: 7, difficulty: .medium),
        IntervalQuestion(name: "纯五度", shortName: "P5", semitones: 7, difficulty: .medium),
        IntervalQuestion(name: "纯五度", shortName: "P5", semitones: 7, difficulty: .medium),
        IntervalQuestion(name: "纯五度", shortName: "P5", semitones: 7, difficulty: .medium),
        IntervalQuestion(name: "纯五度", shortName: "P5", semitones: 7, difficulty: .medium),
        IntervalQuestion(name: "纯五度", shortName: "P5", semitones: 7, difficulty: .medium),
        IntervalQuestion(name: "纯五度", shortName: "P5", semitones: 7, difficulty: .medium),
        
        // 大六度
        IntervalQuestion(name: "大六度", shortName: "M6", semitones: 9, difficulty: .medium),
        IntervalQuestion(name: "大六度", shortName: "M6", semitones: 9, difficulty: .medium),
        IntervalQuestion(name: "大六度", shortName: "M6", semitones: 9, difficulty: .medium),
        IntervalQuestion(name: "大六度", shortName: "M6", semitones: 9, difficulty: .medium),
        IntervalQuestion(name: "大六度", shortName: "M6", semitones: 9, difficulty: .medium),
        IntervalQuestion(name: "大六度", shortName: "M6", semitones: 9, difficulty: .medium),
        IntervalQuestion(name: "大六度", shortName: "M6", semitones: 9, difficulty: .medium),
        IntervalQuestion(name: "大六度", shortName: "M6", semitones: 9, difficulty: .medium),
        
        // 小六度
        IntervalQuestion(name: "小六度", shortName: "m6", semitones: 8, difficulty: .medium),
        IntervalQuestion(name: "小六度", shortName: "m6", semitones: 8, difficulty: .medium),
        IntervalQuestion(name: "小六度", shortName: "m6", semitones: 8, difficulty: .medium),
        IntervalQuestion(name: "小六度", shortName: "m6", semitones: 8, difficulty: .medium),
        IntervalQuestion(name: "小六度", shortName: "m6", semitones: 8, difficulty: .medium),
        IntervalQuestion(name: "小六度", shortName: "m6", semitones: 8, difficulty: .medium),
        IntervalQuestion(name: "小六度", shortName: "m6", semitones: 8, difficulty: .medium),
        
        // ========== 高级（33 题）==========
        // 大七度
        IntervalQuestion(name: "大七度", shortName: "M7", semitones: 11, difficulty: .hard),
        IntervalQuestion(name: "大七度", shortName: "M7", semitones: 11, difficulty: .hard),
        IntervalQuestion(name: "大七度", shortName: "M7", semitones: 11, difficulty: .hard),
        IntervalQuestion(name: "大七度", shortName: "M7", semitones: 11, difficulty: .hard),
        IntervalQuestion(name: "大七度", shortName: "M7", semitones: 11, difficulty: .hard),
        IntervalQuestion(name: "大七度", shortName: "M7", semitones: 11, difficulty: .hard),
        IntervalQuestion(name: "大七度", shortName: "M7", semitones: 11, difficulty: .hard),
        IntervalQuestion(name: "大七度", shortName: "M7", semitones: 11, difficulty: .hard),
        
        // 小七度
        IntervalQuestion(name: "小七度", shortName: "m7", semitones: 10, difficulty: .hard),
        IntervalQuestion(name: "小七度", shortName: "m7", semitones: 10, difficulty: .hard),
        IntervalQuestion(name: "小七度", shortName: "m7", semitones: 10, difficulty: .hard),
        IntervalQuestion(name: "小七度", shortName: "m7", semitones: 10, difficulty: .hard),
        IntervalQuestion(name: "小七度", shortName: "m7", semitones: 10, difficulty: .hard),
        IntervalQuestion(name: "小七度", shortName: "m7", semitones: 10, difficulty: .hard),
        IntervalQuestion(name: "小七度", shortName: "m7", semitones: 10, difficulty: .hard),
        
        // 增四度/减五度（三全音）
        IntervalQuestion(name: "增四度", shortName: "A4", semitones: 6, difficulty: .hard),
        IntervalQuestion(name: "增四度", shortName: "A4", semitones: 6, difficulty: .hard),
        IntervalQuestion(name: "增四度", shortName: "A4", semitones: 6, difficulty: .hard),
        IntervalQuestion(name: "增四度", shortName: "A4", semitones: 6, difficulty: .hard),
        IntervalQuestion(name: "增四度", shortName: "A4", semitones: 6, difficulty: .hard),
        IntervalQuestion(name: "减五度", shortName: "d5", semitones: 6, difficulty: .hard),
        IntervalQuestion(name: "减五度", shortName: "d5", semitones: 6, difficulty: .hard),
        IntervalQuestion(name: "减五度", shortName: "d5", semitones: 6, difficulty: .hard),
        IntervalQuestion(name: "减五度", shortName: "d5", semitones: 6, difficulty: .hard),
        IntervalQuestion(name: "减五度", shortName: "d5", semitones: 6, difficulty: .hard),
        
        // 增音程
        IntervalQuestion(name: "增二度", shortName: "A2", semitones: 3, difficulty: .hard),
        IntervalQuestion(name: "增三度", shortName: "A3", semitones: 5, difficulty: .hard),
        IntervalQuestion(name: "增六度", shortName: "A6", semitones: 10, difficulty: .hard),
        IntervalQuestion(name: "增七度", shortName: "A7", semitones: 12, difficulty: .hard),
        
        // 减音程
        IntervalQuestion(name: "减二度", shortName: "d2", semitones: 1, difficulty: .hard),
        IntervalQuestion(name: "减三度", shortName: "d3", semitones: 2, difficulty: .hard),
        IntervalQuestion(name: "减四度", shortName: "d4", semitones: 4, difficulty: .hard),
        IntervalQuestion(name: "减六度", shortName: "d6", semitones: 7, difficulty: .hard),
        IntervalQuestion(name: "减七度", shortName: "d7", semitones: 9, difficulty: .hard),
        IntervalQuestion(name: "减八度", shortName: "d8", semitones: 11, difficulty: .hard),
    ]
    
    // MARK: - 和弦模块题库（100+ 题）
    static let chordQuestions: [ChordQuestion] = [
        // ========== 初级（34 题）==========
        // 大三和弦
        ChordQuestion(name: "C", notes: [("1", 4), ("3", 4), ("5", 4)], difficulty: .easy),
        ChordQuestion(name: "D", notes: [("2", 4), ("#4", 4), ("6", 4)], difficulty: .easy),
        ChordQuestion(name: "E", notes: [("3", 4), ("#5", 4), ("7", 4)], difficulty: .easy),
        ChordQuestion(name: "F", notes: [("4", 4), ("6", 4), ("1", 5)], difficulty: .easy),
        ChordQuestion(name: "G", notes: [("5", 3), ("7", 3), ("2", 4)], difficulty: .easy),
        ChordQuestion(name: "A", notes: [("6", 3), ("#1", 3), ("3", 4)], difficulty: .easy),
        ChordQuestion(name: "B", notes: [("7", 3), ("#2", 3), ("#4", 4)], difficulty: .easy),
        
        // 大三和弦重复
        ChordQuestion(name: "C", notes: [("1", 3), ("3", 3), ("5", 3)], difficulty: .easy),
        ChordQuestion(name: "G", notes: [("5", 4), ("7", 4), ("2", 5)], difficulty: .easy),
        ChordQuestion(name: "D", notes: [("2", 3), ("#4", 3), ("6", 4)], difficulty: .easy),
        ChordQuestion(name: "F", notes: [("4", 3), ("6", 3), ("1", 4)], difficulty: .easy),
        
        // 小三和弦
        ChordQuestion(name: "Am", notes: [("6", 4), ("1", 4), ("3", 4)], difficulty: .easy),
        ChordQuestion(name: "Bm", notes: [("7", 3), ("2", 4), ("4", 4)], difficulty: .easy),
        ChordQuestion(name: "Cm", notes: [("1", 4), ("♭3", 4), ("5", 4)], difficulty: .easy),
        ChordQuestion(name: "Dm", notes: [("2", 4), ("4", 4), ("6", 4)], difficulty: .easy),
        ChordQuestion(name: "Em", notes: [("3", 4), ("5", 4), ("7", 4)], difficulty: .easy),
        
        // 小三和弦重复
        ChordQuestion(name: "Am", notes: [("6", 3), ("1", 3), ("3", 3)], difficulty: .easy),
        ChordQuestion(name: "Dm", notes: [("2", 3), ("4", 3), ("6", 3)], difficulty: .easy),
        ChordQuestion(name: "Em", notes: [("3", 3), ("5", 3), ("7", 3)], difficulty: .easy),
        ChordQuestion(name: "Bm", notes: [("7", 2), ("2", 3), ("4", 3)], difficulty: .easy),
        ChordQuestion(name: "Cm", notes: [("1", 3), ("♭3", 3), ("5", 3)], difficulty: .easy),
        ChordQuestion(name: "Dm", notes: [("2", 5), ("4", 5), ("6", 5)], difficulty: .easy),
        ChordQuestion(name: "Em", notes: [("3", 5), ("5", 5), ("7", 5)], difficulty: .easy),
        ChordQuestion(name: "Am", notes: [("6", 5), ("1", 5), ("3", 5)], difficulty: .easy),
        
        // 属七和弦（简化版）
        ChordQuestion(name: "G7", notes: [("5", 3), ("7", 3), ("2", 4), ("4", 4)], difficulty: .easy),
        ChordQuestion(name: "A7", notes: [("6", 3), ("#1", 3), ("3", 4), ("5", 4)], difficulty: .easy),
        ChordQuestion(name: "D7", notes: [("2", 4), ("#4", 4), ("6", 4), ("1", 5)], difficulty: .easy),
        ChordQuestion(name: "E7", notes: [("3", 4), ("#5", 4), ("7", 4), ("2", 5)], difficulty: .easy),
        ChordQuestion(name: "C7", notes: [("1", 4), ("3", 4), ("5", 4), ("♭7", 4)], difficulty: .easy),
        
        // ========== 中级（33 题）==========
        // 大横按和弦
        ChordQuestion(name: "F(大横按)", notes: [("4", 4), ("6", 4), ("1", 5), ("3", 5)], difficulty: .medium),
        ChordQuestion(name: "F(大横按)", notes: [("4", 3), ("6", 3), ("1", 4), ("3", 4)], difficulty: .medium),
        ChordQuestion(name: "Bm", notes: [("7", 2), ("2", 3), ("4", 3), ("2", 3)], difficulty: .medium),
        ChordQuestion(name: "Bm", notes: [("7", 3), ("2", 4), ("4", 4), ("2", 4)], difficulty: .medium),
        ChordQuestion(name: "B", notes: [("7", 3), ("#2", 3), ("#4", 4), ("#4", 4)], difficulty: .medium),
        ChordQuestion(name: "B", notes: [("7", 2), ("#2", 2), ("#4", 3), ("#4", 3)], difficulty: .medium),
        
        // 大横按重复练习
        ChordQuestion(name: "F(大横按)", notes: [("4", 5), ("6", 5), ("1", 6), ("3", 6)], difficulty: .medium),
        ChordQuestion(name: "Bm", notes: [("7", 4), ("2", 5), ("4", 5), ("2", 5)], difficulty: .medium),
        ChordQuestion(name: "B", notes: [("7", 4), ("#2", 4), ("#4", 5), ("#4", 5)], difficulty: .medium),
        
        // 其他常见和弦
        ChordQuestion(name: "Dm", notes: [("2", 4), ("4", 4), ("6", 4)], difficulty: .medium),
        ChordQuestion(name: "Dm", notes: [("2", 5), ("4", 5), ("6", 5)], difficulty: .medium),
        ChordQuestion(name: "Dsus2", notes: [("2", 4), ("3", 4), ("6", 4)], difficulty: .medium),
        ChordQuestion(name: "Dsus4", notes: [("2", 4), ("4", 4), ("5", 4)], difficulty: .medium),
        ChordQuestion(name: "Asus2", notes: [("6", 3), ("7", 3), ("3", 4)], difficulty: .medium),
        ChordQuestion(name: "Asus4", notes: [("6", 3), ("7", 3), ("2", 4)], difficulty: .medium),
        ChordQuestion(name: "Esus4", notes: [("3", 4), ("#5", 4), ("6", 4)], difficulty: .medium),
        ChordQuestion(name: "Gsus4", notes: [("5", 3), ("1", 4), ("2", 4)], difficulty: .medium),
        
        // 七和弦
        ChordQuestion(name: "Am7", notes: [("6", 4), ("1", 4), ("3", 4), ("5", 4)], difficulty: .medium),
        ChordQuestion(name: "Dm7", notes: [("2", 4), ("4", 4), ("6", 4), ("1", 5)], difficulty: .medium),
        ChordQuestion(name: "Em7", notes: [("3", 4), ("5", 4), ("7", 4), ("2", 5)], difficulty: .medium),
        ChordQuestion(name: "Cmaj7", notes: [("1", 4), ("3", 4), ("5", 4), ("7", 4)], difficulty: .medium),
        ChordQuestion(name: "Fmaj7", notes: [("4", 4), ("6", 4), ("1", 5), ("3", 5)], difficulty: .medium),
        ChordQuestion(name: "Gmaj7", notes: [("5", 3), ("7", 3), ("2", 4), ("4", 4)], difficulty: .medium),
        ChordQuestion(name: "Dmaj7", notes: [("2", 4), ("#4", 4), ("6", 4), ("#1", 5)], difficulty: .medium),
        
        // 半减七和弦
        ChordQuestion(name: "Bø7", notes: [("7", 3), ("2", 4), ("4", 4), ("6", 4)], difficulty: .medium),
        ChordQuestion(name: "Eø7", notes: [("3", 4), ("5", 4), ("7", 4), ("2", 5)], difficulty: .medium),
        ChordQuestion(name: "Aø7", notes: [("6", 3), ("1", 4), ("3", 4), ("5", 4)], difficulty: .medium),
        
        // ========== 高级（33 题）==========
        // 大七和弦
        ChordQuestion(name: "Cmaj7", notes: [("1", 3), ("3", 3), ("5", 3), ("7", 3)], difficulty: .hard),
        ChordQuestion(name: "Dmaj7", notes: [("2", 3), ("#4", 3), ("6", 3), ("#1", 4)], difficulty: .hard),
        ChordQuestion(name: "Emaj7", notes: [("3", 3), ("#5", 3), ("7", 3), ("#2", 4)], difficulty: .hard),
        ChordQuestion(name: "Fmaj7", notes: [("4", 3), ("6", 3), ("1", 4), ("3", 4)], difficulty: .hard),
        ChordQuestion(name: "Amaj7", notes: [("6", 3), ("#1", 3), ("3", 4), ("5", 4)], difficulty: .hard),
        ChordQuestion(name: "Bmaj7", notes: [("7", 3), ("#2", 3), ("#4", 4), ("#6", 4)], difficulty: .hard),
        
        // 小七和弦
        ChordQuestion(name: "Am7", notes: [("6", 3), ("1", 3), ("3", 3), ("5", 3)], difficulty: .hard),
        ChordQuestion(name: "Dm7", notes: [("2", 3), ("4", 3), ("6", 3), ("1", 4)], difficulty: .hard),
        ChordQuestion(name: "Em7", notes: [("3", 3), ("5", 3), ("7", 3), ("2", 4)], difficulty: .hard),
        ChordQuestion(name: "Bm7", notes: [("7", 2), ("2", 3), ("4", 3), ("6", 3)], difficulty: .hard),
        ChordQuestion(name: "Cm7", notes: [("1", 3), ("♭3", 3), ("5", 3), ("♭7", 3)], difficulty: .hard),
        ChordQuestion(name: "Fm7", notes: [("4", 3), ("♭6", 3), ("1", 4), ("♭3", 4)], difficulty: .hard),
        ChordQuestion(name: "Gm7", notes: [("5", 3), ("♭7", 3), ("2", 4), ("4", 4)], difficulty: .hard),
        
        // 属七和弦
        ChordQuestion(name: "G7", notes: [("5", 4), ("7", 4), ("2", 5), ("4", 5)], difficulty: .hard),
        ChordQuestion(name: "A7", notes: [("6", 4), ("#1", 4), ("3", 5), ("5", 5)], difficulty: .hard),
        ChordQuestion(name: "D7", notes: [("2", 5), ("#4", 5), ("6", 5), ("1", 6)], difficulty: .hard),
        ChordQuestion(name: "E7", notes: [("3", 5), ("#5", 5), ("7", 5), ("2", 6)], difficulty: .hard),
        ChordQuestion(name: "B7", notes: [("7", 3), ("#2", 3), ("#4", 4), ("6", 4)], difficulty: .hard),
        
        // 挂留和弦
        ChordQuestion(name: "Dsus2", notes: [("2", 5), ("3", 5), ("6", 5)], difficulty: .hard),
        ChordQuestion(name: "Dsus4", notes: [("2", 5), ("4", 5), ("5", 5)], difficulty: .hard),
        ChordQuestion(name: "Asus2", notes: [("6", 5), ("7", 5), ("3", 6)], difficulty: .hard),
        ChordQuestion(name: "Asus4", notes: [("6", 5), ("7", 5), ("2", 6)], difficulty: .hard),
        ChordQuestion(name: "Esus4", notes: [("3", 5), ("#5", 5), ("6", 5)], difficulty: .hard),
        ChordQuestion(name: "Gsus2", notes: [("5", 4), ("6", 4), ("2", 5)], difficulty: .hard),
        
        // 加音和弦
        ChordQuestion(name: "Cadd9", notes: [("1", 4), ("3", 4), ("5", 4), ("2", 5)], difficulty: .hard),
        ChordQuestion(name: "Dadd9", notes: [("2", 4), ("#4", 4), ("6", 4), ("3", 5)], difficulty: .hard),
        ChordQuestion(name: "Gadd9", notes: [("5", 3), ("7", 3), ("2", 4), ("6", 4)], difficulty: .hard),
        ChordQuestion(name: "Em9", notes: [("3", 4), ("5", 4), ("7", 4), ("2", 5), ("4", 5)], difficulty: .hard),
        ChordQuestion(name: "Am9", notes: [("6", 4), ("1", 4), ("3", 4), ("2", 5)], difficulty: .hard),
        
        // 6和弦
        ChordQuestion(name: "C6", notes: [("1", 4), ("3", 4), ("5", 4), ("6", 4)], difficulty: .hard),
        ChordQuestion(name: "Am6", notes: [("6", 4), ("1", 4), ("3", 4), ("#5", 4)], difficulty: .hard),
        ChordQuestion(name: "Dm6", notes: [("2", 4), ("4", 4), ("6", 4), ("#1", 5)], difficulty: .hard),
        ChordQuestion(name: "Em6", notes: [("3", 4), ("5", 4), ("7", 4), ("#2", 5)], difficulty: .hard),
    ]
    
    // MARK: - 调式模块题库（100+ 题）
    static let scaleQuestions: [ScaleQuestion] = [
        // ========== 初级（34 题）==========
        // C大调
        ScaleQuestion(name: "C大调", root: "C", notes: ["1", "2", "3", "4", "5", "6", "7"], difficulty: .easy),
        ScaleQuestion(name: "C大调", root: "C", notes: ["C", "D", "E", "F", "G", "A", "B"], difficulty: .easy),
        ScaleQuestion(name: "C大调音阶", root: "C", notes: ["do", "re", "mi", "fa", "sol", "la", "ti"], difficulty: .easy),
        ScaleQuestion(name: "C大调", root: "C", notes: ["1", "3", "5"], difficulty: .easy),
        ScaleQuestion(name: "C大调主和弦", root: "C", notes: ["C", "E", "G"], difficulty: .easy),
        ScaleQuestion(name: "C大调", root: "C", notes: ["2", "4", "6"], difficulty: .easy),
        ScaleQuestion(name: "C大调下属和弦", root: "F", notes: ["F", "A", "C"], difficulty: .easy),
        ScaleQuestion(name: "C大调属和弦", root: "G", notes: ["G", "B", "D"], difficulty: .easy),
        ScaleQuestion(name: "C大调", root: "C", notes: ["4", "6", "1"], difficulty: .easy),
        ScaleQuestion(name: "C大调", root: "C", notes: ["5", "7", "2"], difficulty: .easy),
        
        // G大调
        ScaleQuestion(name: "G大调", root: "G", notes: ["5", "6", "7", "1", "2", "3", "#4"], difficulty: .easy),
        ScaleQuestion(name: "G大调", root: "G", notes: ["G", "A", "B", "C", "D", "E", "F#"], difficulty: .easy),
        ScaleQuestion(name: "G大调音阶", root: "G", notes: ["sol", "la", "ti", "do", "re", "mi", "#fa"], difficulty: .easy),
        ScaleQuestion(name: "G大调", root: "G", notes: ["1", "3", "5"], difficulty: .easy),
        ScaleQuestion(name: "G大调主和弦", root: "G", notes: ["G", "B", "D"], difficulty: .easy),
        ScaleQuestion(name: "G大调", root: "G", notes: ["2", "4", "6"], difficulty: .easy),
        ScaleQuestion(name: "G大调下属和弦", root: "C", notes: ["C", "E", "G"], difficulty: .easy),
        ScaleQuestion(name: "G大调属和弦", root: "D", notes: ["D", "F#", "A"], difficulty: .easy),
        ScaleQuestion(name: "G大调", root: "G", notes: ["4", "6", "1"], difficulty: .easy),
        ScaleQuestion(name: "G大调", root: "G", notes: ["5", "7", "2"], difficulty: .easy),
        
        // D大调
        ScaleQuestion(name: "D大调", root: "D", notes: ["2", "3", "#4", "5", "6", "7", "#1"], difficulty: .easy),
        ScaleQuestion(name: "D大调", root: "D", notes: ["D", "E", "F#", "G", "A", "B", "C#"], difficulty: .easy),
        ScaleQuestion(name: "D大调主和弦", root: "D", notes: ["D", "F#", "A"], difficulty: .easy),
        ScaleQuestion(name: "D大调", root: "D", notes: ["1", "3", "5"], difficulty: .easy),
        
        // ========== 中级（33 题）==========
        // A大调
        ScaleQuestion(name: "A大调", root: "A", notes: ["6", "7", "#1", "2", "3", "#4", "#5"], difficulty: .medium),
        ScaleQuestion(name: "A大调", root: "A", notes: ["A", "B", "C#", "D", "E", "F#", "G#"], difficulty: .medium),
        ScaleQuestion(name: "A大调主和弦", root: "A", notes: ["A", "C#", "E"], difficulty: .medium),
        ScaleQuestion(name: "A大调", root: "A", notes: ["1", "3", "5"], difficulty: .medium),
        ScaleQuestion(name: "A大调", root: "A", notes: ["2", "4", "6"], difficulty: .medium),
        
        // E大调
        ScaleQuestion(name: "E大调", root: "E", notes: ["3", "#4", "#5", "6", "7", "#1", "#2"], difficulty: .medium),
        ScaleQuestion(name: "E大调", root: "E", notes: ["E", "F#", "G#", "A", "B", "C#", "D#"], difficulty: .medium),
        ScaleQuestion(name: "E大调主和弦", root: "E", notes: ["E", "G#", "B"], difficulty: .medium),
        ScaleQuestion(name: "E大调", root: "E", notes: ["1", "3", "5"], difficulty: .medium),
        ScaleQuestion(name: "E大调", root: "E", notes: ["2", "4", "6"], difficulty: .medium),
        
        // F大调
        ScaleQuestion(name: "F大调", root: "F", notes: ["4", "5", "6", "♭7", "1", "2", "3"], difficulty: .medium),
        ScaleQuestion(name: "F大调", root: "F", notes: ["F", "G", "A", "Bb", "C", "D", "E"], difficulty: .medium),
        ScaleQuestion(name: "F大调主和弦", root: "F", notes: ["F", "A", "C"], difficulty: .medium),
        ScaleQuestion(name: "F大调", root: "F", notes: ["1", "3", "5"], difficulty: .medium),
        
        // B大调
        ScaleQuestion(name: "B大调", root: "B", notes: ["7", "#1", "#2", "3", "#4", "#5", "#6"], difficulty: .medium),
        ScaleQuestion(name: "B大调", root: "B", notes: ["B", "C#", "D#", "E", "F#", "G#", "A#"], difficulty: .medium),
        ScaleQuestion(name: "B大调主和弦", root: "B", notes: ["B", "D#", "F#"], difficulty: .medium),
        ScaleQuestion(name: "B大调", root: "B", notes: ["1", "3", "5"], difficulty: .medium),
        
        // 五声音阶
        ScaleQuestion(name: "C宫五声", root: "C", notes: ["1", "2", "3", "5", "6"], difficulty: .medium),
        ScaleQuestion(name: "G宫五声", root: "G", notes: ["5", "6", "7", "2", "3"], difficulty: .medium),
        ScaleQuestion(name: "D宫五声", root: "D", notes: ["2", "3", "#4", "6", "7"], difficulty: .medium),
        ScaleQuestion(name: "A宫五声", root: "A", notes: ["6", "7", "#1", "3", "#4"], difficulty: .medium),
        ScaleQuestion(name: "F宫五声", root: "F", notes: ["4", "5", "6", "1", "2"], difficulty: .medium),
        ScaleQuestion(name: "降B宫五声", root: "Bb", notes: ["♭7", "1", "2", "4", "5"], difficulty: .medium),
        ScaleQuestion(name: "降E宫五声", root: "Eb", notes: ["♭3", "♭7", "1", "♭6", "♭7"], difficulty: .medium),
        ScaleQuestion(name: "降A宫五声", root: "Ab", notes: ["♭6", "♭7", "1", "♭3", "♭7"], difficulty: .medium),
        ScaleQuestion(name: "C徵五声", root: "G", notes: ["5", "6", "1", "2", "3"], difficulty: .medium),
        ScaleQuestion(name: "G徵五声", root: "D", notes: ["2", "3", "5", "6", "7"], difficulty: .medium),
        ScaleQuestion(name: "D商五声", root: "D", notes: ["2", "3", "5", "6", "1"], difficulty: .medium),
        ScaleQuestion(name: "A商五声", root: "A", notes: ["6", "7", "2", "3", "5"], difficulty: .medium),
        ScaleQuestion(name: "E商五声", root: "E", notes: ["3", "#4", "6", "7", "2"], difficulty: .medium),
        
        // ========== 高级（33 题）==========
        // 自然小调
        ScaleQuestion(name: "a小调", root: "A", notes: ["6", "7", "1", "2", "3", "4", "5"], difficulty: .hard),
        ScaleQuestion(name: "e小调", root: "E", notes: ["3", "4", "5", "6", "7", "1", "2"], difficulty: .hard),
        ScaleQuestion(name: "d小调", root: "D", notes: ["2", "3", "4", "5", "6", "♭7", "1"], difficulty: .hard),
        ScaleQuestion(name: "b小调", root: "B", notes: ["7", "1", "2", "3", "#4", "5", "6"], difficulty: .hard),
        ScaleQuestion(name: "g小调", root: "G", notes: ["5", "6", "♭7", "1", "2", "♭3", "4"], difficulty: .hard),
        ScaleQuestion(name: "c小调", root: "C", notes: ["1", "♭3", "4", "5", "♭7", "♭7", "1"], difficulty: .hard),
        ScaleQuestion(name: "f小调", root: "F", notes: ["4", "♭6", "♭7", "1", "♭3", "♭3", "4"], difficulty: .hard),
        
        // 和声小调
        ScaleQuestion(name: "a和声小调", root: "A", notes: ["6", "7", "1", "2", "3", "#4", "#5"], difficulty: .hard),
        ScaleQuestion(name: "e和声小调", root: "E", notes: ["3", "#4", "5", "6", "7", "#1", "#2"], difficulty: .hard),
        ScaleQuestion(name: "d和声小调", root: "D", notes: ["2", "3", "4", "5", "6", "#7", "#1"], difficulty: .hard),
        ScaleQuestion(name: "b和声小调", root: "B", notes: ["7", "#1", "2", "3", "#4", "5", "6"], difficulty: .hard),
        ScaleQuestion(name: "g和声小调", root: "G", notes: ["5", "6", "♭7", "1", "2", "3", "#4"], difficulty: .hard),
        
        // 旋律小调
        ScaleQuestion(name: "a旋律小调(上行)", root: "A", notes: ["6", "7", "1", "2", "3", "#4", "#5", "#6", "#7"], difficulty: .hard),
        ScaleQuestion(name: "e旋律小调(上行)", root: "E", notes: ["3", "#4", "#5", "6", "7", "#1", "#2", "#3", "#4"], difficulty: .hard),
        
        // 民族调式
        ScaleQuestion(name: "C宫调式", root: "C", notes: ["1", "2", "3", "5", "6"], difficulty: .hard),
        ScaleQuestion(name: "G宫调式", root: "G", notes: ["5", "6", "7", "2", "3"], difficulty: .hard),
        ScaleQuestion(name: "D宫调式", root: "D", notes: ["2", "3", "#4", "6", "7"], difficulty: .hard),
        ScaleQuestion(name: "A羽调式", root: "A", notes: ["6", "1", "2", "3", "5"], difficulty: .hard),
        ScaleQuestion(name: "E羽调式", root: "E", notes: ["3", "5", "6", "7", "2"], difficulty: .hard),
        ScaleQuestion(name: "D商调式", root: "D", notes: ["2", "3", "5", "6", "1"], difficulty: .hard),
        ScaleQuestion(name: "A商调式", root: "A", notes: ["6", "7", "2", "3", "5"], difficulty: .hard),
        ScaleQuestion(name: "E商调式", root: "E", notes: ["3", "#4", "6", "7", "2"], difficulty: .hard),
        ScaleQuestion(name: "C角调式", root: "C", notes: ["1", "♭3", "4", "5", "♭7"], difficulty: .hard),
        ScaleQuestion(name: "G角调式", root: "G", notes: ["5", "♭7", "1", "♭3", "4"], difficulty: .hard),
        ScaleQuestion(name: "F徵调式", root: "F", notes: ["4", "5", "6", "1", "2"], difficulty: .hard),
        ScaleQuestion(name: "C徵调式", root: "G", notes: ["5", "6", "7", "2", "3"], difficulty: .hard),
        
        // 混合利底亚
        ScaleQuestion(name: "F混合利底亚", root: "F", notes: ["4", "5", "6", "7", "1", "2", "3"], difficulty: .hard),
        ScaleQuestion(name: "C混合利底亚", root: "C", notes: ["1", "2", "3", "#4", "5", "6", "7"], difficulty: .hard),
        
        // 利底亚
        ScaleQuestion(name: "F利底亚", root: "F", notes: ["4", "5", "6", "7", "1", "2", "#3"], difficulty: .hard),
        ScaleQuestion(name: "C利底亚", root: "C", notes: ["1", "2", "3", "#4", "5", "6", "7"], difficulty: .hard),
    ]
    
    // MARK: - 节奏模块题库（100+ 题）
    static let rhythmQuestions: [RhythmQuestion] = [
        // ========== 初级（34 题）==========
        // 四拍子基础节奏
        RhythmQuestion(name: "下上下上", notation: "↓↑↓↑", beats: 4, difficulty: .easy),
        RhythmQuestion(name: "下上下上", notation: "↓↑↓↑", beats: 4, difficulty: .easy),
        RhythmQuestion(name: "下上下上", notation: "↓↑↓↑", beats: 4, difficulty: .easy),
        RhythmQuestion(name: "下上下上", notation: "↓↑↓↑", beats: 4, difficulty: .easy),
        RhythmQuestion(name: "下上下上", notation: "↓↑↓↑", beats: 4, difficulty: .easy),
        RhythmQuestion(name: "下下下上", notation: "↓↓↓↑", beats: 4, difficulty: .easy),
        RhythmQuestion(name: "下下下上", notation: "↓↓↓↑", beats: 4, difficulty: .easy),
        RhythmQuestion(name: "下下下上", notation: "↓↓↓↑", beats: 4, difficulty: .easy),
        RhythmQuestion(name: "下下下上", notation: "↓↓↓↑", beats: 4, difficulty: .easy),
        RhythmQuestion(name: "下下下上", notation: "↓↓↓↑", beats: 4, difficulty: .easy),
        RhythmQuestion(name: "下下上下", notation: "↓↓↑↓", beats: 4, difficulty: .easy),
        RhythmQuestion(name: "下下上下", notation: "↓↓↑↓", beats: 4, difficulty: .easy),
        RhythmQuestion(name: "下下上下", notation: "↓↓↑↓", beats: 4, difficulty: .easy),
        RhythmQuestion(name: "下下上下", notation: "↓↓↑↓", beats: 4, difficulty: .easy),
        RhythmQuestion(name: "下下上下", notation: "↓↓↑↓", beats: 4, difficulty: .easy),
        
        // 分解和弦节奏
        RhythmQuestion(name: "分解T323", notation: "T-3-2-3", beats: 4, difficulty: .easy),
        RhythmQuestion(name: "分解T323", notation: "T-3-2-3", beats: 4, difficulty: .easy),
        RhythmQuestion(name: "分解T323", notation: "T-3-2-3", beats: 4, difficulty: .easy),
        RhythmQuestion(name: "分解T323", notation: "T-3-2-3", beats: 4, difficulty: .easy),
        RhythmQuestion(name: "分解T1323", notation: "T-1-3-2-3", beats: 4, difficulty: .easy),
        RhythmQuestion(name: "分解T1323", notation: "T-1-3-2-3", beats: 4, difficulty: .easy),
        RhythmQuestion(name: "分解T1323", notation: "T-1-3-2-3", beats: 4, difficulty: .easy),
        RhythmQuestion(name: "分解T1323", notation: "T-1-3-2-3", beats: 4, difficulty: .easy),
        
        // 基础变化
        RhythmQuestion(name: "上下上下", notation: "↑↓↑↓", beats: 4, difficulty: .easy),
        RhythmQuestion(name: "上上下上", notation: "↑↑↓↑", beats: 4, difficulty: .easy),
        RhythmQuestion(name: "上下下上", notation: "↑↓↓↑", beats: 4, difficulty: .easy),
        RhythmQuestion(name: "下上上下", notation: "↓↑↓↑", beats: 4, difficulty: .easy),
        RhythmQuestion(name: "上下上下", notation: "↑↓↑↓", beats: 4, difficulty: .easy),
        
        // ========== 中级（33 题）==========
        // 六拍子节奏
        RhythmQuestion(name: "下下下上下上", notation: "↓↓↓↑↓↑", beats: 6, difficulty: .medium),
        RhythmQuestion(name: "下下下上下上", notation: "↓↓↓↑↓↑", beats: 6, difficulty: .medium),
        RhythmQuestion(name: "下下下上下上", notation: "↓↓↓↑↓↑", beats: 6, difficulty: .medium),
        RhythmQuestion(name: "下下下上下上", notation: "↓↓↓↑↓↑", beats: 6, difficulty: .medium),
        RhythmQuestion(name: "下下下上下上", notation: "↓↓↓↑↓↑", beats: 6, difficulty: .medium),
        RhythmQuestion(name: "下上下下上下", notation: "↓↑↓↓↓↑", beats: 6, difficulty: .medium),
        RhythmQuestion(name: "下上下下上下", notation: "↓↑↓↓↓↑", beats: 6, difficulty: .medium),
        RhythmQuestion(name: "下上下下上下", notation: "↓↑↓↓↓↑", beats: 6, difficulty: .medium),
        RhythmQuestion(name: "下上下下上下", notation: "↓↑↓↓↓↑", beats: 6, difficulty: .medium),
        RhythmQuestion(name: "下上下下上下", notation: "↓↑↓↓↓↑", beats: 6, difficulty: .medium),
        
        // 切分节奏
        RhythmQuestion(name: "下切上", notation: "↓-↑-", beats: 4, difficulty: .medium),
        RhythmQuestion(name: "切下上", notation: "-↓↑-", beats: 4, difficulty: .medium),
        RhythmQuestion(name: "下上切", notation: "↓↑-↓", beats: 4, difficulty: .medium),
        RhythmQuestion(name: "切下切上", notation: "-↓-↑-", beats: 4, difficulty: .medium),
        RhythmQuestion(name: "下切切上", notation: "↓- -↑-", beats: 4, difficulty: .medium),
        RhythmQuestion(name: "切下切切上", notation: "-↓- -↑-", beats: 4, difficulty: .medium),
        RhythmQuestion(name: "下上下切上", notation: "↓↑↓-↑", beats: 4, difficulty: .medium),
        RhythmQuestion(name: "切切下上下上", notation: "- -↓↓↑↓", beats: 4, difficulty: .medium),
        RhythmQuestion(name: "下切上下上", notation: "↓-↑↓↑", beats: 4, difficulty: .medium),
        RhythmQuestion(name: "上下切上下", notation: "↑↓-↑↓", beats: 4, difficulty: .medium),
        
        // 分解532123
        RhythmQuestion(name: "分解532123", notation: "5-3-2-1-2-3", beats: 4, difficulty: .medium),
        RhythmQuestion(name: "分解532123", notation: "5-3-2-1-2-3", beats: 4, difficulty: .medium),
        RhythmQuestion(name: "分解532123", notation: "5-3-2-1-2-3", beats: 4, difficulty: .medium),
        RhythmQuestion(name: "分解54321", notation: "5-4-3-2-1", beats: 4, difficulty: .medium),
        RhythmQuestion(name: "分解54321", notation: "5-4-3-2-1", beats: 4, difficulty: .medium),
        RhythmQuestion(name: "分解135313", notation: "1-3-5-3-1-3", beats: 4, difficulty: .medium),
        RhythmQuestion(name: "分解135313", notation: "1-3-5-3-1-3", beats: 4, difficulty: .medium),
        RhythmQuestion(name: "分解1321", notation: "1-3-2-1", beats: 4, difficulty: .medium),
        RhythmQuestion(name: "分解1321", notation: "1-3-2-1", beats: 4, difficulty: .medium),
        
        // ========== 高级（33 题）==========
        // 复杂切分
        RhythmQuestion(name: "二三重音切分", notation: "↓-↓-↑", beats: 4, difficulty: .hard),
        RhythmQuestion(name: "二三重音切分", notation: "↓-↓-↑", beats: 4, difficulty: .hard),
        RhythmQuestion(name: "二三重音切分", notation: "↓-↓-↑", beats: 4, difficulty: .hard),
        RhythmQuestion(name: "二三重音切分", notation: "↓-↓-↑", beats: 4, difficulty: .hard),
        RhythmQuestion(name: "二三重音切分", notation: "↓-↓-↑", beats: 4, difficulty: .hard),
        RhythmQuestion(name: "三连音切分", notation: "↓↓↓-↑", beats: 4, difficulty: .hard),
        RhythmQuestion(name: "三连音切分", notation: "↓↓↓-↑", beats: 4, difficulty: .hard),
        RhythmQuestion(name: "三连音切分", notation: "↓↓↓-↑", beats: 4, difficulty: .hard),
        RhythmQuestion(name: "三连音切分", notation: "↓↓↓-↑", beats: 4, difficulty: .hard),
        RhythmQuestion(name: "复合切分", notation: "↓-↓↓-↑", beats: 4, difficulty: .hard),
        RhythmQuestion(name: "复合切分", notation: "↓-↓↓-↑", beats: 4, difficulty: .hard),
        RhythmQuestion(name: "复合切分", notation: "↓-↓↓-↑", beats: 4, difficulty: .hard),
        RhythmQuestion(name: "复合切分", notation: "↓-↓↓-↑", beats: 4, difficulty: .hard),
        
        // 复合节奏
        RhythmQuestion(name: "4/4+6/8混合", notation: "4/4:6/8", beats: 4, difficulty: .hard),
        RhythmQuestion(name: "4/4+6/8混合", notation: "4/4:6/8", beats: 4, difficulty: .hard),
        RhythmQuestion(name: "4/4+6/8混合", notation: "4/4:6/8", beats: 4, difficulty: .hard),
        RhythmQuestion(name: "3/4+6/8混合", notation: "3/4:6/8", beats: 6, difficulty: .hard),
        RhythmQuestion(name: "3/4+6/8混合", notation: "3/4:6/8", beats: 6, difficulty: .hard),
        RhythmQuestion(name: "切分+三连音", notation: "syn-3", beats: 4, difficulty: .hard),
        RhythmQuestion(name: "切分+三连音", notation: "syn-3", beats: 4, difficulty: .hard),
        RhythmQuestion(name: "切分+三连音", notation: "syn-3", beats: 4, difficulty: .hard),
        RhythmQuestion(name: "反向节奏", notation: "rev", beats: 4, difficulty: .hard),
        RhythmQuestion(name: "反向节奏", notation: "rev", beats: 4, difficulty: .hard),
        
        // 3连音节奏
        RhythmQuestion(name: "四分三连音", notation: "1&a2&a", beats: 4, difficulty: .hard),
        RhythmQuestion(name: "四分三连音", notation: "1&a2&a", beats: 4, difficulty: .hard),
        RhythmQuestion(name: "四分三连音", notation: "1&a2&a", beats: 4, difficulty: .hard),
        RhythmQuestion(name: "八分三连音", notation: "1a2a", beats: 4, difficulty: .hard),
        RhythmQuestion(name: "八分三连音", notation: "1a2a", beats: 4, difficulty: .hard),
        
        // 5连音节奏
        RhythmQuestion(name: "五连音", notation: "1e&a2", beats: 4, difficulty: .hard),
        RhythmQuestion(name: "五连音", notation: "1e&a2", beats: 4, difficulty: .hard),
        RhythmQuestion(name: "五连音", notation: "1e&a2", beats: 4, difficulty: .hard),
        
        // 混合拍子
        RhythmQuestion(name: "5/4拍子", notation: "3+2", beats: 5, difficulty: .hard),
        RhythmQuestion(name: "5/4拍子", notation: "2+3", beats: 5, difficulty: .hard),
        RhythmQuestion(name: "7/8拍子", notation: "2+2+3", beats: 7, difficulty: .hard),
        RhythmQuestion(name: "7/8拍子", notation: "3+2+2", beats: 7, difficulty: .hard),
        RhythmQuestion(name: "混合拍子练习", notation: "5/4+7/8", beats: 12, difficulty: .hard),
    ]
    
    // MARK: - 旋律模块题库（100+ 题）
    static let melodyQuestions: [MelodyQuestion] = [
        // ========== 初级（34 题）==========
        // 级进上行 - 4音片段
        MelodyQuestion(solfege: "1 2 3 4", description: "C大调音阶上行", intervalType: "stepwise", noteCount: 4, difficulty: .easy),
        MelodyQuestion(solfege: "2 3 4 5", description: "D大调音阶上行", intervalType: "stepwise", noteCount: 4, difficulty: .easy),
        MelodyQuestion(solfege: "5 6 7 1", description: "G大调属音上行", intervalType: "stepwise", noteCount: 4, difficulty: .easy),
        MelodyQuestion(solfege: "3 4 5 6", description: "E大调上行", intervalType: "stepwise", noteCount: 4, difficulty: .easy),
        MelodyQuestion(solfege: "1 2 3 4", description: "C大调上行", intervalType: "stepwise", noteCount: 4, difficulty: .easy),
        MelodyQuestion(solfege: "2 3 4 5", description: "D大调上行", intervalType: "stepwise", noteCount: 4, difficulty: .easy),
        
        // 级进下行 - 4音片段
        MelodyQuestion(solfege: "4 3 2 1", description: "C大调音阶下行", intervalType: "stepwise", noteCount: 4, difficulty: .easy),
        MelodyQuestion(solfege: "5 4 3 2", description: "D大调下行", intervalType: "stepwise", noteCount: 4, difficulty: .easy),
        MelodyQuestion(solfege: "1 7 6 5", description: "G大调下行", intervalType: "stepwise", noteCount: 4, difficulty: .easy),
        MelodyQuestion(solfege: "6 5 4 3", description: "E大调下行", intervalType: "stepwise", noteCount: 4, difficulty: .easy),
        MelodyQuestion(solfege: "4 3 2 1", description: "C大调下行", intervalType: "stepwise", noteCount: 4, difficulty: .easy),
        MelodyQuestion(solfege: "5 4 3 2", description: "D大调下行", intervalType: "stepwise", noteCount: 4, difficulty: .easy),
        
        // 级进旋律 - 5音片段
        MelodyQuestion(solfege: "1 2 3 4 5", description: "C大调上行五音", intervalType: "stepwise", noteCount: 5, difficulty: .easy),
        MelodyQuestion(solfege: "5 4 3 2 1", description: "C大调下行五音", intervalType: "stepwise", noteCount: 5, difficulty: .easy),
        MelodyQuestion(solfege: "1 2 3 4 5", description: "C大调五音", intervalType: "stepwise", noteCount: 5, difficulty: .easy),
        MelodyQuestion(solfege: "5 6 7 1 2", description: "G大调五音", intervalType: "stepwise", noteCount: 5, difficulty: .easy),
        MelodyQuestion(solfege: "2 3 4 5 6", description: "D大调五音", intervalType: "stepwise", noteCount: 5, difficulty: .easy),
        MelodyQuestion(solfege: "6 5 4 3 2", description: "A小调下行", intervalType: "stepwise", noteCount: 5, difficulty: .easy),
        MelodyQuestion(solfege: "1 2 3 4 5", description: "C大调五音", intervalType: "stepwise", noteCount: 5, difficulty: .easy),
        MelodyQuestion(solfege: "3 4 5 6 7", description: "E大调五音", intervalType: "stepwise", noteCount: 5, difficulty: .easy),
        MelodyQuestion(solfege: "4 5 6 7 1", description: "F大调五音", intervalType: "stepwise", noteCount: 5, difficulty: .easy),
        MelodyQuestion(solfege: "5 6 7 1 2", description: "G大调五音", intervalType: "stepwise", noteCount: 5, difficulty: .easy),
        
        // ========== 中级（33 题）==========
        // 三度跳进混合 - 4音
        MelodyQuestion(solfege: "1 3 2 4", description: "三度跳进混合", intervalType: "mixed", noteCount: 4, difficulty: .medium),
        MelodyQuestion(solfege: "3 5 4 6", description: "三度跳进混合", intervalType: "mixed", noteCount: 4, difficulty: .medium),
        MelodyQuestion(solfege: "5 7 6 1", description: "三度跳进混合", intervalType: "mixed", noteCount: 4, difficulty: .medium),
        MelodyQuestion(solfege: "2 4 3 5", description: "三度跳进混合", intervalType: "mixed", noteCount: 4, difficulty: .medium),
        MelodyQuestion(solfege: "1 3 4 5", description: "三度+级进", intervalType: "mixed", noteCount: 4, difficulty: .medium),
        MelodyQuestion(solfege: "5 6 7 2", description: "三度+级进", intervalType: "mixed", noteCount: 4, difficulty: .medium),
        MelodyQuestion(solfege: "3 4 5 6", description: "级进+三度", intervalType: "mixed", noteCount: 4, difficulty: .medium),
        MelodyQuestion(solfege: "7 6 5 4", description: "级进+三度", intervalType: "mixed", noteCount: 4, difficulty: .medium),
        
        // 四度跳进混合 - 4音
        MelodyQuestion(solfege: "1 4 3 5", description: "四度跳进混合", intervalType: "mixed", noteCount: 4, difficulty: .medium),
        MelodyQuestion(solfege: "2 5 4 6", description: "四度跳进混合", intervalType: "mixed", noteCount: 4, difficulty: .medium),
        MelodyQuestion(solfege: "5 1 7 2", description: "四度跳进混合", intervalType: "mixed", noteCount: 4, difficulty: .medium),
        MelodyQuestion(solfege: "3 6 5 7", description: "四度跳进混合", intervalType: "mixed", noteCount: 4, difficulty: .medium),
        MelodyQuestion(solfege: "4 7 6 2", description: "四度跳进混合", intervalType: "mixed", noteCount: 4, difficulty: .medium),
        MelodyQuestion(solfege: "1 5 4 7", description: "四度+级进", intervalType: "mixed", noteCount: 4, difficulty: .medium),
        MelodyQuestion(solfege: "5 2 1 4", description: "四度+级进", intervalType: "mixed", noteCount: 4, difficulty: .medium),
        MelodyQuestion(solfege: "3 6 7 3", description: "四度+级进", intervalType: "mixed", noteCount: 4, difficulty: .medium),
        
        // 混合跳进 - 5-6音
        MelodyQuestion(solfege: "1 3 5 6 7", description: "五音混合", intervalType: "mixed", noteCount: 5, difficulty: .medium),
        MelodyQuestion(solfege: "5 7 2 4 5", description: "五音混合", intervalType: "mixed", noteCount: 5, difficulty: .medium),
        MelodyQuestion(solfege: "1 2 4 5 6", description: "五音混合", intervalType: "mixed", noteCount: 5, difficulty: .medium),
        MelodyQuestion(solfege: "3 4 6 7 2", description: "五音混合", intervalType: "mixed", noteCount: 5, difficulty: .medium),
        MelodyQuestion(solfege: "1 3 5 4 2 1", description: "六音混合", intervalType: "mixed", noteCount: 6, difficulty: .medium),
        MelodyQuestion(solfege: "5 7 2 4 3 5", description: "六音混合", intervalType: "mixed", noteCount: 6, difficulty: .medium),
        MelodyQuestion(solfege: "2 4 5 7 6 5", description: "六音混合", intervalType: "mixed", noteCount: 6, difficulty: .medium),
        MelodyQuestion(solfege: "1 4 3 6 5 7", description: "六音混合", intervalType: "mixed", noteCount: 6, difficulty: .medium),
        MelodyQuestion(solfege: "3 5 4 7 6 1", description: "六音混合", intervalType: "mixed", noteCount: 6, difficulty: .medium),
        MelodyQuestion(solfege: "5 6 4 2 3 1", description: "六音混合", intervalType: "mixed", noteCount: 6, difficulty: .medium),
        
        // ========== 高级（33 题）==========
        // 五度跳进 - 4音
        MelodyQuestion(solfege: "1 5 4 7", description: "五度跳进", intervalType: "skipped", noteCount: 4, difficulty: .hard),
        MelodyQuestion(solfege: "2 6 5 1", description: "五度跳进", intervalType: "skipped", noteCount: 4, difficulty: .hard),
        MelodyQuestion(solfege: "3 7 6 2", description: "五度跳进", intervalType: "skipped", noteCount: 4, difficulty: .hard),
        MelodyQuestion(solfege: "4 1 7 3", description: "五度跳进", intervalType: "skipped", noteCount: 4, difficulty: .hard),
        MelodyQuestion(solfege: "5 2 1 4", description: "五度跳进", intervalType: "skipped", noteCount: 4, difficulty: .hard),
        MelodyQuestion(solfege: "6 3 2 5", description: "五度跳进", intervalType: "skipped", noteCount: 4, difficulty: .hard),
        MelodyQuestion(solfege: "7 4 3 6", description: "五度跳进", intervalType: "skipped", noteCount: 4, difficulty: .hard),
        MelodyQuestion(solfege: "1 5 3 7", description: "五度+三度", intervalType: "skipped", noteCount: 4, difficulty: .hard),
        MelodyQuestion(solfege: "5 2 7 4", description: "五度+三度", intervalType: "skipped", noteCount: 4, difficulty: .hard),
        MelodyQuestion(solfege: "3 7 5 2", description: "五度+三度", intervalType: "skipped", noteCount: 4, difficulty: .hard),
        
        // 六度跳进 - 4音
        MelodyQuestion(solfege: "1 6 5 3", description: "六度跳进", intervalType: "skipped", noteCount: 4, difficulty: .hard),
        MelodyQuestion(solfege: "2 7 6 4", description: "六度跳进", intervalType: "skipped", noteCount: 4, difficulty: .hard),
        MelodyQuestion(solfege: "3 1 7 5", description: "六度跳进", intervalType: "skipped", noteCount: 4, difficulty: .hard),
        MelodyQuestion(solfege: "4 2 1 6", description: "六度跳进", intervalType: "skipped", noteCount: 4, difficulty: .hard),
        MelodyQuestion(solfege: "5 3 2 7", description: "六度跳进", intervalType: "skipped", noteCount: 4, difficulty: .hard),
        MelodyQuestion(solfege: "6 4 3 1", description: "六度跳进", intervalType: "skipped", noteCount: 4, difficulty: .hard),
        MelodyQuestion(solfege: "7 5 4 2", description: "六度跳进", intervalType: "skipped", noteCount: 4, difficulty: .hard),
        MelodyQuestion(solfege: "1 6 4 2", description: "六度+四度", intervalType: "skipped", noteCount: 4, difficulty: .hard),
        MelodyQuestion(solfege: "5 3 1 6", description: "六度+四度", intervalType: "skipped", noteCount: 4, difficulty: .hard),
        MelodyQuestion(solfege: "3 1 6 4", description: "六度+四度", intervalType: "skipped", noteCount: 4, difficulty: .hard),
        
        // 长乐句 - 8音
        MelodyQuestion(solfege: "1 3 5 7 2 4 6 7", description: "八音综合", intervalType: "mixed", noteCount: 8, difficulty: .hard),
        MelodyQuestion(solfege: "5 7 2 4 6 7 1 2", description: "八音综合", intervalType: "mixed", noteCount: 8, difficulty: .hard),
        MelodyQuestion(solfege: "1 5 3 7 2 6 4 5", description: "八音跳进", intervalType: "skipped", noteCount: 8, difficulty: .hard),
        MelodyQuestion(solfege: "7 2 5 1 6 3 4 7", description: "八音跳进", intervalType: "skipped", noteCount: 8, difficulty: .hard),
        MelodyQuestion(solfege: "1 4 2 5 3 6 4 7", description: "八音混合", intervalType: "mixed", noteCount: 8, difficulty: .hard),
        MelodyQuestion(solfege: "5 1 6 2 7 3 1 4", description: "八音混合", intervalType: "mixed", noteCount: 8, difficulty: .hard),
        MelodyQuestion(solfege: "2 5 3 6 4 7 5 1", description: "八音混合", intervalType: "mixed", noteCount: 8, difficulty: .hard),
        MelodyQuestion(solfege: "3 6 4 7 5 1 6 2", description: "八音混合", intervalType: "mixed", noteCount: 8, difficulty: .hard),
        MelodyQuestion(solfege: "4 7 5 1 6 2 7 3", description: "八音混合", intervalType: "mixed", noteCount: 8, difficulty: .hard),
        
        // 综合练习 - 8音
        MelodyQuestion(solfege: "1 2 5 4 3 6 7 1", description: "八音上行", intervalType: "mixed", noteCount: 8, difficulty: .hard),
        MelodyQuestion(solfege: "7 6 3 4 5 2 1 7", description: "八音下行", intervalType: "mixed", noteCount: 8, difficulty: .hard),
        MelodyQuestion(solfege: "1 5 4 7 6 3 2 1", description: "八音复杂", intervalType: "skipped", noteCount: 8, difficulty: .hard),
        MelodyQuestion(solfege: "5 1 6 2 7 3 1 5", description: "八音复杂", intervalType: "skipped", noteCount: 8, difficulty: .hard),
    ]
}

// MARK: - 题库条目结构体

/// 音名题目
struct NoteNameQuestion {
    let solfege: String      // 简谱标记
    let noteName: String     // 音名
    let octave: Int          // 八度
    let isSharp: Bool       // 是否升号
    let difficulty: Difficulty
}

/// 音程题目
struct IntervalQuestion {
    let name: String        // 完整名称
    let shortName: String   // 缩写
    let semitones: Int      // 半音数
    let difficulty: Difficulty
}

/// 和弦题目
struct ChordQuestion {
    let name: String
    let notes: [(solfege: String, octave: Int)]
    let difficulty: Difficulty
}

/// 调式题目
struct ScaleQuestion {
    let name: String
    let root: String
    let notes: [String]
    let difficulty: Difficulty
}

/// 节奏题目
struct RhythmQuestion {
    let name: String
    let notation: String
    let beats: Int
    let difficulty: Difficulty
}

/// 旋律题目
struct MelodyQuestion {
    let solfege: String
    let description: String
    let intervalType: String  // "stepwise" / "skipped" / "mixed"
    let noteCount: Int
    let difficulty: Difficulty
}

// MARK: - 测试引擎

/// 测试引擎 — 生成诊断测试题目并计算结果
final class TestEngine {
    
    /// 生成一套完整的诊断测试（30题，每维度5题）
    static func generateDiagnosticTest() -> [TestQuestion] {
        var allQuestions: [TestQuestion] = []
        
        for module in ExerciseModule.allCases {
            let questions = generateQuestionsForModule(module, count: 5)
            allQuestions.append(contentsOf: questions)
        }
        
        // 打乱题目顺序
        return allQuestions.shuffled()
    }
    
    /// 为指定模块生成测试题
    private static func generateQuestionsForModule(_ module: ExerciseModule, count: Int) -> [TestQuestion] {
        var questions: [TestQuestion] = []
        
        switch module {
        case .noteName:
            questions = generateNoteNameQuestions(count: count)
        case .interval:
            questions = generateIntervalQuestions(count: count)
        case .chord:
            questions = generateChordQuestions(count: count)
        case .scale:
            questions = generateScaleQuestions(count: count)
        case .rhythm:
            questions = generateRhythmQuestions(count: count)
        case .melody:
            questions = generateMelodyQuestions(count: count)
        }
        
        return Array(questions.prefix(count))
    }
    
    // MARK: - 各模块题目生成（按难度均衡抽取）
    
    /// 按难度均衡随机抽取
    private static func balancedRandom抽取<T>(
        from questions: [T],
        difficulty: Difficulty,
        count: Int
    ) -> [T] {
        let filtered = questions.filter { question in
            // 通过反射获取 difficulty 属性
            let mirror = Mirror(reflecting: question)
            for child in mirror.children {
                if child.label == "difficulty",
                   let diff = child.value as? Difficulty {
                    return diff == difficulty
                }
            }
            return false
        }
        return Array(filtered.shuffled().prefix(count))
    }
    
    /// 组合抽取（按比例：初级1题:中级2题:高级2题）
    private static func generateBalancedQuestions<T>(
        from questions: [T],
        total: Int = 5
    ) -> [T] {
        let easy = balancedRandom抽取(from: questions, difficulty: .easy, count: 1)
        let medium = balancedRandom抽取(from: questions, difficulty: .medium, count: 2)
        let hard = balancedRandom抽取(from: questions, difficulty: .hard, count: 2)
        return (easy + medium + hard).shuffled()
    }
    
    private static func generateNoteNameQuestions(count: Int) -> [TestQuestion] {
        let questions = generateBalancedQuestions(from: QuestionBank.noteNameQuestions, total: count)
        
        return questions.enumerated().map { index, question in
            let allNotes = QuestionBank.noteNameQuestions
                .map { $0.noteName }
                .removingDuplicates()
            
            let targetNote = question.noteName
            let wrongNotes = allNotes.filter { $0 != targetNote }.shuffled().prefix(3)
            var options = wrongNotes.map { TestOption(label: $0) }
            options.append(TestOption(label: targetNote))
            options.shuffle()
            
            let correctIndex = options.firstIndex { $0.label == targetNote } ?? 0
            
            return TestQuestion(
                dimension: .noteName,
                difficulty: question.difficulty,
                questionType: .recognition,
                prompt: "听辨这个音（简谱 \(question.solfege)）",
                audioNote: question.solfege,
                options: options,
                correctAnswerIndex: correctIndex
            )
        }
    }
    
    private static func generateIntervalQuestions(count: Int) -> [TestQuestion] {
        let questions = generateBalancedQuestions(from: QuestionBank.intervalQuestions, total: count)
        
        return questions.map { question in
            let allIntervals = QuestionBank.intervalQuestions
                .map { $0.name }
                .removingDuplicates()
            
            let targetInterval = question.name
            let wrongIntervals = allIntervals.filter { $0 != targetInterval }.shuffled().prefix(3)
            var options = wrongIntervals.map { TestOption(label: $0) }
            options.append(TestOption(label: targetInterval))
            options.shuffle()
            
            let correctIndex = options.firstIndex { $0.label == targetInterval } ?? 0
            
            return TestQuestion(
                dimension: .interval,
                difficulty: question.difficulty,
                questionType: .recognition,
                prompt: "听辨这个音程（\(question.shortName)）",
                audioNote: question.shortName,
                options: options,
                correctAnswerIndex: correctIndex
            )
        }
    }
    
    private static func generateChordQuestions(count: Int) -> [TestQuestion] {
        let questions = generateBalancedQuestions(from: QuestionBank.chordQuestions, total: count)
        
        return questions.map { question in
            let allChords = QuestionBank.chordQuestions
                .map { $0.name }
                .removingDuplicates()
            
            let targetChord = question.name
            let wrongChords = allChords.filter { $0 != targetChord }.shuffled().prefix(3)
            
            var options: [TestOption] = wrongChords.map { chordName in
                // 尝试获取六线谱数据
                if let tab = MusicTheory.openChords.first(where: { $0.name == chordName.replacingOccurrences(of: "(大横按)", with: "") }) {
                    return TestOption(label: chordName, tabData: tab.tab)
                }
                return TestOption(label: chordName)
            }
            
            if let tab = MusicTheory.openChords.first(where: { $0.name == targetChord.replacingOccurrences(of: "(大横按)", with: "") }) {
                options.append(TestOption(label: targetChord, tabData: tab.tab))
            } else {
                options.append(TestOption(label: targetChord))
            }
            
            options.shuffle()
            let correctIndex = options.firstIndex { $0.label == targetChord } ?? 0
            
            return TestQuestion(
                dimension: .chord,
                difficulty: question.difficulty,
                questionType: .recognition,
                prompt: "听辨这个和弦（\(targetChord)）",
                audioNote: targetChord,
                options: options,
                correctAnswerIndex: correctIndex
            )
        }
    }
    
    private static func generateScaleQuestions(count: Int) -> [TestQuestion] {
        let questions = generateBalancedQuestions(from: QuestionBank.scaleQuestions, total: count)
        
        return questions.map { question in
            let allScales = QuestionBank.scaleQuestions
                .map { $0.name }
                .removingDuplicates()
            
            let targetScale = question.name
            let wrongScales = allScales.filter { $0 != targetScale }.shuffled().prefix(3)
            var options = wrongScales.map { TestOption(label: $0) }
            options.append(TestOption(label: targetScale))
            options.shuffle()
            
            let correctIndex = options.firstIndex { $0.label == targetScale } ?? 0
            
            return TestQuestion(
                dimension: .scale,
                difficulty: question.difficulty,
                questionType: .identification,
                prompt: "这是哪个调式？（根音: \(question.root)）",
                audioNote: targetScale,
                options: options,
                correctAnswerIndex: correctIndex
            )
        }
    }
    
    private static func generateRhythmQuestions(count: Int) -> [TestQuestion] {
        let questions = generateBalancedQuestions(from: QuestionBank.rhythmQuestions, total: count)
        
        return questions.map { question in
            let allPatterns = QuestionBank.rhythmQuestions
                .map { $0.name }
                .removingDuplicates()
            
            let targetPattern = question.name
            let wrongPatterns = allPatterns.filter { $0 != targetPattern }.shuffled().prefix(3)
            var options = wrongPatterns.map { TestOption(label: $0) }
            options.append(TestOption(label: targetPattern))
            options.shuffle()
            
            let correctIndex = options.firstIndex { $0.label == targetPattern } ?? 0
            
            return TestQuestion(
                dimension: .rhythm,
                difficulty: question.difficulty,
                questionType: .identification,
                prompt: "这是什么节奏型？（\(question.notation)）",
                audioNote: targetPattern,
                options: options,
                correctAnswerIndex: correctIndex
            )
        }
    }
    
    private static func generateMelodyQuestions(count: Int) -> [TestQuestion] {
        let questions = generateBalancedQuestions(from: QuestionBank.melodyQuestions, total: count)
        
        return questions.map { question in
            let allMelodies = QuestionBank.melodyQuestions
                .map { $0.solfege }
                .removingDuplicates()
            
            let targetMelody = question.solfege
            let wrongMelodies = allMelodies.filter { $0 != targetMelody }.shuffled().prefix(3)
            var options = wrongMelodies.map { TestOption(label: $0) }
            options.append(TestOption(label: targetMelody))
            options.shuffle()
            
            let correctIndex = options.firstIndex { $0.label == targetMelody } ?? 0
            
            return TestQuestion(
                dimension: .melody,
                difficulty: question.difficulty,
                questionType: .recognition,
                prompt: "听辨这段旋律（\(question.description)）",
                audioNote: targetMelody,
                options: options,
                correctAnswerIndex: correctIndex
            )
        }
    }
    
    // MARK: - 结果计算
    
    /// 计算测试结果
    static func calculateResult(
        questions: [TestQuestion],
        answers: [UUID: Int],
        responseTimes: [UUID: Double]
    ) -> TestResult {
        var dimensionStats: [ExerciseModule: (correct: Int, total: Int, totalTime: Double)] = [:]
        
        // 初始化
        for module in ExerciseModule.allCases {
            dimensionStats[module] = (correct: 0, total: 0, totalTime: 0)
        }
        
        // 统计每维度
        for question in questions {
            guard let module = question.dimensionValue else { continue }
            guard var stats = dimensionStats[module] else { continue }
            
            stats.total += 1
            
            if let selectedIndex = answers[question.id],
               selectedIndex == question.correctAnswerIndex {
                stats.correct += 1
            }
            
            if let responseTime = responseTimes[question.id] {
                stats.totalTime += responseTime
            }
            
            dimensionStats[module] = stats
        }
        
        // 计算维度得分
        var dimensionScores: [ExerciseModule: DimensionScore] = [:]
        for (module, stats) in dimensionStats {
            let correctRate = stats.total > 0 ? Double(stats.correct) / Double(stats.total) : 0
            let avgTime = stats.total > 0 ? stats.totalTime / Double(stats.total) : 0
            
            // 综合得分 = 正确率×0.7 + (1-归一化反应时间)×0.3
            let normalizedTime = min(avgTime / 3.0, 1.0) // 3秒为满分反应时间
            let score = Int((correctRate * 0.7 + (1 - normalizedTime) * 0.3) * 100)
            
            dimensionScores[module] = DimensionScore(
                module: module,
                correctRate: correctRate,
                avgResponseTime: avgTime,
                score: score,
                questionCount: stats.total,
                correctCount: stats.correct
            )
        }
        
        // 计算总分
        let totalScore = dimensionScores.isEmpty ? 0 :
            dimensionScores.values.reduce(0) { $0 + $1.score } / dimensionScores.count
        
        // 生成推荐
        let recommendations = RecommendationEngine.generateRecommendations(dimensionScores: dimensionScores)
        
        // 总耗时
        let totalDuration = responseTimes.values.reduce(0, +)
        
        return TestResult(
            totalScore: totalScore,
            dimensionScores: dimensionScores,
            recommendations: recommendations,
            totalDurationSeconds: Int(totalDuration)
        )
    }
}

// MARK: - 数组扩展

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
