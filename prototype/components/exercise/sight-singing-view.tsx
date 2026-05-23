"use client"

import { useState, useCallback, useEffect } from "react"
import ExerciseLayout from "./exercise-layout"
import PitchMeter, { SingButton } from "./pitch-meter"

interface SightSingingViewProps {
  exerciseId: string
  onBack: () => void
  onComplete: (score: number) => void
}

const singingExercises = [
  { note: "C4", frequency: 261.63 },
  { note: "D4", frequency: 293.66 },
  { note: "E4", frequency: 329.63 },
  { note: "F4", frequency: 349.23 },
  { note: "G4", frequency: 392.00 },
  { note: "A4", frequency: 440.00 },
  { note: "B4", frequency: 493.88 },
  { note: "C5", frequency: 523.25 },
]

export default function SightSingingView({ onBack, onComplete }: SightSingingViewProps) {
  const [currentQuestion, setCurrentQuestion] = useState(1)
  const [totalQuestions] = useState(10)
  const [isListening, setIsListening] = useState(false)
  const [currentCents, setCurrentCents] = useState(0)
  const [score, setScore] = useState(0)
  const [showResult, setShowResult] = useState(false)
  const [currentExercise, setCurrentExercise] = useState(singingExercises[0])

  useEffect(() => {
    let interval: NodeJS.Timeout
    if (isListening) {
      interval = setInterval(() => {
        const randomCents = (Math.random() - 0.5) * 30
        setCurrentCents(randomCents)
      }, 100)
    }
    return () => {
      if (interval) clearInterval(interval)
    }
  }, [isListening])

  const isAccurate = Math.abs(currentCents) <= 10

  const handlePressStart = useCallback(() => {
    setIsListening(true)
  }, [])

  const handlePressEnd = useCallback(() => {
    setIsListening(false)
    const pitchScore = isAccurate ? 100 : Math.max(0, 100 - Math.abs(currentCents) * 2)
    setScore(prev => prev + Math.round(pitchScore / totalQuestions))
    
    if (currentQuestion < totalQuestions) {
      setTimeout(() => {
        setCurrentQuestion(prev => prev + 1)
        setCurrentExercise(singingExercises[Math.floor(Math.random() * singingExercises.length)])
        setCurrentCents(0)
      }, 500)
    } else {
      setShowResult(true)
    }
  }, [currentCents, currentQuestion, isAccurate, totalQuestions])

  const handlePlayDemo = () => {
    console.log("Playing demo:", currentExercise.note)
  }

  const handleNewExercise = () => {
    setCurrentExercise(singingExercises[Math.floor(Math.random() * singingExercises.length)])
    setCurrentCents(0)
  }

  if (showResult) {
    return (
      <SightSingingResult
        score={score}
        pitchScore={Math.round(score * 0.6)}
        rhythmScore={Math.round(score * 0.4)}
        onRetry={() => {
          setShowResult(false)
          setCurrentQuestion(1)
          setScore(0)
        }}
        onNext={() => onComplete(score)}
        onBack={onBack}
      />
    )
  }

  return (
    <ExerciseLayout
      title="单音视唱"
      questionNumber={currentQuestion}
      totalQuestions={totalQuestions}
      questionText="请看目标音符，按住麦克风按钮演唱该音。"
      score={score}
      onBack={onBack}
      onNewQuestion={handleNewExercise}
      onReplay={handlePlayDemo}
      replayLabel="示范"
      bottomContent={
        <SingButton
          onPressStart={handlePressStart}
          onPressEnd={handlePressEnd}
          isPressed={isListening}
        />
      }
    >
      <div className="flex-1 flex flex-col justify-center">
        <PitchMeter
          targetNote={currentExercise.note}
          targetFrequency={currentExercise.frequency}
          currentCents={currentCents}
          isListening={isListening}
          isAccurate={isAccurate}
        />
      </div>
    </ExerciseLayout>
  )
}

// 视唱结果页
interface SightSingingResultProps {
  score: number
  pitchScore: number
  rhythmScore: number
  onRetry: () => void
  onNext: () => void
  onBack: () => void
}

function SightSingingResult({
  score,
  pitchScore,
  rhythmScore,
  onRetry,
  onNext,
  onBack,
}: SightSingingResultProps) {
  const getGrade = () => {
    if (score >= 95) return { text: "完美!", color: "text-success" }
    if (score >= 85) return { text: "优秀", color: "text-success" }
    if (score >= 70) return { text: "良好", color: "text-warning" }
    if (score >= 60) return { text: "及格", color: "text-warning" }
    return { text: "继续加油", color: "text-destructive" }
  }

  const grade = getGrade()

  return (
    <ExerciseLayout
      title="练习结果"
      questionNumber={10}
      totalQuestions={10}
      questionText="本次练习已完成，以下是您的成绩。"
      onBack={onBack}
      onNewQuestion={onRetry}
      onReplay={onNext}
      replayLabel="下一题"
    >
      <div className="flex-1 flex flex-col items-center justify-center">
        {/* 总分 */}
        <div className="text-center mb-8">
          <p className="text-[15px] text-muted-foreground mb-2">本次得分</p>
          <p className={`text-[72px] font-bold ${grade.color}`}>{score}</p>
          <p className={`text-[20px] font-medium ${grade.color}`}>{grade.text}</p>
        </div>

        {/* 分项得分 */}
        <div className="w-full max-w-xs bg-card rounded-2xl p-4 border border-border mb-8">
          <div className="flex items-center justify-around">
            <div className="text-center">
              <span className="text-[13px] text-muted-foreground">音准</span>
              <p className="text-[28px] font-bold text-primary">{pitchScore}</p>
            </div>
            <div className="w-px h-12 bg-border" />
            <div className="text-center">
              <span className="text-[13px] text-muted-foreground">节奏</span>
              <p className="text-[28px] font-bold text-warning">{rhythmScore}</p>
            </div>
          </div>
        </div>

        {/* 操作按钮 */}
        <div className="w-full max-w-xs space-y-3">
          <button
            onClick={onNext}
            className="w-full h-12 bg-primary text-primary-foreground rounded-xl text-[17px] font-semibold ios-press"
          >
            下一题
          </button>
          <button
            onClick={onRetry}
            className="w-full h-12 bg-secondary text-foreground rounded-xl text-[17px] font-medium ios-press"
          >
            重新练习
          </button>
        </div>
      </div>
    </ExerciseLayout>
  )
}
