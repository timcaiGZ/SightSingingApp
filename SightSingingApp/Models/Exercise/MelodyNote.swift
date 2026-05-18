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
}
