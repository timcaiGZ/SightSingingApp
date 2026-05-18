import AVFoundation
import Accelerate
import Foundation
import SwiftUI

/// 音高检测结果
struct PitchResult {
    let frequency: Double     // 频率 Hz
    let noteName: String       // 音符名 C4, D4...
    let cents: Int             // 音分偏差 (-50 to +50)
    let amplitude: Double      // 音量振幅
    let timestamp: Date
}

/// 音高检测器 — 使用自相关法检测音高
final class PitchDetector: ObservableObject {
    static let shared = PitchDetector()

    enum DetectionState {
        case idle
        case detecting
        case stopped
    }

    // MARK: - 公开属性

    @Published var state: DetectionState = .idle
    @Published var detectedFrequency: Double = 0
    @Published var detectedNote: String = ""
    @Published var detectedMIDI: Int = 0
    @Published var centsDeviation: Double = 0
    @Published var currentScore: Int = 0
    @Published var currentAmplitude: Float = 0

    // 回调
    var onPitchDetected: ((PitchResult) -> Void)?

    // 音高检测配置
    let sampleRate: Double = 44100
    let bufferSize: AVAudioFrameCount = 4096

    // MARK: - 私有属性

    private var audioEngine: AVAudioEngine?
    private var inputNode: AVAudioInputNode?
    private var targetMIDI: Int?
    private var targetSolfege: String?

    // FFT 配置
    private let fftSize: Int = 4096
    private var fftSetup: vDSP_DFT_Setup?
    private var realPart: [Float] = []
    private var imagPart: [Float] = []

    // MARK: - 初始化

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

    // MARK: - 公开方法

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
        currentAmplitude = 0
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

        // 计算振幅
        let amplitude = calculateAmplitude(channelData, frameLength: frameLength)

        // 使用自相关法（YIN 算法的简化版）检测基频
        if let frequency = detectPitch(channelData, frameLength: frameLength, sampleRate: buffer.format.sampleRate) {
            if frequency > 50 && frequency < 2000 {
                Task { @MainActor in
                    self.detectedFrequency = frequency
                    self.currentAmplitude = Float(amplitude)
                    self.detectedMIDI = Int(round(69 + 12 * log2(frequency / 440.0)))
                    self.detectedNote = self.midiToNoteName(self.detectedMIDI)
                    self.updateScore()
                    
                    // 触发回调
                    let noteResult = self.frequencyToNote(frequency)
                    let pitchResult = PitchResult(
                        frequency: frequency,
                        noteName: noteResult.name,
                        cents: noteResult.cents,
                        amplitude: amplitude,
                        timestamp: Date()
                    )
                    self.onPitchDetected?(pitchResult)
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

    /// MIDI 到音符名转换
    private func midiToNoteName(_ midi: Int) -> String {
        let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        let noteIndex = midi % 12
        let octave = (midi / 12) - 1
        return noteNames[noteIndex] + "\(octave)"
    }

    /// 频率到音符转换
    private func frequencyToNote(_ frequency: Double) -> (name: String, cents: Int) {
        // A4 = 440Hz
        let a4 = 440.0
        let c0 = a4 * pow(2.0, -4.75)

        let halfSteps = 12.0 * log2(Double(frequency) / c0)
        let roundedSteps = round(halfSteps)
        let cents = Int((halfSteps - roundedSteps) * 100)

        let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        let noteIndex = Int(roundedSteps + 120) % 12
        let octave = (Int(roundedSteps) + 120) / 12 - 1
        let noteName = noteNames[noteIndex] + "\(octave)"

        return (noteName, cents)
    }

    /// 计算振幅
    private func calculateAmplitude(_ data: UnsafeMutablePointer<Float>, frameLength: Int) -> Double {
        var sum: Float = 0
        for i in 0..<frameLength {
            sum += data[i] * data[i]
        }
        return Double(sqrt(sum / Float(frameLength)))
    }
}

#Preview {
    Text("PitchDetector")
}
