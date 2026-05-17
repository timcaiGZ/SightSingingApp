import Foundation
import SwiftUI

/// 乐理 Tab ViewModel
@Observable
final class TheoryViewModel {
    var searchText: String = ""
    var selectedCategory: TheoryCategory?

    /// 全部知识点（内置静态数据）
    let allTopics: [TheoryTopic] = TheoryDataSource.allTopics

    /// 过滤后的知识点
    var filteredTopics: [TheoryTopic] {
        var topics = allTopics

        // 按分类过滤
        if let category = selectedCategory {
            topics = topics.filter { $0.category == category }
        }

        // 按搜索文本过滤
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            topics = topics.filter { topic in
                topic.title.lowercased().contains(query) ||
                topic.summary.lowercased().contains(query) ||
                topic.searchKeywords.contains { $0.lowercased().contains(query) }
            }
        }

        return topics
    }

    /// 按分类分组的知识点
    var groupedTopics: [(category: TheoryCategory, topics: [TheoryTopic])] {
        let filtered = filteredTopics
        var grouped: [TheoryCategory: [TheoryTopic]] = [:]

        for topic in filtered {
            grouped[topic.category, default: []].append(topic)
        }

        return TheoryCategory.allCases.compactMap { category in
            guard let topics = grouped[category], !topics.isEmpty else { return nil }
            return (category: category, topics: topics)
        }
    }

    /// 切换分类
    func selectCategory(_ category: TheoryCategory?) {
        selectedCategory = category
    }

    /// 清除搜索
    func clearSearch() {
        searchText = ""
    }
}

// MARK: - 乐理知识点数据源（内置静态数据）

struct TheoryDataSource {
    static let allTopics: [TheoryTopic] = [
        // MARK: - 识谱入门
        TheoryTopic(
            title: "六线谱基础",
            category: .notationBasics,
            summary: "认识吉他六线谱，六根弦与六条线的对应关系",
            content: """
            ## 六线谱基础

            六线谱是吉他特有的记谱方式，六条横线代表吉他的六根弦。

            **从上到下：**
            - 第1条线 = 吉他第1弦（最细，音最高）
            - 第2条线 = 吉他第2弦
            - 第3条线 = 吉他第3弦
            - 第4条线 = 吉他第4弦
            - 第5条线 = 吉他第5弦
            - 第6条线 = 吉他第6弦（最粗，音最低）

            **数字含义：**
            - 数字写在哪条线上，表示按那根弦的对应品位
            - `0` = 空弦，不按弦直接拨
            - `1` = 第1品，`2` = 第2品，以此类推
            - `X` = 需要按弦但数字未标出，或表示切音

            **右手符号：**
            - `p` = 拇指（低音弦）
            - `i` = 食指，`m` = 中指，`a` = 无名指
            """,
            searchKeywords: ["六线谱", "tab", "六根弦", "品位", "空弦"]
        ),
        TheoryTopic(
            title: "简谱基础",
            category: .notationBasics,
            summary: "简谱数字与音高的对应关系，高低音点标记",
            content: """
            ## 简谱基础

            简谱用数字 1-7 表示音高，是吉他弹唱最常用的记谱方式。

            **基本音高：**
            - `1` = Do（哆）
            - `2` = Re（来）
            - `3` = Mi（咪）
            - `4` = Fa（发）
            - `5` = Sol（索）
            - `6` = La（拉）
            - `7` = Si（西）

            **高低音标记：**
            - 数字下方加一点 = 低八度（如 `5` 下加点）
            - 数字上方加一点 = 高八度（如 `5` 上加点）
            - 两点 = 再低/高一个八度

            **节奏时值：**
            - `5 - -` = 四分音符（全音）
            - `5 -` = 二分音符
            - `5` = 四分音符
            - `5.` = 四分附点音符
            - `5` 下加横线 = 八分音符
            """,
            searchKeywords: ["简谱", "数字谱", "音高", "高低音", "时值", "节奏"]
        ),
        TheoryTopic(
            title: "空弦音与标准调弦",
            category: .notationBasics,
            summary: "吉他六根弦的空弦音高：EADGBE",
            content: """
            ## 空弦音与标准调弦

            **标准调弦（从粗到细）：**
            - 第6弦（最粗）：`E2` = 82.41 Hz
            - 第5弦：`A2` = 110.00 Hz
            - 第4弦：`D3` = 146.83 Hz
            - 第3弦：`G3` = 196.00 Hz
            - 第2弦：`B3` = 246.94 Hz
            - 第1弦（最细）：`E4` = 329.63 Hz

            **记忆口诀：** "EA狗狗贝比E"（饿啊狗狗贝贝饿）

            **简谱对应：**
            - 第6弦 E = 低音 `3`
            - 第5弦 A = 低音 `6`
            - 第4弦 D = 中音 `2`
            - 第3弦 G = 中音 `5`
            - 第2弦 B = 中音 `7`
            - 第1弦 E = 高音 `3`
            """,
            searchKeywords: ["空弦音", "标准调弦", "EADGBE", "调音", "六根弦音高"]
        ),

        // MARK: - 音程与音阶
        TheoryTopic(
            title: "吉他把位音程关系",
            category: .intervalsAndScales,
            summary: "同一弦相邻品位的音程关系，计算方法",
            content: """
            ## 吉他把位音程关系

            **基本规律：** 吉他上相邻品格互为半音（小二度）。

            **常见音程（同一弦移动）：**
            - 移动 1 品 = 小二度（1个半音）
            - 移动 2 品 = 大二度（2个半音）
            - 移动 3 品 = 小三度（3个半音）
            - 移动 4 品 = 大三度（4个半音）
            - 移动 5 品 = 纯四度（5个半音）
            - 移动 7 品 = 纯五度（7个半音）
            - 移动 12 品 = 纯八度

            **跨弦音程：**
            相邻两根弦的空弦音程差不是完全一致的：
            - 第6→5弦 = 四度（P4）
            - 第5→4弦 = 四度（P4）
            - 第4→3弦 = 四度（P4）
            - 第3→2弦 = 大三度（M3）⚠️ 特殊
            - 第2→1弦 = 四度（P4）

            **练习建议：** 记住第3弦到第2弦是大三度，其他都是纯四度。
            """,
            searchKeywords: ["音程", "把位", "品位", "半音", "音程计算", "跨弦"]
        ),
        TheoryTopic(
            title: "CAGED系统各调把位",
            category: .intervalsAndScales,
            summary: "CAGED系统：5种基本和弦形状在全指板的移动",
            content: """
            ## CAGED系统

            CAGED 系统是理解吉他指板音阶的核心方法。

            **5种基本形状：**
            1. **C 型** — 以 C 和弦形状为基础
            2. **A 型** — 以 A 和弦形状为基础
            3. **G 型** — 以 G 和弦形状为基础
            4. **E 型** — 以 E 和弦形状为基础
            5. **D 型** — 以 D 和弦形状为基础

            **核心原理：**
            - 这5种形状可以移动到任何品位
            - 形状移动的品位数 = 目标音的根音位置
            - 掌握 CAGED = 掌握整个指板

            **实战应用：**
            - 演奏各调的音阶
            - 即兴solo时快速找到和弦
            - 理解和弦之间的关联

            **练习建议：** 先熟练弹奏开放和弦 C-A-G-E-D，然后逐步尝试向上移动。
            """,
            searchKeywords: ["CAGED", "把位", "音阶", "指板", "和弦形状", "移动和弦"]
        ),

        // MARK: - 和弦
        TheoryTopic(
            title: "C 和弦标准按法",
            category: .chords,
            summary: "C 大和弦的食指、小指按法，以及常见错误纠正",
            content: """
            ## C 大和弦

            **按法（左手指法编号）：**
            - 食指：第2弦第1品
            - 中指：第4弦第2品
            - 无名指：第5弦第3品
            - 小指：第3弦第3品（可选）

            **简化按法（3音C和弦）：**
            - 只按第2弦1品、第4弦2品、第5弦3品
            - 第3弦不按或轻触消音

            **常见问题：**
            1. **食指按不实** → 食指稍微向外转，用侧面按弦
            2. **小指够不到** → 先练简化版，不必强求
            3. **第1弦被食指碰到** → 食指稍微立起来

            **转换到其他和弦的练习：**
            C → G：C保持手型，直接移动到G位置
            C → Am：C保持手型，直接移动到Am位置
            C → E：C保持手型，直接移动到E位置
            """,
            searchKeywords: ["C和弦", "按法", "食指", "小指", "和弦转换", "简化按法"]
        ),
        TheoryTopic(
            title: "大横按 F 和弦",
            category: .chords,
            summary: "F 大横按的食指全横按技巧，常见错误与解决方法",
            content: """
            ## F 大横按 — 吉他进阶第一关

            **全横按原理：**
            食指同时按住至少2根弦（通常是1-2根以上），需要食指侧面施加足够力度。

            **标准 F 和弦按法：**
            - 食指：第1-2弦全横按（1品位置），食指轻微弧形
            - 中指：第3弦第2品
            - 无名指：第4弦第3品
            - 小指：第5弦第3品（可选）
            - 第6弦不按（或食指轻触消音）

            **高效练习步骤：**
            1. **单音练习**：逐根弹奏，确保每根弦都清晰
            2. **慢速分解**：T3231321（T=拇指），每个音单独检查
            3. **逐步加速**：从60BPM开始，逐渐提速
            4. **力量训练**：每天靠墙按压食指50次，增强指力

            **小横按替代（Fmaj7）：**
            食指只按第1-2弦，空第3弦，可以先弹Fmaj7替代F和弦。
            """,
            searchKeywords: ["F和弦", "大横按", "横按", "食指", "全横按", "Bm", "Bb"]
        ),
        TheoryTopic(
            title: "吉他和弦级数",
            category: .chords,
            summary: "自然大调各级和弦的性质与吉他按法",
            content: """
            ## 吉他和弦级数

            以 C 大调为例（吉他最友好的调）：

            | 级数 | 和弦 | 性质 | 常用按法 |
            |------|------|------|---------|
            | I    | C    | 大三和弦 | 开放 C |
            | ii   | Dm   | 小三和弦 | 开放 Dm |
            | iii  | Em   | 小三和弦 | 开放 Em |
            | IV   | F    | 大三和弦 | 横按 F |
            | V    | G    | 大三和弦 | 开放 G |
            | vi   | Am   | 小三和弦 | 开放 Am |
            | vii° | Bdim | 减三和弦 | 横按 Bdim |

            **实战应用：**
            - **I-IV-V-I**：C-F-G-C，流行歌曲万能进行
            - **I-V-vi-IV**：C-G-Am-F，卡西欧进行
            - **I-vi-IV-V**：C-Am-F-G，50年代进行

            **A/G/D/E 调的级数表：**
            弹唱最常用的4个调：C、A、G、E
            建议先掌握 C 调和弦，再逐步迁移。
            """,
            searchKeywords: ["和弦级数", "I-IV-V", "级数", "顺阶和弦", "和弦进行", "弹唱"]
        ),

        // MARK: - 节奏
        TheoryTopic(
            title: "扫弦节奏型入门",
            category: .rhythm,
            summary: "最基础的扫弦节奏型：下下下上、下下上下",
            content: """
            ## 扫弦节奏型

            **基本符号：**
            - `↓` = 下扫（从6弦向1弦）
            - `↑` = 上扫（从1弦向6弦）
            - `X` = 切音（下扫瞬间消音）
            - `-` = 延长一拍

            **最常用的4个节奏型：**

            **1. 下下下上（民谣经典）**
            ```
            4/4
            ↓  ↓  ↓  ↑
            1  2  3  4
            ```

            **2. 下下上下（乡村风格）**
            ```
            4/4
            ↓  ↓  ↑  ↓
            1  2  3  4
            ```

            **3. 下上下上（摇滚）**
            ```
            4/4
            ↓  ↑  ↓  ↑
            1  2  3  4
            ```

            **4. 切分节奏**
            ```
            4/4
            X  -  ↓  ↑
            1     2  3  4
            ```

            **练习建议：** 先用空弦练习节奏感，不必急着按和弦。
            """,
            searchKeywords: ["扫弦", "节奏型", "下下下上", "切音", "切分节奏", "乡村风格"]
        ),
        TheoryTopic(
            title: "分解和弦节奏型",
            category: .rhythm,
            summary: "T323、T135 等分解和弦节奏型，适合弹唱伴奏",
            content: """
            ## 分解和弦节奏型

            **右手手指编号：**
            - `T` (Thumb) = 拇指 → 拨低音弦（第4-6弦）
            - `i` (Index) = 食指 → 第3弦
            - `m` (Middle) = 中指 → 第2弦
            - `a` (Annular) = 无名指 → 第1弦

            **最常用的分解节奏：**

            **T323（C和弦示例）**
            ```
            C:  T   3   2   3
               第5  第3 第2 第3弦
            ```
            节奏：1 - 2 - 3 - 4（一拍一个音）

            **T135（C和弦示例）**
            ```
            C:  T   1   3   5
               第5  第4 第2 第1弦
            ```

            **Am 型分解**
            ```
            Am: T   1   3   1
               第5  第4 第2 第1弦
            ```

            **练习步骤：**
            1. 慢速弹奏每个音，确保音色清晰
            2. 配合节拍器，从60BPM开始
            3. 逐步加速到120BPM以上
            4. 加入和弦转换练习
            """,
            searchKeywords: ["分解和弦", "T323", "T135", "指法", "拇指", "食指", "中指", "无名指"]
        ),

        // MARK: - 调式
        TheoryTopic(
            title: "E调与A调把位",
            category: .modes,
            summary: "吉他最常用的两个调：E调/A调音阶把位与和弦",
            content: """
            ## E调与A调把位

            **为什么 E/A 调最常用？**
            - E 调的空弦音与很多和弦音重合
            - A 调只需移动小指位置
            - 很多经典弹唱歌曲使用这两个调

            **E 大调：**
            - 音阶：E F# G# A B C# D# E
            - 核心和弦：E、Em、A、Am、B7、C#m、F#m、G#m
            - **E 型把位**：以第6弦空弦 E 为根音

            **A 大调：**
            - 音阶：A B C# D E F# G# A
            - 核心和弦：A、Am、D、Dm、E7、F#m、Bm
            - **A 型把位**：以第5弦空弦 A 为根音

            **快速转换技巧：**
            E → A：保持手型不变，将食指从第6弦移到第5弦
            A → G：整体向下移动到G把位

            **练习建议：** 先练 E 调，再练 A 调，最后尝试 D 调。
            """,
            searchKeywords: ["E调", "A调", "D调", "把位", "音阶", "吉他调式", "转换"]
        ),
        TheoryTopic(
            title: "G调与D调把位",
            category: .modes,
            summary: "G调和D调的特点、把位与常用和弦",
            content: """
            ## G调与D调把位

            **G 大调：**
            - 音阶：G A B C D E F# G
            - 核心和弦：G、Em、A、Am、Bm、C、D
            - **G 型把位**：以第3弦空弦 G 为根音

            **D 大调：**
            - 音阶：D E F# G A B C# D
            - 核心和弦：D、Em、A7、A、Am、Bm、E7
            - **D 型把位**：以第4弦空弦 D 为根音

            **四个最常用调的和弦对照：**

            | 和弦 | C调 | G调 | D调 | E调 | A调 |
            |------|-----|-----|-----|-----|-----|
            | I    | C   | G   | D   | E   | A   |
            | ii   | Dm  | Am  | Bm  | F#m | Bm  |
            | iii  | Em  | Bm  | C#m | G#m | C#m |
            | IV   | F   | C   | G   | A   | D   |
            | V    | G   | D   | A   | B   | E   |
            | vi   | Am  | Em  | Bm  | C#m | F#m |

            **选择调式的原则：**
            - 根据嗓音最适合的音域选择
            - 吉他上哪个调更好按就选哪个
            - 弹唱转调：使用变调夹更方便
            """,
            searchKeywords: ["G调", "D调", "把位", "音阶", "和弦对照", "变调夹", "转调"]
        ),
    ]
}
