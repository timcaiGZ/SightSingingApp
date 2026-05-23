"use client"

interface ProgressRingProps {
  progress: number // 0-100
  size?: "sm" | "md" | "lg"
  showPercentage?: boolean
  strokeWidth?: number
}

export default function ProgressRing({ 
  progress, 
  size = "sm", 
  showPercentage = false,
  strokeWidth = 2.5
}: ProgressRingProps) {
  const sizeMap = {
    sm: 20,
    md: 28,
    lg: 40
  }
  
  const dimension = sizeMap[size]
  const radius = (dimension - strokeWidth) / 2
  const circumference = radius * 2 * Math.PI
  const offset = circumference - (progress / 100) * circumference
  
  // 根据进度选择颜色
  const getColor = () => {
    if (progress >= 80) return "stroke-green-500"
    if (progress >= 50) return "stroke-primary"
    if (progress > 0) return "stroke-amber-500"
    return "stroke-muted-foreground/30"
  }

  return (
    <div className="relative inline-flex items-center justify-center">
      <svg 
        width={dimension} 
        height={dimension} 
        className="transform -rotate-90"
      >
        {/* 背景圆环 */}
        <circle
          cx={dimension / 2}
          cy={dimension / 2}
          r={radius}
          fill="none"
          stroke="currentColor"
          strokeWidth={strokeWidth}
          className="text-muted-foreground/20"
        />
        {/* 进度圆环 */}
        <circle
          cx={dimension / 2}
          cy={dimension / 2}
          r={radius}
          fill="none"
          strokeWidth={strokeWidth}
          strokeLinecap="round"
          strokeDasharray={circumference}
          strokeDashoffset={offset}
          className={`${getColor()} transition-all duration-500 ease-out`}
        />
      </svg>
      {showPercentage && size === "lg" && (
        <span className="absolute text-[10px] font-medium text-foreground">
          {progress}
        </span>
      )}
    </div>
  )
}

interface ProgressBarProps {
  progress: number // 0-100
  height?: "sm" | "md"
  showLabel?: boolean
}

export function ProgressBar({ progress, height = "sm", showLabel = false }: ProgressBarProps) {
  const heightMap = {
    sm: "h-1",
    md: "h-1.5"
  }
  
  const getColor = () => {
    if (progress >= 80) return "bg-green-500"
    if (progress >= 50) return "bg-primary"
    if (progress > 0) return "bg-amber-500"
    return "bg-muted-foreground/30"
  }

  return (
    <div className="flex items-center gap-2 w-full">
      <div className={`flex-1 ${heightMap[height]} bg-muted-foreground/15 rounded-full overflow-hidden`}>
        <div 
          className={`h-full ${getColor()} rounded-full transition-all duration-500 ease-out`}
          style={{ width: `${Math.max(progress, 0)}%` }}
        />
      </div>
      {showLabel && (
        <span className="text-[12px] font-medium text-muted-foreground min-w-[32px] text-right">
          {progress}%
        </span>
      )}
    </div>
  )
}
