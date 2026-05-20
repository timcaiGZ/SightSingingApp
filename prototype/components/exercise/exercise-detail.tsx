"use client"

import { useState, useEffect, useCallback } from "react"
import SingleNoteExercise from "./single-note-exercise"
import MelodyDictationExercise from "./melody-dictation-exercise"
import ExerciseLayout, { ChoiceList, AudioPromptCard, ReferenceNoteCard } from "./exercise-layout"
import ExerciseCompletionOverlay from "./exercise-completion-overlay"
import { getRandomQuestion, getExerciseTitle, type ExerciseQuestion } from "@/lib/exercise-data"

const TOTAL_QUESTIONS = 10

interface ExerciseDetailProps {
  exerciseId: string
  moduleId: string
  onBack: () => void
}

function getQuestionPrompt(exerciseId: string): string {
  const prompts: Record<string, string> = {
    interval: "请听辨以下音程，选择正确的答案。",
    chord: "请听辨以下和弦，选择正确的和弦类型。",
    triad: "请听辨以下三和弦，选择正确的和弦类型。",
    "seventh-chord": "请听辨以下七和弦，选择正确的和弦类型。",
    "chord-inversion": "请听辨以下和弦，判断其转位。",
    "rhythm-hear": "请听辨以下节奏型，选择正确的答案。",
    "melody-dictation": "请先听标准音校准音高，然后听取旋律并记录。",
    "interval-compare": "请比较两个音程，选择哪个更大。",
    "interval-identify": "请听辨音程，选择正确的音程名称。",
  }
  return prompts[exerciseId] || "请听辨音频，选择正确的答案。"
}

export default function ExerciseDetail({ exerciseId, onBack }: ExerciseDetailProps) {
  if (exerciseId === "single-note") {
    return <SingleNoteExercise onBack={onBack} />
  }
  if (exerciseId === "melody-dictation") {
    return <MelodyDictationExercise onBack={onBack} />
  }

  const title = getExerciseTitle(exerciseId)
  const questionPrompt = getQuestionPrompt(exerciseId)
  const showDecompose = !["rhythm-hear", "melody-dictation", "interval-compare"].includes(exerciseId)
  const isMelodyDictation = exerciseId === "melody-dictation"

  const [currentQuestion, setCurrentQuestion] = useState(1)
  const [score, setScore] = useState(0)
  const [correctCount, setCorrectCount] = useState(0)
  const [selectedOption, setSelectedOption] = useState<string | null>(null)
  const [showResult, setShowResult] = useState(false)
  const [question, setQuestion] = useState<ExerciseQuestion | null>(null)
  const [showComplete, setShowComplete] = useState(false)

  useEffect(() => {
    setQuestion(getRandomQuestion(exerciseId))
  }, [exerciseId])

  const goNext = useCallback(() => {
    if (currentQuestion >= TOTAL_QUESTIONS) {
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
      setScore((s) => s + 10)
    }
  }

  const handleNewQuestion = () => {
    if (showResult) goNext()
  }

  const handleRetryRound = () => {
    setCurrentQuestion(1)
    setCorrectCount(0)
    setScore(0)
    setSelectedOption(null)
    setShowResult(false)
    setShowComplete(false)
    setQuestion(getRandomQuestion(exerciseId))
  }

  if (!question) return null

  return (
    <>
      <ExerciseLayout
        title={title}
        questionNumber={currentQuestion}
        totalQuestions={TOTAL_QUESTIONS}
        questionText={questionPrompt}
        score={score}
        showDecompose={showDecompose}
        onBack={onBack}
        onNewQuestion={handleNewQuestion}
        onDecompose={() => {}}
        onReplay={() => {}}
      >
        {isMelodyDictation && (
          <ReferenceNoteCard note="A4" frequency="440Hz" onPlay={() => {}} />
        )}
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

      {showComplete && (
        <ExerciseCompletionOverlay
          correctCount={correctCount}
          totalQuestions={TOTAL_QUESTIONS}
          onRetry={handleRetryRound}
          onBack={onBack}
        />
      )}
    </>
  )
}
