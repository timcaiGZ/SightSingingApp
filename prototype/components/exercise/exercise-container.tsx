"use client"

import { useState } from "react"
import NavBar from "@/components/nav-bar"
import ProgressDots from "@/components/progress-dots"
import { Play, RefreshCw, Layers } from "lucide-react"

// 交互模式
type ExerciseMode = "multipleChoice" | "keyboardInput" | "sightSinging"

interface ExerciseContainerProps {
  title: string
  mode: ExerciseMode
  currentQuestion: number
  totalQuestions: number
  score?: number
  showDecompose?: boolean // 是否显示分解按钮
  onBack: () => void
  onNewQuestion: () => void
  onDecompose?: () => void
  onReplay: () => void
  children?: React.ReactNode
}

export default function ExerciseContainer({
  title,
  mode,
  currentQuestion,
  totalQuestions,
  score,
  showDecompose = true,
  onBack,
  onNewQuestion,
  onDecompose,
  onReplay,
  children,
}: ExerciseContainerProps) {
  return (
    <div className="min-h-screen bg-background flex flex-col">
      <NavBar
        title={title}
        showBack
        onBack={onBack}
        score={score}
        showSettings
      />

      {/* 进度指示 */}
      <div className="flex flex-col items-center gap-2 py-3">
        <ProgressDots total={totalQuestions} current={currentQuestion} size="md" />
        <span className="text-[13px] text-muted-foreground">
          {currentQuestion} / {totalQuestions}
        </span>
      </div>

      {/* 内容区域 - 传入子组件 */}
      <div className="flex-1 px-4 overflow-auto">
        {children}
      </div>

      {/* 操作栏 */}
      <div className="px-4 py-3 border-t border-border bg-card mb-[84px]">
        <div className="flex items-center justify-center gap-8">
          <button
            onClick={onNewQuestion}
            className="flex flex-col items-center gap-1 ios-press"
          >
            <div className="w-10 h-10 flex items-center justify-center rounded-full bg-secondary">
              <RefreshCw className="w-5 h-5 text-primary" />
            </div>
            <span className="text-[11px] text-muted-foreground">新问题</span>
          </button>

          {showDecompose && mode !== "sightSinging" && (
            <button
              onClick={onDecompose}
              className="flex flex-col items-center gap-1 ios-press"
            >
              <div className="w-10 h-10 flex items-center justify-center rounded-full bg-secondary">
                <Layers className="w-5 h-5 text-primary" />
              </div>
              <span className="text-[11px] text-muted-foreground">分解</span>
            </button>
          )}

          <button
            onClick={onReplay}
            className="flex flex-col items-center gap-1 ios-press"
          >
            <div className="w-10 h-10 flex items-center justify-center rounded-full bg-accent">
              <Play className="w-5 h-5 text-accent-foreground" fill="currentColor" />
            </div>
            <span className="text-[11px] text-muted-foreground">
              {mode === "sightSinging" ? "示范" : "重听"}
            </span>
          </button>
        </div>
      </div>
    </div>
  )
}

// 选择题交互组件
interface MultipleChoiceProps {
  question: string
  options: string[]
  selectedOption: string | null
  correctAnswer?: string
  showResult?: boolean
  onSelect: (option: string) => void
}

export function MultipleChoice({
  question,
  options,
  selectedOption,
  correctAnswer,
  showResult,
  onSelect,
}: MultipleChoiceProps) {
  return (
    <div className="space-y-4">
      <p className="text-[15px] text-foreground">{question}</p>
      
      <div className="bg-card rounded-xl border border-border overflow-hidden">
        <div className="px-4 py-2.5 bg-secondary/50">
          <span className="text-[13px] text-muted-foreground">请选择</span>
        </div>
        <div className="divide-y divide-border">
          {options.map((option) => {
            const isSelected = selectedOption === option
            const isCorrect = showResult && option === correctAnswer
            const isWrong = showResult && isSelected && option !== correctAnswer

            return (
              <button
                key={option}
                onClick={() => onSelect(option)}
                disabled={showResult}
                className={`w-full px-4 py-3 text-left ios-press ${
                  isCorrect
                    ? "bg-success/10 text-success"
                    : isWrong
                    ? "bg-destructive/10 text-destructive"
                    : isSelected
                    ? "bg-accent/10"
                    : ""
                }`}
              >
                <span className="text-[15px]">{option}</span>
              </button>
            )
          })}
        </div>
      </div>
    </div>
  )
}

// 音符键盘输入组件
interface MusicKeyboardProps {
  value: string[]
  onNotePress: (note: string) => void
  onClear: () => void
  onSubmit: () => void
  onReplay: () => void
}

export function MusicKeyboard({
  value,
  onNotePress,
  onClear,
  onSubmit,
  onReplay,
}: MusicKeyboardProps) {
  const [accidental, setAccidental] = useState<"sharp" | "flat" | null>(null)
  const notes = ["C", "D", "E", "F", "G", "A", "B"]

  const handleNotePress = (note: string) => {
    let fullNote = note
    if (accidental === "sharp") fullNote = note + "#"
    if (accidental === "flat") fullNote = note + "b"
    onNotePress(fullNote)
    setAccidental(null)
  }

  return (
    <div className="space-y-4">
      {/* 已输入的音符显示 */}
      <div className="min-h-[44px] px-4 py-2 bg-secondary rounded-xl flex items-center flex-wrap gap-2">
        {value.length === 0 ? (
          <span className="text-muted-foreground text-[15px]">请输入音符...</span>
        ) : (
          value.map((note, i) => (
            <span
              key={i}
              className="px-3 py-1 bg-primary text-primary-foreground rounded-lg text-[15px] font-medium"
            >
              {note}
            </span>
          ))
        )}
      </div>

      {/* 升降号按钮 */}
      <div className="flex gap-2">
        <button
          onClick={() => setAccidental(accidental === "sharp" ? null : "sharp")}
          className={`w-12 h-12 rounded-xl text-lg font-bold transition-all ${
            accidental === "sharp"
              ? "bg-primary text-primary-foreground"
              : "bg-secondary text-foreground"
          }`}
        >
          #
        </button>
        <button
          onClick={() => setAccidental(accidental === "flat" ? null : "flat")}
          className={`w-12 h-12 rounded-xl text-lg font-bold transition-all ${
            accidental === "flat"
              ? "bg-primary text-primary-foreground"
              : "bg-secondary text-foreground"
          }`}
        >
          b
        </button>
      </div>

      {/* 音符键盘 */}
      <div className="grid grid-cols-7 gap-2">
        {notes.map((note) => (
          <button
            key={note}
            onClick={() => handleNotePress(note)}
            className="h-14 bg-primary text-primary-foreground rounded-xl text-[17px] font-semibold ios-press"
          >
            {note}
          </button>
        ))}
      </div>

      {/* 功能按钮 */}
      <div className="grid grid-cols-3 gap-3">
        <button
          onClick={onClear}
          className="h-11 bg-secondary text-foreground rounded-xl text-[15px] font-medium ios-press"
        >
          清空
        </button>
        <button
          onClick={onSubmit}
          className="h-11 bg-accent text-accent-foreground rounded-xl text-[15px] font-medium ios-press"
        >
          确认
        </button>
        <button
          onClick={onReplay}
          className="h-11 bg-secondary text-foreground rounded-xl text-[15px] font-medium ios-press"
        >
          重听
        </button>
      </div>
    </div>
  )
}
