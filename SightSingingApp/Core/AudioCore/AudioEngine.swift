import AVFoundation
import Foundation

/// 音频引擎 actor — 负责播放吉他音色音符，线程安全。
///
/// 现在位于 Core/AudioCore/，支持按 PlaybackEngine 时间线同步调度播放。
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

    // MARK: - Basic Playback (保留原有 API)

    /// 播放单个音符（简谱 solfege，如 "1", "2", "5"）
    func playSolfege(_ solfege: String, octave: Int = 4, duration: TimeInterval = 0.8) async {
        guard let midiNote = MusicTheory.midiNote(from: solfege, octave: octave) else { return }
        let frequency = MusicTheory.frequencyFromMIDI(midiNote)
        await playNote(frequency: frequency, duration: duration)
    }

    /// 播放指定频率的音符（吉他音色合成）
    func playNote(frequency: Double, duration: TimeInterval = 0.8) async {
        await setup()

        guard let player = playerNode else { return }
        player.stop()

        let samples = generateGuitarTone(frequency: frequency, duration: duration)
        let buffer = createBuffer(from: samples)
        player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        player.play()
    }

    /// 播放和弦（多个音符同时发声）
    func playChord(_ notes: [(solfege: String, octave: Int)], duration: TimeInterval = 1.0) async {
        await setup()

        guard let player = playerNode else { return }
        player.stop()

        let allFrequencies = notes.compactMap { note -> Double? in
            guard let midi = MusicTheory.midiNote(from: note.solfege, octave: note.octave) else { return nil }
            return MusicTheory.frequencyFromMIDI(midi)
        }

        let samples = generateGuitarChord(frequencies: allFrequencies, duration: duration)
        let buffer = createBuffer(from: samples)
        player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        player.play()
    }

    /// 播放指定 MIDI note
    func playMIDI(_ midiNote: Int, duration: TimeInterval = 0.8) async {
        let frequency = MusicTheory.frequencyFromMIDI(midiNote)
        await playNote(frequency: frequency, duration: duration)
    }

    /// 停止播放
    func stop() {
        playerNode?.stop()
    }

    // MARK: - Scheduled Playback API (新增 —— 供 PlaybackEngine 调用)

    /// 调度一个音符在指定时间播发（用于时间线同步）
    func scheduleNote(midi: Int, at beat: Double, duration: TimeInterval, velocity: Double = 0.7) {
        guard let player = playerNode else { return }

        let frequency = MusicTheory.frequencyFromMIDI(midi)
        let samples = generateGuitarTone(frequency: frequency, duration: duration)
        let adjustedSamples = samples.map { $0 * velocity }
        let buffer = createBuffer(from: adjustedSamples)

        player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
    }

    /// 调度一个和弦在指定时间播放
    func scheduleChord(midiNotes: [Int], duration: TimeInterval, velocity: Double = 0.7) {
        guard let player = playerNode, !midiNotes.isEmpty else { return }

        let frequencies = midiNotes.map { MusicTheory.frequencyFromMIDI($0) }
        let samples = generateGuitarChord(frequencies: frequencies, duration: duration)
        let adjustedSamples = samples.map { $0 * velocity }
        let buffer = createBuffer(from: adjustedSamples)

        player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
    }

    /// 按时间线直接播放（简化版，不通过 PlaybackEngine）
    func playTimeline(_ events: [PlaybackEngine.TimedAudioEvent]) async {
        await setup()
        guard let player = playerNode else { return }

        player.stop()

        // 将事件按顺序排列
        let sorted = events.sorted { $0.beat < $1.beat }

        guard let bpm = try? await getBPM() else { return }
        let beatDuration = 60.0 / bpm

        for event in sorted {
            if event.isChord, let chordNotes = event.chordNotes {
                await scheduleChord(midiNotes: chordNotes, duration: event.duration * beatDuration, velocity: event.velocity)
            } else {
                await scheduleNote(midi: event.midiNote, at: event.beat, duration: event.duration * beatDuration, velocity: event.velocity)
            }
            // 等待拍数间隔
            try? await Task.sleep(nanoseconds: UInt64(beatDuration * 1_000_000_000))
        }
    }

    /// 播放倒计时
    func playCountIn(beats: Int, bpm: Double) async {
        await setup()

        let beatDuration = 60.0 / bpm
        for i in 0..<beats {
            // 强拍用更亮的音色
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

    // MARK: - Guitar Tone Synthesis

    /// 生成吉他音色波形（正弦波 + 谐波 + ADSR 包络）
    private func generateGuitarTone(frequency: Double, duration: TimeInterval) -> [Double] {
        let sampleRate = 44100.0
        let totalSamples = Int(sampleRate * duration)

        let harmonics: [(partial: Int, amplitude: Double)] = [
            (1, 1.0),
            (2, 0.5),
            (3, 0.3),
            (4, 0.15),
            (5, 0.1),
            (6, 0.05),
        ]

        var samples = [Double](repeating: 0, count: totalSamples)

        for harmonic in harmonics {
            let harmonicFreq = frequency * Double(harmonic.partial)
            for i in 0..<totalSamples {
                let time = Double(i) / sampleRate
                samples[i] += harmonic.amplitude * sin(2.0 * .pi * harmonicFreq * time)
            }
        }

        for i in 0..<totalSamples {
            let time = Double(i) / sampleRate
            let progress = time / duration

            let envelope: Double
            if progress < 0.02 {
                envelope = progress / 0.02
            } else if progress < 0.1 {
                envelope = 1.0 - (progress - 0.02) / 0.08 * 0.4
            } else if progress < 0.8 {
                envelope = 0.6
            } else {
                envelope = 0.6 * (1.0 - (progress - 0.8) / 0.2)
            }

            samples[i] *= envelope
        }

        let maxAmp = samples.map { abs($0) }.max() ?? 1.0
        if maxAmp > 0 {
            samples = samples.map { $0 / maxAmp * 0.7 }
        }

        return samples
    }

    /// 生成和弦波形
    private func generateGuitarChord(frequencies: [Double], duration: TimeInterval) -> [Double] {
        let sampleRate = 44100.0
        let totalSamples = Int(sampleRate * duration)
        var mixedSamples = [Double](repeating: 0, count: totalSamples)

        for freq in frequencies {
            let samples = generateGuitarTone(frequency: freq, duration: duration)
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
}
