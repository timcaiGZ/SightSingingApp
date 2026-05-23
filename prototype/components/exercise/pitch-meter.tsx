"use client"

import { Mic } from "lucide-react"

interface PitchMeterProps {
  targetNote: string
  targetFrequency: number
  currentCents: number
  isListening: boolean
  isAccurate: boolean
}

export default function PitchMeter({
  targetNote,
  currentCents,
  isListening,
  isAccurate,
}: PitchMeterProps) {
  // 音准范围 -50 到 +50 音分
  const maxCents = 50
  const clampedCents = Math.max(-maxCents, Math.min(maxCents, currentCents))
  const percentage = ((clampedCents + maxCents) / (maxCents * 2)) * 100

  // 获取颜色状态
  const getColor = () => {
    if (!isListening) return "bg-muted"
    if (isAccurate) return "bg-success"
    if (Math.abs(currentCents) <= 20) return "bg-warning"
    return "bg-destructive"
  }

  const getTextColor = () => {
    if (!isListening) return "text-muted-foreground"
    if (isAccurate) return "text-success"
    if (Math.abs(currentCents) <= 20) return "text-warning"
    return "text-destructive"
  }

  return (
    <div className="bg-card rounded-2xl p-6 border border-border shadow-sm">
      {/* 目标音符 - Solfeggio 风格 */}
      <div className="text-center mb-8">
        <p className="text-[13px] text-muted-foreground mb-2">目标音符</p>
        <div className="inline-flex items-center justify-center w-24 h-24 rounded-full bg-primary/10 mb-2">
          <span className="text-[48px] font-bold text-primary">{targetNote}</span>
        </div>
        <p className="text-[13px] text-muted-foreground">
          {isListening ? "正在聆听..." : "请唱出此音"}
        </p>
      </div>

      {/* 音准刻度尺 - 更清晰的视觉 */}
      <div className="relative mb-6">
        {/* 背景条 */}
        <div className="h-2 bg-secondary rounded-full overflow-hidden">
          {/* 准确区域 */}
          <div className="absolute left-1/2 -translate-x-1/2 top-0 w-1/5 h-full bg-success/30 rounded-full" />
        </div>
        
        {/* 刻度线 */}
        <div className="absolute top-0 left-1/2 w-0.5 h-2 bg-success -translate-x-1/2" />
        
        {/* 游标 */}
        <div
          className={`absolute top-1/2 -translate-y-1/2 w-5 h-5 rounded-full shadow-lg border-2 border-white transition-all duration-75 ${getColor()}`}
          style={{ left: `calc(${percentage}% - 10px)` }}
        />
      </div>

      {/* 刻度标签 */}
      <div className="flex justify-between text-[12px] text-muted-foreground mb-6">
        <span>-50</span>
        <span className="font-medium text-success">准</span>
        <span>+50</span>
      </div>

      {/* 音准反馈 */}
      <div className={`text-center py-3 px-4 rounded-xl ${isListening ? 'bg-secondary/50' : ''}`}>
        {!isListening ? (
          <p className="text-[15px] text-muted-foreground">按住下方按钮开始演唱</p>
        ) : isAccurate ? (
          <div className="flex items-center justify-center gap-2">
            <div className="w-2 h-2 rounded-full bg-success animate-pulse" />
            <p className="text-[17px] font-semibold text-success">音准良好!</p>
          </div>
        ) : currentCents < 0 ? (
          <p className="text-[15px] text-warning">
            偏低 <span className="font-bold text-[17px]">{Math.abs(Math.round(currentCents))}</span> 音分
          </p>
        ) : (
          <p className="text-[15px] text-destructive">
            偏高 <span className="font-bold text-[17px]">{Math.round(currentCents)}</span> 音分
          </p>
        )}
      </div>
    </div>
  )
}

// 视唱按钮组件 - Solfeggio 风格带麦克风图标
interface SingButtonProps {
  onPressStart: () => void
  onPressEnd: () => void
  isPressed: boolean
}

export function SingButton({ onPressStart, onPressEnd, isPressed }: SingButtonProps) {
  return (
    <div className="flex flex-col items-center gap-3">
      <button
        onTouchStart={onPressStart}
        onTouchEnd={onPressEnd}
        onMouseDown={onPressStart}
        onMouseUp={onPressEnd}
        onMouseLeave={onPressEnd}
        className={`relative w-20 h-20 rounded-full flex items-center justify-center transition-all ${
          isPressed
            ? "bg-destructive scale-95 shadow-lg"
            : "bg-primary shadow-md hover:shadow-lg"
        }`}
      >
        {/* 录音动画环 */}
        {isPressed && (
          <>
            <span className="absolute inset-0 rounded-full bg-destructive animate-ping opacity-30" />
            <span className="absolute inset-[-4px] rounded-full border-2 border-destructive/50 animate-pulse" />
          </>
        )}
        <Mic className={`w-8 h-8 ${isPressed ? 'text-white' : 'text-white'}`} />
      </button>
      <p className={`text-[14px] font-medium ${isPressed ? 'text-destructive' : 'text-muted-foreground'}`}>
        {isPressed ? "松开结束" : "按住演唱"}
      </p>
    </div>
  )
}
