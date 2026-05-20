"use client"

interface ExerciseCompletionOverlayProps {
  correctCount: number
  totalQuestions: number
  onRetry: () => void
  onBack: () => void
}

export default function ExerciseCompletionOverlay({
  correctCount,
  totalQuestions,
  onRetry,
  onBack,
}: ExerciseCompletionOverlayProps) {
  const accuracy = totalQuestions > 0 ? Math.round((correctCount / totalQuestions) * 100) : 0

  return (
    <div className="fixed inset-0 z-[60] flex items-end justify-center bg-black/40 px-4 pb-[100px]">
      <div className="w-full max-w-md bg-card rounded-2xl border border-border shadow-xl p-6">
        <h2 className="text-[20px] font-bold text-foreground text-center mb-1">本轮完成</h2>
        <p className="text-[14px] text-muted-foreground text-center mb-6">
          共 {totalQuestions} 题，答对 {correctCount} 题
        </p>

        <div className="bg-secondary/50 rounded-xl py-4 text-center">
          <p className="text-[13px] text-muted-foreground mb-1">本轮正确率</p>
          <p className="text-[40px] font-bold text-primary">{accuracy}%</p>
        </div>

        <div className="mt-6 space-y-3">
          <button
            type="button"
            onClick={onRetry}
            className="w-full h-12 bg-primary text-primary-foreground rounded-xl text-[17px] font-semibold ios-press"
          >
            再来一轮
          </button>
          <button
            type="button"
            onClick={onBack}
            className="w-full h-12 bg-secondary text-foreground rounded-xl text-[17px] font-medium ios-press"
          >
            返回
          </button>
        </div>
      </div>
    </div>
  )
}
