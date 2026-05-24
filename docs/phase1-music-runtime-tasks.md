# Phase 1: Music Runtime Architecture — 详细任务拆解

## 目标

从「页面型 App」升级为「音乐体验系统」，建立统一的 Music Runtime Layer。

**核心约束**：Phase 1 不新增任何页面，只建 Core 层 + 重构现有视图接入 Runtime。

---

## 当前代码问题分析

在开始任务拆解之前，先列出当前代码中与 Runtime 相关的具体问题：

| 问题 | 位置 | 影响 |
|------|------|------|
| Timer 分散管理 | `SightSingingViewModel` (line 131), `SightSingingContent` (line 979) | 各自维护自己的 Timer，无法同步 |
| 播放逻辑嵌入 ViewModel | `SightSingingViewModel.playDemoMelody()` (line 102) | 播放与 UI 耦合 |
| 节奏评分写死在 VM 里 | `SightSingingViewModel.calculateRhythmScore()` (line 240) | 节奏逻辑不可复用 |
| 播放无统一状态机 | `AudioEngineManager` 没有播放状态 | 不知道当前是 playing/paused/completed |
| BPM/节拍无系统 | `ExerciseSoundPlayer.playRhythmHint()` 硬编码 350ms | 不可调整 BPM |
| 动画散落在 View 里 | `SightSingingContent.pitchMeterBar`, `ExerciseContainerView` body | motion 语言不统一 |
| 无 Haptic | 全项目 0 处触觉反馈 | 缺失音乐触感 |
| Theme 只有颜色 | `AppTheme` 仅颜色常量 | 缺少氛围系统 |

---

## Task 1: 建立 Core/ 目录结构 + MasterMusicClock

### 1.1 创建目录
```
SightSingingApp/Core/
 ├── AudioCore/
 ├── PlaybackCore/
 ├── RhythmCore/
 ├── HarmonyCore/
 ├── PracticeCore/
 ├── VisualizationCore/
 ├── ExperienceCore/
 ├── MotionCore/
 ├── HapticCore/
 └── ThemeCore/
```

### 1.2 MasterMusicClock（最高优先级）
**文件**: `Core/PlaybackCore/MasterMusicClock.swift`

```swift
actor MasterMusicClock {
    static let shared = MasterMusicClock()
    
    // 核心属性
    var bpm: Double = 120.0
    var beatPosition: Double = 0          // 当前拍位 (0.0 ~ beatsPerMeasure)
    var isRunning: Bool = false
    var startTime: Date?
    var beatsPerMeasure: Int = 4
    
    // 订阅者管理
    struct ClockTick {
        let beat: Double       // 绝对拍号
        let bpm: Double
        let timestamp: Date
    }
    typealias TickHandler = (ClockTick) -> Void
    private var subscribers: [UUID: TickHandler] = [:]
    
    func subscribe(_ handler: @escaping TickHandler) -> UUID { ... }
    func unsubscribe(_ id: UUID) { ... }
    
    func start() { ... }
    func stop() { ... }
    func reset() { ... }
    func setBPM(_ bpm: Double) { ... }
    
    // 内部 tick 循环 (高精度 Timer)
    private func tickLoop() { ... }
}
```

**职责**: 全 App 唯一的时间同步源。所有 BPM、拍位、节奏子系统必须订阅此 Clock。

**禁止**: 在 View/ViewModel 里自己管理时间。

---

## Task 2: PlaybackCore — 统一状态机 + 播放引擎

### 2.1 PlaybackState
**文件**: `Core/PlaybackCore/PlaybackState.swift`

```swift
enum PlaybackState {
    case idle
    case preparing
    case countIn(remainingBeats: Int)
    case playing
    case paused
    case looping(region: ClosedRange<Double>)  // 拍号范围
    case scrubbing
    case recording
    case evaluating
    case completed
}
```

### 2.2 PlaybackEngine (actor)
**文件**: `Core/PlaybackCore/PlaybackEngine.swift`

```swift
actor PlaybackEngine {
    static let shared = PlaybackEngine()
    
    let clock = MasterMusicClock.shared
    
    // 播放状态
    private(set) var state: PlaybackState = .idle
    
    // Playlist — 可调度的音频事件
    private var timeline: [TimedAudioEvent] = []
    
    struct TimedAudioEvent {
        let id: UUID
        let beat: Double              // 触发的拍号
        let midiNote: Int
        let duration: Double          // 持续拍数
        let velocity: Double          // 力度 (0-1)
    }
    
    // 状态变更回调 (给 UI 层)
    var onStateChange: ((PlaybackState) -> Void)?
    
    // API
    func prepare(timeline: [TimedAudioEvent]) { ... }
    func play() { ... }
    func pause() { ... }
    func resume() { ... }
    func stop() { ... }
    func setLoop(region: ClosedRange<Double>) { ... }
    func scrub(to beat: Double) { ... }
}
```

**职责**: 管理整个 App 的播放生命周期。将音频事件按时间线调度，确保音频与动画同步。

**必须**: 全 App 只有一个 PlaybackEngine。

### 2.3 PlaybackStore (ObservableObject)
**文件**: `Core/PlaybackCore/PlaybackStore.swift`

```swift
@MainActor
final class PlaybackStore: ObservableObject {
    static let shared = PlaybackStore()
    
    @Published var state: PlaybackState = .idle
    @Published var currentBeat: Double = 0
    @Published var bpm: Double = 120
    @Published var progress: Double = 0  // 0~1
    
    // 订阅 PlaybackEngine 状态变更
    // 提供给所有 View 观察
}
```

**职责**: UI 层唯一的播放状态入口。所有页面通过 `@ObservedObject var playback = PlaybackStore.shared` 订阅。

**禁止**: 页面自己维护播放状态。

---

## Task 3: RhythmCore — 节奏引擎

### 3.1 RhythmEngine
**文件**: `Core/RhythmCore/RhythmEngine.swift`

```swift
struct RhythmEngine {
    // Subdivision
    static func subdivide(beat: Double, division: Int) -> [Double]  // 如四等分 → [0, 0.25, 0.5, 0.75]
    
    // Swing 计算
    static func applySwing(beats: [Double], amount: Double) -> [Double]
    
    // 节拍强调值 (强拍=1.0, 弱拍=0.7, 次强拍=0.85)
    static func beatAccent(beatIndex: Int, beatsPerMeasure: Int) -> Double
    
    // 节奏评分
    static func evaluateTiming(actual: Double, expected: Double, tolerance: Double = 0.1) -> Int
    
    // 切分音检测
    static func isSyncopated(events: [Double], beatSpacing: Double) -> Bool
    
    // 节奏难度分级
    static func difficulty(for pattern: RhythmPattern) -> Int
}
```

**职责**: 纯计算引擎，不持有状态。被 PlaybackEngine 和 PracticeCore 调用。

### 3.2 RhythmPattern 模型
**文件**: `Core/RhythmCore/RhythmPattern.swift`

```swift
struct RhythmPattern: Codable {
    let name: String
    let events: [RhythmEvent]    // 时间序列
    let beatsPerMeasure: Int
    let bpm: Double
    let swingAmount: Double?     // nil = 无 swing
}

struct RhythmEvent: Codable {
    let beat: Double             // 拍位
    let accent: Double           // 强调值
    let articulation: Articulation
}

enum Articulation: String, Codable {
    case normal, staccato, tenuto, rest
}
```

---

## Task 4: AudioCore 重构 — 支持同步播放

**文件**: `Core/AudioCore/AudioEngine.swift`（从 `Services/` 迁移）

### 4.1 重构要点
- 保持现有 `actor AudioEngineManager` 的核心合成逻辑
- 新增 `scheduleNote(midi: Int, at beat: Double, duration: Double)` — 在指定拍号触发
- 新增 `playCountIn(beats: Int, bpm: Double)` — 倒计时
- 新增 `playTimeline(_ events: [TimedAudioEvent])` — 按时间线播放
- 保持线程安全（actor）

### 4.2 需迁移的代码
- 现有的 `generateGuitarTone()` / `generateGuitarChord()` 保持不变
- `playSolfege()`, `playNote()`, `playChord()`, `playMIDI()` 保留（简单播放仍用）
- 新增同步播放 API

### 4.3 AudioBufferStore
```swift
actor AudioBufferStore {
    // 预渲染常用音色 buffer，避免实时合成延迟
    private var bufferCache: [Int: AVAudioPCMBuffer] = [:]
    
    func buffer(for midiNote: Int) -> AVAudioPCMBuffer? { ... }
    func preload(noteRange: ClosedRange<Int>) { ... }
}
```

---

## Task 5: PracticeCore — 统一练习会话

**文件**: `Core/PracticeCore/PracticeSession.swift`

### 5.1 PracticeSession
```swift
@Observable
final class PracticeSession {
    let id: UUID
    let exerciseType: ExerciseType
    let clock = MasterMusicClock.shared
    let playback = PlaybackEngine.shared
    
    // 练习阶段
    enum Phase {
        case intro
        case demo          // 示范播放
        case waitingToStart
        case practicing    // 用户练习中
        case evaluating    // 计算成绩
        case completed
    }
    
    var phase: Phase = .intro
    var currentQuestion: Int = 0
    var totalQuestions: Int = 10
    var answers: [PracticeAnswer] = []
    
    struct PracticeAnswer {
        let questionIndex: Int
        let isCorrect: Bool
        let timingAccuracy: Int     // 0-100
        let pitchAccuracy: Int?     // 视唱才有
        let responseTime: TimeInterval
    }
    
    // 结果
    var score: PracticeScore?
    
    func start() { ... }
    func submitAnswer(_ correct: Bool, timing: Int, pitch: Int?) { ... }
    func nextQuestion() { ... }
    func finish() { ... }
}
```

### 5.2 PracticeScore
```swift
struct PracticeScore: Codable {
    let correctCount: Int
    let totalCount: Int
    let averageTiming: Int
    let averagePitch: Int?
    let totalDuration: TimeInterval
    var percentage: Int { correctCount * 100 / totalCount }
}
```

**职责**: 独立于具体 View，纯练习流程管理。被 `ExerciseContainerView` 和 `SingleNoteListeningView` 使用。

**影响范围**: 重构 `ExerciseContainerView` 和 `SingleNoteListeningView` 接入 PracticeSession。

---

## Task 6: MotionCore — 统一动画语言

**文件**: `Core/MotionCore/MotionTokens.swift`

### 6.1 MotionToken 定义
```swift
enum MotionToken {
    // 脉冲类
    case pulseSoft      // 轻柔脉冲 (呼吸感)
    case pulseStrong    // 强劲脉冲 (节拍强调)
    
    // 波形类
    case waveformBreath // 波形呼吸 (音量可视化)
    case stringBounce   // 弦线振动
    case harmonicBloom  // 和声绽放 (正确反馈)
    
    // 过渡类
    case progressionResolve  // 和弦解决 (从紧张到松弛)
    case rhythmSnap          // 节奏击打
    
    // 反馈类
    case successGlow    // 正确发光
    case mistakeShake   // 错误抖动
}

extension MotionToken {
    var animation: Animation {
        switch self {
        case .pulseSoft: return .easeInOut(duration: 0.6).repeatForever(autoreverses: true)
        case .pulseStrong: return .easeInOut(duration: 0.3).repeatForever(autoreverses: true)
        case .waveformBreath: return .easeInOut(duration: 1.2).repeatForever(autoreverses: true)
        case .stringBounce: return .interpolatingSpring(stiffness: 300, damping: 15)
        case .harmonicBloom: return .spring(response: 0.4, dampingFraction: 0.6)
        case .progressionResolve: return .easeOut(duration: 0.8)
        case .rhythmSnap: return .interpolatingSpring(stiffness: 500, damping: 12)
        case .successGlow: return .spring(response: 0.3, dampingFraction: 0.5)
        case .mistakeShake: return .default.repeatCount(3, autoreverses: true).speed(3)
        }
    }
}
```

### 6.2 ViewModifier 扩展
```swift
extension View {
    func motionPulse(isActive: Bool, strength: MotionToken = .pulseSoft) -> some View
    func motionBreathe(isActive: Bool) -> some View
    func motionSuccess() -> some View
    func motionMistake() -> some View
}
```

**职责**: 整个 App 统一使用 MotionToken，禁止随意的 `.animation()` 调用。

---

## Task 7: ExperienceCore — 体验引擎

**文件**: `Core/ExperienceCore/ExperienceEngine.swift`

### 7.1 体验反馈模型
```swift
@Observable
final class ExperienceEngine {
    static let shared = ExperienceEngine()
    
    // 当前体验状态
    var grooveLevel: Double = 0.0       // 0~1 节奏感
    var accuracy: Double = 0.0          // 0~1 准确度
    var flowState: FlowState = .idle
    
    enum FlowState {
        case idle
        case finding       // 在找感觉
        case locked        // 进入状态
        case struggling    // 有困难
        case mastering     // 掌握中
    }
    
    // 事件处理
    func onUserAction(_ action: ExperienceAction) { ... }
    func onAudioFeedback(_ result: AudioFeedbackResult) { ... }
    func evaluateFlow() { ... }
}
```

### 7.2 体验动作模型
```swift
enum ExperienceAction {
    case noteCorrect(deviation: Double)    // 音高偏差 (cents)
    case noteMissed
    case rhythmOnBeat(accuracy: Double)    // 节奏准确度
    case rhythmOffBeat
    case chordStrummed(velocity: Double)
    case progressionResolved
}
```

**职责**: 监听用户行为 → 计算体验状态 → 驱动 Motion + Haptic 反馈。是整个产品的"灵魂层"。

---

## Task 8: HapticCore — 触觉引擎

**文件**: `Core/HapticCore/HapticEngine.swift`

```swift
final class HapticEngine {
    static let shared = HapticEngine()
    
    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let rigidGenerator = UIImpactFeedbackGenerator(style: .rigid)
    private let softGenerator = UIImpactFeedbackGenerator(style: .soft)
    
    // 音乐触感（克制、音乐感）
    func grooveLock() { /* 节奏锁定的微妙脉冲 */ }
    func chordHit(intensity: Double) { /* 和弦击打的质感 */ }
    func rhythmAccent() { /* 节拍重音 */ }
    func progressionResolve() { /* 和弦解决的释放感 */ }
    func successPulse() { /* 正确的温暖反馈 */ }
    func mistakeNudge() { /* 错误的轻柔提醒 */ }
    
    // 禁止：游戏式震动
}
```

**职责**: 轻量、克制、有音乐感的触觉。通过 `ExperienceEngine` 驱动，不直接在 View 中调用。

---

## Task 9: ThemeCore — 氛围系统

**文件**: `Core/ThemeCore/ThemeSystem.swift`

### 9.1 扩展现有 AppTheme
```swift
extension AppTheme {
    // 氛围属性 (Phase 1)
    enum Atmosphere {
        // Glow 系统
        static func glowIntensity(for accuracy: Double) -> Double
        
        // Shadow 系统 (按层级)
        static let cardShadow: Shadow
        static let elevatedShadow: Shadow
        static let floatingShadow: Shadow
        
        // Ambient Blur
        static func ambientBlur(level: Int) -> CGFloat  // 0~3
    }
    
    struct Shadow {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
}
```

**职责**: 第一阶段只做最基础的氛围扩展（Shadow 系统统一 + Glow 计算）。完整的 Dark/Light 氛围系统留到 Phase 4。

---

## Task 10: 重构现有视图接入 Runtime

### 10.1 ExerciseContainerView 重构
- **当前**: `@State` 管理所有状态（currentQuestion, correctCount, isCompleted, roundNumber, selectedOption, showResult...）
- **目标**: 接入 `PracticeSession`，View 只负责 UI 渲染
- **具体改动**:
  - 用 `PracticeSession` 替代 `@State currentQuestion/correctCount/isCompleted`
  - 播放逻辑从 `playCurrentExerciseAudio()` 迁移到 `PlaybackEngine.prepare()` + `play()`
  - 自动播放时序用 `MasterMusicClock` 回调替代 `DispatchQueue.main.asyncAfter`
  - 动画用 `MotionToken` 替代裸 `.animation()`

### 10.2 SightSingingContent / SightSingingViewModel 重构
- **当前**: VM 有自己独立的 Timer、播放逻辑、节奏评分
- **目标**: 接入 `PlaybackEngine` + `PracticeSession` + `ExperienceEngine`
- **具体改动**:
  - `SightSingingViewModel.singingTimer` → 订阅 `MasterMusicClock` tick
  - `playDemoMelody()` → `PlaybackEngine.prepare()` + `play()`
  - `calculateRhythmScore()` → `RhythmEngine.evaluateTiming()`
  - 评分反馈 → `ExperienceEngine.onUserAction()` → 驱动 Motion + Haptic
  - PitchMeter 动画 → `MotionToken.pulseSoft`

### 10.3 SingleNoteListeningView 重构
- **当前**: 相同的 `DispatchQueue.asyncAfter` 延迟播放模式
- **目标**: 接入 `PlaybackEngine` + `PracticeSession`
- **具体改动**:
  - 自动播放新题目 → `PlaybackEngine.prepare()` → 完成后回调 → 自动跳转
  - 答题状态管理 → `PracticeSession`

---

## 执行顺序

```
Task 1 → Task 2 → Task 3
         ↓
Task 4 → Task 5
         ↓
Task 6 → Task 7 → Task 8 → Task 9
                              ↓
                        Task 10 (逐步重构)
```

### 第一轮（基础设施，无破坏性变更）
1. **Task 1** — MasterMusicClock（纯新增，无影响）
2. **Task 2** — PlaybackCore（纯新增，无影响）
3. **Task 3** — RhythmEngine（纯新增，无影响）
4. **Task 6** — MotionTokens（纯新增，无影响）
5. **Task 8** — HapticEngine（纯新增，无影响）
6. **Task 9** — Theme 扩展（扩展已有文件，无破坏性）

### 第二轮（迁移+适配）
7. **Task 4** — AudioCore 迁移（移动文件 + 新增 API）
8. **Task 5** — PracticeSession（新增，替代部分 VM 职责）
9. **Task 7** — ExperienceEngine（新增，桥接层）

### 第三轮（视图重构）
10. **Task 10.1** — ExerciseContainerView 重构
11. **Task 10.2** — SightSinging 重构
12. **Task 10.3** — SingleNoteListeningView 重构

### 第四轮（验证+清理）
13. 编译验证
14. 功能回归测试
15. 移除冗余代码（旧的 Timer、旧的 dispatch 逻辑）
16. 更新 Xcode project 文件

---

## 文件清单（预计新增/修改）

### 新增文件 (14个)
```
Core/PlaybackCore/MasterMusicClock.swift
Core/PlaybackCore/PlaybackState.swift
Core/PlaybackCore/PlaybackEngine.swift
Core/PlaybackCore/PlaybackStore.swift
Core/RhythmCore/RhythmEngine.swift
Core/RhythmCore/RhythmPattern.swift
Core/PracticeCore/PracticeSession.swift
Core/PracticeCore/PracticeScore.swift
Core/MotionCore/MotionTokens.swift
Core/MotionCore/MotionModifiers.swift
Core/ExperienceCore/ExperienceEngine.swift
Core/ExperienceCore/ExperienceActions.swift
Core/HapticCore/HapticEngine.swift
Core/ThemeCore/ThemeAtmosphere.swift
```

### 迁移文件 (1个)
```
Services/AudioEngine.swift → Core/AudioCore/AudioEngine.swift
```

### 修改文件 (6-8个)
```
Views/Practice/ExerciseContainerView.swift      # 接入 PracticeSession + PlaybackEngine
Views/Practice/SingleNoteListeningView.swift     # 接入 PracticeSession + PlaybackEngine
ViewModels/SightSingingViewModel.swift           # 移除 Timer，接入 Runtime
Views/Practice/ExerciseContainerView.swift       # SightSingingContent 改 Motion
Services/ExerciseSoundPlayer.swift               # 部分逻辑迁移到 PlaybackEngine
SightSingingApp.xcodeproj/project.pbxproj        # 新增文件引用
```

---

## 验收标准

### 功能不变
- [ ] 练习页面所有模式正常工作（选择题、键盘输入、视唱）
- [ ] 单音辨认正常（自动播放、输入、判题、下一题）
- [ ] 视唱练习正常（播放示范、音高检测、节奏评分、结果）
- [ ] 多轮练习正常

### 架构达标
- [ ] 全 App 只有 1 个 PlaybackEngine 实例
- [ ] 全 App 只有 1 个 MasterMusicClock 实例
- [ ] View/ViewModel 中不再有裸 `Timer.scheduledTimer`
- [ ] View/ViewModel 中不再有裸 `DispatchQueue.main.asyncAfter` 用于播放时序
- [ ] 所有动画使用 MotionToken
- [ ] Haptic 在关键节点触发（正确、错误、节拍锁定）

### 编译
- [ ] `xcodebuild` BUILD SUCCEEDED
- [ ] 无新增 linter 错误
- [ ] 现有测试通过
