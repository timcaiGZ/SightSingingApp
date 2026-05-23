"use client"

interface Note {
  pitch: string // C, D, E, F, G, A, B
  octave: number // 3, 4, 5
  accidental?: "sharp" | "flat" | "natural"
  duration: "whole" | "half" | "quarter" | "eighth" | "sixteenth"
}

interface StaffNotationProps {
  notes: Note[]
  clef?: "treble" | "bass"
  timeSignature?: { upper: number; lower: number }
  keySignature?: string
  highlightIndex?: number
}

export default function StaffNotation({
  notes,
  clef = "treble",
  timeSignature = { upper: 4, lower: 4 },
  highlightIndex,
}: StaffNotationProps) {
  // 五线谱线位置 (从下到上: E4, G4, B4, D5, F5)
  const linePositions = [0, 1, 2, 3, 4]
  
  // 计算音符在五线谱上的位置 (从C4开始，每个位置间隔半音)
  const getNotePosition = (pitch: string, octave: number): number => {
    const pitchMap: Record<string, number> = {
      C: 0, D: 1, E: 2, F: 3, G: 4, A: 5, B: 6
    }
    const basePosition = pitchMap[pitch] + (octave - 4) * 7
    // E4 在第一线上，位置为2
    return basePosition - 2
  }

  // 获取升降号符号
  const getAccidentalSymbol = (accidental?: string) => {
    if (accidental === "sharp") return "#"
    if (accidental === "flat") return "b"
    if (accidental === "natural") return "n"
    return ""
  }

  return (
    <div className="bg-card rounded-2xl p-4 border border-border overflow-x-auto">
      <svg
        viewBox="0 0 400 100"
        className="w-full h-auto min-w-[300px]"
        preserveAspectRatio="xMidYMid meet"
      >
        {/* 谱号 */}
        <text
          x="15"
          y="58"
          className="fill-foreground"
          style={{ fontSize: "40px", fontFamily: "serif" }}
        >
          {clef === "treble" ? "\u{1D11E}" : "\u{1D122}"}
        </text>

        {/* 拍号 */}
        <text x="50" y="45" className="fill-foreground text-[16px] font-bold">
          {timeSignature.upper}
        </text>
        <text x="50" y="65" className="fill-foreground text-[16px] font-bold">
          {timeSignature.lower}
        </text>

        {/* 五条线 */}
        {linePositions.map((_, index) => (
          <line
            key={index}
            x1="10"
            y1={30 + index * 10}
            x2="390"
            y2={30 + index * 10}
            stroke="currentColor"
            strokeWidth="1"
            className="text-muted-foreground/50"
          />
        ))}

        {/* 音符 */}
        {notes.map((note, index) => {
          const position = getNotePosition(note.pitch, note.octave)
          const y = 70 - position * 5 // 从底部计算位置
          const x = 80 + index * 50
          const isHighlighted = highlightIndex === index

          return (
            <g key={index}>
              {/* 升降号 */}
              {note.accidental && (
                <text
                  x={x - 12}
                  y={y + 4}
                  className={`text-[14px] ${isHighlighted ? "fill-accent" : "fill-foreground"}`}
                >
                  {getAccidentalSymbol(note.accidental)}
                </text>
              )}

              {/* 符头 */}
              <ellipse
                cx={x}
                cy={y}
                rx="6"
                ry="4.5"
                className={isHighlighted ? "fill-accent" : "fill-foreground"}
                transform={`rotate(-15 ${x} ${y})`}
              />

              {/* 符干 */}
              {note.duration !== "whole" && (
                <line
                  x1={x + 5}
                  y1={y}
                  x2={x + 5}
                  y2={y - 28}
                  stroke="currentColor"
                  strokeWidth="1.5"
                  className={isHighlighted ? "text-accent" : "text-foreground"}
                />
              )}

              {/* 符尾 (八分音符及更短) */}
              {(note.duration === "eighth" || note.duration === "sixteenth") && (
                <path
                  d={`M ${x + 5} ${y - 28} Q ${x + 15} ${y - 20} ${x + 10} ${y - 10}`}
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="1.5"
                  className={isHighlighted ? "text-accent" : "text-foreground"}
                />
              )}

              {/* 加线 (如果需要) */}
              {position < 0 && (
                <line
                  x1={x - 10}
                  y1={70}
                  x2={x + 10}
                  y2={70}
                  stroke="currentColor"
                  strokeWidth="1"
                  className="text-muted-foreground/50"
                />
              )}
              {position > 8 && (
                <line
                  x1={x - 10}
                  y1={30}
                  x2={x + 10}
                  y2={30}
                  stroke="currentColor"
                  strokeWidth="1"
                  className="text-muted-foreground/50"
                />
              )}

              {/* 音名标注 */}
              <text
                x={x}
                y={y + 25}
                textAnchor="middle"
                className={`text-[10px] ${isHighlighted ? "fill-accent" : "fill-muted-foreground"}`}
              >
                {note.pitch}{note.accidental ? getAccidentalSymbol(note.accidental) : ""}
              </text>
            </g>
          )
        })}
      </svg>
    </div>
  )
}
