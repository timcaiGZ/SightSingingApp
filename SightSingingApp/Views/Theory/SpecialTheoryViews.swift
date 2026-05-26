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

    // MARK: - 常用七和弦吉他指法数据（每个和弦提供2-3种常用按法）
    private let chordDiagrams: [String: [ChordGraphicItem]] = [
        // C调
        "Cmaj7": [
            ChordGraphicItem(name: "Cmaj7", frets: [nil, 3, 2, 0, 0, 0], fingers: [nil, 3, 2, nil, nil, nil]),
            ChordGraphicItem(name: "Cmaj7", frets: [8, 10, 9, 9, 8, 8], fingers: [1, 3, 2, 2, 1, 1]),
            ChordGraphicItem(name: "Cmaj7", frets: [nil, 3, 5, 4, 5, 3], fingers: [nil, 1, 3, 2, 4, 1]),
        ],
        "Dm7": [
            ChordGraphicItem(name: "Dm7", frets: [nil, nil, 0, 2, 1, 1], fingers: [nil, nil, nil, 3, 1, 2]),
            ChordGraphicItem(name: "Dm7", frets: [nil, 5, 7, 5, 6, 5], fingers: [nil, 1, 3, 1, 2, 1]),
            ChordGraphicItem(name: "Dm7", frets: [10, 12, 10, 10, 10, 10], fingers: [1, 3, 1, 1, 1, 1]),
        ],
        "Em7": [
            ChordGraphicItem(name: "Em7", frets: [0, 2, 0, 0, 0, 0], fingers: [nil, 2, nil, nil, nil, nil]),
            ChordGraphicItem(name: "Em7", frets: [nil, 7, 9, 7, 8, 7], fingers: [nil, 1, 3, 1, 2, 1]),
            ChordGraphicItem(name: "Em7", frets: [12, 14, 12, 12, 12, 12], fingers: [1, 3, 1, 1, 1, 1]),
        ],
        "Fmaj7": [
            ChordGraphicItem(name: "Fmaj7", frets: [nil, nil, 3, 2, 1, 0], fingers: [nil, nil, 3, 2, 1, nil]),
            ChordGraphicItem(name: "Fmaj7", frets: [1, 3, 3, 2, 1, 1], fingers: [1, 3, 4, 2, 1, 1]),
            ChordGraphicItem(name: "Fmaj7", frets: [8, 10, 10, 9, 8, 8], fingers: [1, 3, 4, 2, 1, 1]),
        ],
        "G7": [
            ChordGraphicItem(name: "G7", frets: [3, 2, 0, 0, 0, 1], fingers: [3, 2, nil, nil, nil, 1]),
            ChordGraphicItem(name: "G7", frets: [nil, 10, 12, 10, 12, 10], fingers: [nil, 1, 3, 1, 4, 1]),
            ChordGraphicItem(name: "G7", frets: [3, 5, 3, 4, 3, 3], fingers: [1, 3, 1, 2, 1, 1]),
        ],
        "Am7": [
            ChordGraphicItem(name: "Am7", frets: [nil, 0, 2, 0, 1, 0], fingers: [nil, nil, 2, nil, 1, nil]),
            ChordGraphicItem(name: "Am7", frets: [5, 7, 5, 5, 5, 5], fingers: [1, 3, 1, 1, 1, 1]),
            ChordGraphicItem(name: "Am7", frets: [nil, 5, 7, 5, 5, 5], fingers: [nil, 1, 3, 1, 1, 1]),
        ],
        "Bm7b5": [
            ChordGraphicItem(name: "Bm7b5", frets: [nil, 2, 3, 2, 3, nil], fingers: [nil, 1, 3, 2, 4, nil]),
            ChordGraphicItem(name: "Bm7b5", frets: [7, 9, 7, 7, 7, nil], fingers: [1, 3, 1, 1, 1, nil]),
            ChordGraphicItem(name: "Bm7b5", frets: [nil, 7, 8, 7, 8, nil], fingers: [nil, 1, 3, 2, 4, nil]),
        ],
        // G调
        "Gmaj7": [
            ChordGraphicItem(name: "Gmaj7", frets: [3, 2, 0, 0, 0, 2], fingers: [3, 2, nil, nil, nil, 4]),
            ChordGraphicItem(name: "Gmaj7", frets: [nil, 10, 12, 11, 12, 10], fingers: [nil, 1, 3, 2, 4, 1]),
            ChordGraphicItem(name: "Gmaj7", frets: [3, 5, 4, 4, 3, 3], fingers: [1, 3, 2, 2, 1, 1]),
        ],
        "D7": [
            ChordGraphicItem(name: "D7", frets: [nil, nil, 0, 2, 1, 2], fingers: [nil, nil, nil, 3, 1, 2]),
            ChordGraphicItem(name: "D7", frets: [nil, 5, 7, 5, 7, 5], fingers: [nil, 1, 3, 1, 4, 1]),
            ChordGraphicItem(name: "D7", frets: [10, 12, 10, 11, 10, 10], fingers: [1, 3, 1, 2, 1, 1]),
        ],
        "Bm7": [
            ChordGraphicItem(name: "Bm7", frets: [nil, 2, 4, 2, 3, 2], fingers: [nil, 1, 3, 1, 2, 1]),
            ChordGraphicItem(name: "Bm7", frets: [7, 9, 7, 7, 7, 7], fingers: [1, 3, 1, 1, 1, 1]),
            ChordGraphicItem(name: "Bm7", frets: [nil, 7, 9, 7, 8, 7], fingers: [nil, 1, 3, 1, 2, 1]),
        ],
        "F#m7b5": [
            ChordGraphicItem(name: "F#m7b5", frets: [nil, nil, 2, 2, 1, 1], fingers: [nil, nil, 3, 4, 1, 2]),
            ChordGraphicItem(name: "F#m7b5", frets: [2, 4, 2, 2, 2, nil], fingers: [1, 3, 1, 1, 1, nil]),
            ChordGraphicItem(name: "F#m7b5", frets: [nil, 9, 10, 9, 10, nil], fingers: [nil, 1, 3, 2, 4, nil]),
        ],
        // D调
        "Dmaj7": [
            ChordGraphicItem(name: "Dmaj7", frets: [nil, nil, 0, 2, 2, 2], fingers: [nil, nil, nil, 1, 2, 3]),
            ChordGraphicItem(name: "Dmaj7", frets: [nil, 5, 7, 6, 7, 5], fingers: [nil, 1, 3, 2, 4, 1]),
            ChordGraphicItem(name: "Dmaj7", frets: [10, 12, 11, 11, 10, 10], fingers: [1, 3, 2, 2, 1, 1]),
        ],
        "F#m7": [
            ChordGraphicItem(name: "F#m7", frets: [2, nil, 2, 2, 2, nil], fingers: [1, nil, 2, 3, 4, nil]),
            ChordGraphicItem(name: "F#m7", frets: [2, 4, 2, 2, 2, 2], fingers: [1, 3, 1, 1, 1, 1]),
            ChordGraphicItem(name: "F#m7", frets: [9, 11, 9, 9, 9, 9], fingers: [1, 3, 1, 1, 1, 1]),
        ],
        "A7": [
            ChordGraphicItem(name: "A7", frets: [nil, 0, 2, 0, 2, 0], fingers: [nil, nil, 2, nil, 3, nil]),
            ChordGraphicItem(name: "A7", frets: [nil, 5, 7, 5, 7, 5], fingers: [nil, 1, 3, 1, 4, 1]),
            ChordGraphicItem(name: "A7", frets: [5, 7, 5, 6, 5, 5], fingers: [1, 3, 1, 2, 1, 1]),
        ],
        "C#m7b5": [
            ChordGraphicItem(name: "C#m7b5", frets: [nil, 4, 5, 4, 5, nil], fingers: [nil, 1, 3, 2, 4, nil]),
            ChordGraphicItem(name: "C#m7b5", frets: [4, 6, 4, 4, 4, nil], fingers: [1, 3, 1, 1, 1, nil]),
            ChordGraphicItem(name: "C#m7b5", frets: [nil, 9, 10, 9, 10, nil], fingers: [nil, 1, 3, 2, 4, nil]),
        ],
        // A调
        "Amaj7": [
            ChordGraphicItem(name: "Amaj7", frets: [nil, 0, 2, 1, 2, 0], fingers: [nil, nil, 3, 1, 2, nil]),
            ChordGraphicItem(name: "Amaj7", frets: [nil, 5, 7, 6, 7, 5], fingers: [nil, 1, 3, 2, 4, 1]),
            ChordGraphicItem(name: "Amaj7", frets: [5, 7, 7, 6, 5, 5], fingers: [1, 3, 4, 2, 1, 1]),
        ],
        "C#m7": [
            ChordGraphicItem(name: "C#m7", frets: [nil, 4, 6, 4, 5, 4], fingers: [nil, 1, 4, 2, 3, 1]),
            ChordGraphicItem(name: "C#m7", frets: [4, 6, 4, 4, 4, 4], fingers: [1, 3, 1, 1, 1, 1]),
            ChordGraphicItem(name: "C#m7", frets: [nil, 9, 11, 9, 10, 9], fingers: [nil, 1, 3, 1, 2, 1]),
        ],
        "E7": [
            ChordGraphicItem(name: "E7", frets: [0, 2, 0, 1, 0, 0], fingers: [nil, 3, nil, 1, nil, nil]),
            ChordGraphicItem(name: "E7", frets: [nil, 7, 9, 7, 9, 7], fingers: [nil, 1, 3, 1, 4, 1]),
            ChordGraphicItem(name: "E7", frets: [7, 9, 7, 8, 7, 7], fingers: [1, 3, 1, 2, 1, 1]),
        ],
        "G#m7b5": [
            ChordGraphicItem(name: "G#m7b5", frets: [4, nil, 4, 4, 4, nil], fingers: [1, nil, 2, 3, 4, nil]),
            ChordGraphicItem(name: "G#m7b5", frets: [4, 6, 4, 4, 4, nil], fingers: [1, 3, 1, 1, 1, nil]),
            ChordGraphicItem(name: "G#m7b5", frets: [nil, 9, 10, 9, 10, nil], fingers: [nil, 1, 3, 2, 4, nil]),
        ],
        // E调
        "Emaj7": [
            ChordGraphicItem(name: "Emaj7", frets: [0, 2, 1, 1, 0, 0], fingers: [nil, 3, 1, 2, nil, nil]),
            ChordGraphicItem(name: "Emaj7", frets: [nil, 7, 9, 8, 9, 7], fingers: [nil, 1, 3, 2, 4, 1]),
            ChordGraphicItem(name: "Emaj7", frets: [7, 9, 9, 8, 7, 7], fingers: [1, 3, 4, 2, 1, 1]),
        ],
        "G#m7": [
            ChordGraphicItem(name: "G#m7", frets: [4, nil, 4, 4, 4, nil], fingers: [1, nil, 2, 3, 4, nil]),
            ChordGraphicItem(name: "G#m7", frets: [4, 6, 4, 4, 4, 4], fingers: [1, 3, 1, 1, 1, 1]),
            ChordGraphicItem(name: "G#m7", frets: [11, 13, 11, 11, 11, 11], fingers: [1, 3, 1, 1, 1, 1]),
        ],
        "B7": [
            ChordGraphicItem(name: "B7", frets: [nil, 2, 1, 2, 0, 2], fingers: [nil, 3, 1, 2, nil, 4]),
            ChordGraphicItem(name: "B7", frets: [nil, 7, 9, 7, 9, 7], fingers: [nil, 1, 3, 1, 4, 1]),
            ChordGraphicItem(name: "B7", frets: [7, 9, 7, 8, 7, 7], fingers: [1, 3, 1, 2, 1, 1]),
        ],
        "D#m7b5": [
            ChordGraphicItem(name: "D#m7b5", frets: [nil, 5, 6, 5, 6, nil], fingers: [nil, 1, 3, 2, 4, nil]),
            ChordGraphicItem(name: "D#m7b5", frets: [6, 8, 6, 6, 6, nil], fingers: [1, 3, 1, 1, 1, nil]),
            ChordGraphicItem(name: "D#m7b5", frets: [nil, 11, 12, 11, 12, nil], fingers: [nil, 1, 3, 2, 4, nil]),
        ],
        // F调
        "Bbmaj7": [
            ChordGraphicItem(name: "Bbmaj7", frets: [nil, 1, 3, 2, 3, 1], fingers: [nil, 1, 4, 2, 3, 1]),
            ChordGraphicItem(name: "Bbmaj7", frets: [6, 8, 8, 7, 6, 6], fingers: [1, 3, 4, 2, 1, 1]),
            ChordGraphicItem(name: "Bbmaj7", frets: [nil, 6, 8, 7, 8, 6], fingers: [nil, 1, 3, 2, 4, 1]),
        ],
        "Gm7": [
            ChordGraphicItem(name: "Gm7", frets: [3, 5, 3, 3, 3, 3], fingers: [1, 3, 1, 1, 1, 1]),
            ChordGraphicItem(name: "Gm7", frets: [nil, 10, 12, 10, 11, 10], fingers: [nil, 1, 3, 1, 2, 1]),
            ChordGraphicItem(name: "Gm7", frets: [10, 12, 10, 10, 10, 10], fingers: [1, 3, 1, 1, 1, 1]),
        ],
        "C7": [
            ChordGraphicItem(name: "C7", frets: [nil, 3, 2, 3, 1, 0], fingers: [nil, 4, 2, 3, 1, nil]),
            ChordGraphicItem(name: "C7", frets: [nil, 8, 10, 8, 10, 8], fingers: [nil, 1, 3, 1, 4, 1]),
            ChordGraphicItem(name: "C7", frets: [8, 10, 8, 9, 8, 8], fingers: [1, 3, 1, 2, 1, 1]),
        ],
        "Em7b5": [
            ChordGraphicItem(name: "Em7b5", frets: [nil, nil, 2, 3, 3, 3], fingers: [nil, nil, 1, 2, 3, 4]),
            ChordGraphicItem(name: "Em7b5", frets: [nil, 7, 8, 7, 8, nil], fingers: [nil, 1, 3, 2, 4, nil]),
            ChordGraphicItem(name: "Em7b5", frets: [7, 9, 7, 7, 7, nil], fingers: [1, 3, 1, 1, 1, nil]),
        ],
        // Bb调
        "Ebmaj7": [
            ChordGraphicItem(name: "Ebmaj7", frets: [nil, nil, 1, 3, 3, 3], fingers: [nil, nil, 1, 2, 3, 4]),
            ChordGraphicItem(name: "Ebmaj7", frets: [nil, 6, 8, 7, 8, 6], fingers: [nil, 1, 3, 2, 4, 1]),
            ChordGraphicItem(name: "Ebmaj7", frets: [6, 8, 8, 7, 6, 6], fingers: [1, 3, 4, 2, 1, 1]),
        ],
        "Cm7": [
            ChordGraphicItem(name: "Cm7", frets: [nil, 3, 5, 3, 4, 3], fingers: [nil, 1, 4, 2, 3, 1]),
            ChordGraphicItem(name: "Cm7", frets: [nil, 8, 10, 8, 9, 8], fingers: [nil, 1, 3, 1, 2, 1]),
            ChordGraphicItem(name: "Cm7", frets: [8, 10, 8, 8, 8, 8], fingers: [1, 3, 1, 1, 1, 1]),
        ],
        "Fm7": [
            ChordGraphicItem(name: "Fm7", frets: [1, 3, 1, 1, 1, 1], fingers: [1, 3, 1, 1, 1, 1]),
            ChordGraphicItem(name: "Fm7", frets: [nil, 8, 10, 8, 9, 8], fingers: [nil, 1, 3, 1, 2, 1]),
            ChordGraphicItem(name: "Fm7", frets: [8, 10, 8, 8, 8, 8], fingers: [1, 3, 1, 1, 1, 1]),
        ],
        "Abmaj7": [
            ChordGraphicItem(name: "Abmaj7", frets: [4, 6, 5, 5, 4, 4], fingers: [1, 3, 2, 2, 1, 1]),
            ChordGraphicItem(name: "Abmaj7", frets: [nil, 11, 13, 12, 13, 11], fingers: [nil, 1, 3, 2, 4, 1]),
            ChordGraphicItem(name: "Abmaj7", frets: [11, 13, 13, 12, 11, 11], fingers: [1, 3, 4, 2, 1, 1]),
        ],
        "Bb7": [
            ChordGraphicItem(name: "Bb7", frets: [nil, 1, 3, 1, 3, 1], fingers: [nil, 1, 3, 1, 4, 1]),
            ChordGraphicItem(name: "Bb7", frets: [nil, 6, 8, 6, 8, 6], fingers: [nil, 1, 3, 1, 4, 1]),
            ChordGraphicItem(name: "Bb7", frets: [6, 8, 6, 7, 6, 6], fingers: [1, 3, 1, 2, 1, 1]),
        ],
        "Am7b5": [
            ChordGraphicItem(name: "Am7b5", frets: [nil, 0, 1, 0, 1, nil], fingers: [nil, nil, 2, nil, 1, nil]),
            ChordGraphicItem(name: "Am7b5", frets: [nil, 5, 6, 5, 6, nil], fingers: [nil, 1, 3, 2, 4, nil]),
            ChordGraphicItem(name: "Am7b5", frets: [5, 7, 5, 5, 5, nil], fingers: [1, 3, 1, 1, 1, nil]),
        ],
        // Eb调
        "Bbm7": [
            ChordGraphicItem(name: "Bbm7", frets: [nil, 1, 3, 1, 2, 1], fingers: [nil, 1, 4, 2, 3, 1]),
            ChordGraphicItem(name: "Bbm7", frets: [nil, 6, 8, 6, 7, 6], fingers: [nil, 1, 3, 1, 2, 1]),
            ChordGraphicItem(name: "Bbm7", frets: [6, 8, 6, 6, 6, 6], fingers: [1, 3, 1, 1, 1, 1]),
        ],
        "Eb7": [
            ChordGraphicItem(name: "Eb7", frets: [nil, nil, 1, 3, 2, 3], fingers: [nil, nil, 1, 4, 2, 3]),
            ChordGraphicItem(name: "Eb7", frets: [nil, 6, 8, 6, 8, 6], fingers: [nil, 1, 3, 1, 4, 1]),
            ChordGraphicItem(name: "Eb7", frets: [6, 8, 6, 7, 6, 6], fingers: [1, 3, 1, 2, 1, 1]),
        ],
        "Dm7b5": [
            ChordGraphicItem(name: "Dm7b5", frets: [nil, nil, 0, 1, 1, 1], fingers: [nil, nil, nil, 1, 2, 3]),
            ChordGraphicItem(name: "Dm7b5", frets: [nil, 5, 6, 5, 6, nil], fingers: [nil, 1, 3, 2, 4, nil]),
            ChordGraphicItem(name: "Dm7b5", frets: [5, 7, 5, 5, 5, nil], fingers: [1, 3, 1, 1, 1, nil]),
        ],
        // Ab调
        "Ebm7": [
            ChordGraphicItem(name: "Ebm7", frets: [nil, nil, 1, 3, 2, 2], fingers: [nil, nil, 1, 4, 2, 3]),
            ChordGraphicItem(name: "Ebm7", frets: [nil, 6, 8, 6, 7, 6], fingers: [nil, 1, 3, 1, 2, 1]),
            ChordGraphicItem(name: "Ebm7", frets: [6, 8, 6, 6, 6, 6], fingers: [1, 3, 1, 1, 1, 1]),
        ],
        "Ab7": [
            ChordGraphicItem(name: "Ab7", frets: [4, 6, 4, 5, 4, 4], fingers: [1, 3, 1, 2, 1, 1]),
            ChordGraphicItem(name: "Ab7", frets: [nil, 11, 13, 11, 13, 11], fingers: [nil, 1, 3, 1, 4, 1]),
            ChordGraphicItem(name: "Ab7", frets: [11, 13, 11, 12, 11, 11], fingers: [1, 3, 1, 2, 1, 1]),
        ],
        "Cm7b5": [
            ChordGraphicItem(name: "Cm7b5", frets: [nil, 3, 4, 3, 4, nil], fingers: [nil, 1, 3, 2, 4, nil]),
            ChordGraphicItem(name: "Cm7b5", frets: [3, 5, 3, 3, 3, nil], fingers: [1, 3, 1, 1, 1, nil]),
            ChordGraphicItem(name: "Cm7b5", frets: [nil, 8, 9, 8, 9, nil], fingers: [nil, 1, 3, 2, 4, nil]),
        ],
        // Db调
        "Abm7": [
            ChordGraphicItem(name: "Abm7", frets: [4, 6, 4, 4, 4, 4], fingers: [1, 3, 1, 1, 1, 1]),
            ChordGraphicItem(name: "Abm7", frets: [nil, 11, 13, 11, 12, 11], fingers: [nil, 1, 3, 1, 2, 1]),
            ChordGraphicItem(name: "Abm7", frets: [11, 13, 11, 11, 11, 11], fingers: [1, 3, 1, 1, 1, 1]),
        ],
        "Cbmaj7": [
            ChordGraphicItem(name: "Cbmaj7", frets: [nil, nil, 0, 1, 0, 0], fingers: [nil, nil, nil, 1, nil, nil]),
            ChordGraphicItem(name: "Cbmaj7", frets: [nil, 6, 8, 7, 8, 6], fingers: [nil, 1, 3, 2, 4, 1]),
            ChordGraphicItem(name: "Cbmaj7", frets: [6, 8, 8, 7, 6, 6], fingers: [1, 3, 4, 2, 1, 1]),
        ],
        "Db7": [
            ChordGraphicItem(name: "Db7", frets: [nil, nil, 1, 1, 1, 2], fingers: [nil, nil, 1, 1, 1, 2]),
            ChordGraphicItem(name: "Db7", frets: [nil, 6, 8, 6, 8, 6], fingers: [nil, 1, 3, 1, 4, 1]),
            ChordGraphicItem(name: "Db7", frets: [6, 8, 6, 7, 6, 6], fingers: [1, 3, 1, 2, 1, 1]),
        ],
        "Fm7b5": [
            ChordGraphicItem(name: "Fm7b5", frets: [nil, nil, 1, 1, 0, 1], fingers: [nil, nil, 2, 3, nil, 1]),
            ChordGraphicItem(name: "Fm7b5", frets: [nil, 6, 7, 6, 7, nil], fingers: [nil, 1, 3, 2, 4, nil]),
            ChordGraphicItem(name: "Fm7b5", frets: [6, 8, 6, 6, 6, nil], fingers: [1, 3, 1, 1, 1, nil]),
        ],
    ]

    var body: some View {
        VStack(spacing: 0) {
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
                        VStack(spacing: 0) {
                            HStack(alignment: .top, spacing: 10) {
                                // 左侧：级数 + 类型标签
                                VStack(spacing: 6) {
                                    Text(degrees[index])
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundStyle(AppTheme.primaryText)
                                        .frame(width: 26)

                                    Text(chordTypes[index])
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundStyle(chordColors[chordTypes[index]] ?? AppTheme.secondaryText)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background((chordColors[chordTypes[index]] ?? AppTheme.secondaryText).opacity(0.1))
                                        .clipShape(RoundedRectangle(cornerRadius: 5))
                                }
                                .padding(.top, 4)

                                // 右侧：多个指法图横向滚动
                                if let diagrams = chordDiagrams[chord], !diagrams.isEmpty {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 8) {
                                            ForEach(Array(diagrams.enumerated()), id: \.offset) { _, diagram in
                                                SeventhChordDiagram(diagram: diagram)
                                            }
                                        }
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 4)
                                    }
                                }

                                Spacer()
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                        }

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
        .navigationTitle("七和弦")
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(Color.white, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("返回")
                            .font(.system(size: 15))
                    }
                    .foregroundStyle(AppTheme.accent)
                }
            }
        }
    }
}

// MARK: - 七和弦指法图（v0 原型 SVG 风格）

struct SeventhChordDiagram: View {
    let diagram: ChordGraphicItem

    // 对应 v0 原型的 viewBox="0 0 60 70"
    private let stringXs: [CGFloat] = [10, 18, 26, 34, 42, 50]
    private let fretYs: [CGFloat] = [10, 22.5, 35, 47.5, 60]

    /// 计算显示的起始品位（支持高把位）
    private var startFret: Int {
        let maxFret = diagram.frets.compactMap { $0 }.filter { $0 > 0 }.max() ?? 4
        if maxFret > 4 {
            return max(1, maxFret - 3)
        }
        return 1
    }

    /// 是否有高把位按法
    private var isHighFret: Bool {
        startFret > 1
    }

    var body: some View {
        VStack(spacing: 0) {
            Text(diagram.name)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppTheme.primaryText)
                .padding(.bottom, 6)

            ZStack {
                // 品位线（第一条加粗模拟琴枕或起始品位线）
                ForEach(0..<5, id: \.self) { i in
                    Path { path in
                        path.move(to: CGPoint(x: stringXs.first!, y: fretYs[i]))
                        path.addLine(to: CGPoint(x: stringXs.last!, y: fretYs[i]))
                    }
                    .stroke(i == 0 && !isHighFret ? AppTheme.primaryText.opacity(0.4) : AppTheme.border,
                            lineWidth: i == 0 && !isHighFret ? 2.5 : 1)
                }

                // 弦线（6根竖线）
                ForEach(0..<6, id: \.self) { i in
                    Path { path in
                        path.move(to: CGPoint(x: stringXs[i], y: fretYs.first!))
                        path.addLine(to: CGPoint(x: stringXs[i], y: fretYs.last!))
                    }
                    .stroke(AppTheme.border, lineWidth: 1)
                }

                // 高把位起始品位标记
                if isHighFret {
                    Text("\(startFret)fr")
                        .font(.system(size: 6, weight: .bold))
                        .foregroundStyle(AppTheme.primaryText)
                        .position(x: 5, y: 16)
                }

                // 指法标记（×、○、●）
                ForEach(Array(diagram.frets.enumerated()), id: \.offset) { i, fret in
                    let x = stringXs[i]
                    if let f = fret {
                        if f == 0 {
                            // 空弦 — 空心圆
                            Circle()
                                .stroke(AppTheme.primaryText, lineWidth: 1)
                                .frame(width: 5, height: 5)
                                .position(x: x, y: 4)
                        } else {
                            // 按品 — 实心圆（使用相对品号计算位置）
                            let relativeFret = f - startFret + 1
                            let y = 10 + (CGFloat(relativeFret) - 0.5) * 12.5
                            ZStack {
                                Circle()
                                    .fill(AppTheme.primaryText)
                                    .frame(width: 6, height: 6)
                                if i < diagram.fingers.count, let finger = diagram.fingers[i] {
                                    Text("\(finger)")
                                        .font(.system(size: 5.5, weight: .bold))
                                        .foregroundStyle(.white)
                                }
                            }
                            .position(x: x, y: y)
                        }
                    } else {
                        // 不弹 — × 标记
                        Text("×")
                            .font(.system(size: 7, weight: .medium))
                            .foregroundStyle(AppTheme.secondaryText)
                            .position(x: x, y: 6)
                    }
                }
            }
            .frame(width: 60, height: 70)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(AppTheme.border, lineWidth: 1)
        )
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
        .background(AppTheme.background)
        .navigationTitle("五度圈")
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(Color.white, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("返回")
                            .font(.system(size: 15))
                    }
                    .foregroundStyle(AppTheme.accent)
                }
            }
        }
    }
}

#Preview {
    CircleOfFifthsView()
}

/// 乐理知识点详情页 - 四级页面
struct TheoryDetailView: View {
    let topic: TheoryTopicData
    var progressService: TheoryProgressService? = nil
    @Environment(\.dismiss) private var dismiss
    @State private var detailData: TheoryDetailData?
    @State private var audio = TheoryTapAudio()

    // 关联练习导航状态
    @State private var selectedPracticeExercise: PracticeExerciseData?
    @State private var practiceCategory: PracticeCategoryData?

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // === 五度圈（如果需要）===
                if detailData?.showCircleOfFifths == true {
                    CircleOfFifthsCompact(audio: audio)
                }

                // === 内容章节 ===
                if let details = detailData {
                    ForEach(details.sections) { section in
                        sectionCard(section)
                    }
                } else {
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
        .background(AppTheme.background)
        .navigationTitle(detailData?.title ?? topic.title)
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(Color.white, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("返回")
                            .font(.system(size: 15))
                    }
                    .foregroundStyle(AppTheme.accent)
                }
            }
        }
        .navigationDestination(item: $selectedPracticeExercise) { exercise in
            if let category = practiceCategory {
                if exercise.id == "single-note" {
                    SingleNoteListeningView()
                } else if exercise.hasLevels {
                    ExerciseLevelsPage(exercise: exercise, categoryId: category.id, color: category.color)
                } else {
                    ExerciseContainerView(
                        exercise: ExerciseItem(
                            id: exercise.id,
                            title: exercise.title,
                            mode: exerciseMode(for: exercise.id, categoryId: category.id),
                            percentage: exercise.progress
                        ),
                        moduleId: category.id
                    )
                }
            }
        }
        .onAppear {
            detailData = TheoryDetailDatabase.getCurriculumDetail(for: topic.id)
            progressService?.markRead(topic.id)
        }
    }

    /// 根据练习ID和分类ID推断练习模式
    private func exerciseMode(for exerciseId: String, categoryId: String) -> ExerciseMode {
        switch exerciseId {
        case "single-note-sing", "interval-imitate", "interval-singing",
             "melody-singing", "chord-singing", "scale-sing", "interval-construct",
             "three-note-sing":
            return .sightSinging
        case "note-name-keyboard":
            return .keyboardInput
        default:
            return categoryId == "singing" ? .sightSinging : .multipleChoice
        }
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

            if section.graphicType != .none {
                TheoryGraphics.graphicView(for: section, audio: audio)
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
        if let resolved = TheoryPracticeMapper.resolvedLink(for: topic.id) {
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

                // 练习信息
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(resolved.category.color.opacity(0.1))
                            .frame(width: 44, height: 44)
                        Image(systemName: resolved.category.systemImage)
                            .font(.system(size: 20))
                            .foregroundStyle(resolved.category.color)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(resolved.exercise.title)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(AppTheme.primaryText)
                        Text(resolved.link.reason)
                            .font(.system(size: 12))
                            .foregroundStyle(AppTheme.secondaryText)
                            .lineLimit(1)
                    }

                    Spacer()
                }

                Button(action: {
                    practiceCategory = resolved.category
                    selectedPracticeExercise = resolved.exercise
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
        } else {
            // 无关联练习时显示提示
            VStack(spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: "figure.run")
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.secondaryText)
                    Text("关联练习")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AppTheme.secondaryText)
                    Spacer()
                }
                Text("该知识点的专项练习即将上线，请先通过「练习」Tab进行相关训练")
                    .font(.system(size: 13))
                    .foregroundStyle(AppTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.border, lineWidth: 0.5))
        }
    }
}

// MARK: - 紧凑五度圈（用于乐理详情内嵌）

struct CircleOfFifthsCompact: View {
    var audio: TheoryTapAudio? = nil
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
                Text("五度圈 · 点击调号试听")
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

                    Button(action: {
                        selectedKey = key
                        audio?.playKeyChord(key)
                    }) {
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
