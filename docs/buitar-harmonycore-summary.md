# Buitar → HarmonyCore 精华吸取与复用总结

## 概述

SightSingingApp 从 Buitar（吉他助手项目）中吸取了**音频引擎 + 和声核心**两大模块的精华，通过 `HarmonyCore` 目录直接复用核心算法，形成了一套完整的「吉他乐理可视化 + 交互式练习」体系。

---

## 一、整体架构分层

```
┌─────────────────────────────────────────────────────────────┐
│                      视图层 (Views)                          │
│  HarmonyGraphics.swift  │  TheoryGraphics.swift              │
│  指板视图 / 和弦指法 / 音阶可视化 / 和弦进行播放器           │
├─────────────────────────────────────────────────────────────┤
│                      服务层 (Services)                        │
│  ExerciseSoundPlayer.swift  │  TheoryTapAudio.swift          │
│  练习音频播放 / 乐理点击发音                                  │
├──────────────────────┬──────────────────────────────────────┤
│     音频引擎层        │         和声核心层                     │
│   AudioCore/          │       HarmonyCore/                   │
│   AudioEngine.swift   │   6 个核心模型文件                    │
│   actor 封装          │   纯逻辑 / 无 UI 依赖                │
│   AVAudioEngine       │   借鉴 buitar 核心算法               │
│   MIDI 合成 + 缓存    │   可直接被视图层调用                  │
└──────────────────────┴──────────────────────────────────────┘
```

---

## 二、HarmonyCore 六大模块详解

### 1. FretboardPoint.swift — 指板点模型
> 借鉴 buitar `Point` 模型

```
核心能力：统一编码「弦、品、音名、MIDI音高、音程」五维信息
```

| 数据结构 | 作用 |
|---------|------|
| `NoteName` | 12 平均律音名枚举 (C/C#/D.../B)，支持 pitch 互转、升降号别名 |
| `ScaleInterval` | 调内音程 (1-7 + ♭/# 变体)，支持半音偏移计算 |
| `FretboardPoint` | 指板单点 — 含 string/fret/note/midiNote/interval，支持八度标记 |

### 2. FretboardModel.swift — 吉他指板模型
> 借鉴 buitar `GuitarBoard`

```
核心能力：标准调弦 EADGBE × 16品 二维网格，支持音高查询、位置搜索
```

| 方法 | 功能 |
|-----|------|
| `point(at:fret:)` | 获取弦×品位置的音高 |
| `findPositions(of:)` | 查找某音名在指板所有位置 |
| `findPosition(of:)` | 按 MIDI 音高查位置 |
| `generatePoints()` | 自动生成 6×16 二维网格 |

### 3. ChordIdentity.swift — 和弦身份系统 ⭐
> 借鉴 buitar `chord key` 指纹系统

```
核心算法：通过「相邻音程半音差拼接」生成唯一和弦指纹
```

| 标记 | 中文名 | 音程 | 指纹 key |
|-----|-------|------|---------|
| M | 大三和弦 | 1-3-5 | `"43"` |
| m | 小三和弦 | 1-♭3-5 | `"34"` |
| 7 | 属七和弦 | 1-3-5-♭7 | `"433"` |
| maj7 | 大七和弦 | 1-3-5-7 | `"434"` |
| dim | 减三和弦 | 1-♭3-♭5 | `"33"` |

**一共定义 24 种和弦类型**，分为三和弦(5)、七和弦(11)、扩展和弦(8)三组。

`computeKey()` 算法：
```swift
// 大三和弦 [1,3,5] → 半音距 [4,3] → key = "43"
gaps = [3-1的半音差, 5-3的半音差] = [4, 3]
key = gaps.map(String.init).joined() = "43"
```

### 4. ChordFingeringSolver.swift — 和弦指法求解器 ⭐⭐
> 借鉴 buitar `findNextString` 递归算法

```
核心能力：给定和弦名 → 在标准调弦指板上自动求解所有可行按法
```

| 特性 | 说明 |
|-----|------|
| 算法 | 递归回溯，从低音弦→高音弦逐弦搜索 |
| 约束 | 手指跨度 ≤ 4品、最多用 4 指、优先低把位 |
| 输出 | 按难度分类（beginner/intermediate/advanced），最多返回 10 种 |
| 横按检测 | 自动识别 barre 位置 |
| 数据结构 | `ChordVoicing` → `[ChordStringTap]` |

### 5. ScaleEngine.swift — 调式与音阶引擎
> 借鉴 buitar `ModeType`

```
核心能力：11 种调式 × 12 个根音 × 任意品范围 → 指板音阶
```

| 功能 | 方法 |
|-----|------|
| 音阶生成 | `ScaleEngine.scale(root:mode:)` → 7 音音阶 |
| 顺阶三和弦 | `diatonicTriads(root:mode:)` → 七级三和弦 |
| 顺阶七和弦 | `diatonicSeventhChords(root:mode:)` → 七级七和弦 |
| 调内音判断 | `ScaleEngine.isDiatonic(note:in:mode:)` |
| 调式分类 | `ScaleMode.tonality` → `.major` / `.minor` |

### 6. ChordProgressionEngine.swift — 和弦进行引擎
> 借鉴 buitar `Sequencer` + `Progression` 配置

```
核心能力：11 种内置和弦进行 × 12 个调 × 任意转调
```

| 内置进行 | 说明 |
|---------|------|
| 1-6-4-5 | 万能和弦进行 (1645) |
| 1-5-6-4 | 卡农进行 (1564) |
| 1-4-5 | 经典摇滚 |
| 卡农走向 | C-G-Am-Em-F-C-F-G |
| 50 年代 | 1-6-4-5 (doo-wop) |
| 布鲁斯 | I7-IV7-V7 |
| 爵士 2-5-1 | 爵士核心进行 |
| 4-5-3-6-2-5-1 | 4536251 (华语万能走向) |
| 安达卢西亚 | i-♭VII-♭VI-V |
| Doo-Wop | 1-6-4-5 |

---

## 三、音频引擎层

### AudioEngineManager (actor)
```
AVAudioEngine → MIDI 合成 → Buffer 缓存 → 练习播放
```

| 特性 | 说明 |
|-----|------|
| 线程模型 | `actor` 保证线程安全 |
| Buffer 缓存 | 预渲染常用 MIDI 音高，避免重复合成 |
| 双模式 | `.playback`（仅播放）/ `.playAndRecord`（录音+播放） |
| 封装层 | `ExerciseSoundPlayer`（练习） + `TheoryTapAudio`（乐理点击） |

---

## 四、视图层复用关系

```
HarmonyCore (纯逻辑)
    │
    ├──→ HarmonyFretboardView     可点击发音的完整指板网格
    ├──→ DynamicChordDiagramView   和弦指法自动求解 + 多把位展示
    ├──→ ScaleOnFretboardView      调式音阶指板高亮
    ├──→ ChordProgressionPlayerView 和弦进行播放器（调速/转调/指板联动）
    ├──→ HarmonyChordCardsView      和弦信息卡片（自动生成）
    ├──→ AllKeysGridView            12 调速查视图
    ├──→ DiatonicChordTableView     顺阶和弦表
    └──→ ChordTypeBrowserView       24 种和弦类型浏览器
```

**调用链路示例**：
```
用户点击「C大调 1645 进行」
  → ChordProgressionPlayerView
    → ChordProgressionEngine.allKeys(.oneSixFourFive)
      → ScaleEngine.diatonicTriads(root: .C, mode: .major)
        → [C, Am, F, G]
    → DynamicChordDiagramView(chordName: "C")
      → ChordFingeringSolver.solve("C", on: fretboard)
        → [开放C, 横按C (3品), 横按C (8品)]
    → AudioEngineManager.playMIDI(60) → 播放 C4
```

---

## 五、关键设计原则

### 1. 「指纹」驱动
和弦、音阶、进行全部以数据驱动，不硬编码。`ChordIdentity.key` 是核心，24 种和弦通过 `"43"` `"34"` `"433"` 等短字符串唯一标识，便于查找和对比。

### 2. 「纯逻辑」核心
HarmonyCore 中 6 个文件**全部不依赖 SwiftUI**，只 import Foundation。这意味着可以：
- 直接在测试中使用
- 未来迁移到 Server 端
- 不绑定 UI 框架

### 3. 「求解器」模式
`ChordFingeringSolver` 使用了经典递归回溯算法，不是查表而是**实时计算**。优势：
- 支持任意调弦（不只是 EADGBE）
- 不限指板范围
- 结果可按难度、音域、舒适度排序

### 4. 「数据即视图」
HarmonyGraphics.swift 中的 9 个视图组件遵循「数据驱动视图」原则：
- 输入：纯粹的数据模型（`ChordIdentity`, `FretboardModel`, `ChordVoicing`）
- 输出：SwiftUI View
- 无副作用，无本地状态泄漏

---

## 六、模块依赖关系

```
              NoteName / ScaleInterval / FretboardPoint
                      │
              ┌───────┴───────┐
              │               │
      FretboardModel    ChordIdentity
              │               │
              └───────┬───────┘
                      │
            ChordFingeringSolver
                      │
              ┌───────┴───────┐
              │               │
         ScaleEngine    ChordProgressionEngine
              │               │
              └───────┬───────┘
                      │
              HarmonyGraphics.swift
              (9 个交互式视图组件)
                      │
              ┌───────┴───────┐
              │               │
      TheoryTapAudio    ExerciseSoundPlayer
              │               │
              └───────┬───────┘
                      │
              AudioEngineManager
              (AVAudioEngine)
```

---

## 七、统计数据

| 维度 | 数量 |
|-----|------|
| HarmonyCore 文件 | 6 个 |
| HarmonyGraphics 视图组件 | 9 个 |
| 支持的调式 | 11 种 |
| 支持的和弦类型 | 24 种 |
| 内置和弦进行 | 11 种 |
| 标准指板网格 | 6 弦 × 16 品 |
| 指法求解返回上限 | 10 种/和弦 |
| 音频引擎模式 | 2 种 (playback / playAndRecord) |

---

## 八、和声核心相对于乐理课程的作用

HarmonyCore 不是替代原有的乐理数据结构，而是为**模块四「和弦」（29 课时）** 提供交互式可视化能力：

| 乐理子板块 | 使用的 HarmonyCore 能力 |
|-----------|----------------------|
| 和弦基础（12 课时） | `ChordIdentity` 指纹系统 + `ChordFingeringSolver` 指法求解 |
| 指板数据库（8 课时） | `FretboardModel` 指板模型 + `FretboardPoint` 位置查询 |
| 和弦进行与替代（9 课时） | `ChordProgressionEngine` 进行引擎 + `ScaleEngine` 顺阶和弦 |
