interface ProgressDotsProps {
  total: number
  /** 当前题号（1-based） */
  current: number
  size?: "sm" | "md"
}

export default function ProgressDots({ total, current, size = "sm" }: ProgressDotsProps) {
  const dotSize = size === "sm" ? "w-2 h-2" : "w-2.5 h-2.5"
  const gap = size === "sm" ? "gap-1" : "gap-1.5"

  return (
    <div className={`flex items-center ${gap}`}>
      {Array.from({ length: total }, (_, i) => {
        const questionIndex = i + 1
        const isCompleted = questionIndex < current
        const isCurrent = questionIndex === current

        return (
          <div
            key={i}
            className={`${dotSize} rounded-full transition-all duration-200 ${
              isCurrent
                ? "bg-primary scale-110"
                : isCompleted
                  ? "bg-primary/40"
                  : "bg-muted-foreground/30"
            }`}
          />
        )
      })}
    </div>
  )
}
