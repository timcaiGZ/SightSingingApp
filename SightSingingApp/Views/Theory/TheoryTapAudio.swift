import SwiftUI

/// 乐理知识点点击发音管理器
/// 封装 ExerciseSoundPlayer，为 TheoryGraphics 中的图形提供语义化音频 API
@Observable
class TheoryTapAudio {

    // MARK: - 单音

    func playNote(_ midi: Int, duration: TimeInterval = 0.8) {
        Task { await AudioEngineManager.shared.playMIDI(midi, duration: duration) }
    }

    func playNoteByName(_ name: String, octave: Int = 4) {
        guard let midi = ExerciseSoundPlayer.parseNoteNameToMIDI(name, defaultOctave: octave)
        else { return }
        playNote(midi)
    }

    // MARK: - 音程

    func playInterval(_ semitones: Int, rootMidi: Int = 60) {
        Task {
            await AudioEngineManager.shared.playMIDI(rootMidi, duration: 0.6)
            try? await Task.sleep(nanoseconds: 500_000_000)
            await AudioEngineManager.shared.playMIDI(rootMidi + semitones, duration: 0.6)
        }
    }

    // MARK: - 和弦

    func playTriadQuality(_ quality: TriadQuality, root: String? = nil) {
        ExerciseSoundPlayer.playTriadQuality(quality, root: root)
    }

    func playChord(named name: String) {
        ExerciseSoundPlayer.playChordNamed(name)
    }

    // MARK: - 音阶

    func playScale(_ notes: [String]) {
        Task {
            for note in notes {
                playNoteByName(note)
                try? await Task.sleep(nanoseconds: 350_000_000)
            }
        }
    }

    // MARK: - 节奏

    func playRhythmHint() {
        ExerciseSoundPlayer.playRhythmHint()
    }

    // MARK: - 吉他指板

    /// 标准调音：E2(40) A2(45) D3(50) G3(55) B3(59) E4(64)
    /// string: 0=低音E .. 5=高音E
    func playFretboardNote(string: Int, fret: Int) {
        let openMidi = [40, 45, 50, 55, 59, 64]
        guard string >= 0, string < openMidi.count else { return }
        playNote(openMidi[string] + fret)
    }

    // MARK: - 五度圈

    /// 点击调号时弹该调的主和弦
    func playKeyChord(_ keyName: String) {
        let root = String(keyName.prefix(while: { !$0.isLowercase && $0 != " " }))
        // 小调 → 小三和弦，大调 → 大三和弦
        let quality: TriadQuality = keyName.contains("m") ? .minor : .major
        playTriadQuality(quality, root: root)
    }
}
