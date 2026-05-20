"use client"

import NavBar from "@/components/nav-bar"
import { Play } from "lucide-react"
import { ChordDiagram } from "@/components/notation/guitar-tab"
import CircleOfFifths, { MiniCircleOfFifths } from "./circle-of-fifths"

interface TheoryDetailProps {
  topicId: string
  onBack: () => void
}

// 简谱展示组件
function SolfegeDisplay({ notes, labels }: { notes: string[]; labels?: string[] }) {
  return (
    <div className="bg-secondary/30 rounded-xl p-4 mt-3">
      <div className="flex items-center justify-center gap-6">
        {notes.map((note, index) => (
          <div key={index} className="flex flex-col items-center">
            <span className="text-[28px] font-bold text-primary">{note}</span>
            {labels && labels[index] && (
              <span className="text-[11px] text-muted-foreground mt-1">{labels[index]}</span>
            )}
          </div>
        ))}
      </div>
    </div>
  )
}

// 音程图示组件
function IntervalDisplay({ interval, notes, semitones }: { interval: string; notes: string; semitones: number }) {
  return (
    <div className="flex items-center justify-between bg-secondary/30 rounded-xl p-3 mt-2">
      <div className="flex items-center gap-3">
        <div className="w-10 h-10 rounded-full bg-primary/10 flex items-center justify-center">
          <span className="text-[14px] font-bold text-primary">{semitones}</span>
        </div>
        <div>
          <p className="text-[14px] font-medium text-foreground">{interval}</p>
          <p className="text-[12px] text-muted-foreground">{notes}</p>
        </div>
      </div>
      <div className="text-[12px] text-muted-foreground">{semitones}个半音</div>
    </div>
  )
}

// 吉他指板音程图
function GuitarFretboardInterval({ title }: { title: string }) {
  return (
    <div className="bg-secondary/30 rounded-xl p-4 mt-3">
      <p className="text-[12px] text-muted-foreground mb-2">{title}</p>
      <svg viewBox="0 0 280 60" className="w-full">
        {/* 六条弦 */}
        {[0, 1, 2, 3, 4, 5].map((i) => (
          <line key={i} x1="20" y1={10 + i * 8} x2="260" y2={10 + i * 8} stroke="#94A3B8" strokeWidth={0.5 + i * 0.1} />
        ))}
        {/* 品丝 */}
        {[0, 1, 2, 3, 4, 5].map((i) => (
          <line key={i} x1={20 + i * 48} y1="10" x2={20 + i * 48} y2="50" stroke="#94A3B8" strokeWidth="1" />
        ))}
        {/* 品位标记 */}
        <circle cx="116" cy="52" r="2" fill="#94A3B8" />
        {/* 半音标记 */}
        <g>
          <circle cx="44" cy="42" r="6" className="fill-primary" />
          <text x="44" y="45" textAnchor="middle" className="fill-white text-[8px]">1</text>
        </g>
        <g>
          <circle cx="92" cy="42" r="6" className="fill-accent" />
          <text x="92" y="45" textAnchor="middle" className="fill-white text-[8px]">2</text>
        </g>
        {/* 说明 */}
        <text x="150" y="45" className="fill-muted-foreground text-[9px]">相邻品位 = 半音</text>
      </svg>
    </div>
  )
}

// 获取知识点详情（带图形）
function getTopicDetail(topicId: string) {
  const details: Record<string, {
    title: string
    sections: Array<{
      title: string
      content: string
      graphic?: React.ReactNode
    }>
    showCircleOfFifths?: boolean
  }> = {
    "notes": {
      title: "认识音符",
      sections: [
        {
          title: "音符的构成",
          content: "音符由三个部分组成：符头、符干和符尾。符头决定音高位置，符干和符尾决定音符时值。",
          graphic: (
            <div className="bg-secondary/30 rounded-xl p-4 mt-3">
              <div className="flex items-center justify-around">
                <div className="text-center">
                  <span className="text-[32px]">𝅝</span>
                  <p className="text-[11px] text-muted-foreground">全音符</p>
                </div>
                <div className="text-center">
                  <span className="text-[32px]">𝅗𝅥</span>
                  <p className="text-[11px] text-muted-foreground">二分音符</p>
                </div>
                <div className="text-center">
                  <span className="text-[32px]">♩</span>
                  <p className="text-[11px] text-muted-foreground">四分音符</p>
                </div>
                <div className="text-center">
                  <span className="text-[32px]">♪</span>
                  <p className="text-[11px] text-muted-foreground">八分音符</p>
                </div>
              </div>
            </div>
          ),
        },
        {
          title: "时值关系",
          content: "每种音符的时值是前一种的一半。在吉他中最常用四分音符和八分音符。",
          graphic: <SolfegeDisplay notes={["4", "2", "1", "½"]} labels={["全音符", "二分", "四分", "八分"]} />,
        },
      ],
    },
    "pitch-names": {
      title: "音名与唱名",
      sections: [
        {
          title: "音名系统 (C-D-E-F-G-A-B)",
          content: "西方音乐使用七个字母表示音名，对应钢琴白键。这七个音构成一个八度。",
          graphic: <SolfegeDisplay notes={["C", "D", "E", "F", "G", "A", "B"]} />,
        },
        {
          title: "唱名系统 (Do-Re-Mi)",
          content: "唱名帮助我们更容易地视唱乐谱。首调唱名法中主音唱Do，更适合吉他弹唱。",
          graphic: <SolfegeDisplay notes={["1", "2", "3", "4", "5", "6", "7"]} labels={["do", "re", "mi", "fa", "sol", "la", "si"]} />,
        },
      ],
    },
    "whole-half": {
      title: "全音与半音",
      sections: [
        {
          title: "半音的定义",
          content: "半音是音程中最小的单位。在吉他上，相邻两个品位之间就是一个半音。",
          graphic: <GuitarFretboardInterval title="吉他指板上的半音" />,
        },
        {
          title: "自然音阶中的全半音",
          content: "在自然音阶中，E-F 和 B-C 之间是半音，其他相邻音之间都是全音。",
          graphic: (
            <div className="bg-secondary/30 rounded-xl p-4 mt-3">
              <div className="flex items-center justify-center gap-1 flex-wrap">
                {["C", "—", "D", "—", "E", "·", "F", "—", "G", "—", "A", "—", "B", "·", "C"].map((item, i) => (
                  <span key={i} className={`text-[16px] ${item === "·" ? "text-destructive font-bold" : item === "—" ? "text-muted-foreground" : "text-primary font-bold"}`}>
                    {item === "·" ? "½" : item === "—" ? "全" : item}
                  </span>
                ))}
              </div>
              <p className="text-[11px] text-muted-foreground text-center mt-2">红色标记为半音位置 (E-F, B-C)</p>
            </div>
          ),
        },
      ],
    },
    "triads": {
      title: "三和弦",
      sections: [
        {
          title: "大三和弦",
          content: "由根音、大三度和纯五度构成。声音明亮、稳定。",
          graphic: (
            <div className="flex items-center gap-4 mt-3 overflow-x-auto pb-2">
              <ChordDiagram name="C" frets={[null, 3, 2, 0, 1, 0]} fingers={[null, 3, 2, null, 1, null]} />
              <ChordDiagram name="G" frets={[3, 2, 0, 0, 0, 3]} fingers={[2, 1, null, null, null, 3]} />
              <ChordDiagram name="D" frets={[null, null, 0, 2, 3, 2]} fingers={[null, null, null, 1, 3, 2]} />
            </div>
          ),
        },
        {
          title: "小三和弦",
          content: "由根音、小三度和纯五度构成。声音柔和、略带忧伤。",
          graphic: (
            <div className="flex items-center gap-4 mt-3 overflow-x-auto pb-2">
              <ChordDiagram name="Am" frets={[null, 0, 2, 2, 1, 0]} fingers={[null, null, 2, 3, 1, null]} />
              <ChordDiagram name="Em" frets={[0, 2, 2, 0, 0, 0]} fingers={[null, 2, 3, null, null, null]} />
              <ChordDiagram name="Dm" frets={[null, null, 0, 2, 3, 1]} fingers={[null, null, null, 2, 3, 1]} />
            </div>
          ),
        },
      ],
    },
    "seventh-chords": {
      title: "七和弦",
      sections: [
        {
          title: "属七和弦 (Dominant 7th)",
          content: "由大三和弦加小七度构成。具有强烈的解决倾向，常用于V-I进行。",
          graphic: (
            <div className="flex items-center gap-4 mt-3 overflow-x-auto pb-2">
              <ChordDiagram name="G7" frets={[3, 2, 0, 0, 0, 1]} fingers={[3, 2, null, null, null, 1]} />
              <ChordDiagram name="D7" frets={[null, null, 0, 2, 1, 2]} fingers={[null, null, null, 2, 1, 3]} />
              <ChordDiagram name="A7" frets={[null, 0, 2, 0, 2, 0]} fingers={[null, null, 2, null, 3, null]} />
            </div>
          ),
        },
        {
          title: "大七和弦 (Major 7th)",
          content: "由大三和弦加大七度构成。声音梦幻、柔美，常用于流行和爵士。",
          graphic: (
            <div className="flex items-center gap-4 mt-3 overflow-x-auto pb-2">
              <ChordDiagram name="Cmaj7" frets={[null, 3, 2, 0, 0, 0]} fingers={[null, 3, 2, null, null, null]} />
              <ChordDiagram name="Fmaj7" frets={[null, null, 3, 2, 1, 0]} fingers={[null, null, 3, 2, 1, null]} />
            </div>
          ),
        },
      ],
    },
    "guitar-chords": {
      title: "吉他和弦指法",
      sections: [
        {
          title: "常用开放和弦",
          content: "开放和弦使用空弦，音色丰富，是民谣吉他最常用的和弦形式。",
          graphic: (
            <div className="flex items-center gap-3 mt-3 overflow-x-auto pb-2">
              <ChordDiagram name="C" frets={[null, 3, 2, 0, 1, 0]} fingers={[null, 3, 2, null, 1, null]} />
              <ChordDiagram name="G" frets={[3, 2, 0, 0, 0, 3]} fingers={[2, 1, null, null, null, 3]} />
              <ChordDiagram name="Am" frets={[null, 0, 2, 2, 1, 0]} fingers={[null, null, 2, 3, 1, null]} />
              <ChordDiagram name="Em" frets={[0, 2, 2, 0, 0, 0]} fingers={[null, 2, 3, null, null, null]} />
            </div>
          ),
        },
        {
          title: "F和弦 (横按和弦)",
          content: "F和弦需要食指横按，是初学者的难点。掌握后可移动到任意把位。",
          graphic: (
            <div className="flex items-center gap-4 mt-3">
              <ChordDiagram name="F" frets={[1, 1, 2, 3, 3, 1]} fingers={[1, 1, 2, 3, 4, 1]} />
              <div className="flex-1 text-[13px] text-muted-foreground">
                <p>食指横按1品全部6弦</p>
                <p className="mt-1">中指按3弦2品</p>
                <p className="mt-1">无名指和小指按4、5弦3品</p>
              </div>
            </div>
          ),
        },
      ],
    },
    "interval-concept": {
      title: "音程的概念",
      sections: [
        {
          title: "什么是音程",
          content: "音程是两个音之间的音高距离，用'度'来表示。同时包含度数和性质两个要素。",
        },
        {
          title: "常见音程",
          content: "以下是吉他中常用的音程及其半音数量：",
          graphic: (
            <div className="space-y-2 mt-3">
              <IntervalDisplay interval="小二度" notes="E → F" semitones={1} />
              <IntervalDisplay interval="大二度" notes="C → D" semitones={2} />
              <IntervalDisplay interval="小三度" notes="A → C" semitones={3} />
              <IntervalDisplay interval="大三度" notes="C → E" semitones={4} />
              <IntervalDisplay interval="纯四度" notes="C → F" semitones={5} />
              <IntervalDisplay interval="纯五度" notes="C → G" semitones={7} />
            </div>
          ),
        },
      ],
    },
    "major-scale": {
      title: "大调音阶",
      showCircleOfFifths: true,
      sections: [
        {
          title: "自然大调结构",
          content: "大调音阶由'全全半全全全半'的音程结构组成，是最基础的音阶。",
          graphic: (
            <div className="bg-secondary/30 rounded-xl p-4 mt-3">
              <div className="flex items-center justify-center gap-2">
                {["C", "D", "E", "F", "G", "A", "B", "C"].map((note, i) => (
                  <div key={i} className="flex items-center">
                    <div className="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center">
                      <span className="text-[14px] font-bold text-primary">{note}</span>
                    </div>
                    {i < 7 && (
                      <span className="text-[10px] text-muted-foreground mx-1">
                        {[0, 1, 3, 4, 5, 6].includes(i) ? "全" : "半"}
                      </span>
                    )}
                  </div>
                ))}
              </div>
            </div>
          ),
        },
        {
          title: "常用大调",
          content: "C大调无升降号最易学习，G大调和D大调是吉他常用调。",
        },
      ],
    },
    "mode-relation": {
      title: "调式关系",
      showCircleOfFifths: true,
      sections: [
        {
          title: "关系大小调",
          content: "每个大调都有一个关系小调，它们使用相同的音符，但主音不同。例如C大调的关系小调是A小调。",
        },
        {
          title: "五度圈",
          content: "五度圈展示了所有大调和小调之间的关系，是理解调性的重要工具。",
        },
      ],
    },
  }

  return details[topicId] || {
    title: "知识点",
    sections: [{ title: "内容", content: "该知识点的详细内容正在完善中..." }],
  }
}

export default function TheoryDetail({ topicId, onBack }: TheoryDetailProps) {
  const detail = getTopicDetail(topicId)

  return (
    <div className="min-h-screen bg-background pb-24">
      <NavBar title={detail.title} showBack onBack={onBack} />

      <div className="px-4 py-4 space-y-4">
        {/* 示例播放卡片 */}
        <div className="bg-card rounded-2xl p-4 border border-border">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-[15px] font-semibold text-foreground">音频示例</p>
              <p className="text-[13px] text-muted-foreground">点击播放相关示例</p>
            </div>
            <button className="w-12 h-12 bg-primary rounded-full flex items-center justify-center ios-press">
              <Play className="w-6 h-6 text-primary-foreground" fill="currentColor" />
            </button>
          </div>
        </div>

        {/* 五度圈（如果需要） */}
        {detail.showCircleOfFifths && <CircleOfFifths />}

        {/* 内容区域 */}
        {detail.sections.map((section, index) => (
          <div key={index} className="bg-card rounded-2xl p-4 border border-border">
            <h3 className="text-[15px] font-semibold text-foreground mb-2">
              {section.title}
            </h3>
            <p className="text-[15px] text-muted-foreground leading-relaxed">
              {section.content}
            </p>
            {section.graphic}
          </div>
        ))}

        {/* 关联练习 */}
        <div className="bg-card rounded-2xl p-4 border border-border">
          <h3 className="text-[15px] font-semibold text-foreground mb-2">
            关联练习
          </h3>
          <button className="w-full py-3 bg-primary text-primary-foreground rounded-xl text-[15px] font-medium ios-press">
            开始练习
          </button>
        </div>
      </div>
    </div>
  )
}
