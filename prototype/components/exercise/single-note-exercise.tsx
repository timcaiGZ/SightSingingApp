"use client"

import { useState, useCallback } from "react"
import ExerciseLayout from "./exercise-layout"
import ExerciseCompletionOverlay from "./exercise-completion-overlay"
import { useSettings } from "@/lib/settings-context"

interface SingleNoteExerciseProps {
  onBack: () => void
}

// 五线谱组件
function StaffNotation({
  inputNotes,
  feedback = "idle",
}: {
  inputNotes: string[]
  feedback?: "idle" | "correct" | "wrong"
}) {
  const border =
    feedback === "correct"
      ? "border-success"
      : feedback === "wrong"
        ? "border-destructive"
        : "border-border"
  const notePositions: Record<string, number> = {
    "C": 0, "D": 1, "E": 2, "F": 3, "G": 4, "A": 5, "B": 6,
  }
  
  return (
    <div className={`bg-card rounded-xl p-4 border mb-4 ${border}`}>
      <svg viewBox="0 0 320 100" className="w-full h-[100px]">
        {[0, 1, 2, 3, 4].map((i) => (
          <line
            key={i}
            x1="30"
            y1={30 + i * 10}
            x2="310"
            y2={30 + i * 10}
            stroke="#007AFF"
            strokeWidth="1"
          />
        ))}
        
        <g transform="translate(5, 25)">
          <path
            d="M15 45 C15 35, 25 30, 25 20 C25 10, 15 5, 10 10 C5 15, 10 25, 15 30 C20 35, 25 40, 20 50 C15 60, 5 55, 10 45"
            fill="none"
            stroke="#007AFF"
            strokeWidth="2"
          />
          <circle cx="12" cy="52" r="4" fill="#007AFF" />
        </g>
        
        {inputNotes.map((note, index) => {
          const baseNote = note.replace(/[#b]/g, "")
          const position = notePositions[baseNote] || 0
          const y = 70 - position * 5
          const x = 80 + index * 30
          const accidental = note.includes("#") ? "#" : note.includes("b") ? "b" : ""
          
          return (
            <g key={index}>
              {accidental && (
                <text x={x - 12} y={y + 4} fontSize="14" fill="#007AFF">{accidental}</text>
              )}
              <ellipse cx={x} cy={y} rx="6" ry="4.5" fill="#007AFF" transform={`rotate(-15 ${x} ${y})`} />
              {position <= 0 && (
                <line x1={x - 10} y1={70} x2={x + 10} y2={70} stroke="#007AFF" strokeWidth="1" />
              )}
            </g>
          )
        })}
      </svg>
    </div>
  )
}

// 六线谱+简谱组件
function TabSolfegeNotation({
  inputNotes,
  feedback = "idle",
}: {
  inputNotes: string[]
  feedback?: "idle" | "correct" | "wrong"
}) {
  const border =
    feedback === "correct"
      ? "border-success"
      : feedback === "wrong"
        ? "border-destructive"
        : "border-border"
  const noteToSolfege: Record<string, string> = {
    "C": "1", "D": "2", "E": "3", "F": "4", "G": "5", "A": "6", "B": "7",
  }
  
  const noteToFret: Record<string, { string: number; fret: number }> = {
    "C": { string: 5, fret: 3 },
    "D": { string: 4, fret: 0 },
    "E": { string: 4, fret: 2 },
    "F": { string: 4, fret: 3 },
    "G": { string: 3, fret: 0 },
    "A": { string: 3, fret: 2 },
    "B": { string: 2, fret: 0 },
  }
  
  return (
    <div className="space-y-3 mb-4">
      {/* 六线谱 */}
      <div className={`bg-card rounded-xl p-4 border ${border}`}>
        <div className="text-[11px] text-muted-foreground mb-2">六线谱</div>
        <svg viewBox="0 0 320 80" className="w-full h-[80px]">
          {[1, 2, 3, 4, 5, 6].map((num, index) => (
            <text key={num} x="8" y={18 + index * 10} className="fill-muted-foreground text-[9px]">
              {num}
            </text>
          ))}
          
          {[0, 1, 2, 3, 4, 5].map((index) => (
            <line
              key={index}
              x1="25"
              y1={15 + index * 10}
              x2="310"
              y2={15 + index * 10}
              stroke="#94A3B8"
              strokeWidth={0.8 + index * 0.1}
            />
          ))}
          
          {inputNotes.map((note, index) => {
            const baseNote = note.replace(/[#b]/g, "")
            const pos = noteToFret[baseNote]
            if (!pos) return null
            
            const x = 50 + index * 35
            const y = 15 + (pos.string - 1) * 10
            
            return (
              <g key={index}>
                <circle cx={x} cy={y} r="7" fill="white" />
                <text x={x} y={y + 3} textAnchor="middle" className="fill-foreground text-[10px] font-medium">
                  {pos.fret}
                </text>
              </g>
            )
          })}
        </svg>
      </div>
      
      {/* 简谱 */}
      <div className={`bg-card rounded-xl p-4 border ${border}`}>
        <div className="text-[11px] text-muted-foreground mb-2">简谱</div>
        <div className="flex items-center gap-4 min-h-[40px] px-2">
          {inputNotes.length === 0 ? (
            <span className="text-muted-foreground text-[14px]">等待输入...</span>
          ) : (
            inputNotes.map((note, index) => {
              const baseNote = note.replace(/[#b]/g, "")
              const solfege = noteToSolfege[baseNote] || "?"
              const hasSharp = note.includes("#")
              const hasFlat = note.includes("b")
              
              return (
                <div key={index} className="flex flex-col items-center">
                  <div className="flex items-baseline">
                    {hasSharp && <span className="text-[12px] text-primary mr-0.5">#</span>}
                    {hasFlat && <span className="text-[12px] text-primary mr-0.5">b</span>}
                    <span className="text-[24px] font-bold text-primary">{solfege}</span>
                  </div>
                  <span className="text-[10px] text-muted-foreground">
                    {baseNote === "C" && "do"}
                    {baseNote === "D" && "re"}
                    {baseNote === "E" && "mi"}
                    {baseNote === "F" && "fa"}
                    {baseNote === "G" && "sol"}
                    {baseNote === "A" && "la"}
                    {baseNote === "B" && "si"}
                  </span>
                </div>
              )
            })
          )}
        </div>
      </div>
    </div>
  )
}

// 音乐输入键盘
function MusicKeyboard({
  onNotePress,
  onAccidentalChange,
  onClear,
  onSubmit,
  currentAccidental,
  canSubmit,
}: {
  onNotePress: (note: string) => void
  onAccidentalChange: (acc: string) => void
  onClear: () => void
  onSubmit: () => void
  currentAccidental: string
  canSubmit: boolean
}) {
  const accidentals = [
    { label: "无", value: "" },
    { label: "#", value: "#" },
    { label: "x", value: "x" },
    { label: "n", value: "n" },
    { label: "b", value: "b" },
    { label: "bb", value: "bb" },
  ]
  
  const notes = ["C", "D", "E", "F", "G", "A", "B"]
  
  return (
    <div className="bg-[#D1D5DB] p-1 rounded-xl">
      <div className="flex gap-0.5">
        {/* 左侧升降号列 */}
        <div className="flex flex-col gap-0.5 w-[50px]">
          {accidentals.map((acc) => (
            <button
              key={acc.value}
              onClick={() => onAccidentalChange(acc.value)}
              className={`h-[42px] rounded-lg text-[15px] font-medium transition-all shadow-sm ${
                currentAccidental === acc.value
                  ? "bg-primary text-white"
                  : "bg-[#ADB5BD] text-foreground"
              }`}
            >
              {acc.label}
            </button>
          ))}
        </div>
        
        {/* 中间音名区 */}
        <div className="flex-1 grid grid-cols-3 gap-0.5">
          <button
            onClick={() => onNotePress("休")}
            className="h-[42px] bg-white rounded-lg text-[18px] text-muted-foreground shadow-sm ios-press"
          >
            𝄽
          </button>
          {notes.slice(0, 2).map((note) => (
            <button
              key={note}
              onClick={() => onNotePress(currentAccidental + note)}
              className="h-[42px] bg-white rounded-lg text-[20px] font-semibold text-foreground shadow-sm ios-press"
            >
              {note}
            </button>
          ))}
          {notes.slice(2, 5).map((note) => (
            <button
              key={note}
              onClick={() => onNotePress(currentAccidental + note)}
              className="h-[42px] bg-white rounded-lg text-[20px] font-semibold text-foreground shadow-sm ios-press"
            >
              {note}
            </button>
          ))}
          {notes.slice(5).map((note) => (
            <button
              key={note}
              onClick={() => onNotePress(currentAccidental + note)}
              className="h-[42px] bg-white rounded-lg text-[20px] font-semibold text-foreground shadow-sm ios-press"
            >
              {note}
            </button>
          ))}
          <button
            onClick={() => onNotePress("𝄾")}
            className="h-[42px] bg-white rounded-lg text-[18px] text-muted-foreground shadow-sm ios-press"
          >
            𝄾
          </button>
          <button
            onClick={() => onNotePress("+8va")}
            className="h-[42px] bg-white rounded-lg text-[13px] font-medium text-foreground shadow-sm ios-press"
          >
            +8va
          </button>
          <button
            onClick={() => onNotePress("-8va")}
            className="h-[42px] bg-white rounded-lg text-[13px] font-medium text-foreground shadow-sm ios-press"
          >
            -8va
          </button>
          <button
            onClick={() => onNotePress("|")}
            className="h-[42px] bg-white rounded-lg text-[13px] text-muted-foreground shadow-sm ios-press"
          >
            小节
          </button>
        </div>
        
        {/* 右侧功能键 */}
        <div className="flex flex-col gap-0.5 w-[50px]">
          <button
            onClick={onClear}
            className="h-[42px] bg-[#ADB5BD] rounded-lg flex items-center justify-center shadow-sm ios-press"
          >
            <span className="text-[16px]">⌫</span>
          </button>
          <button className="h-[42px] bg-[#ADB5BD] rounded-lg flex items-center justify-center shadow-sm ios-press">
            <span className="text-[16px]">⇧</span>
          </button>
          <button
            type="button"
            onClick={onSubmit}
            disabled={!canSubmit}
            className="flex-1 bg-[#ADB5BD] rounded-lg text-[15px] font-medium text-foreground shadow-sm ios-press disabled:opacity-40"
          >
            完成
          </button>
        </div>
      </div>
    </div>
  )
}

const TOTAL = 10
const DEMO_ANSWER = "E"

export default function SingleNoteExercise({ onBack }: SingleNoteExerciseProps) {
  const { notationType } = useSettings()
  const [currentQuestion, setCurrentQuestion] = useState(1)
  const [inputNotes, setInputNotes] = useState<string[]>([])
  const [currentAccidental, setCurrentAccidental] = useState("")
  const [score, setScore] = useState(0)
  const [correctCount, setCorrectCount] = useState(0)
  const [answerState, setAnswerState] = useState<"idle" | "correct" | "wrong">("idle")
  const [showNext, setShowNext] = useState(false)
  const [showComplete, setShowComplete] = useState(false)

  const goNext = useCallback(() => {
    if (currentQuestion >= TOTAL) {
      setShowComplete(true)
      return
    }
    setInputNotes([])
    setCurrentAccidental("")
    setAnswerState("idle")
    setShowNext(false)
    setCurrentQuestion((q) => q + 1)
  }, [currentQuestion])

  const handleNewQuestion = useCallback(() => {
    if (showNext) goNext()
  }, [showNext, goNext])

  const handleNotePress = (note: string) => {
    if (answerState !== "idle") return
    setInputNotes((prev) => [...prev, note])
    setCurrentAccidental("")
  }

  const handleClear = () => {
    if (answerState !== "idle") return
    setInputNotes((prev) => prev.slice(0, -1))
  }

  const handleSubmit = () => {
    if (inputNotes.length === 0 || answerState !== "idle") return
    const last = inputNotes[inputNotes.length - 1]?.replace(/[#b]/g, "") ?? ""
    const ok = last === DEMO_ANSWER
    setAnswerState(ok ? "correct" : "wrong")
    setShowNext(true)
    if (ok) {
      setCorrectCount((c) => c + 1)
      setScore((s) => s + 10)
    }
  }

  const handleRetryRound = () => {
    setCurrentQuestion(1)
    setCorrectCount(0)
    setScore(0)
    setInputNotes([])
    setAnswerState("idle")
    setShowNext(false)
    setShowComplete(false)
  }

  return (
    <>
    <ExerciseLayout
      title="单音辨认"
      questionNumber={currentQuestion}
      totalQuestions={TOTAL}
      questionText="请问演奏了哪个单音? 你听到的第一个音是标准音 (无须录入)。"
      score={score}
      onBack={onBack}
      onNewQuestion={handleNewQuestion}
      onReplay={handleReplay}
      bottomContent={
        <MusicKeyboard
          onNotePress={handleNotePress}
          onAccidentalChange={setCurrentAccidental}
          onClear={handleClear}
          onSubmit={handleSubmit}
          currentAccidental={currentAccidental}
          canSubmit={inputNotes.length > 0 && answerState === "idle"}
        />
      }
    >
      {notationType === "staff" ? (
        <StaffNotation inputNotes={inputNotes} feedback={answerState} />
      ) : (
        <TabSolfegeNotation inputNotes={inputNotes} feedback={answerState} />
      )}
      {showNext && (
        <button
          type="button"
          onClick={goNext}
          className="w-full h-12 mt-3 bg-primary text-primary-foreground rounded-xl text-[17px] font-semibold ios-press"
        >
          下一题
        </button>
      )}
    </ExerciseLayout>
    {showComplete && (
      <ExerciseCompletionOverlay
        correctCount={correctCount}
        totalQuestions={TOTAL}
        onRetry={handleRetryRound}
        onBack={onBack}
      />
    )}
    </>
  )
}
