// 练习题目数据配置

export interface ExerciseQuestion {
  displayContent: string // 显示的内容（音符、音程、和弦等）
  displayLabel: string // 标签说明
  question: string // 问题文本
  options: string[] // 选项
  correctAnswer: string // 正确答案
}

// 单音辨认题库 - 不显示具体音符，只显示播放提示
const singleNoteQuestions: ExerciseQuestion[] = [
  { displayContent: "听辨单音", displayLabel: "点击播放按钮聆听", question: "请选择你听到的音：", options: ["C", "D", "E", "F", "G", "A", "B"], correctAnswer: "C" },
  { displayContent: "听辨单音", displayLabel: "点击播放按钮聆听", question: "请选择你听到的音：", options: ["C", "D", "E", "F", "G", "A", "B"], correctAnswer: "D" },
  { displayContent: "听辨单音", displayLabel: "点击播放按钮聆听", question: "请选择你听到的音：", options: ["C", "D", "E", "F", "G", "A", "B"], correctAnswer: "E" },
  { displayContent: "听辨单音", displayLabel: "点击播放按钮聆听", question: "请选择你听到的音：", options: ["C", "D", "E", "F", "G", "A", "B"], correctAnswer: "F" },
  { displayContent: "听辨单音", displayLabel: "点击播放按钮聆听", question: "请选择你听到的音：", options: ["C", "D", "E", "F", "G", "A", "B"], correctAnswer: "G" },
]

// 音程听辨题库 - 不显示具体音符，只显示播放提示
const intervalQuestions: ExerciseQuestion[] = [
  { displayContent: "听辨音程", displayLabel: "点击播放按钮聆听", question: "请选择你听到的音程：", options: ["小二度", "大二度", "小三度", "大三度", "纯四度", "纯五度"], correctAnswer: "大三度" },
  { displayContent: "听辨音程", displayLabel: "点击播放按钮聆听", question: "请选择你听到的音程：", options: ["小三度", "大三度", "纯四度", "增四度", "纯五度", "小六度"], correctAnswer: "纯五度" },
  { displayContent: "听辨音程", displayLabel: "点击播放按钮聆听", question: "请选择你听到的音程：", options: ["小二度", "大二度", "小三度", "大三度", "纯四度", "增四度"], correctAnswer: "小三度" },
  { displayContent: "听辨音程", displayLabel: "点击播放按钮聆听", question: "请选择你听到的音程：", options: ["大三度", "纯四度", "增四度", "纯五度", "小六度", "大六度"], correctAnswer: "纯四度" },
  { displayContent: "听辨音程", displayLabel: "点击播放按钮聆听", question: "请选择你听到的音程：", options: ["小二度", "大二度", "小三度", "大三度", "纯四度", "纯五度"], correctAnswer: "大三度" },
]

// 三和弦辨认题库 - 不显示具体和弦音，只显示播放提示
const triadQuestions: ExerciseQuestion[] = [
  { displayContent: "听辨和弦", displayLabel: "点击播放按钮聆听", question: "请选择你听到的和弦类型：", options: ["大三和弦", "小三和弦", "增三和弦", "减三和弦"], correctAnswer: "大三和弦" },
  { displayContent: "听辨和弦", displayLabel: "点击播放按钮聆听", question: "请选择你听到的和弦类型：", options: ["大三和弦", "小三和弦", "增三和弦", "减三和弦"], correctAnswer: "小三和弦" },
  { displayContent: "听辨和弦", displayLabel: "点击播放按钮聆听", question: "请选择你听到的和弦类型：", options: ["大三和弦", "小三和弦", "增三和弦", "减三和弦"], correctAnswer: "小三和弦" },
  { displayContent: "听辨和弦", displayLabel: "点击播放按钮聆听", question: "请选择你听到的和弦类型：", options: ["大三和弦", "小三和弦", "增三和弦", "减三和弦"], correctAnswer: "大三和弦" },
  { displayContent: "听辨和弦", displayLabel: "点击播放按钮聆听", question: "请选择你听到的和弦类型：", options: ["大三和弦", "小三和弦", "增三和弦", "减三和弦"], correctAnswer: "减三和弦" },
]

// 七和弦辨认题库 - 不显示具体和弦音，只显示播放提示
const seventhChordQuestions: ExerciseQuestion[] = [
  { displayContent: "听辨七和弦", displayLabel: "点击播放按钮聆听", question: "请选择你听到的七和弦类型：", options: ["大七和弦", "小七和弦", "属七和弦", "半减七和弦", "减七和弦"], correctAnswer: "大七和弦" },
  { displayContent: "听辨七和弦", displayLabel: "点击播放按钮聆听", question: "请选择你听到的七和弦类型：", options: ["大七和弦", "小七和弦", "属七和弦", "半减七和弦", "减七和弦"], correctAnswer: "小七和弦" },
  { displayContent: "听辨七和弦", displayLabel: "点击播放按钮聆听", question: "请选择你听到的七和弦类型：", options: ["大七和弦", "小七和弦", "属七和弦", "半减七和弦", "减七和弦"], correctAnswer: "属七和弦" },
  { displayContent: "听辨七和弦", displayLabel: "点击播放按钮聆听", question: "请选择你听到的七和弦类型：", options: ["大七和弦", "小七和弦", "属七和弦", "半减七和弦", "减七和弦"], correctAnswer: "半减七和弦" },
  { displayContent: "听辨七和弦", displayLabel: "点击播放按钮聆听", question: "请选择你听到的七和弦类型：", options: ["大七和弦", "小七和弦", "属七和弦", "半减七和弦", "减七和弦"], correctAnswer: "小七和弦" },
]

// 和弦辨认题库（综合）- 不显示具体和弦，只显示播放提示
const chordQuestions: ExerciseQuestion[] = [
  { displayContent: "听辨和弦", displayLabel: "点击播放按钮聆听", question: "请选择你听到的和弦：", options: ["C大三和弦", "C小三和弦", "C增三和弦", "C减三和弦"], correctAnswer: "C大三和弦" },
  { displayContent: "听辨和弦", displayLabel: "点击播放按钮聆听", question: "请选择你听到的和弦：", options: ["A大三和弦", "A小三和弦", "Am7", "Amaj7"], correctAnswer: "A小三和弦" },
  { displayContent: "听辨和弦", displayLabel: "点击播放按钮聆听", question: "请选择你听到的和弦：", options: ["G大三和弦", "G小三和弦", "G7", "Gmaj7"], correctAnswer: "G大三和弦" },
  { displayContent: "听辨和弦", displayLabel: "点击播放按钮聆听", question: "请选择你听到的和弦：", options: ["D大三和弦", "D小三和弦", "Dm7", "D7"], correctAnswer: "D小三和弦" },
  { displayContent: "听辨和弦", displayLabel: "点击播放按钮聆听", question: "请选择你听到的和弦：", options: ["F大三和弦", "F小三和弦", "Fmaj7", "F7"], correctAnswer: "F大三和弦" },
]

// 和弦转位辨认题库 - 不显示具体和弦音，只显示播放提示
const chordInversionQuestions: ExerciseQuestion[] = [
  { displayContent: "听辨转位", displayLabel: "点击播放按钮聆听", question: "请选择该和弦的转位：", options: ["原位", "第一转位", "第二转位"], correctAnswer: "第一转位" },
  { displayContent: "听辨转位", displayLabel: "点击播放按钮聆听", question: "请选择该和弦的转位：", options: ["原位", "第一转位", "第二转位"], correctAnswer: "第二转位" },
  { displayContent: "听辨转位", displayLabel: "点击播放按钮聆听", question: "请选择该和弦的转位：", options: ["原位", "第一转位", "第二转位"], correctAnswer: "原位" },
  { displayContent: "听辨转位", displayLabel: "点击播放按钮聆听", question: "请选择该和弦的转位：", options: ["原位", "第一转位", "第二转位"], correctAnswer: "第一转位" },
  { displayContent: "听辨转位", displayLabel: "点击播放按钮聆听", question: "请选择该和弦的转位：", options: ["原位", "第一转位", "第二转位"], correctAnswer: "第二转位" },
]

// 调式辨认题库 - 不显示具体调式，只显示播放提示
const modeQuestions: ExerciseQuestion[] = [
  { displayContent: "听辨调式", displayLabel: "点击播放按钮聆听", question: "请选择你听到的调式：", options: ["C大调", "A小调", "G大调", "E小调"], correctAnswer: "C大调" },
  { displayContent: "听辨调式", displayLabel: "点击播放按钮聆听", question: "请选择你听到的调式：", options: ["C大调", "A小调", "G大调", "E小调"], correctAnswer: "A小调" },
  { displayContent: "听辨调式", displayLabel: "点击播放按钮聆听", question: "请选择你听到的调式：", options: ["C大调", "D大调", "G大调", "F大调"], correctAnswer: "G大调" },
  { displayContent: "听辨调式", displayLabel: "点击播放按钮聆听", question: "请选择你听到的调式：", options: ["D大调", "D小调", "A小调", "E小调"], correctAnswer: "D小调" },
  { displayContent: "听辨调式", displayLabel: "点击播放按钮聆听", question: "请选择你听到的调式：", options: ["C大调", "F大调", "Bb大调", "G大调"], correctAnswer: "F大调" },
]

// 节奏辨认题库 - 不显示具体节奏型，只显示播放提示
const rhythmHearQuestions: ExerciseQuestion[] = [
  { displayContent: "听辨节奏", displayLabel: "点击播放按钮聆听", question: "请选择你听到的节奏型：", options: ["四分音符×4", "二分音符×2", "八分音符×8", "全音符×1"], correctAnswer: "四分音符×4" },
  { displayContent: "听辨节奏", displayLabel: "点击播放按钮聆听", question: "请选择你听到的节奏型：", options: ["八分×4 + 四分×1", "四分×2 + 二分×1", "十六分×4 + 八分×2", "附点四分 + 八分"], correctAnswer: "八分×4 + 四分×1" },
  { displayContent: "听辨节奏", displayLabel: "点击播放按钮聆听", question: "请选择你听到的节奏型：", options: ["附点四分 + 八分 + 四分", "四分×3", "二分 + 四分", "八分×4 + 四分"], correctAnswer: "附点四分 + 八分 + 四分" },
  { displayContent: "听辨节奏", displayLabel: "点击播放按钮聆听", question: "请选择你听到的节奏型：", options: ["十六分×16", "八分×8", "四分×4", "三连音×4"], correctAnswer: "十六分×16" },
  { displayContent: "听辨节奏", displayLabel: "点击播放按钮聆听", question: "请选择你听到的节奏型：", options: ["二分 + 四分×2", "全音符", "四分×4", "附点二分 + 四分"], correctAnswer: "二分 + 四分×2" },
]

// 音程比较题库 - 保留A vs B显示（用户需要比较两个音程）
const intervalCompareQuestions: ExerciseQuestion[] = [
  { displayContent: "A vs B", displayLabel: "比较两个音程", question: "哪个音程更大？", options: ["A 更大", "B 更大", "一样大"], correctAnswer: "B 更大" },
  { displayContent: "A vs B", displayLabel: "比较两个音程", question: "哪个音程更大？", options: ["A 更大", "B 更大", "一样大"], correctAnswer: "A 更大" },
  { displayContent: "A vs B", displayLabel: "比较两个音程", question: "哪个音程更大？", options: ["A 更大", "B 更大", "一样大"], correctAnswer: "一样大" },
]

// 音程辨认题库 - 不显示具体音程，只显示播放提示
const intervalIdentifyQuestions: ExerciseQuestion[] = [
  { displayContent: "听辨音程", displayLabel: "点击播放按钮聆听", question: "请辨认这个音程：", options: ["小二度", "大二度", "小三度", "大三度"], correctAnswer: "小二度" },
  { displayContent: "听辨音程", displayLabel: "点击播放按钮聆听", question: "请辨认这个音程：", options: ["纯五度", "小六度", "大六度", "小七度"], correctAnswer: "大六度" },
  { displayContent: "听辨音程", displayLabel: "点击播放按钮聆听", question: "请辨认这个音程：", options: ["大七度", "小七度", "纯八度", "增七度"], correctAnswer: "纯八度" },
]

// 节奏训练题库
const rhythmQuestions: ExerciseQuestion[] = [
  { displayContent: "♩ ♩ ♩ ♩", displayLabel: "打出这个节奏", question: "请跟随节奏打拍：", options: ["正确", "太快", "太慢", "节奏不稳"], correctAnswer: "正确" },
  { displayContent: "♫ ♫ ♩ ♩", displayLabel: "打出这个节奏", question: "请跟随节奏打拍：", options: ["正确", "太快", "太慢", "节奏不稳"], correctAnswer: "正确" },
]

// 根据练习ID获取对应题库
export function getExerciseQuestions(exerciseId: string): ExerciseQuestion[] {
  const questionMap: Record<string, ExerciseQuestion[]> = {
    "single-note": singleNoteQuestions,
    "interval": intervalQuestions,
    "chord": chordQuestions,
    "triad": triadQuestions,
    "seventh-chord": seventhChordQuestions,
    "chord-inversion": chordInversionQuestions,
    "mode": modeQuestions,
    "rhythm-hear": rhythmHearQuestions,
    "interval-compare": intervalCompareQuestions,
    "interval-identify": intervalIdentifyQuestions,
    "quarter-rhythm": rhythmQuestions,
    "eighth-rhythm": rhythmQuestions,
    "sixteenth-rhythm": rhythmQuestions,
    "syncopation": rhythmQuestions,
    "triplet": rhythmQuestions,
    "compound-rhythm": rhythmQuestions,
  }
  
  return questionMap[exerciseId] || singleNoteQuestions
}

// 随机获取一道题
export function getRandomQuestion(exerciseId: string): ExerciseQuestion {
  const questions = getExerciseQuestions(exerciseId)
  return questions[Math.floor(Math.random() * questions.length)]
}

// 获取练习标题
export function getExerciseTitle(exerciseId: string): string {
  const titles: Record<string, string> = {
    "single-note": "单音辨认",
    "interval": "音程听辨",
    "chord": "和弦辨认",
    "mode": "调式辨认",
    "rhythm-hear": "节奏辨认",
    "melody-dictation": "旋律听写",
    "single-sing": "单音视唱",
    "interval-sing": "音程构唱",
    "melody-sing": "旋律视唱",
    "rhythm-sing": "节奏视唱",
    "quarter-rhythm": "四分音符节奏",
    "eighth-rhythm": "八分音符节奏",
    "sixteenth-rhythm": "十六分音符节奏",
    "syncopation": "切分节奏",
    "triplet": "三连音",
    "compound-rhythm": "复合节奏",
    "interval-compare": "音程比较",
    "interval-identify": "音程辨认",
    "interval-construct": "音程构唱",
    "triad": "三和弦辨认",
    "seventh-chord": "七和弦辨认",
    "chord-inversion": "和弦转位辨认",
  }
  return titles[exerciseId] || "练习"
}

// 获取练习模式
export function getExerciseMode(exerciseId: string): "multipleChoice" | "keyboardInput" | "sightSinging" {
  if (exerciseId.includes("sing")) return "sightSinging"
  if (exerciseId.includes("dictation") || exerciseId.includes("write")) return "keyboardInput"
  return "multipleChoice"
}
