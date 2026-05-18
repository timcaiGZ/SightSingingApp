import AVFoundation
import Accelerate
import Foundation

/// 音高检测器 — 纯 AVFoundation + Accelerate 实现
final class PitchDetector: ObservableObject {
    static let shared = PitchDetector()

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
    private var targetMIDI: Int?
    private var targetSolfege: String?

    // FFT 配置
    private let fftSize: Int = 4096
    private var fftSetup: vDSP_DFT_Setup?
    private var realPart: [Float] = []
    private var imagPart: [Float] = []

    private init() {
        fftSetup = vDSP_DFT_zop_CreateSetup(nil, vDSP_Length(fftSize), .FORWARD)
        realPart = [Float](repeating: 0, count: fftSize)
        imagPart = [Float](repeating: 0, count: fftSize)
    }

    deinit {
        if let setup = fftSetup {
            vDSP_DFT_DestroySetup(setup)
        }
    }

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
        guard state != .detecting else { return }

        Task {
            let granted = await requestMicrophonePermission()
            guard granted else {
                print("麦克风权限被拒绝")
                await MainActor.run { self.state = .idle }
                return
            }

            await MainActor.run {
                self.setupEngine()
            }
        }
    }

    /// 停止检测
    func stopDetection() {
        audioEngine?.stop()
        inputNode?.removeTap(onBus: 0)
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

    // MARK: - 私有方法

    private func setupEngine() {
        audioEngine = AVAudioEngine()
        inputNode = audioEngine?.inputNode

        guard let inputNode = inputNode else {
            print("无法获取音频输入")
            state = .idle
            return
        }

        let format = inputNode.outputFormat(forBus: 0)
        let bufferSize: AVAudioFrameCount = AVAudioFrameCount(fftSize)

        inputNode.installTap(onBus: 0, bufferSize: bufferSize, format: format) { [weak self] buffer, _ in
            self?.processAudioBuffer(buffer)
        }

        do {
            try audioEngine?.start()
            state = .detecting
        } catch {
            print("音频引擎启动失败: \(error)")
            state = .idle
        }
    }

    /// 处理音频缓冲区
    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameLength = Int(buffer.frameLength)

        // 使用自相关法（YIN 算法的简化版）检测基频
        if let frequency = detectPitch(channelData, frameLength: frameLength, sampleRate: buffer.format.sampleRate) {
            if frequency > 50 && frequency < 2000 {
                Task { @MainActor in
                    self.detectedFrequency = frequency
                    self.detectedMIDI = Int(round(69 + 12 * log2(frequency / 440.0)))
                    self.updateScore()
                }
            }
        }
    }

    /// 使用自相关法检测音高
    private func detectPitch(_ data: UnsafeMutablePointer<Float>, frameLength: Int, sampleRate: Double) -> Double? {
        let minPeriod = Int(sampleRate / 2000)  // 最大频率 2000Hz
        let maxPeriod = Int(sampleRate / 50)    // 最小频率 50Hz

        guard maxPeriod < frameLength else { return nil }

        var bestCorrelation: Float = 0
        var bestPeriod: Int = 0

        // 简化的自相关检测
        for period in minPeriod..<min(maxPeriod, frameLength / 2) {
            var correlation: Float = 0
            var energy1: Float = 0
            var energy2: Float = 0

            for i in 0..<(frameLength - period) {
                correlation += data[i] * data[i + period]
                energy1 += data[i] * data[i]
                energy2 += data[i + period] * data[i + period]
            }

            let normalizedCorrelation = correlation / (sqrt(energy1 * energy2) + 1e-10)

            if normalizedCorrelation > bestCorrelation {
                bestCorrelation = normalizedCorrelation
                bestPeriod = period
            }
        }

        // 如果相关性太低，认为没有有效音高
        if bestCorrelation < 0.5 || bestPeriod == 0 {
            return nil
        }

        // 使用抛物线插值提高精度
        let refinedPeriod = parabolicInterpolation(data, frameLength: frameLength, period: bestPeriod, sampleRate: sampleRate)

        return sampleRate / refinedPeriod
    }

    /// 抛物线插值提高精度
    private func parabolicInterpolation(_ data: UnsafeMutablePointer<Float>, frameLength: Int, period: Int, sampleRate: Double) -> Double {
        guard period > 1 && period < frameLength - 1 else {
            return Double(period)
        }

        // 计算三个点的相关值
        func correlation(at offset: Int) -> Float {
            var sum: Float = 0
            let limit = min(frameLength - offset, frameLength)
            for i in 0..<limit {
                sum += data[i] * data[i + offset]
            }
            return sum
        }

        let y1 = correlation(at: period - 1)
        let y2 = correlation(at: period)
        let y3 = correlation(at: period + 1)

        // 抛物线顶点
        let a = (y1 - 2 * y2 + y3) / 2
        let b = (y3 - y1) / 2

        if abs(a) > 1e-10 {
            let peakPosition = -b / (2 * a)
            return Double(period) + Double(peakPosition)
        }

        return Double(period)
    }

    /// 实时计算音准评分
    private func updateScore() {
        guard let target = targetMIDI, detectedMIDI > 0 else { return }

        let targetFreq = MusicTheory.frequencyFromMIDI(target)
        let deviation = MusicTheory.centsDeviation(detected: detectedFrequency, target: targetFreq)
        centsDeviation = deviation

        currentScore = MusicTheory.pitchScore(cents: abs(deviation))
    }
}
