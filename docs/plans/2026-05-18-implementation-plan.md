# SightSingingApp 全面重构实施计划

> **For implementer:** 使用 TDD 方法，先写测试再实现
>
> **Goal:** 本周内完成对标 Solfeggio 的全面重构

**Architecture:** 
- 采用 MVVM 架构，SwiftUI 声明式 UI
- 复用现有 SwiftData 模型，新增 ColorTheme 主题系统
- AVFoundation 实现音高检测，AudioEngine 处理音频播放

**Tech Stack:** SwiftUI / SwiftData / AVFoundation / SwiftUI Charts / iOS 17+

---

## Phase 1: 界面重构（第1-2天）

### Task 1.1: 创建深蓝主题 ColorTheme

**Files:**
- Create: `SightSingingApp/Utilities/ColorTheme.swift`

**Step 1: 创建主题配置**
```swift
import SwiftUI

// MARK: - 颜色主题
struct AppColors {
    // 主色调
    static let primaryBlue = Color(hex: "1E3A5F")      // 深蓝
    static let accentBlue = Color(hex: "3B82F6")        // 亮蓝
    
    // 功能色
    static let success = Color(hex: "22C55E")
    static let warning = Color(hex: "F59E0B")
    static let error = Color(hex: "EF4444")
    
    // 背景色
    static let pageBackground = Color(hex: "F8FAFC")
    static let cardBackground = Color.white
    static let groupBackground = Color(hex: "F1F5F9")
    
    // 文字色
    static let primaryText = Color(hex: "1E293B")
    static let secondaryText = Color(hex: "64748B")
    static let tertiaryText = Color(hex: "94A3B8")
    
    // 模块色
    static let noteName = Color(hex: "3B82F6")
    static let interval = Color(hex: "8B5CF6")
    static let chord = Color(hex: "EC4899")
    static let scale = Color(hex: "14B8A6")
    static let rhythm = Color(hex: "F59E0B")
    static let melody = Color(hex: "22C55E")
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
```

**Step 2: 验证构建**
Command: `xcodebuild -project SightSingingApp.xcodeproj -scheme SightSingingApp -sdk iphonesimulator build`
Expected: BUILD SUCCEEDED

**Step 3: Commit**
```bash
git add SightSingingApp/Utilities/ColorTheme.swift && git commit -m "feat: 添加深蓝主题 ColorTheme"
```

---

### Task 1.2: 创建卡片组件库

**Files:**
- Create: `SightSingingApp/Components/StyleCard.swift`
- Create: `SightSingingApp/Components/ProgressDots.swift`
- Create: `SightSingingApp/Components/ModuleBadge.swift`

**Step 1: 创建进度圆点组件**
```swift
import SwiftUI

/// 进度指示器（圆点样式）
struct ProgressDots: View {
    let total: Int
    let completed: Int
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<total, id: \.self) { index in
                Circle()
                    .fill(index < completed ? AppColors.primaryBlue : Color(hex: "E2E8F0"))
                    .frame(width: 8, height: 8)
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ProgressDots(total: 5, completed: 0)
        ProgressDots(total: 5, completed: 2)
        ProgressDots(total: 5, completed: 5)
    }
    .padding()
}
```

**Step 2: 创建模块卡片组件**
```swift
import SwiftUI

/// 模块卡片（带左侧彩色条）
struct ModuleCard<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 标题栏
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(color)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.primaryText)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(color.opacity(0.08))
            
            // 内容
            VStack(spacing: 0) {
                content()
            }
        }
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    ModuleCard(title: "听力训练", icon: "music.note", color: AppColors.noteName) {
        Text("练习内容...")
            .padding()
    }
    .padding()
}
```

**Step 3: 验证构建**
Expected: BUILD SUCCEEDED

**Step 4: Commit**
```bash
git add SightSingingApp/Components/*.swift && git commit -m "feat: 添加卡片组件库 (ProgressDots, ModuleCard, ModuleBadge)"
```

---

### Task 1.3: 重构 PracticeTab

**Files:**
- Modify: `SightSingingApp/Views/Tabs/PracticeTab.swift`

**Step 1: 替换颜色引用**
- 将 `Color(.systemGroupedBackground)` 替换为 `AppColors.pageBackground`
- 将 `Color(.systemBackground)` 替换为 `AppColors.cardBackground`
- 将 `AppColors.primaryText` 等替换为新主题色

**Step 2: 更新布局为卡片风格**
- 每个练习模块用 `ModuleCard` 包裹
- 添加左侧彩色竖条标识
- 进度显示改为 `ProgressDots` 圆点样式

**Step 3: 验证构建**
Expected: BUILD SUCCEEDED

**Step 4: Commit**
```bash
git add SightSingingApp/Views/Tabs/PracticeTab.swift && git commit -m "refactor: 重构 PracticeTab 为深蓝主题卡片风格"
```

---

### Task 1.4: 重构 CourseTab

**Files:**
- Modify: `SightSingingApp/Views/Tabs/CourseTab.swift`

**Step 1: 应用新主题**
- 更新课程卡片为白色背景 + 淡阴影
- 添加课程图标和颜色标识
- 进度使用 `ProgressDots` 圆点样式

**Step 2: 验证构建**
Expected: BUILD SUCCEEDED

**Step 3: Commit**
```bash
git add SightSingingApp/Views/Tabs/CourseTab.swift && git commit -m "refactor: 重构 CourseTab 课程卡片"
```

---

### Task 1.5: 重构 ProfileTab

**Files:**
- Modify: `SightSingingApp/Views/Tabs/ProfileTab.swift`

**Step 1: 更新统计卡片**
- 用户头像区域优化
- 学习概况卡片
- 能力趋势图表（使用 SwiftUI Charts）

**Step 2: 验证构建**
Expected: BUILD SUCCEEDED

**Step 3: Commit**
```bash
git add SightSingingApp/Views/Tabs/ProfileTab.swift && git commit -m "refactor: 重构 ProfileTab 统计展示"
```

---

## Phase 2: 视唱功能（第3-4天）

### Task 2.1: 实现 PitchDetector 音高检测

**Files:**
- Create: `SightSingingApp/Services/PitchDetector.swift`

**Step 1: 创建音高检测服务**
```swift
import AVFoundation
import Combine

/// 音高检测结果
struct PitchResult {
    let frequency: Float      // 频率 Hz
    let noteName: String       // 音符名 C4, D4...
    let cents: Int             // 音分偏差 (-50 to +50)
    let amplitude: Float       // 音量振幅
    let timestamp: Date
}

/// 音高检测器
@Observable
class PitchDetector: NSObject {
    private var audioEngine: AVAudioEngine?
    private var inputNode: AVAudioInputNode?
    
    var isRunning = false
    var currentPitch: PitchResult?
    var onPitchDetected: ((PitchResult) -> Void)?
    
    // 音高检测配置
    let sampleRate: Double = 44100
    let bufferSize: AVAudioFrameCount = 4096
    
    override init() {
        super.init()
    }
    
    func start() throws {
        // 配置音频会话
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .measurement, options: [.defaultToSpeaker, .allowBluetooth])
        try session.setActive(true)
        
        // 创建音频引擎
        audioEngine = AVAudioEngine()
        guard let engine = audioEngine else { return }
        
        inputNode = engine.inputNode
        let format = inputNode!.outputFormat(forBus: 0)
        
        // 安装 tap 进行音频分析
        inputNode!.installTap(onBus: 0, bufferSize: bufferSize, format: format) { [weak self] buffer, _ in
            self?.processAudioBuffer(buffer)
        }
        
        try engine.start()
        isRunning = true
    }
    
    func stop() {
        inputNode?.removeTap(onBus: 0)
        audioEngine?.stop()
        audioEngine = nil
        isRunning = false
    }
    
    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameLength = Int(buffer.frameLength)
        
        // 计算音高（使用自相关算法简化版）
        let frequency = detectPitch(channelData, frameLength: frameLength)
        
        guard frequency > 20 && frequency < 5000 else { return }
        
        // 计算音符信息
        let noteResult = frequencyToNote(frequency)
        
        // 计算振幅
        let amplitude = calculateAmplitude(channelData, frameLength: frameLength)
        
        let result = PitchResult(
            frequency: frequency,
            noteName: noteResult.name,
            cents: noteResult.cents,
            amplitude: amplitude,
            timestamp: Date()
        )
        
        DispatchQueue.main.async {
            self.currentPitch = result
            self.onPitchDetected?(result)
        }
    }
    
    // 简化版音高检测（实际应使用 YIN 或 McLeod Pitch Method）
    private func detectPitch(_ data: UnsafePointer<Float>, frameLength: Int) -> Float {
        // 使用过零率简化估算，实际应使用自相关
        var zeroCrossings = 0
        for i in 1..<frameLength {
            if (data[i-1] >= 0 && data[i] < 0) || (data[i-1] < 0 && data[i] >= 0) {
                zeroCrossings += 1
            }
        }
        let rate = Float(zeroCrossings) / Float(frameLength) * Float(sampleRate)
        return rate / 2.0
    }
    
    private func frequencyToNote(_ frequency: Float) -> (name: String, cents: Int) {
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
    
    private func calculateAmplitude(_ data: UnsafePointer<Float>, frameLength: Int) -> Float {
        var sum: Float = 0
        for i in 0..<frameLength {
            sum += data[i] * data[i]
        }
        return sqrt(sum / Float(frameLength))
    }
}

#Preview {
    Text("PitchDetector")
}
```

**Step 2: 验证构建**
Expected: BUILD SUCCEEDED

**Step 3: Commit**
```bash
git add SightSingingApp/Services/PitchDetector.swift && git commit -m "feat: 实现 PitchDetector 音高检测服务"
```

---

### Task 2.2: 创建视唱视图 SightSingingView

**Files:**
- Create: `SightSingingApp/Views/Practice/SightSingingView.swift`

**Step 1: 创建视唱界面**
```swift
import SwiftUI

/// 视唱练习视图
struct SightSingingView: View {
    let melody: MelodyExercise    // 旋律练习
    @State private var viewModel = SightSingingViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部进度
            progressHeader
            
            // 简谱展示区
            sheetDisplay
            
            // 音准指示器
            pitchIndicator
            
            // 演唱按钮
            singButton
            
            Spacer()
        }
        .background(AppColors.pageBackground)
        .navigationTitle("视唱练习")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.setup(melody: melody)
        }
        .onDisappear {
            viewModel.cleanup()
        }
    }
    
    // MARK: - 子视图
    
    private var progressHeader: some View {
        VStack(spacing: 8) {
            ProgressDots(total: 10, completed: viewModel.currentIndex)
            Text("\(viewModel.currentIndex + 1) / \(melody.notes.count)")
                .font(.caption)
                .foregroundStyle(AppColors.secondaryText)
        }
        .padding()
    }
    
    private var sheetDisplay: some View {
        VStack(spacing: 16) {
            Text(viewModel.currentNote?.display ?? "—")
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.primaryBlue)
            
            Text(viewModel.currentNote?.name ?? "")
                .font(.title2)
                .foregroundStyle(AppColors.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
        .padding(.horizontal, 16)
    }
    
    private var pitchIndicator: some View {
        VStack(spacing: 12) {
            // 音准刻度尺
            GeometryReader { geometry in
                ZStack {
                    // 刻度线
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex: "E2E8F0"))
                        .frame(height: 8)
                    
                    // 中心线（目标音高）
                    Rectangle()
                        .fill(AppColors.secondaryText)
                        .frame(width: 2, height: 40)
                        .position(x: geometry.size.width / 2, y: 20)
                    
                    // 游标（当前音高）
                    if let pitch = viewModel.currentPitch {
                        let offset = CGFloat(pitch.cents) / 50.0 * (geometry.size.width / 2 - 20)
                        
                        Circle()
                            .fill(pitch.cents >= -10 && pitch.cents <= 10 ? AppColors.success : AppColors.warning)
                            .frame(width: 20, height: 20)
                            .position(x: geometry.size.width / 2 + offset, y: 20)
                            .animation(.spring(response: 0.2), value: pitch.cents)
                    }
                }
            }
            .frame(height: 40)
            .padding(.horizontal, 20)
            
            // 音分显示
            if let pitch = viewModel.currentPitch {
                HStack {
                    if pitch.cents < -10 {
                        Image(systemName: "arrow.down")
                        Text("低了 \(abs(pitch.cents)) 音分")
                    } else if pitch.cents > 10 {
                        Image(systemName: "arrow.up")
                        Text("高了 \(pitch.cents) 音分")
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(AppColors.success)
                        Text("音准良好!")
                    }
                }
                .font(.caption)
                .foregroundStyle(AppColors.secondaryText)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 16)
    }
    
    private var singButton: some View {
        Button {
            if viewModel.isSinging {
                viewModel.stopSinging()
            } else {
                viewModel.startSinging()
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: viewModel.isSinging ? "stop.fill" : "mic.fill")
                    .font(.title2)
                Text(viewModel.isSinging ? "停止演唱" : "按住演唱")
                    .font(.headline)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(viewModel.isSinging ? AppColors.error : AppColors.primaryBlue)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal, 16)
        .padding(.top, 24)
    }
}

#Preview {
    NavigationStack {
        SightSingingView(melody: .sample)
    }
}
```

**Step 2: 创建视唱 ViewModel**
```swift
// SightSingingViewModel.swift
@Observable
class SightSingingViewModel {
    var currentIndex = 0
    var currentPitch: PitchResult?
    var isSinging = false
    var currentNote: NoteDisplay?
    
    private var pitchDetector: PitchDetector?
    private var melody: MelodyExercise?
    
    func setup(melody: MelodyExercise) {
        self.melody = melody
        currentNote = melody.notes.first?.display
    }
    
    func startSinging() {
        pitchDetector = PitchDetector()
        pitchDetector?.onPitchDetected = { [weak self] pitch in
            self?.currentPitch = pitch
            self?.evaluatePitch(pitch)
        }
        
        do {
            try pitchDetector?.start()
            isSinging = true
        } catch {
            print("Pitch detection error: \(error)")
        }
    }
    
    func stopSinging() {
        pitchDetector?.stop()
        isSinging = false
    }
    
    func cleanup() {
        stopSinging()
        pitchDetector = nil
    }
    
    private func evaluatePitch(_ pitch: PitchResult) {
        guard let note = currentNote else { return }
        
        // 评估音准
        if abs(pitch.cents) <= 10 {
            // 音准正确，可以进入下一个音
        }
    }
}

// 旋律练习数据结构
struct MelodyExercise {
    let id: String
    let title: String
    let notes: [NoteDisplay]
    
    static let sample = MelodyExercise(
        id: "melody-1",
        title: "C大调音阶",
        notes: [
            NoteDisplay(note: "C", octave: 4, duration: 1),
            NoteDisplay(note: "D", octave: 4, duration: 1),
            NoteDisplay(note: "E", octave: 4, duration: 1),
            NoteDisplay(note: "F", octave: 4, duration: 1),
            NoteDisplay(note: "G", octave: 4, duration: 1)
        ]
    )
}

struct NoteDisplay {
    let note: String
    let octave: Int
    let duration: Int
    
    var display: String { "\(note)\(octave)" }
    var frequency: Double {
        // 计算频率
        let noteMap = ["C": 0, "C#": 1, "D": 2, "D#": 3, "E": 4, "F": 5, "F#": 6, "G": 7, "G#": 8, "A": 9, "A#": 10, "B": 11]
        let noteValue = (octave + 1) * 12 + (noteMap[note] ?? 0)
        return 440.0 * pow(2.0, Double(noteValue - 49) / 12.0)
    }
}
```

**Step 3: 验证构建**
Expected: BUILD SUCCEEDED

**Step 4: Commit**
```bash
git add SightSingingApp/Views/Practice/SightSingingView.swift SightSingingApp/ViewModels/SightSingingViewModel.swift && git commit -m "feat: 添加 SightSingingView 视唱练习界面"
```

---

### Task 2.3: 实现评分展示组件

**Files:**
- Create: `SightSingingApp/Views/Practice/ScoreResultView.swift`

**Step 1: 创建评分结果视图**
```swift
import SwiftUI

/// 视唱评分结果视图
struct ScoreResultView: View {
    let totalScore: Int
    let pitchScore: Int
    let rhythmScore: Int
    let onNext: () -> Void
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // 总分
            VStack(spacing: 8) {
                Text("本题得分")
                    .font(.headline)
                    .foregroundStyle(AppColors.secondaryText)
                
                Text("\(totalScore)")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundStyle(scoreColor(totalScore))
                
                Text(scoreLabel(totalScore))
                    .font(.title3)
                    .foregroundStyle(scoreColor(totalScore))
            }
            
            // 分项得分
            HStack(spacing: 32) {
                scoreItem(title: "音准", score: pitchScore, icon: "music.note")
                scoreItem(title: "节奏", score: rhythmScore, icon: "metronome")
            }
            .padding()
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
            
            Spacer()
            
            // 操作按钮
            VStack(spacing: 12) {
                Button {
                    onNext()
                } label: {
                    Text("下一题")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppColors.primaryBlue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Button {
                    onRetry()
                } label: {
                    Text("重新练习")
                        .font(.headline)
                        .foregroundStyle(AppColors.primaryBlue)
                }
            }
            .padding(.horizontal, 16)
        }
        .padding()
        .background(AppColors.pageBackground)
    }
    
    private func scoreItem(title: String, score: Int, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(AppColors.primaryBlue)
            
            Text("\(score)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(scoreColor(score))
            
            Text(title)
                .font(.caption)
                .foregroundStyle(AppColors.secondaryText)
        }
    }
    
    private func scoreColor(_ score: Int) -> Color {
        if score >= 90 { return AppColors.success }
        else if score >= 70 { return AppColors.warning }
        else { return AppColors.error }
    }
    
    private func scoreLabel(_ score: Int) -> String {
        switch score {
        case 95...100: return "完美!"
        case 85..<95: return "优秀"
        case 70..<85: return "良好"
        case 60..<70: return "及格"
        default: return "继续加油"
        }
    }
}

#Preview {
    ScoreResultView(totalScore: 92, pitchScore: 95, rhythmScore: 85, onNext: {}, onRetry: {})
}
```

**Step 2: 验证构建**
Expected: BUILD SUCCEEDED

**Step 3: Commit**
```bash
git add SightSingingApp/Views/Practice/ScoreResultView.swift && git commit -m "feat: 添加 ScoreResultView 评分结果展示"
```

---

## Phase 3: 课程模块（第5天）

### Task 3.1: 完善课程数据

**Files:**
- Modify: `SightSingingApp/Models/Course/CourseData.swift`

**Step 1: 扩充课程内容**
- 乐理基础: 3章节/9课时（添加完整练习）
- 视唱入门: 3章节/7课时
- 节奏训练: 3章节/6课时

**Step 2: 验证构建**
Expected: BUILD SUCCEEDED

**Step 3: Commit**
```bash
git add SightSingingApp/Models/Course/CourseData.swift && git commit -m "content: 完善课程数据，添加完整课时内容"
```

---

### Task 3.2: 完善课程练习入口

**Files:**
- Modify: `SightSingingApp/Views/Course/CourseLessonView.swift`

**Step 1: 完善练习Sheet和导航**
- 练习类型选择（乐理/视唱/听力）
- 跳转对应练习页面

**Step 2: 验证构建**
Expected: BUILD SUCCEEDED

**Step 3: Commit**
```bash
git add SightSingingApp/Views/Course/CourseLessonView.swift && git commit -m "feat: 完善课程练习入口"
```

---

## Phase 4: 乐理模块（第6天）

### Task 4.1: 完善乐理知识库

**Files:**
- Modify: `SightSingingApp/Models/Theory/TheoryTopic.swift`

**Step 1: 添加完整乐理内容**
- 六线谱识谱
- 简谱识谱
- 音程
- 和弦构成
- 节奏型
- 常用调式
- 吉他指法

**Step 2: 验证构建**
Expected: BUILD SUCCEEDED

**Step 3: Commit**
```bash
git add SightSingingApp/Models/Theory/TheoryTopic.swift && git commit -m "content: 完善乐理知识库内容"
```

---

## Phase 5: 收尾优化（第7天）

### Task 5.1: 深色模式适配

**Files:**
- Modify: `SightSingingApp/Utilities/ColorTheme.swift`

**Step 1: 添加深色模式支持**
```swift
// Color 扩展支持语义化颜色
extension Color {
    static let appBackground = Color("AppBackground")
    static let appCardBackground = Color("AppCardBackground")
    static let appPrimaryText = Color("AppPrimaryText")
    // ...
}
```

**Step 2: 验证构建**
Expected: BUILD SUCCEEDED

**Step 3: Commit**
```bash
git add SightSingingApp/Utilities/ColorTheme.swift && git commit -m "feat: 添加深色模式适配"
```

---

### Task 5.2: 构建验证和Bug修复

**Step 1: 完整构建测试**
Command: `xcodebuild -project SightSingingApp.xcodeproj -scheme SightSingingApp -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17' build`

**Step 2: GitHub 提交**
```bash
git push origin main
```

---

## 任务清单汇总

| Phase | Task | 文件 | 状态 |
|-------|------|------|------|
| 1.1 | ColorTheme | Utilities/ColorTheme.swift | ⏳ |
| 1.2 | 卡片组件 | Components/*.swift | ⏳ |
| 1.3 | PracticeTab | Views/Tabs/PracticeTab.swift | ⏳ |
| 1.4 | CourseTab | Views/Tabs/CourseTab.swift | ⏳ |
| 1.5 | ProfileTab | Views/Tabs/ProfileTab.swift | ⏳ |
| 2.1 | PitchDetector | Services/PitchDetector.swift | ⏳ |
| 2.2 | SightSingingView | Views/Practice/SightSingingView.swift | ⏳ |
| 2.3 | ScoreResultView | Views/Practice/ScoreResultView.swift | ⏳ |
| 3.1 | 课程数据 | Models/Course/CourseData.swift | ⏳ |
| 3.2 | 课程练习入口 | Views/Course/CourseLessonView.swift | ⏳ |
| 4.1 | 乐理知识库 | Models/Theory/TheoryTopic.swift | ⏳ |
| 5.1 | 深色模式 | Utilities/ColorTheme.swift | ⏳ |
| 5.2 | 构建验证 | - | ⏳ |

---

## 每日目标

| 天数 | 完成目标 |
|------|---------|
| 第1天 | Task 1.1, 1.2 |
| 第2天 | Task 1.3, 1.4, 1.5 |
| 第3天 | Task 2.1, 2.2 |
| 第4天 | Task 2.3 |
| 第5天 | Task 3.1, 3.2 |
| 第6天 | Task 4.1 |
| 第7天 | Task 5.1, 5.2 |
