import Foundation

// MARK: - 视唱旋律音符

/// 视唱练习中的旋律音符
struct MelodyNote: Identifiable, Equatable {
    let id = UUID()
    let solfege: String   // 简谱音名：1-7
    let octave: Int       // 八度
    let duration: Double  // 时值（拍）

    init(solfege: String, octave: Int, duration: Double) {
        self.solfege = solfege
        self.octave = octave
        self.duration = duration
    }

    /// 显示名称（如 "C4", "D#5" 等）
    var displayName: String {
        let solfegeToNote: [String: String] = [
            "1": "C", "#1": "C#", "♭2": "Db",
            "2": "D", "#2": "D#", "♭3": "Eb",
            "3": "E",
            "4": "F", "#4": "F#",
            "5": "G", "#5": "G#", "♭6": "Ab",
            "6": "A", "#6": "A#", "♭7": "Bb",
            "7": "B",
        ]
        let noteName = solfegeToNote[solfege] ?? solfege
        return "\(noteName)\(octave)"
    }
}
