import Foundation
import SwiftUI

// MARK: - 课程数据结构（4层深度：课程 → 章节 → 课时 → 练习）

/// 课程练习类型（简化版：乐理/视唱/听力）
enum CourseExerciseCategory: String, CaseIterable, Codable, Hashable {
    case theory = "乐理"
    case singing = "视唱"
    case earTraining = "听力"
}

/// 课程练习
struct CourseExercise: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let title: String
    let type: CourseExerciseCategory
    let difficulty: Int
    let description: String
    let content: String
}

/// 课时
struct Lesson: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let title: String
    let content: String
    let duration: Int
    var exercises: [CourseExercise]
    var isCompleted: Bool = false
    
    static let sample = Lesson(
        id: "lesson-1-1",
        title: "音名与音高",
        content: "学习七个基本音名的认识与音高关系",
        duration: 15,
        exercises: [
            CourseExercise(id: "ex-1", title: "音名识别", type: .theory, difficulty: 1, description: "识别五线谱上的音名", content: "请在钢琴键盘上找到以下音名对应的位置：\n\n1. C音（中音C）\n2. D音\n3. E音\n4. F音\n5. G音"),
            CourseExercise(id: "ex-2", title: "音高听辨", type: .earTraining, difficulty: 2, description: "辨别不同音名的音高", content: "聆听钢琴演奏的音符，判断是升还是降：\n\n1. 从C音开始，上升二度是什么音？\n2. 从G音开始，下降三度是什么音？"),
            CourseExercise(id: "ex-3", title: "视唱练习", type: .singing, difficulty: 2, description: "演唱指定旋律", content: "跟随钢琴伴奏演唱以下旋律，注意音准：\n\n| 1 | 2 | 3 | 4 | 5 | 4 | 3 | 2 | 1 | ‖\n\n音名：C | D | E | F | G | F | E | D | C |")
        ]
    )
}

/// 课程
struct Course: Identifiable, Hashable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let colorName: String
    let chapters: [Chapter]
    var progress: Double = 0.0

    var totalLessons: Int { chapters.reduce(0) { $0 + $1.lessons.count } }
    var completedLessons: Int { chapters.flatMap { $0.lessons }.filter { $0.isCompleted }.count }
}

/// 章节
struct Chapter: Identifiable, Hashable {
    let id: String
    let title: String
    let courseId: String
    let lessons: [Lesson]
}

// MARK: - 视图模型扩展

extension CourseViewModel {
    /// 根据章节获取所属课程的颜色
    func iconColor(for chapter: Chapter) -> Color {
        if let course = courses.first(where: { $0.id == chapter.courseId }) {
            return iconColor(for: course)
        }
        return .blue
    }
}

// MARK: - 预置课程

extension Course {
    static let allCourses: [Course] = [.musicTheoryBasics, .sightSingingIntro, .rhythmTraining, .earTrainingCourse]

    static let musicTheoryBasics = Course(
        id: "course_music_theory",
        title: "乐理基础",
        description: "从零开始系统学习音乐理论",
        icon: "music.note.list",
        colorName: "blue",
        chapters: [
            Chapter(id: "ch_mt_1", title: "第一章 音名与音高", courseId: "course_music_theory", lessons: [
                Lesson(id: "les_mt_1_1", title: "1.1 认识音名", content: "学习七个基本音名 C D E F G A B", duration: 5,
                       exercises: [
                           CourseExercise(id: "ex1", title: "音名识别", type: .theory, difficulty: 1, description: "识别钢琴键盘上的音名", content: "请在钢琴键盘上找到并点击以下音名：\n\n1. C音\n2. D音\n3. E音\n4. F音\n5. G音"),
                           CourseExercise(id: "ex2", title: "吉他音名位置", type: .earTraining, difficulty: 2, description: "在吉他指板上找音名", content: "吉他空弦音从六弦到一弦是：E A D G B E\n\n请在指板上找到以下音名的位置：\n\n1. G音（二弦）\n2. A音（三弦）\n3. B音（二弦）")
                       ]),
                Lesson(id: "les_mt_1_2", title: "1.2 音名与简谱", content: "理解音名与简谱数字的对应关系", duration: 8,
                       exercises: [
                           CourseExercise(id: "ex3", title: "音名转简谱", type: .theory, difficulty: 1, description: "音名对应简谱数字", content: "简谱数字与唱名的对应关系：\n\n1=C, 2=D, 3=E, 4=F, 5=G, 6=A, 7=B\n\n请转换以下音名为简谱数字：\n1. F音 → ?\n2. A音 → ?\n3. G音 → ?")
                       ]),
                Lesson(id: "les_mt_1_3", title: "1.3 吉他空弦音", content: "掌握吉他标准调弦的空弦音名", duration: 6,
                       exercises: [
                           CourseExercise(id: "ex4", title: "空弦音辨认", type: .earTraining, difficulty: 2, description: "听辨吉他空弦", content: "吉他六根空弦从粗到细的音名是：\n\n六弦(E) - 五弦(A) - 四弦(D) - 三弦(G) - 二弦(B) - 一弦(E)\n\n请按顺序写出六根空弦的音名：\n\n____ - ____ - ____ - ____ - ____ - ____")
                       ])
            ]),
            Chapter(id: "ch_mt_2", title: "第二章 音程", courseId: "course_music_theory", lessons: [
                Lesson(id: "les_mt_2_1", title: "2.1 什么是音程", content: "学习音程的概念和命名", duration: 10,
                       exercises: [
                           CourseExercise(id: "ex5", title: "音程计算", type: .theory, difficulty: 2, description: "计算音程距离", content: "音程用\"度\"来表示。\n\n从C到D是多少度？\n从G到B是多少度？\n从E到G是多少度？"),
                           CourseExercise(id: "ex6", title: "音程性质辨认", type: .earTraining, difficulty: 3, description: "听辨大小音程", content: "聆听以下音程，判断是大还是小：\n\n1. C到E（大三度/小三度）\n2. D到F（大二/小二）\n3. F到A（大三/小三）")
                       ]),
                Lesson(id: "les_mt_2_2", title: "2.2 吉他上的音程", content: "理解吉他指板上的音程关系", duration: 12,
                       exercises: [
                           CourseExercise(id: "ex7", title: "同弦音程", type: .earTraining, difficulty: 3, description: "在同弦上找音程", content: "吉他同弦上，相邻品位的音程是半音（全音=2个半音）。\n\n在二弦上，从第1品到第5品是什么音程？")
                       ])
            ]),
            Chapter(id: "ch_mt_3", title: "第三章 和弦构成", courseId: "course_music_theory", lessons: [
                Lesson(id: "les_mt_3_1", title: "3.1 三和弦", content: "学习大三和弦、小三和弦的构成", duration: 15,
                       exercises: [
                           CourseExercise(id: "ex8", title: "和弦构成识别", type: .theory, difficulty: 3, description: "识别和弦音", content: "大三和弦 = 根音 + 大三度 + 小三度\n小三和弦 = 根音 + 小三度 + 大三度\n\nC和弦（根音C）由哪些音组成？\nAm和弦（根音A）由哪些音组成？"),
                           CourseExercise(id: "ex9", title: "和弦性质听辨", type: .earTraining, difficulty: 4, description: "听辨大小和弦", content: "聆听和弦，判断是大三和弦还是小三和弦：\n\n1. C-E-G\n2. A-C-E\n3. D-F#-A")
                       ]),
                Lesson(id: "les_mt_3_2", title: "3.2 吉他常用和弦", content: "学习吉他上常见和弦的按法", duration: 20,
                       exercises: [
                           CourseExercise(id: "ex10", title: "和弦辨认", type: .theory, difficulty: 2, description: "识别和弦名称", content: "根据以下音组成，判断和弦名称：\n\n1. G-B-D = ?和弦\n2. E-G-B = ?和弦\n3. A-C-E = ?和弦")
                       ])
            ])
        ]
    )

    static let sightSingingIntro = Course(
        id: "course_sight_singing",
        title: "视唱入门",
        description: "通过简谱视唱训练培养音准感",
        icon: "mic.fill",
        colorName: "green",
        chapters: [
            Chapter(id: "ch_ss_1", title: "第一章 单音视唱", courseId: "course_sight_singing", lessons: [
                Lesson(id: "les_ss_1_1", title: "1.1 Do Re Mi", content: "从基础音阶开始学习视唱", duration: 8,
                       exercises: [
                           CourseExercise(id: "ex11", title: "音阶模唱", type: .singing, difficulty: 1, description: "跟随钢琴演唱音阶", content: "跟随钢琴或节拍器，演唱C大调音阶：\n\nC(do) - D(re) - E(mi) - F(fa) - G(sol) - A(la) - B(si) - C(do)\n\n注意音准，从C开始回到C。"),
                           CourseExercise(id: "ex12", title: "单音音准", type: .singing, difficulty: 2, description: "准确演唱单个音", content: "聆听钢琴演奏的音符，然后准确演唱：\n\n1. C音 - 演唱\"do\"\n2. E音 - 演唱\"mi\"\n3. G音 - 演唱\"sol\"")
                       ]),
                Lesson(id: "les_ss_1_2", title: "1.2 上行与下行", content: "练习音阶的上行和下行", duration: 10,
                       exercises: [
                           CourseExercise(id: "ex13", title: "上行音阶", type: .singing, difficulty: 2, description: "演唱上行音阶", content: "演唱C大调上行音阶，注意上行时的渐强：\n\nC - D - E - F - G - A - B - C")
                       ])
            ]),
            Chapter(id: "ch_ss_2", title: "第二章 音程视唱", courseId: "course_sight_singing", lessons: [
                Lesson(id: "les_ss_2_1", title: "2.1 二度音程", content: "学习二度音程的视唱", duration: 12,
                       exercises: [
                           CourseExercise(id: "ex14", title: "二度音程模唱", type: .singing, difficulty: 3, description: "演唱二度音程", content: "演唱以下二度音程，注意半音和全音的区别：\n\n1. C - D（大二度）\n2. E - F（小二度）\n3. G - A（大二度）")
                       ]),
                Lesson(id: "les_ss_2_2", title: "2.2 三度音程", content: "学习三度音程的视唱", duration: 15,
                       exercises: [
                           CourseExercise(id: "ex15", title: "三度音程模唱", type: .singing, difficulty: 3, description: "演唱三度音程", content: "演唱以下三度音程：\n\n1. C - E（大三度）\n2. D - F（小三度）\n3. E - G（小三度）")
                       ])
            ]),
            Chapter(id: "ch_ss_3", title: "第三章 节奏视唱", courseId: "course_sight_singing", lessons: [
                Lesson(id: "les_ss_3_1", title: "3.1 四分音符", content: "稳定节拍训练", duration: 10,
                       exercises: [
                           CourseExercise(id: "ex16", title: "四分音符节奏", type: .singing, difficulty: 2, description: "稳定节拍演唱", content: "使用节拍器（速度60），每拍演唱一个音：\n\n| 1 | 2 | 3 | 4 | 1 | 2 | 3 | 4 |\n| C | D | E | F | G | A | B | C |")
                       ])
            ])
        ]
    )

    static let earTrainingCourse = Course(
        id: "course_ear_training",
        title: "听力训练",
        description: "系统训练音乐听力，掌握音高、音程、和弦听辨",
        icon: "ear.fill",
        colorName: "purple",
        chapters: [
            Chapter(id: "ch_et_1", title: "第一章 音高辨别", courseId: "course_ear_training", lessons: [
                Lesson(id: "les_et_1_1", title: "1.1 音高感知", content: "训练对音高上下行的感知能力", duration: 10,
                       exercises: [
                           CourseExercise(id: "ex_et_1", title: "音高上行辨别", type: .earTraining, difficulty: 1, description: "辨别音高上行", content: "聆听两组音符，判断第二组音高比第一组高还是低：\n\n1. C → D（高/低？）\n2. G → E（高/低？）\n3. A → B（高/低？）"),
                           CourseExercise(id: "ex_et_2", title: "音高记忆", type: .earTraining, difficulty: 2, description: "记住标准音高", content: "记住A4=440Hz的标准音高，然后判断以下音比A高还是低：\n\n1. G4\n2. B4\n3. F#4")
                       ]),
                Lesson(id: "les_et_1_2", title: "1.2 音名听辨", content: "听辨吉他空弦音名", duration: 12,
                       exercises: [
                           CourseExercise(id: "ex_et_3", title: "空弦音听辨", type: .earTraining, difficulty: 2, description: "听辨空弦音名", content: "聆听吉他空弦音，判断是哪根弦的音：\n\n1. 答案：E2（六弦空弦）\n2. 答案：A2（五弦空弦）\n3. 答案：G3（三弦空弦）\n4. 答案：E4（一弦空弦）")
                       ])
            ]),
            Chapter(id: "ch_et_2", title: "第二章 音程听辨", courseId: "course_ear_training", lessons: [
                Lesson(id: "les_et_2_1", title: "2.1 大小二度听辨", content: "辨别大二度和小二度音程", duration: 15,
                       exercises: [
                           CourseExercise(id: "ex_et_4", title: "大小二度辨析", type: .earTraining, difficulty: 3, description: "听辨大二度与小二度", content: "聆听以下音程，判断是大二度还是小二度：\n\n1. C-D（大二度/小二度？）\n2. E-F（大二度/小二度？）\n3. B-C（大二度/小二度？）\n\n提示：小二度听起来更\"紧张\"")
                       ]),
                Lesson(id: "les_et_2_2", title: "2.2 大小三度听辨", content: "辨别大三度和小三度音程", duration: 15,
                       exercises: [
                           CourseExercise(id: "ex_et_5", title: "大小三度辨析", type: .earTraining, difficulty: 3, description: "听辨大三度与小三度", content: "聆听以下音程，判断是大三度还是小三度：\n\n1. C-E（大三度/小三度？）\n2. D-F（大三度/小三度？）\n3. A-C（大三度/小三度？）\n\n提示：大三度听起来更\"明亮\"，小三度更\"忧郁\"")
                       ]),
                Lesson(id: "les_et_2_3", title: "2.3 纯四五度听辨", content: "辨别纯四度和纯五度音程", duration: 18,
                       exercises: [
                           CourseExercise(id: "ex_et_6", title: "纯四五度辨析", type: .earTraining, difficulty: 4, description: "听辨纯四度与纯五度", content: "聆听以下音程，判断是纯四度还是纯五度：\n\n1. C-F（纯四度/纯五度？）\n2. C-G（纯四度/纯五度？）\n3. G-C（纯四度/纯五度？）\n\n提示：纯四度听起来像\"婚礼进行曲\"开头，纯五度像\"星球大战\"主题")
                       ])
            ]),
            Chapter(id: "ch_et_3", title: "第三章 和弦听辨", courseId: "course_ear_training", lessons: [
                Lesson(id: "les_et_3_1", title: "3.1 大小三和弦听辨", content: "辨别大三和弦与小三和弦", duration: 20,
                       exercises: [
                           CourseExercise(id: "ex_et_7", title: "大小和弦辨析", type: .earTraining, difficulty: 3, description: "听辨大三和弦与小三和弦", content: "聆听以下和弦，判断是大三和弦还是小三和弦：\n\n1. C-E-G（大/小？）\n2. A-C-E（大/小？）\n3. D-F#-A（大/小？）\n4. E-G-B（大/小？）\n\n提示：大三和弦听起来\"明亮开朗\"，小三和弦听起来\"忧伤沉郁\"")
                       ]),
                Lesson(id: "les_et_3_2", title: "3.2 常见和弦进行听辨", content: "听辨常见和弦进行模式", duration: 25,
                       exercises: [
                           CourseExercise(id: "ex_et_8", title: "和弦进行识别", type: .earTraining, difficulty: 5, description: "听辨和弦进行", content: "聆听以下和弦进行，写出和弦级数：\n\n1. C-G-Am-F（这是哪个经典进行？）\n2. C-Am-F-G（这是哪个经典进行？）\n3. Am-F-C-G（这是哪个经典进行？）\n\n提示：I-V-vi-IV, I-vi-IV-V, vi-IV-I-V")
                       ])
            ]),
            Chapter(id: "ch_et_4", title: "第四章 节奏模仿", courseId: "course_ear_training", lessons: [
                Lesson(id: "les_et_4_1", title: "4.1 简单节奏模仿", content: "听打节奏并模仿", duration: 12,
                       exercises: [
                           CourseExercise(id: "ex_et_9", title: "四拍子模仿", type: .earTraining, difficulty: 2, description: "模仿简单节奏", content: "聆听节奏，用手拍出相同的节奏：\n\n1. | 哒 | 哒 | 哒 | 哒 |（四分音符）\n2. | 哒哒 | 哒哒 | 哒哒 | 哒哒 |（八分音符）\n3. | 哒 | 哒哒 | 哒 | 哒哒 |（混合）")
                       ]),
                Lesson(id: "les_et_4_2", title: "4.2 旋律听写入门", content: "听旋律并写出简谱", duration: 20,
                       exercises: [
                           CourseExercise(id: "ex_et_10", title: "简谱听写", type: .earTraining, difficulty: 4, description: "听旋律写简谱", content: "聆听钢琴演奏的旋律，用简谱数字写出：\n\n1. 两小节，4/4拍，仅使用1 2 3\n2. 两小节，4/4拍，使用1 2 3 4 5\n3. 两小节，4/4拍，使用1-7全部音\n\n提示：先确定第一个音，再判断后续音是上行还是下行")
                       ])
            ])
        ]
    )

    static let rhythmTraining = Course(
        id: "course_rhythm",
        title: "节奏训练",
        description: "系统训练节奏感，掌握吉他常用节奏型",
        icon: "metronome",
        colorName: "orange",
        chapters: [
            Chapter(id: "ch_rt_1", title: "第一章 基础节奏型", courseId: "course_rhythm", lessons: [
                Lesson(id: "les_rt_1_1", title: "1.1 四拍子", content: "4/4拍的稳定节奏训练", duration: 10,
                       exercises: [
                           CourseExercise(id: "ex17", title: "四拍子节奏", type: .earTraining, difficulty: 1, description: "稳定节拍感", content: "使用节拍器（速度80），用\"哒\"打四拍节奏：\n\n| 1 | 2 | 3 | 4 |\n| 哒 | 哒 | 哒 | 哒 |")
                       ]),
                Lesson(id: "les_rt_1_2", title: "1.2 三拍子", content: "3/4拍圆舞曲节奏", duration: 10,
                       exercises: [
                           CourseExercise(id: "ex18", title: "三拍子节奏", type: .earTraining, difficulty: 2, description: "强弱弱节拍", content: "3/4拍是\"强弱弱\"的节拍，用\"哒\"打出：\n\n| 1 | 2 | 3 | 1 | 2 | 3 |\n| 哒(强) | 哒(弱) | 哒(弱) | 哒(强) | 哒(弱) | 哒(弱) |")
                       ])
            ]),
            Chapter(id: "ch_rt_2", title: "第二章 扫弦节奏型", courseId: "course_rhythm", lessons: [
                Lesson(id: "les_rt_2_1", title: "2.1 下扫", content: "单向下扫练习", duration: 12,
                       exercises: [
                           CourseExercise(id: "ex19", title: "下扫节奏", type: .earTraining, difficulty: 2, description: "稳定下扫", content: "使用节拍器，每拍向下扫弦一次：\n\n| 下 | 下 | 下 | 下 |\n| 1 | 2 | 3 | 4 |")
                       ]),
                Lesson(id: "les_rt_2_2", title: "2.2 上下扫", content: "交替扫弦入门", duration: 15,
                       exercises: [
                           CourseExercise(id: "ex20", title: "上下扫节奏", type: .earTraining, difficulty: 3, description: "交替扫弦", content: "交替上下扫弦，每拍一次：\n\n↓ ↑ ↓ ↑ ↓ ↑ ↓ ↑\n1  2  3  4  5  6  7  8")
                       ])
            ]),
            Chapter(id: "ch_rt_3", title: "第三章 切分节奏", courseId: "course_rhythm", lessons: [
                Lesson(id: "les_rt_3_1", title: "3.1 切分音", content: "切分节奏的识别与演奏", duration: 15,
                       exercises: [
                           CourseExercise(id: "ex21", title: "切分音辨认", type: .earTraining, difficulty: 4, description: "识别切分节奏", content: "切分节奏的特点是\"强拍后移\"。\n\n在以下节奏中，用\"X\"标记切分音的位置：\n\n| 哒 | 哒 | X | 哒 |")
                       ])
            ])
        ]
    )
}
