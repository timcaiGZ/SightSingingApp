"use client"

import { useState, useCallback, useEffect } from "react"
import ExerciseLayout, {
  AudioPromptCard,
  ChoiceList,
} from "./exercise-layout"
import { getRandomQuestion, getExerciseTitle, type ExerciseQuestion } from "@/lib/exercise-data"

const TOTAL = 10

interface TestSessionProps {
  testId: string
  onBack: () => void
}

export default function TestSession({ testId, onBack }: TestSessionProps) {
  const [currentQuestion, setCurrentQuestion] = useState(1)
  const [correctCount, setCorrectCount] = useState(0)
  const [selectedOption, setSelectedOption] = useState<string | null>(null)
  const [showResult, setShowResult] = useState(false)
  const [question, setQuestion] = useState<ExerciseQuestion | null>(null)
  const [showComplete, setShowComplete] = useState(false)
  const [startTime] = useState(Date.now())

  const exerciseId = testId === "interval-test" ? "interval" : testId === "chord-test" ? "chord" : "single-note"

  useEffect(() => {
    setQuestion(getRandomQuestion(exerciseId))
  }, [exerciseId, currentQuestion])

  const goNext = useCallback(() => {
    if (currentQuestion >= TOTAL) {
      setShowComplete(true)
      return
    }
    setSelectedOption(null)
    setShowResult(false)
    setCurrentQuestion((q) => q + 1)
    setQuestion(getRandomQuestion(exerciseId))
  }, [currentQuestion, exerciseId])

  const handleSelect = (option: string) => {
    if (showResult || !question) return
    setSelectedOption(option)
    setShowResult(true)
    if (option === question.correctAnswer) {
      setCorrectCount((c) => c + 1)
    }
  }

  const handleNewQuestion = () => {
    if (showResult) goNext()
  }

  if (!question) return null

  if (showComplete) {
    const elapsedMin = Math.max(1, Math.round((Date.now() - startTime) / 60000))
    const totalScore = Math.round((correctCount / TOTAL) * 100)
    return (
      <div className="min-h-screen bg-background flex flex-col pb-[84px]">
        <div className="flex-1 flex flex-col items-center justify-center px-4">
          <p className="text-[15px] text-muted-foreground mb-2">测试成绩</p>
          <p className="text-[72px] font-bold text-primary">{totalScore}</p>
          <p className="text-[14px] text-muted-foreground mt-2">
            正确 {correctCount}/{TOTAL} · 用时约 {elapsedMin} 分钟
          </p>
          <div className="w-full max-w-xs mt-8 space-y-3">
            <button
              type="button"
              disabled
              className="w-full h-12 bg-secondary text-muted-foreground rounded-xl text-[17px] font-medium"
            >
              查看解析（V3.0）
            </button>
            <button
              type="button"
              onClick={onBack}
              className="w-full h-12 bg-primary text-primary-foreground rounded-xl text-[17px] font-semibold ios-press"
            >
              返回
            </button>
          </div>
        </div>
      </div>
    )
  }

  return (
    <>
      <ExerciseLayout
        title={getExerciseTitle(exerciseId)}
        questionNumber={currentQuestion}
        totalQuestions={TOTAL}
        questionText="请听辨音频，选择正确答案。"
        showDecompose={false}
        onBack={() => {
          if (confirm("放弃测试？未完成的测试将不会保存成绩。")) onBack()
        }}
        onNewQuestion={handleNewQuestion}
        onReplay={() => {}}
      >
        <AudioPromptCard
          label={question.displayContent}
          hint={question.displayLabel}
          onPlay={() => {}}
        />
        <ChoiceList
          options={question.options}
          selectedOption={selectedOption}
          correctAnswer={question.correctAnswer}
          showResult={showResult}
          onSelect={handleSelect}
          onNext={goNext}
        />
      </ExerciseLayout>
    </>
  )
}
