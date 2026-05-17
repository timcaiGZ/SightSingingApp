# AudioKit 升级方案

## 当前实现 vs AudioKit

| 特性 | 当前实现（AVFoundation） | AudioKit |
|------|------------------------|----------|
| 音高检测算法 | 简化自相关 | YIN / 频谱分析 |
| 检测精度 | 一般（±10-20音分） | 精准（±5音分以内） |
| 抗噪能力 | 较弱 | 强（内置滤波） |
| 依赖 | 无外部依赖 | 需要 CocoaPods/SPM |
| 包大小 | 0 | +约 30MB |
| 实时性能 | 尚可 | 优秀 |

## 升级步骤

### 步骤 1：安装 AudioKit

**方式 A：CocoaPods（推荐）**

```ruby
# Podfile
pod 'AudioKit', '~> 5.6'
```

```bash
pod install
```

**方式 B：Swift Package Manager**

在 Xcode → File → Add Package Dependencies 中添加：
```
https://github.com/AudioKit/AudioKit
```

### 步骤 2：替换 PitchDetector 实现

将 `PitchDetector.swift` 中的实现替换为 AudioKit 版本：

```swift
import AVFoundation
import AudioKit
import AudioKitUI

/// 音高检测器 — AudioKit 高精度版
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

    private var engine: AudioEngine?
    private var tracker: PitchTap?
    private var silence: Fader?

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
        tracker?.stop()
        engine?.stop()
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
        engine = AudioEngine()

        guard let input = engine?.input else { return }

        // PitchTap 自动进行音高追踪
        tracker = PitchTap(input, handler: { [weak self] pitch, amp in
            guard let self = self else { return }

            let frequency = pitch[0]
            let amplitude = amp[0]

            // 只处理有意义的音频（高于噪音阈值）
            if amplitude > 0.1 && frequency > 50 && frequency < 2000 {
                DispatchQueue.main.async {
                    self.detectedFrequency = frequency
                    self.detectedMIDI = Int(round(69 + 12 * log2(frequency / 440.0)))
                    self.updateScore()
                }
            }
        })

        tracker?.start()
        silence = Fader(input, gain: 0)
        silence?.connect(to: engine!.output)

        do {
            try engine?.start()
            state = .detecting
        } catch {
            print("AudioKit 引擎启动失败: \(error)")
            state = .idle
        }
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
```

### 步骤 3：更新 Info.plist

添加麦克风权限描述：

```xml
<key>NSMicrophoneUsageDescription</key>
<string>视唱练习需要使用麦克风来检测您的音高并给出评分</string>
```

### 步骤 4：构建测试

```bash
cd SightSingingApp
xcodebuild -project SightSingingApp.xcodeproj \
           -scheme SightSingingApp \
           -destination 'platform=iOS Simulator,name=iPhone 17' \
           build
```

## 是否升级的决策建议

### 推荐升级的场景
- 对音准评分精度要求高
- 目标用户群体有专业音乐背景
- 视唱功能是核心卖点

### 暂时不升级的场景
- MVP 快速验证阶段
- 包大小敏感（+30MB）
- 当前 AVFoundation 实现已满足基本需求
- 项目时间有限

## 备选方案：混合使用

如果暂时不引入 AudioKit，但想提升当前实现的精度，可以在 `PitchDetector` 中优化检测算法：

1. 增加缓冲区大小（从 4096 增加到 8192）
2. 使用 FFT（快速傅里叶变换）代替简单自相关
3. 添加噪声门限过滤
4. 使用 Hanning 窗口减少频谱泄漏

这些优化可以在不引入外部依赖的情况下，将检测精度从 ±20 音分提升到 ±10 音分左右。
