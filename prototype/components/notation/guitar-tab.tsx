"use client"

interface TabNote {
  string: number // 1-6, 1=最细高音弦
  fret: number // 0=空弦, 1-24=品位
  technique?: "hammer" | "pull" | "slide" | "bend" | "vibrato" | "mute"
}

interface GuitarTabProps {
  notes: TabNote[][]  // 每组代表同时演奏的音
  highlightIndex?: number
}

export default function GuitarTab({ notes, highlightIndex }: GuitarTabProps) {
  const stringLabels = ["e", "B", "G", "D", "A", "E"] // 从高到低
  const stringNumbers = [1, 2, 3, 4, 5, 6]

  return (
    <div className="bg-card rounded-2xl p-4 border border-border overflow-x-auto">
      <div className="text-[11px] text-muted-foreground mb-2 px-1">六线谱</div>
      
      <svg
        viewBox="0 0 400 90"
        className="w-full h-auto min-w-[300px]"
        preserveAspectRatio="xMidYMid meet"
      >
        {/* 弦标签 */}
        {stringNumbers.map((num, index) => (
          <text
            key={num}
            x="8"
            y={18 + index * 12}
            className="fill-muted-foreground text-[10px]"
          >
            {num}
          </text>
        ))}

        {/* 音名标签 */}
        {stringLabels.map((label, index) => (
          <text
            key={label}
            x="22"
            y={18 + index * 12}
            className="fill-muted-foreground text-[10px]"
          >
            {label}
          </text>
        ))}

        {/* 六条弦 */}
        {[0, 1, 2, 3, 4, 5].map((index) => (
          <line
            key={index}
            x1="35"
            y1={15 + index * 12}
            x2="395"
            y2={15 + index * 12}
            stroke="currentColor"
            strokeWidth={1 + index * 0.15}
            className="text-muted-foreground/40"
          />
        ))}

        {/* 品位标记 */}
        {notes.map((chord, chordIndex) => {
          const x = 60 + chordIndex * 50
          const isHighlighted = highlightIndex === chordIndex

          return (
            <g key={chordIndex}>
              {chord.map((note, noteIndex) => {
                const y = 15 + (note.string - 1) * 12

                return (
                  <g key={noteIndex}>
                    {/* 背景圆 */}
                    <circle
                      cx={x}
                      cy={y}
                      r="8"
                      className={isHighlighted ? "fill-accent/20" : "fill-card"}
                    />
                    
                    {/* 品位数字或空弦圈 */}
                    {note.fret === 0 ? (
                      <circle
                        cx={x}
                        cy={y}
                        r="5"
                        fill="none"
                        stroke="currentColor"
                        strokeWidth="1.5"
                        className={isHighlighted ? "text-accent" : "text-foreground"}
                      />
                    ) : (
                      <text
                        x={x}
                        y={y + 3.5}
                        textAnchor="middle"
                        className={`text-[11px] font-medium ${
                          isHighlighted ? "fill-accent" : "fill-foreground"
                        }`}
                      >
                        {note.fret}
                      </text>
                    )}

                    {/* 技法标记 */}
                    {note.technique && (
                      <text
                        x={x}
                        y={y - 10}
                        textAnchor="middle"
                        className="fill-accent text-[8px]"
                      >
                        {note.technique === "hammer" && "h"}
                        {note.technique === "pull" && "p"}
                        {note.technique === "slide" && "/"}
                        {note.technique === "bend" && "b"}
                        {note.technique === "vibrato" && "~"}
                        {note.technique === "mute" && "x"}
                      </text>
                    )}
                  </g>
                )
              })}
            </g>
          )
        })}
      </svg>
    </div>
  )
}

// 和弦框图组件
interface ChordDiagramProps {
  name: string
  frets: (number | null)[] // 从6弦到1弦，null表示不弹
  barFret?: number
  fingers?: (number | null)[]
}

export function ChordDiagram({ name, frets, fingers }: ChordDiagramProps) {
  const stringCount = 6
  const fretCount = 4

  return (
    <div className="bg-card rounded-xl p-3 border border-border inline-block">
      <div className="text-center mb-2">
        <span className="text-[13px] font-semibold text-foreground">{name}</span>
      </div>

      <svg viewBox="0 0 60 70" className="w-16 h-20">
        {/* 弦 */}
        {Array.from({ length: stringCount }).map((_, i) => (
          <line
            key={`string-${i}`}
            x1={10 + i * 8}
            y1="10"
            x2={10 + i * 8}
            y2="60"
            stroke="currentColor"
            strokeWidth="1"
            className="text-muted-foreground/50"
          />
        ))}

        {/* 品位线 */}
        {Array.from({ length: fretCount + 1 }).map((_, i) => (
          <line
            key={`fret-${i}`}
            x1="10"
            y1={10 + i * 12.5}
            x2="50"
            y2={10 + i * 12.5}
            stroke="currentColor"
            strokeWidth={i === 0 ? 3 : 1}
            className="text-muted-foreground/50"
          />
        ))}

        {/* 指法标记 */}
        {frets.map((fret, stringIndex) => {
          const x = 10 + stringIndex * 8

          if (fret === null) {
            // X 标记 - 不弹
            return (
              <text
                key={stringIndex}
                x={x}
                y="6"
                textAnchor="middle"
                className="fill-muted-foreground text-[8px]"
              >
                x
              </text>
            )
          }

          if (fret === 0) {
            // O 标记 - 空弦
            return (
              <circle
                key={stringIndex}
                cx={x}
                cy="4"
                r="2.5"
                fill="none"
                stroke="currentColor"
                strokeWidth="1"
                className="text-foreground"
              />
            )
          }

          // 品位标记
          const y = 10 + (fret - 0.5) * 12.5
          return (
            <g key={stringIndex}>
              <circle
                cx={x}
                cy={y}
                r="3"
                className="fill-foreground"
              />
              {fingers && fingers[stringIndex] && (
                <text
                  x={x}
                  y={y + 2}
                  textAnchor="middle"
                  className="fill-card text-[6px] font-bold"
                >
                  {fingers[stringIndex]}
                </text>
              )}
            </g>
          )
        })}
      </svg>
    </div>
  )
}
