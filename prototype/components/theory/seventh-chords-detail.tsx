"use client"

import { useState } from "react"
import NavBar from "@/components/nav-bar"
import { Play, ChevronDown } from "lucide-react"
import { ChordDiagram } from "@/components/notation/guitar-tab"

interface SeventhChordsDetailProps {
  onBack: () => void
}

// 七和弦类型定义
type SeventhChordType = "maj7" | "m7" | "7" | "m7b5" | "dim7"

// 十二个调
const keys = ["C", "G", "D", "A", "E", "B", "F#", "F", "Bb", "Eb", "Ab", "Db"] as const
type Key = typeof keys[number]

// 每个调的顺阶七和弦
function getDiatonicSeventhChords(key: Key): Array<{ degree: string; name: string; type: SeventhChordType; roman: string }> {
  // 大调顺阶七和弦的级数和类型
  // I: maj7, II: m7, III: m7, IV: maj7, V: 7, VI: m7, VII: m7b5
  const majorScale: Record<Key, string[]> = {
    "C": ["C", "D", "E", "F", "G", "A", "B"],
    "G": ["G", "A", "B", "C", "D", "E", "F#"],
    "D": ["D", "E", "F#", "G", "A", "B", "C#"],
    "A": ["A", "B", "C#", "D", "E", "F#", "G#"],
    "E": ["E", "F#", "G#", "A", "B", "C#", "D#"],
    "B": ["B", "C#", "D#", "E", "F#", "G#", "A#"],
    "F#": ["F#", "G#", "A#", "B", "C#", "D#", "E#"],
    "F": ["F", "G", "A", "Bb", "C", "D", "E"],
    "Bb": ["Bb", "C", "D", "Eb", "F", "G", "A"],
    "Eb": ["Eb", "F", "G", "Ab", "Bb", "C", "D"],
    "Ab": ["Ab", "Bb", "C", "Db", "Eb", "F", "G"],
    "Db": ["Db", "Eb", "F", "Gb", "Ab", "Bb", "C"],
  }
  
  const scale = majorScale[key]
  const types: SeventhChordType[] = ["maj7", "m7", "m7", "maj7", "7", "m7", "m7b5"]
  const romans = ["I", "II", "III", "IV", "V", "VI", "VII"]
  const suffixes = ["maj7", "m7", "m7", "maj7", "7", "m7", "m7b5"]
  
  return scale.map((note, i) => ({
    degree: romans[i],
    name: note + (suffixes[i] === "maj7" ? "maj7" : suffixes[i] === "m7" ? "m7" : suffixes[i] === "7" ? "7" : suffixes[i] === "m7b5" ? "m7b5" : "dim7"),
    type: types[i],
    roman: romans[i] + (suffixes[i] === "maj7" ? "maj7" : suffixes[i] === "m7" ? "m7" : suffixes[i] === "7" ? "7" : suffixes[i])
  }))
}

// 和弦指法数据
const chordFingerings: Record<string, { frets: (number | null)[]; fingers?: (number | null)[] }> = {
  // 大七和弦
  "Cmaj7": { frets: [null, 3, 2, 0, 0, 0], fingers: [null, 3, 2, null, null, null] },
  "Gmaj7": { frets: [3, 2, 0, 0, 0, 2], fingers: [2, 1, null, null, null, 3] },
  "Dmaj7": { frets: [null, null, 0, 2, 2, 2], fingers: [null, null, null, 1, 1, 1] },
  "Amaj7": { frets: [null, 0, 2, 1, 2, 0], fingers: [null, null, 3, 1, 2, null] },
  "Emaj7": { frets: [0, 2, 1, 1, 0, 0], fingers: [null, 3, 1, 2, null, null] },
  "Fmaj7": { frets: [null, null, 3, 2, 1, 0], fingers: [null, null, 3, 2, 1, null] },
  "Bbmaj7": { frets: [null, 1, 3, 2, 3, 1], fingers: [null, 1, 3, 2, 4, 1] },
  "Ebmaj7": { frets: [null, null, 1, 3, 3, 3], fingers: [null, null, 1, 2, 3, 4] },
  
  // 小七和弦
  "Dm7": { frets: [null, null, 0, 2, 1, 1], fingers: [null, null, null, 2, 1, 1] },
  "Em7": { frets: [0, 2, 0, 0, 0, 0], fingers: [null, 2, null, null, null, null] },
  "Am7": { frets: [null, 0, 2, 0, 1, 0], fingers: [null, null, 2, null, 1, null] },
  "Bm7": { frets: [null, 2, 4, 2, 3, 2], fingers: [null, 1, 3, 1, 2, 1] },
  "F#m7": { frets: [2, 4, 2, 2, 2, 2], fingers: [1, 3, 1, 1, 1, 1] },
  "Gm7": { frets: [3, 5, 3, 3, 3, 3], fingers: [1, 3, 1, 1, 1, 1] },
  "Cm7": { frets: [null, 3, 5, 3, 4, 3], fingers: [null, 1, 3, 1, 2, 1] },
  
  // 属七和弦
  "G7": { frets: [3, 2, 0, 0, 0, 1], fingers: [3, 2, null, null, null, 1] },
  "D7": { frets: [null, null, 0, 2, 1, 2], fingers: [null, null, null, 2, 1, 3] },
  "A7": { frets: [null, 0, 2, 0, 2, 0], fingers: [null, null, 2, null, 3, null] },
  "E7": { frets: [0, 2, 0, 1, 0, 0], fingers: [null, 2, null, 1, null, null] },
  "B7": { frets: [null, 2, 1, 2, 0, 2], fingers: [null, 2, 1, 3, null, 4] },
  "C7": { frets: [null, 3, 2, 3, 1, 0], fingers: [null, 3, 2, 4, 1, null] },
  "F7": { frets: [1, 3, 1, 2, 1, 1], fingers: [1, 3, 1, 2, 1, 1] },
  
  // 半减七和弦 (m7b5)
  "Bm7b5": { frets: [null, 2, 3, 2, 3, null], fingers: [null, 1, 2, 1, 3, null] },
  "F#m7b5": { frets: [null, null, 2, 2, 1, 2], fingers: [null, null, 2, 3, 1, 4] },
  "C#m7b5": { frets: [null, 4, 5, 4, 5, null], fingers: [null, 1, 2, 1, 3, null] },
  "G#m7b5": { frets: [null, null, 4, 4, 3, 4], fingers: [null, null, 2, 3, 1, 4] },
  "Em7b5": { frets: [null, null, 2, 3, 3, 3], fingers: [null, null, 1, 2, 3, 4] },
  "Am7b5": { frets: [null, 0, 1, 0, 1, null], fingers: [null, null, 1, null, 2, null] },
  
  // 减七和弦
  "Bdim7": { frets: [null, 2, 3, 1, 3, null], fingers: [null, 2, 3, 1, 4, null] },
  "C#dim7": { frets: [null, 4, 5, 3, 5, null], fingers: [null, 2, 3, 1, 4, null] },
}

// 获取和弦指法，如果没有预设则返回默认
function getChordFingering(chordName: string): { frets: (number | null)[]; fingers?: (number | null)[] } {
  return chordFingerings[chordName] || { frets: [null, null, null, null, null, null] }
}

// 七和弦类型颜色
const typeColors: Record<SeventhChordType, string> = {
  "maj7": "bg-blue-500",
  "m7": "bg-purple-500", 
  "7": "bg-orange-500",
  "m7b5": "bg-amber-600",
  "dim7": "bg-red-500",
}

const typeLabels: Record<SeventhChordType, string> = {
  "maj7": "大七",
  "m7": "小七",
  "7": "属七",
  "m7b5": "半减七",
  "dim7": "减七",
}

export default function SeventhChordsDetail({ onBack }: SeventhChordsDetailProps) {
  const [selectedKey, setSelectedKey] = useState<Key>("C")
  const [showKeyPicker, setShowKeyPicker] = useState(false)
  
  const diatonicChords = getDiatonicSeventhChords(selectedKey)
  
  return (
    <div className="min-h-screen bg-background pb-24">
      <NavBar title="七和弦" showBack onBack={onBack} />

      <div className="px-4 py-4 space-y-4">
        {/* 音频示例 */}
        <div className="bg-card rounded-2xl p-4 border border-border">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-[15px] font-semibold text-foreground">音频示例</p>
              <p className="text-[13px] text-muted-foreground">点击播放七和弦示例</p>
            </div>
            <button className="w-12 h-12 bg-primary rounded-full flex items-center justify-center ios-press">
              <Play className="w-6 h-6 text-primary-foreground" fill="currentColor" />
            </button>
          </div>
        </div>

        {/* 五种七和弦类型 */}
        <div className="bg-card rounded-2xl p-4 border border-border">
          <h3 className="text-[15px] font-semibold text-foreground mb-4">七和弦类型</h3>
          
          <div className="space-y-4">
            {/* 大七和弦 */}
            <div>
              <div className="flex items-center gap-2 mb-2">
                <span className={`w-3 h-3 rounded-full ${typeColors.maj7}`}></span>
                <span className="text-[14px] font-medium text-foreground">大七和弦 (Major 7th)</span>
              </div>
              <p className="text-[13px] text-muted-foreground mb-3">
                大三和弦 + 大七度。声音梦幻、柔美，常用于流行和爵士。记作 maj7 或 △7。
              </p>
              <div className="flex items-center gap-3 overflow-x-auto pb-2">
                <ChordDiagram name="Cmaj7" {...getChordFingering("Cmaj7")} />
                <ChordDiagram name="Fmaj7" {...getChordFingering("Fmaj7")} />
                <ChordDiagram name="Gmaj7" {...getChordFingering("Gmaj7")} />
              </div>
            </div>
            
            {/* 小七和弦 */}
            <div>
              <div className="flex items-center gap-2 mb-2">
                <span className={`w-3 h-3 rounded-full ${typeColors.m7}`}></span>
                <span className="text-[14px] font-medium text-foreground">小七和弦 (Minor 7th)</span>
              </div>
              <p className="text-[13px] text-muted-foreground mb-3">
                小三和弦 + 小七度。声音柔和、忧郁，是最常用的七和弦之一。记作 m7 或 -7。
              </p>
              <div className="flex items-center gap-3 overflow-x-auto pb-2">
                <ChordDiagram name="Am7" {...getChordFingering("Am7")} />
                <ChordDiagram name="Dm7" {...getChordFingering("Dm7")} />
                <ChordDiagram name="Em7" {...getChordFingering("Em7")} />
              </div>
            </div>
            
            {/* 属七和弦 */}
            <div>
              <div className="flex items-center gap-2 mb-2">
                <span className={`w-3 h-3 rounded-full ${typeColors["7"]}`}></span>
                <span className="text-[14px] font-medium text-foreground">属七和弦 (Dominant 7th)</span>
              </div>
              <p className="text-[13px] text-muted-foreground mb-3">
                大三和弦 + 小七度。具有强烈的解决倾向，常用于 V-I 进行。记作 7。
              </p>
              <div className="flex items-center gap-3 overflow-x-auto pb-2">
                <ChordDiagram name="G7" {...getChordFingering("G7")} />
                <ChordDiagram name="D7" {...getChordFingering("D7")} />
                <ChordDiagram name="A7" {...getChordFingering("A7")} />
              </div>
            </div>
            
            {/* 半减七和弦 */}
            <div>
              <div className="flex items-center gap-2 mb-2">
                <span className={`w-3 h-3 rounded-full ${typeColors.m7b5}`}></span>
                <span className="text-[14px] font-medium text-foreground">半减七和弦 (Half-Diminished 7th)</span>
              </div>
              <p className="text-[13px] text-muted-foreground mb-3">
                减三和弦 + 小七度。声音紧张、不稳定，常出现在大调的第七级。记作 m7b5 或 ø7。
              </p>
              <div className="flex items-center gap-3 overflow-x-auto pb-2">
                <ChordDiagram name="Bm7b5" {...getChordFingering("Bm7b5")} />
                <ChordDiagram name="F#m7b5" {...getChordFingering("F#m7b5")} />
              </div>
            </div>
            
            {/* 减七和弦 */}
            <div>
              <div className="flex items-center gap-2 mb-2">
                <span className={`w-3 h-3 rounded-full ${typeColors.dim7}`}></span>
                <span className="text-[14px] font-medium text-foreground">减七和弦 (Diminished 7th)</span>
              </div>
              <p className="text-[13px] text-muted-foreground mb-3">
                减三和弦 + 减七度。全部由小三度叠加构成，声音非常紧张。记作 dim7 或 °7。
              </p>
              <div className="flex items-center gap-3 overflow-x-auto pb-2">
                <ChordDiagram name="Bdim7" {...getChordFingering("Bdim7")} />
              </div>
            </div>
          </div>
        </div>

        {/* 调式选择器和顺阶七和弦 */}
        <div className="bg-card rounded-2xl p-4 border border-border">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-[15px] font-semibold text-foreground">顺阶七和弦</h3>
            
            {/* 调式选择器 */}
            <div className="relative">
              <button 
                onClick={() => setShowKeyPicker(!showKeyPicker)}
                className="flex items-center gap-1 px-3 py-1.5 bg-primary/10 rounded-lg ios-press"
              >
                <span className="text-[15px] font-bold text-primary">{selectedKey} 大调</span>
                <ChevronDown className={`w-4 h-4 text-primary transition-transform ${showKeyPicker ? "rotate-180" : ""}`} />
              </button>
              
              {showKeyPicker && (
                <div className="absolute right-0 top-full mt-2 bg-card rounded-xl border border-border shadow-lg z-50 p-2 min-w-[200px]">
                  <div className="grid grid-cols-4 gap-1">
                    {keys.map((key) => (
                      <button
                        key={key}
                        onClick={() => {
                          setSelectedKey(key)
                          setShowKeyPicker(false)
                        }}
                        className={`py-2 px-3 rounded-lg text-[14px] font-medium transition-colors ${
                          selectedKey === key 
                            ? "bg-primary text-primary-foreground" 
                            : "hover:bg-secondary text-foreground"
                        }`}
                      >
                        {key}
                      </button>
                    ))}
                  </div>
                </div>
              )}
            </div>
          </div>
          
          <p className="text-[13px] text-muted-foreground mb-4">
            {selectedKey} 大调的顺阶七和弦由音阶上的每个音为根音构建：
          </p>
          
          {/* 顺阶七和弦图示 */}
          <div className="space-y-3">
            {/* 级数标签行 */}
            <div className="flex items-center justify-between px-2">
              {diatonicChords.map((chord, index) => (
                <div key={index} className="flex flex-col items-center">
                  <span className={`w-6 h-6 rounded-full flex items-center justify-center text-[10px] font-bold text-white ${typeColors[chord.type]}`}>
                    {chord.degree}
                  </span>
                  <span className="text-[10px] text-muted-foreground mt-1">{typeLabels[chord.type]}</span>
                </div>
              ))}
            </div>
            
            {/* 和弦名称行 */}
            <div className="bg-secondary/50 rounded-xl p-3">
              <div className="flex items-center justify-between">
                {diatonicChords.map((chord, index) => (
                  <div key={index} className="text-center">
                    <span className="text-[13px] font-bold text-foreground">{chord.name}</span>
                  </div>
                ))}
              </div>
            </div>
            
            {/* 和弦图展示 */}
            <div className="flex items-start gap-2 overflow-x-auto pb-2 pt-2">
              {diatonicChords.slice(0, 4).map((chord, index) => {
                const fingering = getChordFingering(chord.name)
                return (
                  <div key={index} className="flex flex-col items-center">
                    <ChordDiagram name={chord.name} {...fingering} />
                    <span className={`text-[10px] mt-1 px-2 py-0.5 rounded-full text-white ${typeColors[chord.type]}`}>
                      {chord.degree}
                    </span>
                  </div>
                )
              })}
            </div>
            
            <div className="flex items-start gap-2 overflow-x-auto pb-2">
              {diatonicChords.slice(4).map((chord, index) => {
                const fingering = getChordFingering(chord.name)
                return (
                  <div key={index} className="flex flex-col items-center">
                    <ChordDiagram name={chord.name} {...fingering} />
                    <span className={`text-[10px] mt-1 px-2 py-0.5 rounded-full text-white ${typeColors[chord.type]}`}>
                      {chord.degree}
                    </span>
                  </div>
                )
              })}
            </div>
          </div>
          
          {/* 和弦功能说明 */}
          <div className="mt-4 p-3 bg-secondary/30 rounded-xl">
            <p className="text-[13px] text-foreground font-medium mb-2">和弦功能</p>
            <div className="space-y-1 text-[12px] text-muted-foreground">
              <p><span className="font-medium text-foreground">I / IV</span> - 主功能和弦（大七和弦），稳定</p>
              <p><span className="font-medium text-foreground">II / III / VI</span> - 下属/副功能和弦（小七和弦）</p>
              <p><span className="font-medium text-foreground">V</span> - 属功能和弦（属七和弦），需要解决</p>
              <p><span className="font-medium text-foreground">VII</span> - 导和弦（半减七和弦），强烈倾向主和弦</p>
            </div>
          </div>
        </div>

        {/* 常用七和弦进行 */}
        <div className="bg-card rounded-2xl p-4 border border-border">
          <h3 className="text-[15px] font-semibold text-foreground mb-3">常用七和弦进行</h3>
          
          <div className="space-y-3">
            <div className="p-3 bg-secondary/30 rounded-xl">
              <p className="text-[13px] font-medium text-foreground">II-V-I 进行 ({selectedKey}大调)</p>
              <div className="flex items-center gap-2 mt-2">
                {[diatonicChords[1], diatonicChords[4], diatonicChords[0]].map((chord, i) => (
                  <div key={i} className="flex items-center">
                    <span className={`px-2 py-1 rounded text-[12px] font-bold text-white ${typeColors[chord.type]}`}>
                      {chord.name}
                    </span>
                    {i < 2 && <span className="mx-2 text-muted-foreground">→</span>}
                  </div>
                ))}
              </div>
              <p className="text-[11px] text-muted-foreground mt-2">爵士乐中最重要的和弦进行</p>
            </div>
            
            <div className="p-3 bg-secondary/30 rounded-xl">
              <p className="text-[13px] font-medium text-foreground">I-VI-II-V 进行 ({selectedKey}大调)</p>
              <div className="flex items-center gap-2 mt-2 flex-wrap">
                {[diatonicChords[0], diatonicChords[5], diatonicChords[1], diatonicChords[4]].map((chord, i) => (
                  <div key={i} className="flex items-center">
                    <span className={`px-2 py-1 rounded text-[12px] font-bold text-white ${typeColors[chord.type]}`}>
                      {chord.name}
                    </span>
                    {i < 3 && <span className="mx-1 text-muted-foreground">→</span>}
                  </div>
                ))}
              </div>
              <p className="text-[11px] text-muted-foreground mt-2">流行经典循环进行</p>
            </div>
          </div>
        </div>

        {/* 关联练习 */}
        <div className="bg-card rounded-2xl p-4 border border-border">
          <h3 className="text-[15px] font-semibold text-foreground mb-2">关联练习</h3>
          <button className="w-full py-3 bg-primary text-primary-foreground rounded-xl text-[15px] font-medium ios-press">
            开始七和弦听辨练习
          </button>
        </div>
      </div>
    </div>
  )
}
