# Code Review Tasks

## Implementation Checklist

### Critical Issues

- [x] **TASK-001**: 修复 TestEngine 反射问题 ✅
  - 创建 `DifficultyProvidable` 协议
  - 让所有题目类型遵循协议
  - 重构 `balancedRandom抽取` 使用泛型约束
  - 验证编译通过

- [x] **TASK-002**: 修复 SightSingingView Timer 生命周期 ✅
  - 添加 `@State private var singingTimer: Timer?`
  - 在 `startSinging()` 中存储 Timer 引用
  - 添加 `cleanup()` 方法
  - 在 `.onDisappear` 调用 cleanup

- [x] **TASK-003**: 修复 AudioEngine 线程安全 ✅
  - 重构为 `actor AudioEngineManager`
  - 更新所有调用处为 `await AudioEngineManager.shared.xxx()`
  - 验证多线程调用安全

### High Priority

- [x] **TASK-004**: 统一错误处理 ✅
  - 创建 `AppLogger` 工具（Utilities/AppLogger.swift）
  - 重构 `try? context.save()` 为带日志的版本
  - 在关键位置添加 try-catch

- [x] **TASK-005**: 迁移 DispatchQueue 到 async/await ✅
  - 重构 `TestViewModel.selectAnswer`
  - 重构 `PitchDetector.setupEngine`
  - 重构 `SightSingingView.playDemoMelody`
  - 重构 `ExerciseDetailView.selectAnswer`
  - 使用 `Task { @MainActor in }` 替代 `DispatchQueue`

- [x] **TASK-006**: 修复 MusicTheory.solfegeWithAccidental ✅
  - 添加 flat (♭) 处理逻辑
  - 添加 `Accidental` 枚举支持 sharp/flat/natural

### Medium Priority

- [x] **TASK-007**: 添加单元测试 ✅
  - 创建 `MusicTheoryTests.swift`（16 个测试用例）
  - 创建 `PitchDetectorConfigurationTests.swift`（4 个测试用例）
  - 创建 `TestConfigurationTests.swift`（9 个测试用例）

- [x] **TASK-008**: 提取 Magic Numbers ✅
  - 创建 `AudioConfiguration` 结构体
  - 创建 `TestConfiguration` 结构体
  - 创建 `SingingConfiguration` 结构体
  - 创建 `PitchDetectorConfiguration` 结构体

- [x] **TASK-009**: 修复 ThemedColors ✅
  - 重构为 `@Observable final class ThemedColors`
  - 添加 `inject(from:)` 方法

- [x] **TASK-010**: 优化题库数据 ✅
  - 创建 `QuestionBank.swift`（Services/QuestionBank.swift）
  - 分离题库数据为静态常量（600+ 题）
  - 添加 `Statistics` 结构体统计信息
  - 从 TestEngine.swift 删除重复定义

### Low Priority

- [x] **TASK-011**: 修复 Preview unsafe unwrap ✅
  - 修复 `TheoryDetailView` 中的 `first!`
  - 使用 `if let` 提供 fallback

- [x] **TASK-012**: 添加 API 文档注释 ✅
  - 为 `AppLogger` 添加完整 SwiftDoc
  - 为 `Configuration` 枚举添加 SwiftDoc
  - 为 `MusicTheory` 函数添加 SwiftDoc
  - 为 `ThemedColors` 添加 SwiftDoc

## Verification

- [ ] 运行 `pod install` 确保 AudioKit 依赖正确
- [ ] XcodeBuild 编译通过
- [ ] 所有测试通过
- [ ] 代码审查通过

## Summary

### 已完成: 12/12 任务 🎉

| 类别 | 完成 | 总计 |
:|------|------|------:|
| Critical | 3 | 3 |
| High | 3 | 3 |
| Medium | 4 | 4 |
| Low | 2 | 2 |
| **总计** | **12** | **12** |
