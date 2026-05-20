"use client"

import { ChevronLeft, Settings } from "lucide-react"

interface NavBarProps {
  title: string
  showBack?: boolean
  onBack?: () => void
  rightAction?: React.ReactNode
  showSettings?: boolean
  onSettings?: () => void
  score?: number
}

export default function NavBar({
  title,
  showBack = false,
  onBack,
  rightAction,
  showSettings = false,
  onSettings,
  score,
}: NavBarProps) {
  return (
    <header className="sticky top-0 z-40 bg-background/95 ios-blur border-b border-border safe-area-top">
      <div className="flex items-center justify-between h-11 px-4">
        {/* 左侧 */}
        <div className="w-20 flex items-center">
          {showBack && (
            <button
              onClick={onBack}
              className="flex items-center gap-0.5 text-accent ios-press -ml-1"
            >
              <ChevronLeft className="w-6 h-6" strokeWidth={2.5} />
              <span className="text-[17px]">返回</span>
            </button>
          )}
        </div>

        {/* 中间标题 */}
        <h1 className="flex-1 text-center text-[17px] font-semibold text-foreground truncate">
          {title}
        </h1>

        {/* 右侧 */}
        <div className="w-20 flex items-center justify-end gap-2">
          {score !== undefined && (
            <span className="text-[15px] font-medium text-accent">
              {score} 分
            </span>
          )}
          {showSettings && (
            <button onClick={onSettings} className="p-1 ios-press">
              <Settings className="w-[22px] h-[22px] text-accent" />
            </button>
          )}
          {rightAction}
        </div>
      </div>
    </header>
  )
}
