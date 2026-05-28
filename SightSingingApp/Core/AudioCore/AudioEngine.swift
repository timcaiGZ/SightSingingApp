import AVFoundation
import Foundation

/// 音频引擎 actor — 负责播放多音色音符与鼓组，线程安全。
///
/// 现在位于 Core/AudioCore/，支持按 PlaybackEngine 时间线同步调度播放。
/// 音色由全局 TimbreSettings 通过 UserDefaults 驱动，所有播放自动适配当前设定。
actor AudioEngineManager {
    static let shared = AudioEngineManager()

    private var audioEngine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    private var isSetup = false
    private var currentCategory: AVAudioSession.Category = .playback

    // MARK: - Buffer Cache (预渲染优化)

    private var bufferCache: [Int: AVAudioPCMBuffer] = [:]

    private init() {}

    // MARK: - Setup

    /// 初始化音频引擎（.playback 模式，仅播放，默认）
    func setup() {
        setup(category: .playback, options: [.mixWithOthers])
    }

    /// 初始化音频引擎（.playAndRecord 模式，支持同时播放和录音）
    func setupPlayAndRecord() {
        setup(category: .playAndRecord, options: [.mixWithOthers, .allowBluetoothHFP, .defaultToSpeaker])
    }

    /// 切换音频会话为 .playAndRecord（已初始化后通过 PitchDetector 场景调用）
    func activatePlayAndRecord() {
        guard isSetup else {
            setup(category: .playAndRecord, options: [.mixWithOthers, .allowBluetoothHFP, .defaultToSpeaker])
            return
        }
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: [.mixWithOthers, .allowBluetoothHFP, .defaultToSpeaker])
            try session.setActive(true)
            currentCategory = .playAndRecord
        } catch {
            print("切换音频会话到 playAndRecord 失败: \(error)")
        }
    }

    /// 私有初始化方法
    private func setup(category: AVAudioSession.Category, options: AVAudioSession.CategoryOptions) {
        guard !isSetup || currentCategory != category else { return }

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(category, mode: .default, options: options)
            try session.setActive(true)
            currentCategory = category
        } catch {
            print("音频会话配置失败: \(error)")
        }

        guard audioEngine == nil else { return }

        audioEngine = AVAudioEngine()
        playerNode = AVAudioPlayerNode()

        guard let engine = audioEngine, let player = playerNode else { return }

        engine.attach(player)

        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        engine.connect(player, to: engine.mainMixerNode, format: format)

        do {
            try engine.start()
            isSetup = true
        } catch {
            print("音频引擎启动失败: \(error)")
        }
    }

    // MARK: - Tone & Drum Kit (read from UserDefaults)

    private var currentInstrumentTone: TimbreSettings.InstrumentTone {
        let raw = UserDefaults.standard.string(forKey: "timbre.instrumentTone") ?? "acoustic-guitar"
        return TimbreSettings.InstrumentTone(rawValue: raw) ?? .acousticGuitar
    }

    private var currentDrumKit: TimbreSettings.DrumKit {
        let raw = UserDefaults.standard.string(forKey: "timbre.drumKit") ?? "drum-kit"
        return TimbreSettings.DrumKit(rawValue: raw) ?? .drumKit
    }

    // MARK: - Basic Playback

    /// 播放单个音符（简谱 solfege，如 "1", "2", "5"）
    func playSolfege(_ solfege: String, octave: Int = 4, duration: TimeInterval = 0.8) async {
        guard let midiNote = MusicTheory.midiNote(from: solfege, octave: octave) else { return }
        let frequency = MusicTheory.frequencyFromMIDI(midiNote)
        await playNote(frequency: frequency, duration: duration)
    }

    /// 播放指定频率的音符（自动适配当前乐器音色）
    func playNote(frequency: Double, duration: TimeInterval = 0.8, stopPrevious: Bool = true) async {
        await setup()

        guard let player = playerNode else { return }
        if stopPrevious {
            player.stop()
        }

        let samples = generateInstrumentTone(frequency: frequency, duration: duration)
        let buffer = createBuffer(from: samples)
        player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        if !player.isPlaying {
            player.play()
        }
    }

    /// 播放和弦（多个音符同时发声，自动适配当前乐器音色）
    func playChord(_ notes: [(solfege: String, octave: Int)], duration: TimeInterval = 1.0) async {
        await setup()

        guard let player = playerNode else { return }
        player.stop()

        let allFrequencies = notes.compactMap { note -> Double? in
            guard let midi = MusicTheory.midiNote(from: note.solfege, octave: note.octave) else { return nil }
            return MusicTheory.frequencyFromMIDI(midi)
        }

        let samples = generateInstrumentChord(frequencies: allFrequencies, duration: duration)
        let buffer = createBuffer(from: samples)
        player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        player.play()
    }

    /// 播放指定 MIDI note
    func playMIDI(_ midiNote: Int, duration: TimeInterval = 0.8, stopPrevious: Bool = true) async {
        let frequency = MusicTheory.frequencyFromMIDI(midiNote)
        await playNote(frequency: frequency, duration: duration, stopPrevious: stopPrevious)
    }

    /// 停止播放
    func stop() {
        playerNode?.stop()
    }

    // MARK: - Scheduled Playback API

    /// 调度一个音符在指定时间播发（用于时间线同步）
    func scheduleNote(midi: Int, at beat: Double, duration: TimeInterval, velocity: Double = 0.7) {
        guard let player = playerNode else { return }

        let frequency = MusicTheory.frequencyFromMIDI(midi)
        let samples = generateInstrumentTone(frequency: frequency, duration: duration)
        let adjustedSamples = samples.map { $0 * velocity }
        let buffer = createBuffer(from: adjustedSamples)

        player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
    }

    /// 调度一个和弦在指定时间播放
    func scheduleChord(midiNotes: [Int], duration: TimeInterval, velocity: Double = 0.7) {
        guard let player = playerNode, !midiNotes.isEmpty else { return }

        let frequencies = midiNotes.map { MusicTheory.frequencyFromMIDI($0) }
        let samples = generateInstrumentChord(frequencies: frequencies, duration: duration)
        let adjustedSamples = samples.map { $0 * velocity }
        let buffer = createBuffer(from: adjustedSamples)

        player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
    }

    /// 按时间线直接播放（简化版，不通过 PlaybackEngine）
    func playTimeline(_ events: [PlaybackEngine.TimedAudioEvent]) async {
        await setup()
        guard let player = playerNode else { return }

        player.stop()

        let sorted = events.sorted { $0.beat < $1.beat }

        guard let bpm = try? await getBPM() else { return }
        let beatDuration = 60.0 / bpm

        for event in sorted {
            if event.isChord, let chordNotes = event.chordNotes {
                await scheduleChord(midiNotes: chordNotes, duration: event.duration * beatDuration, velocity: event.velocity)
            } else {
                await scheduleNote(midi: event.midiNote, at: event.beat, duration: event.duration * beatDuration, velocity: event.velocity)
            }
            try? await Task.sleep(nanoseconds: UInt64(beatDuration * 1_000_000_000))
        }
    }

    /// 播放倒计时
    func playCountIn(beats: Int, bpm: Double) async {
        await setup()

        let beatDuration = 60.0 / bpm
        for i in 0..<beats {
            let midi = i == 0 ? 72 : 70
            let velocity = i == 0 ? 1.0 : 0.6
            await playMIDI(midi, duration: min(0.15, beatDuration * 0.3))
            try? await Task.sleep(nanoseconds: UInt64(beatDuration * 1_000_000_000))
        }
    }

    /// 从 MasterMusicClock 获取当前 BPM
    private func getBPM() async throws -> Double {
        return await MasterMusicClock.shared.bpm
    }

    // MARK: - Buffer Factory

    private func createBuffer(from samples: [Double]) -> AVAudioPCMBuffer {
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(samples.count))!
        buffer.frameLength = buffer.frameCapacity

        let channelData = buffer.floatChannelData![0]
        for (index, sample) in samples.enumerated() {
            channelData[index] = Float(sample)
        }
        return buffer
    }

    // MARK: - Instrument Tone Synthesis

    /// 生成乐器音色波形（根据当前 TimbreSettings 自动适配）
    private func generateInstrumentTone(frequency: Double, duration: TimeInterval) -> [Double] {
        let sampleRate = 44100.0
        let totalSamples = Int(sampleRate * duration)

        let (harmonics, envelopeProfile): ([(partial: Int, amplitude: Double)], EnvelopeProfile)
        switch currentInstrumentTone {
        case .acousticGuitar:
            harmonics = [(1, 1.0), (2, 0.5), (3, 0.3), (4, 0.15), (5, 0.1), (6, 0.05)]
            envelopeProfile = .pluckedString
        case .electricGuitar:
            harmonics = [(1, 1.0), (2, 0.6), (3, 0.4), (4, 0.25), (5, 0.15), (6, 0.1), (7, 0.05)]
            envelopeProfile = .sustainedPluck
        case .nylonGuitar:
            harmonics = [(1, 1.0), (2, 0.3), (3, 0.35), (4, 0.1), (5, 0.08), (6, 0.03)]
            envelopeProfile = .softPluck
        case .bass:
            harmonics = [(1, 1.0), (2, 0.2), (3, 0.05), (4, 0.02)]
            envelopeProfile = .longBass
        case .piano:
            harmonics = [(1, 1.0), (2, 0.4), (3, 0.25), (4, 0.12), (5, 0.06), (6, 0.03)]
            envelopeProfile = .piano
        case .ukulele:
            harmonics = [(1, 1.0), (2, 0.45), (3, 0.2), (4, 0.08), (5, 0.04)]
            envelopeProfile = .shortPluck
        case .synth:
            harmonics = [(1, 1.0), (2, 0.1), (3, 0.05)]
            envelopeProfile = .synthPad
        }

        var samples = [Double](repeating: 0, count: totalSamples)

        for harmonic in harmonics {
            let harmonicFreq = frequency * Double(harmonic.partial)
            for i in 0..<totalSamples {
                let time = Double(i) / sampleRate
                samples[i] += harmonic.amplitude * sin(2.0 * .pi * harmonicFreq * time)
            }
        }

        applyEnvelope(&samples, duration: duration, profile: envelopeProfile)

        let maxAmp = samples.map { abs($0) }.max() ?? 1.0
        if maxAmp > 0 {
            samples = samples.map { $0 / maxAmp * 0.7 }
        }

        return samples
    }

    /// 生成和弦波形（自动适配当前乐器音色）
    private func generateInstrumentChord(frequencies: [Double], duration: TimeInterval) -> [Double] {
        let sampleRate = 44100.0
        let totalSamples = Int(sampleRate * duration)
        var mixedSamples = [Double](repeating: 0, count: totalSamples)

        for freq in frequencies {
            let samples = generateInstrumentTone(frequency: freq, duration: duration)
            for i in 0..<min(totalSamples, samples.count) {
                mixedSamples[i] += samples[i] / Double(frequencies.count)
            }
        }

        let maxAmp = mixedSamples.map { abs($0) }.max() ?? 1.0
        if maxAmp > 0 {
            mixedSamples = mixedSamples.map { $0 / maxAmp * 0.7 }
        }

        return mixedSamples
    }

    // MARK: - Envelope Profiles

    private enum EnvelopeProfile {
        case pluckedString      // 木吉他
        case sustainedPluck     // 电吉他
        case softPluck          // 尼龙吉他
        case longBass           // 贝斯
        case piano              // 钢琴
        case shortPluck         // 尤克里里
        case synthPad           // 合成音
    }

    private func applyEnvelope(_ samples: inout [Double], duration: TimeInterval, profile: EnvelopeProfile) {
        let totalSamples = samples.count
        let sampleRate = 44100.0

        for i in 0..<totalSamples {
            let time = Double(i) / sampleRate
            let progress = time / duration
            var envelope: Double = 0

            switch profile {
            case .pluckedString:
                if progress < 0.02 {
                    envelope = progress / 0.02
                } else if progress < 0.1 {
                    envelope = 1.0 - (progress - 0.02) / 0.08 * 0.4
                } else if progress < 0.8 {
                    envelope = 0.6
                } else {
                    envelope = 0.6 * (1.0 - (progress - 0.8) / 0.2)
                }
            case .sustainedPluck:
                if progress < 0.01 {
                    envelope = progress / 0.01
                } else if progress < 0.15 {
                    envelope = 1.0 - (progress - 0.01) / 0.14 * 0.2
                } else if progress < 0.9 {
                    envelope = 0.8 * exp(-(progress - 0.15) * 2.0)
                } else {
                    envelope = 0.8 * exp(-0.75 * 2.0) * (1.0 - (progress - 0.9) / 0.1)
                }
            case .softPluck:
                if progress < 0.03 {
                    envelope = progress / 0.03
                } else if progress < 0.2 {
                    envelope = 1.0 - (progress - 0.03) / 0.17 * 0.3
                } else {
                    envelope = 0.7 * exp(-(progress - 0.2) * 3.0)
                }
            case .longBass:
                if progress < 0.01 {
                    envelope = progress / 0.01
                } else if progress < 0.05 {
                    envelope = 1.0
                } else {
                    envelope = exp(-(progress - 0.05) * 4.0)
                }
            case .piano:
                if progress < 0.005 {
                    envelope = progress / 0.005
                } else {
                    envelope = exp(-progress * 5.0)
                }
            case .shortPluck:
                if progress < 0.02 {
                    envelope = progress / 0.02
                } else if progress < 0.08 {
                    envelope = 1.0 - (progress - 0.02) / 0.06 * 0.3
                } else if progress < 0.5 {
                    envelope = 0.7
                } else {
                    envelope = 0.7 * (1.0 - (progress - 0.5) / 0.5)
                }
            case .synthPad:
                if progress < 0.05 {
                    envelope = progress / 0.05
                } else if progress < 0.7 {
                    envelope = 1.0
                } else {
                    envelope = 1.0 - (progress - 0.7) / 0.3
                }
            }

            samples[i] *= envelope
        }
    }

    // MARK: - Drum & Metronome

    /// 节拍器重音级别
    enum MetronomeAccent {
        case strong   // 第一拍重音
        case medium   // 其他拍首
        case weak     // 非拍首位置
    }

    /// 播放节拍器/鼓组点击声（自动适配当前鼓组设置）
    func playMetronomeClick(accent: MetronomeAccent) async {
        await setup()
        guard let player = playerNode else { return }

        let samples: [Double]
        switch currentDrumKit {
        case .metronome:
            samples = generateMetronomeClick(accent: accent)
        default:
            samples = generateDrumHit(accent: accent)
        }

        let buffer = createBuffer(from: samples)
        player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        if !player.isPlaying {
            player.play()
        }
    }

    // MARK: - Metronome Synthesis (legacy)

    private func generateMetronomeClick(accent: MetronomeAccent) -> [Double] {
        let sampleRate = 44100.0

        let (duration, mainFreq, overtoneFreq, amplitude): (TimeInterval, Double, Double, Double)
        switch accent {
        case .strong:
            duration = 0.12
            mainFreq = 800
            overtoneFreq = 2400
            amplitude = 1.0
        case .medium:
            duration = 0.08
            mainFreq = 1200
            overtoneFreq = 3600
            amplitude = 0.65
        case .weak:
            duration = 0.045
            mainFreq = 1600
            overtoneFreq = 4800
            amplitude = 0.35
        }

        let totalSamples = Int(sampleRate * duration)
        var samples = [Double](repeating: 0, count: totalSamples)

        for i in 0..<totalSamples {
            let time = Double(i) / sampleRate
            let envelope = exp(-time * 40.0)
            let click = sin(2.0 * .pi * mainFreq * time) * 0.65 +
                        sin(2.0 * .pi * overtoneFreq * time) * 0.25 +
                        (Double.random(in: -0.1...0.1) * exp(-time * 80.0))
            samples[i] = click * envelope * amplitude
        }

        normalize(&samples, target: 0.9)
        return samples
    }

    // MARK: - Drum Kit Synthesis

    private func generateDrumHit(accent: MetronomeAccent) -> [Double] {
        switch currentDrumKit {
        case .drumKit:
            return generateDrumKitHit(accent: accent)
        case .acousticDrum:
            return generateAcousticDrumHit(accent: accent)
        case .electronicDrum:
            return generateElectronicDrumHit(accent: accent)
        case .metronome:
            return generateMetronomeClick(accent: accent)
        }
    }

    /// 套鼓：强拍=kick+hi-hat, 中拍=snare+hi-hat, 弱拍=hi-hat
    private func generateDrumKitHit(accent: MetronomeAccent) -> [Double] {
        let sampleRate = 44100.0
        let duration: TimeInterval = accent == .strong ? 0.25 : (accent == .medium ? 0.18 : 0.12)
        let totalSamples = Int(sampleRate * duration)
        var samples = [Double](repeating: 0, count: totalSamples)

        // Hi-hat 始终存在
        addHiHat(to: &samples, sampleRate: sampleRate, electronic: false)

        switch accent {
        case .strong:
            addKick(to: &samples, sampleRate: sampleRate, electronic: false)
        case .medium:
            addSnare(to: &samples, sampleRate: sampleRate, electronic: false)
        case .weak:
            break // hi-hat only
        }

        normalize(&samples, target: 0.9)
        return samples
    }

    /// 原声鼓：更温暖、自然的音色
    private func generateAcousticDrumHit(accent: MetronomeAccent) -> [Double] {
        let sampleRate = 44100.0
        let duration: TimeInterval = accent == .strong ? 0.3 : (accent == .medium ? 0.22 : 0.15)
        let totalSamples = Int(sampleRate * duration)
        var samples = [Double](repeating: 0, count: totalSamples)

        addHiHat(to: &samples, sampleRate: sampleRate, electronic: false, softer: true)

        switch accent {
        case .strong:
            addKick(to: &samples, sampleRate: sampleRate, electronic: false, deeper: true)
        case .medium:
            addSnare(to: &samples, sampleRate: sampleRate, electronic: false, warmer: true)
        case .weak:
            break
        }

        normalize(&samples, target: 0.85)
        return samples
    }

    /// 电音鼓：电子鼓机音色
    private func generateElectronicDrumHit(accent: MetronomeAccent) -> [Double] {
        let sampleRate = 44100.0
        let duration: TimeInterval = accent == .strong ? 0.2 : (accent == .medium ? 0.15 : 0.1)
        let totalSamples = Int(sampleRate * duration)
        var samples = [Double](repeating: 0, count: totalSamples)

        addHiHat(to: &samples, sampleRate: sampleRate, electronic: true)

        switch accent {
        case .strong:
            addKick(to: &samples, sampleRate: sampleRate, electronic: true)
        case .medium:
            addSnare(to: &samples, sampleRate: sampleRate, electronic: true)
        case .weak:
            break
        }

        normalize(&samples, target: 0.9)
        return samples
    }

    // MARK: - Drum Components

    private func addKick(to samples: inout [Double], sampleRate: Double, electronic: Bool, deeper: Bool = false) {
        let count = samples.count
        let freq: Double = electronic ? 55.0 : (deeper ? 50.0 : 60.0)
        let decay: Double = electronic ? 25.0 : 18.0

        for i in 0..<count {
            let time = Double(i) / sampleRate
            let env = exp(-time * decay)
            let sweep = freq * (1.0 - min(time * 15.0, 0.5))
            samples[i] += sin(2.0 * .pi * sweep * time) * env * 0.8
            if !electronic {
                samples[i] += sin(2.0 * .pi * sweep * 2.0 * time) * env * 0.15
            }
        }
    }

    private func addSnare(to samples: inout [Double], sampleRate: Double, electronic: Bool, warmer: Bool = false) {
        let count = samples.count
        let toneFreq: Double = electronic ? 220.0 : (warmer ? 180.0 : 200.0)
        let decay: Double = electronic ? 35.0 : 22.0

        for i in 0..<count {
            let time = Double(i) / sampleRate
            let env = exp(-time * decay)
            let tone = sin(2.0 * .pi * toneFreq * time) * env * 0.3
            let noise = (Double.random(in: -1.0...1.0) * exp(-time * (electronic ? 50.0 : 30.0))) * 0.5
            samples[i] += tone + noise
        }
    }

    private func addHiHat(to samples: inout [Double], sampleRate: Double, electronic: Bool, softer: Bool = false) {
        let count = samples.count
        let decay: Double = electronic ? 80.0 : (softer ? 45.0 : 60.0)
        let amp: Double = softer ? 0.25 : 0.35

        for i in 0..<count {
            let time = Double(i) / sampleRate
            let env = exp(-time * decay)
            let metallic = sin(2.0 * .pi * 8000.0 * time) * 0.3 +
                           sin(2.0 * .pi * 12000.0 * time) * 0.2
            let noise = Double.random(in: -1.0...1.0) * 0.5
            samples[i] += (metallic + noise) * env * amp
        }
    }

    private func normalize(_ samples: inout [Double], target: Double) {
        let maxAmp = samples.map { abs($0) }.max() ?? 1.0
        if maxAmp > 0 {
            samples = samples.map { $0 / maxAmp * target }
        }
    }
}
