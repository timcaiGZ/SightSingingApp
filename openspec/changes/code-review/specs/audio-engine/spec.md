# Audio Engine Service Specification

## Overview

音频引擎负责合成吉他音色并播放音符、和弦，支持简谱和 MIDI 格式。

## Requirements

### REQ-AE-001: 吉他音色合成
系统 SHALL 使用正弦波 + 谐波叠加模拟吉他音色。

#### Scenario: 单音符播放
- GIVEN 目标音高 A4 (440Hz)
- WHEN 调用 `playNote(frequency: 440)`
- THEN 播放包含基频 + 6 个谐波的合成音色

### REQ-AE-002: ADSR 包络
系统 SHALL 实现 Attack-Decay-Sustain-Release 包络。

#### Scenario: 包络参数
- GIVEN 音符触发
- THEN 使用以下包络参数：
  - Attack: 0.02s (快速起音)
  - Decay: 0.1s (中等衰减)
  - Sustain: 0.8 (持续音量)
  - Release: 0.3s (较快释放)

### REQ-AE-003: 和弦播放
系统 SHALL 支持同时播放多个音符。

#### Scenario: 和弦播放
- GIVEN 和弦 C (C4, E4, G4)
- WHEN 调用 `playChord()`
- THEN 同时播放三个音符

## Implementation Notes

### Current Implementation
- 6 个谐波分量 (基频 + 5 个泛音)
- 谐波衰减比例: 1/f^2
- AVAudioEngine 驱动

### Issues Found

### CRITICAL: 线程安全问题
- **位置**: `AudioEngine.swift`
- **问题**: `isSetup` 标志位访问无同步机制
- **影响**: 多线程调用可能产生竞态条件
- **建议**: 使用 `actor` 或 `@MainActor` 保护

```swift
actor AudioEngine {
    private var isSetup = false
    
    func setup() async {
        guard !isSetup else { return }
        // ...
        isSetup = true
    }
}
```

### MEDIUM: Magic Numbers
| 参数 | 值 | 位置 |
|------|-----|------|
| 采样率 | 44100 | L119 |
| ADSR | 0.02, 0.1, 0.8, 0.3 | L149-161 |

建议提取到 `AudioConfiguration` 常量结构体。
