# Sight Singing Practice Specification

## Overview

视唱练习模块提供旋律播放、实时音高检测和评分反馈的完整闭环。

## Requirements

### REQ-SS-001: 练习流程
系统 SHALL 实现以下流程：介绍 → 播放示范 → 等待演唱 → 演唱检测 → 结果展示。

#### Scenario: 完整练习流程
- GIVEN 用户选择旋律练习
- WHEN 进入练习
- THEN 按顺序执行：介绍页 → 播放示范 → 等待演唱 → 演唱检测 → 结果页

### REQ-SS-002: 实时音高指示
系统 SHALL 实时显示检测音高与目标音高的偏差。

#### Scenario: 音高偏差显示
- GIVEN 目标音高 A4，用户演唱 A4# (466Hz)
- WHEN 实时检测中
- THEN 显示约 +100 音分偏差

### REQ-SS-003: 评分计算
系统 SHALL 计算音准分和节奏分，综合分 = 音准分×0.7 + 节奏分×0.3。

#### Scenario: 评分结果
- GIVEN 用户演唱音准偏差平均 10 音分
- WHEN 计算结果
- THEN 音准分约 100，节奏分固定 100，综合分约 100

## Issues Found

### CRITICAL: Timer 生命周期管理
- **位置**: `SightSingingView.swift` L319-333
- **问题**: Timer 未存储引用，无法在 View 消失时主动停止
- **影响**: 可能导致内存泄漏和后台持续运行
- **建议**:

```swift
@State private var timer: Timer?

func startSinging() {
    // ...
    timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
        // ...
    }
}

func cleanup() {
    timer?.invalidate()
    timer = nil
    pitchDetector.stopDetection()
}
```

### MEDIUM: 评分计算不完整
- **问题**: 节奏分目前固定为 100，未实现实际节奏检测
- **建议**: 添加节奏模式检测或标注为 TODO

### LOW: Preview 不安全
- **位置**: 多处 `#Preview` 使用 `first!` force unwrap
- **建议**: 使用 `if let` 或提供 mock 数据
