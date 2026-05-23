import SwiftUI

// MARK: - 练习层级分组页 (匹配 v0 ExerciseLevelsPage)
struct ExerciseLevelsPage: View {
    let exercise: PracticeExerciseData
    let categoryId: String
    let color: Color
    @Environment(\.dismiss) private var dismiss
    @State private var selectedLevel: ExerciseLevelData?
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部导航
            ZStack {
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 2) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                            Text("返回")
                                .font(.system(size: 15))
                        }
                        .foregroundStyle(AppTheme.accent)
                    }
                    Spacer()
                }
                
                Text(exercise.title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(AppTheme.primaryText)
                    .lineLimit(1)
            }
            .padding(.horizontal, 16)
            .frame(height: 44)
            .background(AppTheme.background.opacity(0.95))
            .overlay(alignment: .bottom) {
                Rectangle().fill(AppTheme.border).frame(height: 0.5)
            }
            
            ScrollView {
                VStack(spacing: 0) {
                    // 头部
                    VStack(alignment: .leading, spacing: 6) {
                        Text(exercise.title)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(AppTheme.primaryText)
                        Text(exercise.description)
                            .font(.system(size: 14))
                            .foregroundStyle(AppTheme.secondaryText)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                    
                    // 分组列表
                    VStack(spacing: 8) {
                        ForEach(levels, id: \.id) { level in
                            LevelCardView(
                                level: level,
                                color: color,
                                onTap: { selectedLevel = level }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 32)
            }
        }
        .background(AppTheme.background)
        .navigationBarHidden(true)
        .navigationDestination(item: $selectedLevel) { level in
            ExerciseContainerView(
                exercise: ExerciseItem(
                    id: exercise.id,
                    title: "\(exercise.title) · \(level.name)",
                    mode: modeForExercise,
                    percentage: level.progress,
                    levelItems: level.items
                ),
                moduleId: categoryId
            )
        }
    }
    
    private var modeForExercise: ExerciseMode {
        switch exercise.id {
        // 视唱类 → sightSinging（按 exerciseId 细分）
        case "single-note-sing": return .sightSinging       // T2 单音视唱
        case "interval-imitate": return .sightSinging      // T3 音程模唱（修复：ID 匹配 PracticeCategory 中的 interval-imitate）
        case "interval-singing": return .sightSinging      // T3 音程模唱（兼容旧 ID）
        case "melody-singing": return .sightSinging        // T3 旋律模唱
        case "chord-singing": return .sightSinging         // T3 和弦模唱
        case "scale-sing": return .sightSinging            // T2 音阶视唱
        case "interval-construct": return .sightSinging    // T3 音程构唱
        case "three-note-sing": return .sightSinging       // T3 三音组合模唱
        case "rhythm-sight": return .multipleChoice         // T6 节奏视唱
        case "rhythm-memory": return .multipleChoice        // T6 节奏背唱
        // 键盘输入类 → keyboardInput
        case "note-name-keyboard":
            return .keyboardInput
        // 节奏类 → multipleChoice
        case "quarter-eighth", "sixteenth-group", "syncopation",
             "triplet", "strumming", "rhythm-complex",
             "ascending-interval", "descending-interval", "harmonic-interval",
             "triad-identify", "chord-inversion", "seventh-chord":
            return .multipleChoice
        default:
            return categoryId == "singing" ? .sightSinging : .multipleChoice
        }
    }
    
    // 匹配 v0 levelsByExercise 数据
    private var levels: [ExerciseLevelData] {
        LevelDataProvider.levels(for: exercise.id)
    }
}

// MARK: - 分组卡片
struct LevelCardView: View {
    let level: ExerciseLevelData
    let color: Color
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // 完成状态图标
                ZStack {
                    Circle()
                        .fill(level.completed ? color : color.opacity(0.1))
                        .frame(width: 36, height: 36)
                    if level.completed {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                    } else {
                        Image(systemName: "play.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(color)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(level.name)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(AppTheme.primaryText)
                        Text(level.description)
                            .font(.system(size: 13))
                            .foregroundStyle(AppTheme.secondaryText)
                            .lineLimit(1)
                    }
                    
                    // 进度条
                    HStack(spacing: 8) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(AppTheme.secondaryBg).frame(height: 4)
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(color)
                                    .frame(width: geo.size.width * CGFloat(level.progress) / 100, height: 4)
                            }
                        }
                        .frame(height: 4)
                        Text("\(level.progress)%")
                            .font(.system(size: 10))
                            .foregroundStyle(AppTheme.secondaryText)
                            .frame(width: 28, alignment: .trailing)
                    }
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(AppTheme.secondaryText.opacity(0.5))
            }
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppTheme.border, lineWidth: 1)
            )
        }
        .buttonStyle(IOSPressStyle())
    }
}

// MARK: - 层级分组数据提供者 (匹配 v0 levelsByExercise)
struct LevelDataProvider {
    static func levels(for exerciseId: String) -> [ExerciseLevelData] {
        switch exerciseId {
        // 音程听辨
        case "ascending-interval", "descending-interval":
            return [
                ExerciseLevelData(id: "l1", name: "1组", description: "纯一度 / 小二度 / 大二度", items: ["纯一度", "小二度", "大二度"], progress: exerciseId == "ascending-interval" ? 100 : 80),
                ExerciseLevelData(id: "l2", name: "2组", description: "大二度 / 小三度 / 大三度", items: ["大二度", "小三度", "大三度"], progress: exerciseId == "ascending-interval" ? 75 : 45),
                ExerciseLevelData(id: "l3", name: "3组", description: "大三度 / 纯四度 / 增四减五度", items: ["大三度", "纯四度", "增四减五度"], progress: exerciseId == "ascending-interval" ? 40 : 20),
                ExerciseLevelData(id: "l4", name: "4组", description: "纯五度 / 小六度 / 大六度", items: ["纯五度", "小六度", "大六度"], progress: exerciseId == "ascending-interval" ? 20 : 0),
                ExerciseLevelData(id: "l5", name: "5组", description: "大六度 / 小七度 / 大七度 / 纯八度", items: ["大六度", "小七度", "大七度", "纯八度"], progress: 0),
                ExerciseLevelData(id: "l6", name: "综合", description: "八度内全音程随机", items: ["纯一度","小二度","大二度","小三度","大三度","纯四度","增四减五度","纯五度","小六度","大六度","小七度","大七度","纯八度"], progress: 0),
            ]
        case "harmonic-interval":
            return [
                ExerciseLevelData(id: "l1", name: "1组", description: "纯一度 / 小二度 / 大二度", items: ["纯一度", "小二度", "大二度"], progress: 65),
                ExerciseLevelData(id: "l2", name: "2组", description: "大二度 / 小三度 / 大三度", items: ["大二度", "小三度", "大三度"], progress: 30),
                ExerciseLevelData(id: "l3", name: "3组", description: "大三度 / 纯四度 / 增四减五度", items: ["大三度", "纯四度", "增四减五度"], progress: 10),
                ExerciseLevelData(id: "l4", name: "4组", description: "纯五度 / 小六度 / 大六度", items: ["纯五度", "小六度", "大六度"], progress: 0),
                ExerciseLevelData(id: "l5", name: "5组", description: "大六度 / 小七度 / 大七度 / 纯八度", items: ["大六度","小七度","大七度","纯八度"], progress: 0),
                ExerciseLevelData(id: "l6", name: "综合", description: "八度内全音程随机", items: ["纯一度","小二度","大二度","小三度","大三度","纯四度","增四减五度","纯五度","小六度","大六度","小七度","大七度","纯八度"], progress: 0),
            ]
        // 视唱
        case "single-note-sing":
            return [
                ExerciseLevelData(id: "l1", name: "1组", description: "核心稳定音 1/3/5", items: ["1","3","5"], progress: 100),
                ExerciseLevelData(id: "l2", name: "2组", description: "调内基础音 1/2/3/5/6", items: ["1","2","3","5","6"], progress: 85),
                ExerciseLevelData(id: "l3", name: "3组", description: "完整七声音阶 1-7", items: ["1","2","3","4","5","6","7"], progress: 55),
                ExerciseLevelData(id: "l4", name: "4组", description: "高低八度单音", items: ["低1","低2","低3","低4","低5","低6","低7","1","2","3","4","5","6","7","高1","高2","高3","高4","高5"], progress: 30),
                ExerciseLevelData(id: "l5", name: "综合", description: "调内单音随机视唱", items: [], progress: 10),
            ]
        // 唱准类 — 音阶视唱
        case "scale-sing":
            return [
                ExerciseLevelData(id: "l1", name: "1组", description: "C大调音阶上行", items: ["C大调上行"], progress: 80),
                ExerciseLevelData(id: "l2", name: "2组", description: "C大调音阶下行", items: ["C大调下行"], progress: 60),
                ExerciseLevelData(id: "l3", name: "3组", description: "G/D大调音阶", items: ["G大调上行","D大调上行"], progress: 40),
                ExerciseLevelData(id: "l4", name: "4组", description: "a/e小调音阶", items: ["a小调上行","e小调上行"], progress: 20),
                ExerciseLevelData(id: "l5", name: "5组", description: "五声音阶", items: ["C宫五声","G宫五声"], progress: 10),
                ExerciseLevelData(id: "l6", name: "综合", description: "各调式随机", items: [], progress: 0),
            ]
        // 唱准类 — 音程模唱（修复 ID 匹配：PracticeCategory 用 interval-imitate，modeForExercise 也需要匹配）
        case "interval-imitate":
            return [
                ExerciseLevelData(id: "l1", name: "1组", description: "一度 / 小二度 / 大二度", items: ["纯一度","小二度","大二度"], progress: 70),
                ExerciseLevelData(id: "l2", name: "2组", description: "小三度 / 大三度", items: ["小三度","大三度"], progress: 50),
                ExerciseLevelData(id: "l3", name: "3组", description: "纯四度 / 纯五度", items: ["纯四度","纯五度"], progress: 35),
                ExerciseLevelData(id: "l4", name: "4组", description: "小六度 / 大六度", items: ["小六度","大六度"], progress: 20),
                ExerciseLevelData(id: "l5", name: "5组", description: "小七度 / 大七度 / 纯八度", items: ["小七度","大七度","纯八度"], progress: 10),
                ExerciseLevelData(id: "l6", name: "综合", description: "八度内全音程随机", items: ["纯一度","小二度","大二度","小三度","大三度","纯四度","增四减五度","纯五度","小六度","大六度","小七度","大七度","纯八度"], progress: 0),
            ]
        // 唱准类 — 音程构唱
        case "interval-construct":
            return [
                ExerciseLevelData(id: "l1", name: "1组", description: "构唱纯一度/八度", items: ["纯一度","纯八度"], progress: 65),
                ExerciseLevelData(id: "l2", name: "2组", description: "构唱二/三度", items: ["小二度","大二度","小三度","大三度"], progress: 45),
                ExerciseLevelData(id: "l3", name: "3组", description: "构唱四/五度", items: ["纯四度","增四减五度","纯五度"], progress: 25),
                ExerciseLevelData(id: "l4", name: "4组", description: "构唱六/七度", items: ["小六度","大六度","小七度","大七度"], progress: 10),
                ExerciseLevelData(id: "l5", name: "5组", description: "综合构唱", items: ["纯一度","小二度","大二度","小三度","大三度","纯四度","增四减五度","纯五度","小六度","大六度","小七度","大七度","纯八度"], progress: 0),
                ExerciseLevelData(id: "l6", name: "挑战", description: "快速反应构唱", items: [], progress: 0),
            ]
        // 唱准类 — 三音模唱
        case "three-note-sing":
            return [
                ExerciseLevelData(id: "l1", name: "1组", description: "级进三音组合", items: ["123","234","345","456"], progress: 55),
                ExerciseLevelData(id: "l2", name: "2组", description: "跳进三音组合", items: ["135","351","531"], progress: 35),
                ExerciseLevelData(id: "l3", name: "3组", description: "混合进行", items: ["132","143","356","653"], progress: 20),
                ExerciseLevelData(id: "l4", name: "4组", description: "含升降号", items: ["#123","4#56"], progress: 10),
                ExerciseLevelData(id: "l5", name: "5组", description: "跨八度", items: ["高1高2高3","低5低6低7"], progress: 5),
                ExerciseLevelData(id: "l6", name: "综合", description: "随机三音组合", items: [], progress: 0),
            ]
        // 节奏 — 十六分音符
        case "sixteenth-group", "sixteenth":
            return [
                ExerciseLevelData(id: "l1", name: "1组", description: "四个十六分均分", items: ["xxxx"], progress: 80),
                ExerciseLevelData(id: "l2", name: "2组", description: "八分+两个十六分", items: ["x xx","xx x"], progress: 60),
                ExerciseLevelData(id: "l3", name: "3组", description: "附点+十六分", items: ["X.xx","x.XX"], progress: 40),
                ExerciseLevelData(id: "l4", name: "4组", description: "切分十六分", items: ["x x.x","x X.xx"], progress: 25),
                ExerciseLevelData(id: "l5", name: "5组", description: "复杂组合", items: ["xxx x","x xxx","X xx x"], progress: 10),
                ExerciseLevelData(id: "l6", name: "综合", description: "含十六分节奏随机", items: ["X","x","xxxx","x xx","xx x","X.xx","-","0"], progress: 0),
            ]
        // 节奏 — 切分
        case "syncopation":
            return [
                ExerciseLevelData(id: "l1", name: "1组", description: "弱起节奏", items: ["x X","x X -"], progress: 70),
                ExerciseLevelData(id: "l2", name: "2组", description: "中间切分", items: ["X x X","x X x"], progress: 50),
                ExerciseLevelData(id: "l3", name: "3组", description: "连续切分", items: ["x X x X","X x X x"], progress: 30),
                ExerciseLevelData(id: "l4", name: "4组", description: "重音移位", items: ["> x X","x > X"], progress: 20),
                ExerciseLevelData(id: "l5", name: "5组", description: "跨小节切分", items: ["X x | x X"], progress: 10),
                ExerciseLevelData(id: "l6", name: "综合", description: "切分节奏混合", items: ["X","x","X x X","x X x","> x X","x > X","-","0"], progress: 0),
            ]
        // 节奏 — 三连音
        case "triplet":
            return [
                ExerciseLevelData(id: "l1", name: "1组", description: "基本三连音", items: ["(xxx)"], progress: 65),
                ExerciseLevelData(id: "l2", name: "2组", description: "三连音+四分", items: ["X (xxx)","(xxx) X"], progress: 45),
                ExerciseLevelData(id: "l3", name: "3组", description: "两个连续三连音", items: ["(xxx)(xxx)"], progress: 25),
                ExerciseLevelData(id: "l4", name: "4组", description: "三连音+休止", items: ["(xx-)","(-xx)"], progress: 15),
                ExerciseLevelData(id: "l5", name: "5组", description: "复杂组合", items: ["X (xxx) X","(xxx) x (xxx)"], progress: 5),
                ExerciseLevelData(id: "l6", name: "综合", description: "含三连音节奏随机", items: ["X","x","(xxx)","X (xxx)","(xx-)","-","0"], progress: 0),
            ]
        // 节奏 — 扫弦
        case "strumming", "strum-rhythm", "rhythm-complex":
            return [
                ExerciseLevelData(id: "l1", name: "1组", description: "基础下扫上扫", items: ["↓↑↓↑","↓↓↓↑"], progress: 75),
                ExerciseLevelData(id: "l2", name: "2组", description: "加入切分", items: ["↓↓↑↓","↓↑↓↓"], progress: 55),
                ExerciseLevelData(id: "l3", name: "3组", description: "分解和弦节奏", items: ["分解T323","分解T1323"], progress: 35),
                ExerciseLevelData(id: "l4", name: "4组", description: "重音变化", items: [">↓↓↑","↓↓>↑"], progress: 20),
                ExerciseLevelData(id: "l5", name: "5组", description: "复合节奏型", items: ["分解532123","分解135313"], progress: 10),
                ExerciseLevelData(id: "l6", name: "综合", description: "扫弦节奏随机", items: ["↓↑↓↑","↓↓↓↑","↓↓↑↓","↓↑↓↓","分解T323",">","-"], progress: 0),
            ]
        // 和弦 — 七和弦
        case "seventh-chord", "seventh-identify":
            return [
                ExerciseLevelData(id: "l1", name: "1组", description: "属七 / 小七", items: ["属七和弦","小七和弦"], progress: 70),
                ExerciseLevelData(id: "l2", name: "2组", description: "属七 / 小七 / 半减七", items: ["属七和弦","小七和弦","半减七和弦"], progress: 50),
                ExerciseLevelData(id: "l3", name: "3组", description: "加入大七", items: ["属七和弦","小七和弦","大七和弦","半减七和弦"], progress: 30),
                ExerciseLevelData(id: "l4", name: "4组", description: "全部七和弦类型", items: ["属七和弦","小七和弦","大七和弦","半减七和弦","减七和弦"], progress: 15),
                ExerciseLevelData(id: "l5", name: "5组", description: "七和弦听辨进阶", items: ["属七和弦","小七和弦","大七和弦","半减七和弦","减七和弦","小大七和弦"], progress: 5),
                ExerciseLevelData(id: "l6", name: "综合", description: "七和弦综合随机", items: ["属七和弦","小七和弦","大七和弦","半减七和弦","减七和弦"], progress: 0),
            ]
        // 和弦 — TSD 功能判断
        case "tsd-function":
            return [
                ExerciseLevelData(id: "l1", name: "1组", description: "主功能 (T)", items: ["I","vi"], progress: 70),
                ExerciseLevelData(id: "l2", name: "2组", description: "下属功能 (S)", items: ["IV","ii"], progress: 50),
                ExerciseLevelData(id: "l3", name: "3组", description: "属功能 (D)", items: ["V","vii°"], progress: 35),
                ExerciseLevelData(id: "l4", name: "4组", description: "T+S+D 混合", items: ["I","iv","IV","ii","V","vii°"], progress: 20),
                ExerciseLevelData(id: "l5", name: "5组", description: "含离调和弦", items: ["I","IV","V","vi","ii","V7","V/vi"], progress: 10),
                ExerciseLevelData(id: "l6", name: "综合", description: "功能判断综合", items: ["I","ii","iii","IV","V","vi","vii°"], progress: 0),
            ]
        // 和弦 — 常用和弦进行
        case "chord-progression":
            return [
                ExerciseLevelData(id: "l1", name: "1组", description: "1645 进行", items: ["1645"], progress: 70),
                ExerciseLevelData(id: "l2", name: "2组", description: "1564 / 4515", items: ["1564","4515"], progress: 50),
                ExerciseLevelData(id: "l3", name: "3组", description: "346 / K46", items: ["K64-V-I","ii6-V-I"], progress: 35),
                ExerciseLevelData(id: "l4", name: "4组", description: "爵士常用进行", items: ["251","1625","36251"], progress: 20),
                ExerciseLevelData(id: "l5", name: "5组", description: "复杂进行", items: ["1645","1564","4515","251","1625"], progress: 10),
                ExerciseLevelData(id: "l6", name: "综合", description: "和弦进行综合", items: ["1645","1564","4515","K64-V-I","251","1625"], progress: 0),
            ]
        // 和弦 — 五度圈
        case "circle-of-fifths":
            return [
                ExerciseLevelData(id: "l1", name: "1组", description: "顺五度相邻调", items: ["C→G","G→D","D→A"], progress: 70),
                ExerciseLevelData(id: "l2", name: "2组", description: "逆五度（四度）", items: ["C→F","F→Bb","Bb→Eb"], progress: 50),
                ExerciseLevelData(id: "l3", name: "3组", description: "调号与五度", items: ["1个升号G","2个升号D","3个升号A"], progress: 35),
                ExerciseLevelData(id: "l4", name: "4组", description: "降号调", items: ["1个降号F","2个降号Bb","3个降号Eb"], progress: 20),
                ExerciseLevelData(id: "l5", name: "5组", description: "五度圈快速定位", items: ["C→G→D→A→E→B","C→F→Bb→Eb→Ab→Db"], progress: 10),
                ExerciseLevelData(id: "l6", name: "综合", description: "五度圈综合练习", items: [], progress: 0),
            ]
        // 和弦 — 离调和弦
        case "borrowed-chord":
            return [
                ExerciseLevelData(id: "l1", name: "1组", description: "副属和弦 V/V, V/vi", items: ["V/V","V/vi"], progress: 55),
                ExerciseLevelData(id: "l2", name: "2组", description: "借用和弦 ♭VII, ♭VI", items: ["♭VII","♭VI","IVm"], progress: 35),
                ExerciseLevelData(id: "l3", name: "3组", description: "那不勒斯六和弦", items: ["N6","It+6","Fr6"], progress: 20),
                ExerciseLevelData(id: "l4", name: "4组", description: "离调模进", items: ["V/V→V/vi→V/ii"], progress: 10),
                ExerciseLevelData(id: "l5", name: "5组", description: "综合听辨", items: ["V/V","V/vi","♭VII","♭VI","N6"], progress: 5),
                ExerciseLevelData(id: "l6", name: "综合", description: "离调和弦综合", items: [], progress: 0),
            ]
        // 和弦 — 吉他开放和弦
        case "open-chord", "chord-inversion":
            return [
                ExerciseLevelData(id: "l1", name: "1组", description: "C/G/Am/Em", items: ["C","G","Am","Em"], progress: 80),
                ExerciseLevelData(id: "l2", name: "2组", description: "D/F/A/E", items: ["D","F","A","E"], progress: 60),
                ExerciseLevelData(id: "l3", name: "3组", description: "加入 Dm/Bm", items: ["Dm","Bm"], progress: 40),
                ExerciseLevelData(id: "l4", name: "4组", description: "大横按 F/Bm", items: ["F(大横按)"], progress: 25),
                ExerciseLevelData(id: "l5", name: "5组", description: "全部开放和弦", items: ["C","G","Am","Em","D","F","A","E","Dm","Bm","F(大横按)"], progress: 15),
                ExerciseLevelData(id: "l6", name: "综合", description: "开放和弦综合随机", items: ["C","G","Am","Em","D","F","A","E","Dm","Bm"], progress: 0),
            ]
        // 节奏
        case "quarter-eighth":
            return [
                ExerciseLevelData(id: "l1", name: "1组", description: "四分音符稳定拍", items: ["X","-"], progress: 100),
                ExerciseLevelData(id: "l2", name: "2组", description: "八分音符均分", items: ["X","x","-"], progress: 85),
                ExerciseLevelData(id: "l3", name: "3组", description: "四分 + 八分组合", items: ["X","x","X x","x X"], progress: 60),
                ExerciseLevelData(id: "l4", name: "4组", description: "加入休止", items: ["X","x","-","0"], progress: 40),
                ExerciseLevelData(id: "l5", name: "5组", description: "加入重音", items: ["X","x","-","0",">"], progress: 20),
                ExerciseLevelData(id: "l6", name: "综合", description: "四分八分随机节奏", items: ["X","x","X x","x X","-","0",">"], progress: 0),
            ]
        // 和弦
        case "triad-identify":
            return [
                ExerciseLevelData(id: "l1", name: "1组", description: "大三 / 小三和弦", items: ["大三","小三"], progress: 85),
                ExerciseLevelData(id: "l2", name: "2组", description: "大三 / 小三 / 减三", items: ["大三","小三","减三"], progress: 60),
                ExerciseLevelData(id: "l3", name: "3组", description: "全部三和弦", items: ["大三","小三","减三","增三"], progress: 35),
                ExerciseLevelData(id: "l4", name: "4组", description: "加入转位", items: ["大三原位","大三一转","大三大转","小三原位","小三一转","小三六转"], progress: 15),
                ExerciseLevelData(id: "l5", name: "5组", description: "分散和弦听辨", items: ["大三","小三","减三","增三"], progress: 5),
                ExerciseLevelData(id: "l6", name: "综合", description: "三和弦综合随机", items: ["大三","小三","减三","增三","大六","小六"], progress: 0),
            ]
        // 默认通用6组
        default:
            return (1...6).map { i in
                ExerciseLevelData(
                    id: "l\(i)",
                    name: i == 6 ? "综合" : "\(i)组",
                    description: "第\(i)组练习",
                    items: [],
                    progress: i == 1 ? 50 : (i == 2 ? 25 : 0)
                )
            }
        }
    }
}

#Preview {
    NavigationStack {
        ExerciseLevelsPage(
            exercise: PracticeCategoryData.allCategories[0].exercises[1],
            categoryId: "pitch",
            color: AppTheme.Category.pitch
        )
    }
}
