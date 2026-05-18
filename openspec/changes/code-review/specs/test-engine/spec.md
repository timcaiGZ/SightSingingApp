# Test Engine Service Specification

## Overview

测试引擎负责生成诊断测试题目、计算评分并生成个性化练习推荐。

## Requirements

### REQ-TE-001: 题目生成
系统 SHALL 从题库中随机抽取题目，每模块 5 题，按 1:2:2 比例分配难度。

#### Scenario: 均衡抽取
- GIVEN 题库包含初/中/高级题目
- WHEN 生成测试
- THEN 抽取 1 道初级、2 道中级、2 道高级题目

### REQ-TE-002: 评分计算
系统 SHALL 基于正确率和反应时间计算综合得分。

#### Scenario: 综合得分计算
- GIVEN 正确率 80%，平均反应时间 2 秒
- WHEN 计算综合得分
- THEN 综合得分 = 正确率×0.7 + (1-归一化反应时间)×0.3

### REQ-TE-003: 推荐生成
系统 SHALL 基于测试结果生成个性化推荐，和弦权重最高 (1.3x)。

#### Scenario: 薄弱项推荐
- GIVEN 用户和弦模块得分最低
- WHEN 生成推荐
- THEN 和弦练习优先推荐

## Issues Found

### CRITICAL: Mirror 反射性能问题
- **位置**: `TestEngine.swift` L847-864
- **问题**: 使用 `Mirror(reflecting:)` 获取 difficulty 属性
- **影响**: 每次筛选 100+ 题时性能极差
- **建议**: 定义协议 `DifficultyProvidable`，使用类型安全的方式访问

```swift
protocol DifficultyProvidable {
    var difficulty: Difficulty { get }
}
```

### HIGH: 错误处理缺失
- **位置**: 多处 `try? context.save()`
- **问题**: 错误被静默吞掉，无法调试
- **建议**: 至少添加日志输出

### MEDIUM: 题库数据重复
- **位置**: `TestEngine.swift` L146-155
- **问题**: 相同题目数据重复创建
- **建议**: 定义静态常量题库，只初始化一次
