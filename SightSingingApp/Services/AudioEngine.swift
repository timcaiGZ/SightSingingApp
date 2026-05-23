import AVFoundation
import Foundation

/// 音频引擎 actor — 负责播放吉他音色音符，线程安全
actor AudioEngineManager {
    static let shared = AudioEngineManager()

    private var audioEngine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    private var isSetup = false
    private var currentCategory: AVAudioSession.Category = .playback

    private init() {}

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

        // 停止之前的播放
        player.stop()

        // 生成吉他音色（正弦波 + 谐波）
        let samples = generateGuitarTone(frequency: frequency, duration: duration)
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(samples.count))!
        buffer.frameLength = buffer.frameCapacity

        let channelData = buffer.floatChannelData![0]
        for (index, sample) in samples.enumerated() {
            channelData[index] = Float(sample)
        }

        player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        player.play()
    }

    /// 播放和弦（多个音符同时发声）
    func playChord(_ notes: [(solfege: String, octave: Int)], duration: TimeInterval = 1.0) async {
        await setup()

        guard let player = playerNode else { return }
        player.stop()

        // 混合所有音符
        let allFrequencies = notes.compactMap { note -> Double? in
            guard let midi = MusicTheory.midiNote(from: note.solfege, octave: note.octave) else { return nil }
            return MusicTheory.frequencyFromMIDI(midi)
        }

        let samples = generateGuitarChord(frequencies: allFrequencies, duration: duration)
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(samples.count))!
        buffer.frameLength = buffer.frameCapacity

        let channelData = buffer.floatChannelData![0]
        for (index, sample) in samples.enumerated() {
            channelData[index] = Float(sample)
        }

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

    // MARK: - 吉他音色合成

    /// 生成吉他音色波形（正弦波 + 谐波 + ADSR 包络）
    private func generateGuitarTone(frequency: Double, duration: TimeInterval) -> [Double] {
        let sampleRate = 44100.0
        let totalSamples = Int(sampleRate * duration)

        // 吉他音色谐波比例（谐波越多音色越丰富）
        let harmonics: [(partial: Int, amplitude: Double)] = [
            (1, 1.0),    // 基频
            (2, 0.5),    // 2次谐波
            (3, 0.3),    // 3次谐波
            (4, 0.15),   // 4次谐波
            (5, 0.1),    // 5次谐波
            (6, 0.05),   // 6次谐波
        ]

        var samples = [Double](repeating: 0, count: totalSamples)

        // 谐波叠加
        for harmonic in harmonics {
            let harmonicFreq = frequency * Double(harmonic.partial)
            for i in 0..<totalSamples {
                let time = Double(i) / sampleRate
                samples[i] += harmonic.amplitude * sin(2.0 * .pi * harmonicFreq * time)
            }
        }

        // 吉他 ADSR 包络（快速起音、中等衰减、持续音量、较快释放）
        for i in 0..<totalSamples {
            let time = Double(i) / sampleRate
            let progress = time / duration

            let envelope: Double
            if progress < 0.02 {
                // 起音阶段（0-2%）
                envelope = progress / 0.02
            } else if progress < 0.1 {
                // 衰减阶段（2-10%）
                envelope = 1.0 - (progress - 0.02) / 0.08 * 0.4
            } else if progress < 0.8 {
                // 持续阶段（10-80%）
                envelope = 0.6
            } else {
                // 释放阶段（80-100%）
                envelope = 0.6 * (1.0 - (progress - 0.8) / 0.2)
            }

            samples[i] *= envelope
        }

        // 归一化
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

        // 归一化
        let maxAmp = mixedSamples.map { abs($0) }.max() ?? 1.0
        if maxAmp > 0 {
            mixedSamples = mixedSamples.map { $0 / maxAmp * 0.7 }
        }

        return mixedSamples
    }
}
