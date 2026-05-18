# Pitch Detection Service Specification

## Overview

音高检测服务使用 AudioKit PitchTap 进行实时音频分析，检测用户演唱音高并计算评分。

## Requirements

### REQ-PD-001: 麦克风权限管理
系统 SHALL 在启动检测前请求麦克风权限。

#### Scenario: 权限已授予
- GIVEN 用户已授予麦克风权限
- WHEN 调用 `startDetection()`
- THEN 音频引擎启动成功

#### Scenario: 权限被拒绝
- GIVEN 用户拒绝麦克风权限
- WHEN 调用 `startDetection()`
- THEN `state` 设置为 `.idle`，打印错误日志

### REQ-PD-002: 音高检测精度
系统 SHOULD 使用 AudioKit PitchTap 实现 ±5 音分以内的检测精度。

#### Scenario: 正常音高检测
- GIVEN 用户演唱 A4 (440Hz)
- WHEN 音频幅度 > 0.1
- THEN `detectedFrequency` 更新为实际频率 ±5Hz

### REQ-PD-003: 频率范围过滤
系统 SHALL 只处理 50Hz - 2000Hz 范围内的音频。

#### Scenario: 频率超出范围
- GIVEN 检测到的频率为 30Hz
- WHEN 频率计算完成
- THEN `detectedFrequency` 保持为 0

### REQ-PD-004: 实时评分计算
系统 SHALL 基于音分偏差计算 0-100 分的音准评分。

#### Scenario: 音分偏差计算
- GIVEN 目标音高 A4 (440Hz)，用户演唱 445Hz
- WHEN `updateScore()` 被调用
- THEN `centsDeviation` 约为 19.6 音分，`currentScore` 约为 86

### REQ-PD-005: 生命周期管理
系统 SHALL 在 `stopDetection()` 时正确释放 AudioKit 资源。

#### Scenario: 停止检测
- GIVEN 检测状态为 `.detecting`
- WHEN 调用 `stopDetection()`
- THEN PitchTap 停止，AudioEngine 停止，`state` 设为 `.stopped`

## Implementation Notes

### Current Implementation
- 使用 `PitchTap` 进行音高追踪
- 使用 `Fader` 静音输出
- 检测频率范围: 50-2000Hz
- 阈值: amplitude > 0.1

### Issues Found
1. `[weak self]` 在 `DispatchQueue.main.async` 中需要额外注意避免循环引用
2. 需要验证 AudioKit 5.6 兼容性
