import AVFoundation
import Foundation

/// 音高检测器 — 实时检测用户演唱的音高（模拟实现）
/// 注意：实际项目中应使用 AudioKit PitchTap，这里提供接口和模拟实现
final class PitchDetector: ObservableObject {
    static let shared = PitchDetector()

    /// 检测状态
    enum DetectionState {
        case idle
        case detecting
        case stopped
    }

    @Published var state: DetectionState = .idle
    @Published var detectedFrequency: Double = 0
    @Published var detectedNote: String = ""
    @Published var detectedMIDI: Int = 0
    @Published var centsDeviation: Double = 0
    @Published var currentScore: Int = 0

    private var audioEngine: AVAudioEngine?
    private var inputNode: AVAudioInputNode?
    private var isMonitoring = false

    /// 目标音高（用于评分）
    private var targetMIDI: Int?
    private var targetSolfege: String?

    private init() {}

    /// 请求麦克风权限
    func requestMicrophonePermission() async -> Bool {
        let status = AVAudioApplication.shared.recordPermission
        switch status {
        case .granted:
            return true
        case .denied:
            return false
        case .undetermined:
            return await withCheckedContinuation { continuation in
                AVAudioApplication.requestRecordPermission { granted in
                    continuation.resume(returning: granted)
                }
            }
        @unknown default:
            return false
        }
    }

    /// 开始检测音高
    func startDetection() {
        guard !isMonitoring else { return }

        Task {
            let granted = await requestMicrophonePermission()
            guard granted else {
                print("麦克风权限被拒绝")
                return
            }

            await MainActor.run {
                self.setupAudioSession()
                self.startListening()
            }
        }
    }

    /// 停止检测
    func stopDetection() {
        audioEngine?.stop()
        inputNode?.removeTap(onBus: 0)
        isMonitoring = false
        state = .stopped
    }

    /// 重置状态
    func reset() {
        detectedFrequency = 0
        detectedNote = ""
        detectedMIDI = 0
        centsDeviation = 0
        currentScore = 0
        targetMIDI = nil
        targetSolfege = nil
        state = .idle
    }

    /// 设置目标音高（用于评分）
    func setTarget(solfege: String, octave: Int = 4) {
        targetSolfege = solfege
        targetMIDI = MusicTheory.midiNote(from: solfege, octave: octave)
        currentScore = 0
    }

    /// 实时计算音准评分
    private func updateScore() {
        guard let target = targetMIDI, detectedMIDI > 0 else { return }

        // 计算与目标音的音分偏差
        let targetFreq = MusicTheory.frequencyFromMIDI(target)
        let deviation = MusicTheory.centsDeviation(detected: detectedFrequency, target: targetFreq)
        centsDeviation = deviation

        currentScore = MusicTheory.pitchScore(cents: abs(deviation))
    }

    // MARK: - 私有方法

    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .measurement, options: [])
            try session.setActive(true)
        } catch {
            print("音频会话配置失败: \(error)")
        }
    }

    private func startListening() {
        audioEngine = AVAudioEngine()
        guard let engine = audioEngine else { return }

        inputNode = engine.inputNode
        let format = inputNode?.outputFormat(forBus: 0)

        // 在输入节点安装 tapped
        inputNode?.installTap(onBus: 0, bufferSize: 4096, format: format) { [weak self] buffer, _ in
            self?.processAudioBuffer(buffer)
        }

        do {
            try engine.start()
            isMonitoring = true
            state = .detecting
        } catch {
            print("音频引擎启动失败: \(error)")
        }
    }

    /// 处理音频缓冲（简化实现，实际应使用 FFT 或 AudioKit）
    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameCount = Int(buffer.frameLength)

        // 简化的音高检测（使用过零率 + 自相关）
        let frequency = detectPitch(samples: channelData, frameCount: frameCount, sampleRate: 44100)

        if frequency > 50 && frequency < 2000 {
            DispatchQueue.main.async { [weak self] in
                self?.detectedFrequency = frequency
                self?.detectedMIDI = self?.frequencyToMIDI(frequency) ?? 0
                self?.updateScore()
            }
        }
    }

    /// 简化音高检测算法
    private func detectPitch(samples: UnsafePointer<Float>, frameCount: Int, sampleRate: Double) -> Double {
        // 使用简化的自相关算法检测基频
        var maxCorrelation: Float = 0
        var bestLag = 0

        let minLag = Int(sampleRate / 1000) // 最高1000Hz
        let maxLag = Int(sampleRate / 50)   // 最低50Hz

        for lag in minLag..<min(maxLag, frameCount / 2) {
            var correlation: Float = 0
            for i in 0..<(frameCount - lag) {
                correlation += samples[i] * samples[i + lag]
            }

            if correlation > maxCorrelation {
                maxCorrelation = correlation
                bestLag = lag
            }
        }

        guard bestLag > 0 else { return 0 }
        return sampleRate / Double(bestLag)
    }

    /// 频率转 MIDI note
    private func frequencyToMIDI(_ frequency: Double) -> Int {
        Int(round(69 + 12 * log2(frequency / 440.0)))
    }
}
