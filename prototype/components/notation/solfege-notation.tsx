"use client"

interface SolfegeNote {
  number: number // 1-7
  octave: "low" | "middle" | "high"
  accidental?: "sharp" | "flat"
  duration: "whole" | "half" | "quarter" | "eighth" | "sixteenth"
  syllable?: string // Do, Re, Mi...
}

interface SolfegeNotationProps {
  notes: SolfegeNote[]
  highlightIndex?: number
}

export default function SolfegeNotation({ notes, highlightIndex }: SolfegeNotationProps) {
  // 获取唱名
  const getSyllable = (number: number): string => {
    const syllables = ["Do", "Re", "Mi", "Fa", "Sol", "La", "Si"]
    return syllables[number - 1] || ""
  }

  // 获取升降号
  const getAccidentalSymbol = (accidental?: string) => {
    if (accidental === "sharp") return "#"
    if (accidental === "flat") return "b"
    return ""
  }

  // 获取八度标记
  const getOctaveMarker = (octave: string) => {
    if (octave === "high") return "'"
    if (octave === "low") return "."
    return ""
  }

  return (
    <div className="bg-card rounded-2xl p-4 border border-border">
      <div className="text-[11px] text-muted-foreground mb-3 px-1">简谱</div>
      
      <div className="flex items-end gap-6 overflow-x-auto pb-2">
        {notes.map((note, index) => {
          const isHighlighted = highlightIndex === index

          return (
            <div
              key={index}
              className={`flex flex-col items-center min-w-[32px] ${
                isHighlighted ? "text-accent" : "text-foreground"
              }`}
            >
              {/* 高八度点 */}
              {note.octave === "high" && (
                <span className="text-[10px] mb-[-4px]">·</span>
              )}

              {/* 音符数字 */}
              <div className="relative">
                {/* 升降号 */}
                {note.accidental && (
                  <span className="absolute -left-3 top-0 text-[14px]">
                    {getAccidentalSymbol(note.accidental)}
                  </span>
                )}
                <span className="text-[24px] font-bold">{note.number}</span>
              </div>

              {/* 低八度点 */}
              {note.octave === "low" && (
                <span className="text-[10px] mt-[-4px]">·</span>
              )}

              {/* 时值线 */}
              {(note.duration === "eighth" || note.duration === "sixteenth") && (
                <div className={`w-full h-0.5 mt-1 ${
                  isHighlighted ? "bg-accent" : "bg-foreground"
                }`} />
              )}
              {note.duration === "sixteenth" && (
                <div className={`w-full h-0.5 mt-0.5 ${
                  isHighlighted ? "bg-accent" : "bg-foreground"
                }`} />
              )}

              {/* 唱名 */}
              <span className={`text-[11px] mt-2 ${
                isHighlighted ? "text-accent" : "text-muted-foreground"
              }`}>
                {note.syllable || getSyllable(note.number)}
              </span>
            </div>
          )
        })}
      </div>
    </div>
  )
}
