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
        case "interval-singing": return .sightSinging      // T3 音程模唱
        case "melody-singing": return .sightSinging        // T3 旋律模唱
        case "chord-singing": return .sightSinging         // T3 和弦模唱
        case "rhythm-sight": return .multipleChoice         // T6 节奏视唱
        case "rhythm-memory": return .multipleChoice        // T6 节奏背唱
        case "scale-sing", "interval-sing", "melody-sing":
            return .sightSinging
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
                ExerciseLevelData(id: "l1", name: "1组", description: "一度 / 小二度 / 大二度", items: ["一度", "小二度", "大二度"], progress: exerciseId == "ascending-interval" ? 100 : 80),
                ExerciseLevelData(id: "l2", name: "2组", description: "大二度 / 小三度 / 大三度", items: ["大二度", "小三度", "大三度"], progress: exerciseId == "ascending-interval" ? 75 : 45),
                ExerciseLevelData(id: "l3", name: "3组", description: "大三度 / 纯四度 / 增四减五度", items: ["大三度", "纯四度", "增四减五度"], progress: exerciseId == "ascending-interval" ? 40 : 20),
                ExerciseLevelData(id: "l4", name: "4组", description: "纯五度 / 小六度 / 大六度", items: ["纯五度", "小六度", "大六度"], progress: exerciseId == "ascending-interval" ? 20 : 0),
                ExerciseLevelData(id: "l5", name: "5组", description: "大六度 / 小七度 / 大七度 / 纯八度", items: ["大六度", "小七度", "大七度", "纯八度"], progress: 0),
                ExerciseLevelData(id: "l6", name: "综合", description: "八度内全音程随机", items: ["一度","小二度","大二度","小三度","大三度","纯四度","增四减五度","纯五度","小六度","大六度","小七度","大七度","纯八度"], progress: 0),
            ]
        case "harmonic-interval":
            return [
                ExerciseLevelData(id: "l1", name: "1组", description: "一度 / 小二度 / 大二度", items: ["一度", "小二度", "大二度"], progress: 65),
                ExerciseLevelData(id: "l2", name: "2组", description: "大二度 / 小三度 / 大三度", items: ["大二度", "小三度", "大三度"], progress: 30),
                ExerciseLevelData(id: "l3", name: "3组", description: "大三度 / 纯四度 / 增四减五度", items: ["大三度", "纯四度", "增四减五度"], progress: 10),
                ExerciseLevelData(id: "l4", name: "4组", description: "纯五度 / 小六度 / 大六度", items: ["纯五度", "小六度", "大六度"], progress: 0),
                ExerciseLevelData(id: "l5", name: "5组", description: "大六度 / 小七度 / 大七度 / 纯八度", items: ["大六度","小七度","大七度","纯八度"], progress: 0),
                ExerciseLevelData(id: "l6", name: "综合", description: "八度内全音程随机", items: ["一度","小二度","大二度","小三度","大三度","纯四度","增四减五度","纯五度","小六度","大六度","小七度","大七度","纯八度"], progress: 0),
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
