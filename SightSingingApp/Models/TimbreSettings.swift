import Foundation
import SwiftUI

// MARK: - 全局音色设置

/// App 统一的音色配置中心
/// 所有涉及音频播放的模块都通过此设置决定发声音色
@Observable
final class TimbreSettings {
    static let shared = TimbreSettings()

    // MARK: - 吉他调音

    enum GuitarTuning: String, CaseIterable, Identifiable {
        case guitarEADGBE = "guitar-eadgbe"
        case ukuleleGCEA  = "ukulele-gcea"
        case bassEADG     = "bass-eadg"

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .guitarEADGBE: return "吉他"
            case .ukuleleGCEA:  return "尤克里里"
            case .bassEADG:     return "贝斯"
            }
        }

        var subtitle: String {
            switch self {
            case .guitarEADGBE: return "EADGBE"
            case .ukuleleGCEA:  return "GCEA"
            case .bassEADG:     return "EADG"
            }
        }

        var systemImage: String {
            switch self {
            case .guitarEADGBE: return "guitars"
            case .ukuleleGCEA:  return "guitars"
            case .bassEADG:     return "guitars"
            }
        }

        /// 空弦 MIDI 音高（从低音弦到高音弦）
        var openStringsMIDI: [Int] {
            switch self {
            case .guitarEADGBE:
                return [40, 45, 50, 55, 59, 64] // E2 A2 D3 G3 B3 E4
            case .ukuleleGCEA:
                return [67, 60, 64, 69]         // G4 C4 E4 A4
            case .bassEADG:
                return [28, 33, 38, 43]         // E1 A1 D2 G2
            }
        }

        /// 弦数
        var stringCount: Int { openStringsMIDI.count }
    }

    // MARK: - 鼓组

    enum DrumKit: String, CaseIterable, Identifiable {
        case drumKit       = "drum-kit"
        case acousticDrum  = "acoustic-drum"
        case electronicDrum = "electronic-drum"
        case metronome     = "metronome"

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .drumKit:       return "套鼓"
            case .acousticDrum:  return "原声鼓"
            case .electronicDrum: return "电音鼓"
            case .metronome:     return "节拍器"
            }
        }

        var systemImage: String {
            switch self {
            case .drumKit:       return "drum"
            case .acousticDrum:  return "drum"
            case .electronicDrum: return "drum"
            case .metronome:     return "metronome"
            }
        }
    }

    // MARK: - 乐器音色

    enum InstrumentTone: String, CaseIterable, Identifiable {
        case acousticGuitar = "acoustic-guitar"
        case electricGuitar = "electric-guitar"
        case nylonGuitar    = "nylon-guitar"
        case bass           = "bass"
        case piano          = "piano"
        case ukulele        = "ukulele"
        case synth          = "synth"

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .acousticGuitar: return "木吉他"
            case .electricGuitar: return "电吉他"
            case .nylonGuitar:    return "尼龙吉他"
            case .bass:           return "贝斯"
            case .piano:          return "钢琴"
            case .ukulele:        return "尤克里里"
            case .synth:          return "合成音"
            }
        }

        var systemImage: String {
            switch self {
            case .acousticGuitar: return "guitars"
            case .electricGuitar: return "guitars"
            case .nylonGuitar:    return "guitars"
            case .bass:           return "guitars"
            case .piano:          return "pianokeys"
            case .ukulele:        return "guitars"
            case .synth:          return "waveform"
            }
        }
    }

    // MARK: - 存储属性（stored + didSet，@Observable 可正确追踪变化）

    private let ud = UserDefaults.standard
    private let keyGuitarTuning = "timbre.guitarTuning"
    private let keyDrumKit = "timbre.drumKit"
    private let keyInstrumentTone = "timbre.instrumentTone"

    var guitarTuning: GuitarTuning {
        didSet { ud.set(guitarTuning.rawValue, forKey: keyGuitarTuning) }
    }

    var drumKit: DrumKit {
        didSet { ud.set(drumKit.rawValue, forKey: keyDrumKit) }
    }

    var instrumentTone: InstrumentTone {
        didSet { ud.set(instrumentTone.rawValue, forKey: keyInstrumentTone) }
    }

    private init() {
        guitarTuning = GuitarTuning(rawValue: ud.string(forKey: keyGuitarTuning) ?? "") ?? .guitarEADGBE
        drumKit = DrumKit(rawValue: ud.string(forKey: keyDrumKit) ?? "") ?? .drumKit
        instrumentTone = InstrumentTone(rawValue: ud.string(forKey: keyInstrumentTone) ?? "") ?? .acousticGuitar
    }
}
