"use client"

import { useEffect, useState } from "react"
import NavBar from "@/components/nav-bar"
import ProgressDots from "@/components/progress-dots"
import { Play } from "lucide-react"
import { useSettings, type NotationType } from "@/lib/settings-context"

interface ExerciseLayoutProps {
  title: string
  questionNumber: number
  totalQuestions: number
  questionText: string
  score?: number
  showDecompose?: boolean
  onBack: () => void
  onNewQuestion: () => void
  onDecompose?: () => void
  onReplay: () => void
  replayLabel?: string
  children: React.ReactNode
  bottomContent?: React.ReactNode
}

// 统一的练习页面布局
export default function ExerciseLayout({
  title,
  questionNumber,
  totalQuestions,
  questionText,
  score,
  showDecompose = false,
  onBack,
  onNewQuestion,
  onDecompose,
  onReplay,
  replayLabel = "重听",
  children,
  bottomContent,
}: ExerciseLayoutProps) {
  const { notationType: globalNotation } = useSettings()
  const [localNotation, setLocalNotation] = useState<NotationType>(globalNotation)

  useEffect(() => {
    setLocalNotation(globalNotation)
  }, [globalNotation])

  return (
    <div className="min-h-screen bg-background flex flex-col pb-[84px]">
      <NavBar
        title={title}
        showBack
        onBack={onBack}
        score={score}
      />

      <div className="px-4 pt-2 pb-1 flex justify-center">
        <NotationPillSwitcher value={localNotation} onChange={setLocalNotation} />
      </div>

      <div className="flex flex-col items-center gap-1 py-2">
        <ProgressDots total={totalQuestions} current={questionNumber} size="md" />
        <span className="text-[13px] text-muted-foreground">
          {questionNumber} / {totalQuestions}
        </span>
      </div>

      {/* 问题提示 */}
      <div className="px-4 py-3">
        <p className="text-[14px] text-foreground leading-relaxed">
          Q{questionNumber}: {questionText}
        </p>
      </div>

      {/* 主要内容区域 */}
      <div className="flex-1 px-4 flex flex-col">
        {children}
      </div>

      {/* 操作按钮行 */}
      <div className="px-4 py-3 flex items-center justify-between">
        <button
          onClick={onNewQuestion}
          className="text-primary text-[15px] font-medium ios-press"
        >
          新问题
        </button>
        
        {showDecompose && (
          <button
            onClick={onDecompose}
            className="text-primary text-[15px] font-medium ios-press"
          >
            分解
          </button>
        )}
        
        <button
          onClick={onReplay}
          className="text-primary text-[15px] font-medium ios-press"
        >
          {replayLabel}
        </button>
      </div>

      {/* 底部内容（键盘、录音按钮等） */}
      {bottomContent && (
        <div className="px-4 pb-4">
          {bottomContent}
        </div>
      )}
    </div>
  )
}

// 选择题选项组件
interface ChoiceListProps {
  options: string[]
  selectedOption: string | null
  correctAnswer?: string
  showResult?: boolean
  onSelect: (option: string) => void
  onNext?: () => void
}

export function ChoiceList({
  options,
  selectedOption,
  correctAnswer,
  showResult,
  onSelect,
  onNext,
}: ChoiceListProps) {
  return (
    <div className="space-y-3">
    <div className="bg-card rounded-xl border border-border overflow-hidden">
      <div className="px-4 py-2.5 bg-secondary/50 border-b border-border">
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
              className={`w-full px-4 py-3.5 text-left ios-press transition-colors ${
                isCorrect
                  ? "bg-success/10"
                  : isWrong
                  ? "bg-destructive/10"
                  : isSelected
                  ? "bg-primary/5"
                  : ""
              }`}
            >
              <span className={`text-[16px] ${
                isCorrect
                  ? "text-success font-medium"
                  : isWrong
                  ? "text-destructive"
                  : "text-foreground"
              }`}>
                {option}
              </span>
            </button>
          )
        })}
      </div>
    </div>
    {showResult && onNext && (
      <button
        type="button"
        onClick={onNext}
        className="w-full h-12 bg-primary text-primary-foreground rounded-xl text-[17px] font-semibold ios-press"
      >
        下一题
      </button>
    )}
    </div>
  )
}

function NotationPillSwitcher({
  value,
  onChange,
}: {
  value: NotationType
  onChange: (v: NotationType) => void
}) {
  return (
    <div className="flex p-1 bg-secondary rounded-full">
      <button
        type="button"
        onClick={() => onChange("staff")}
        className={`px-4 py-1.5 text-[13px] font-medium rounded-full transition-all ${
          value === "staff" ? "bg-primary text-primary-foreground" : "text-muted-foreground"
        }`}
      >
        五线谱
      </button>
      <button
        type="button"
        onClick={() => onChange("tabSolfege")}
        className={`px-4 py-1.5 text-[13px] font-medium rounded-full transition-all ${
          value === "tabSolfege" ? "bg-primary text-primary-foreground" : "text-muted-foreground"
        }`}
      >
        六线谱+简谱
      </button>
    </div>
  )
}

// 听力题目展示卡片
interface AudioPromptCardProps {
  label: string
  hint: string
  onPlay?: () => void
}

export function AudioPromptCard({ label, hint, onPlay }: AudioPromptCardProps) {
  return (
    <button
      onClick={onPlay}
      className="w-full bg-card rounded-2xl p-6 border border-border ios-press mb-4"
    >
      <div className="flex flex-col items-center justify-center min-h-[100px]">
        <div className="w-16 h-16 rounded-full bg-primary/10 flex items-center justify-center mb-3">
          <Play className="w-7 h-7 text-primary" fill="currentColor" />
        </div>
        <p className="text-[15px] font-medium text-foreground">{label}</p>
        <p className="text-[13px] text-muted-foreground mt-1">{hint}</p>
      </div>
    </button>
  )
}

// 标准音卡片（用于旋律听写等）
interface ReferenceNoteCardProps {
  note: string
  frequency?: string
  onPlay?: () => void
}

export function ReferenceNoteCard({ note, frequency = "440Hz", onPlay }: ReferenceNoteCardProps) {
  return (
    <div className="flex items-center gap-4 mb-4">
      <button
        onClick={onPlay}
        className="w-14 h-14 rounded-full bg-primary flex items-center justify-center ios-press shadow-lg"
      >
        <span className="text-[18px] font-bold text-primary-foreground">{note}</span>
      </button>
      <div>
        <p className="text-[14px] font-medium text-foreground">标准音 {note}</p>
        <p className="text-[12px] text-muted-foreground">{frequency}</p>
      </div>
    </div>
  )
}
