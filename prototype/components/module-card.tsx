"use client"

import { ChevronRight } from "lucide-react"
import ProgressRing, { ProgressBar } from "./progress-ring"
import type { ReactNode } from "react"

interface ModuleCardProps {
  title: string
  icon?: ReactNode
  accentColor?: string
  children?: ReactNode
  onClick?: () => void
}

export function ModuleCard({ title, icon, accentColor = "bg-accent", children, onClick }: ModuleCardProps) {
  return (
    <div 
      className="bg-card rounded-2xl shadow-sm overflow-hidden card-hover cursor-pointer"
      onClick={onClick}
    >
      {/* 顶部彩色条 */}
      <div className={`h-1 ${accentColor}`} />
      
      {/* 标题栏 */}
      <div className="flex items-center gap-2 px-4 py-3 border-b border-border">
        {icon && <span className="text-lg">{icon}</span>}
        <h3 className="text-[15px] font-semibold text-foreground">{title}</h3>
      </div>
      
      {/* 内容区 */}
      <div className="divide-y divide-border">
        {children}
      </div>
    </div>
  )
}

interface ModuleItemProps {
  title: string
  progress?: number
  total?: number
  percentage?: number
  onClick?: () => void
}

export function ModuleItem({ title, progress, total, percentage, onClick }: ModuleItemProps) {
  const handleClick = (e: React.MouseEvent) => {
    e.stopPropagation()
    onClick?.()
  }
  
  return (
    <button
      onClick={handleClick}
      className="w-full flex items-center justify-between px-4 py-3 ios-press text-left"
    >
      <span className="text-[15px] text-foreground">{title}</span>
      <div className="flex items-center gap-3">
        {percentage !== undefined && (
          <ProgressRing progress={percentage} size="sm" />
        )}
        {percentage !== undefined && (
          <span className="text-[13px] text-muted-foreground min-w-[32px] text-right">
            {percentage > 0 ? `${percentage}%` : "—"}
          </span>
        )}
        <ChevronRight className="w-4 h-4 text-muted-foreground/50" />
      </div>
    </button>
  )
}

interface CourseCardProps {
  title: string
  icon?: ReactNode
  lessonCount: number
  status: "not-started" | "in-progress" | "completed"
  progress: number
  total: number
  accentColor?: string
  onClick?: () => void
}

export function CourseCard({ 
  title, 
  icon, 
  lessonCount, 
  status, 
  progress, 
  total,
  accentColor = "bg-primary",
  onClick 
}: CourseCardProps) {
  const statusText = {
    "not-started": "未开始",
    "in-progress": "进行中",
    "completed": "已完成"
  }
  
  const percentage = total > 0 ? Math.round((progress / total) * 100) : 0

  return (
    <button 
      className="w-full bg-card rounded-2xl shadow-sm overflow-hidden card-hover text-left"
      onClick={onClick}
    >
      {/* 顶部彩色条 */}
      <div className={`h-1 ${accentColor}`} />
      
      {/* 内容 */}
      <div className="p-4">
        <div className="flex items-start justify-between gap-3">
          <div className="flex-1">
            <div className="flex items-center gap-2 mb-2">
              {icon && <span className="text-lg">{icon}</span>}
              <h3 className="text-[17px] font-semibold text-foreground">{title}</h3>
            </div>
            
            <div className="flex items-center gap-2 text-[13px] text-muted-foreground mb-3">
              <span>{lessonCount}课时</span>
              <span>·</span>
              <span>{statusText[status]}</span>
            </div>
          </div>
          
          <ProgressRing progress={percentage} size="lg" showPercentage />
        </div>
        
        <ProgressBar progress={percentage} height="md" />
        <div className="mt-1.5 text-[12px] text-muted-foreground text-right">
          {progress}/{total} 课时
        </div>
      </div>
    </button>
  )
}
