"use client"

import { useState } from "react"
import NavBar from "@/components/nav-bar"
import ProgressDots from "@/components/progress-dots"
import { ChevronRight, Check, Lock, Play } from "lucide-react"

interface CourseDetailProps {
  courseId: string
  onBack: () => void
  onLessonSelect: (lessonId: string) => void
}

// 获取课程标题
function getCourseTitle(courseId: string): string {
  const titles: Record<string, string> = {
    "music-theory": "乐理基础",
    "sight-singing": "视唱入门",
    "rhythm": "节奏训练",
    "ear-training": "听力训练",
  }
  return titles[courseId] || "课程"
}

// 获取课程章节
function getCourseLessons(courseId: string) {
  const lessonData: Record<string, Array<{ id: string; title: string; duration: number; status: "completed" | "current" | "locked" }>> = {
    "music-theory": [
      { id: "1", title: "认识音符", duration: 8, status: "completed" },
      { id: "2", title: "音名与唱名", duration: 10, status: "completed" },
      { id: "3", title: "全音与半音", duration: 12, status: "completed" },
      { id: "4", title: "音符时值", duration: 15, status: "completed" },
      { id: "5", title: "节拍与拍号", duration: 12, status: "current" },
      { id: "6", title: "简谱入门", duration: 10, status: "locked" },
      { id: "7", title: "六线谱识谱", duration: 15, status: "locked" },
      { id: "8", title: "节奏基础", duration: 12, status: "locked" },
      { id: "9", title: "休止符", duration: 8, status: "locked" },
    ],
    "sight-singing": [
      { id: "1", title: "C大调音阶", duration: 15, status: "locked" },
      { id: "2", title: "音程构唱", duration: 12, status: "locked" },
      { id: "3", title: "二声部视唱", duration: 18, status: "locked" },
      { id: "4", title: "节奏视唱", duration: 15, status: "locked" },
      { id: "5", title: "综合练习", duration: 20, status: "locked" },
    ],
    "rhythm": [
      { id: "1", title: "四分音符节奏", duration: 10, status: "locked" },
      { id: "2", title: "八分音符节奏", duration: 12, status: "locked" },
      { id: "3", title: "十六分音符节奏", duration: 15, status: "locked" },
      { id: "4", title: "切分节奏", duration: 12, status: "locked" },
      { id: "5", title: "三连音", duration: 10, status: "locked" },
      { id: "6", title: "复合节奏", duration: 18, status: "locked" },
    ],
    "ear-training": [
      { id: "1", title: "音高辨别", duration: 12, status: "locked" },
      { id: "2", title: "音程听辨", duration: 15, status: "locked" },
      { id: "3", title: "和弦听辨", duration: 18, status: "locked" },
      { id: "4", title: "节奏模仿", duration: 12, status: "locked" },
      { id: "5", title: "旋律听写", duration: 20, status: "locked" },
    ],
  }
  return lessonData[courseId] || []
}

export default function CourseDetail({ courseId, onBack, onLessonSelect }: CourseDetailProps) {
  const title = getCourseTitle(courseId)
  const lessons = getCourseLessons(courseId)
  const completedCount = lessons.filter(l => l.status === "completed").length

  return (
    <div className="min-h-screen bg-background">
      <NavBar title={title} showBack onBack={onBack} />

      <div className="px-4 py-4 space-y-4">
        {/* 课程进度卡片 */}
        <div className="bg-card rounded-2xl p-4 border border-border">
          <div className="flex items-center justify-between mb-3">
            <span className="text-[13px] text-muted-foreground">课程进度</span>
            <span className="text-[13px] text-muted-foreground">
              {completedCount}/{lessons.length} 课时
            </span>
          </div>
          <ProgressDots total={lessons.length} current={completedCount} size="md" />
        </div>

        {/* 课时列表 */}
        <div className="bg-card rounded-2xl border border-border overflow-hidden">
          <div className="px-4 py-3 border-b border-border">
            <h3 className="text-[15px] font-semibold text-foreground">课时列表</h3>
          </div>
          <div className="divide-y divide-border">
            {lessons.map((lesson, index) => (
              <button
                key={lesson.id}
                onClick={() => lesson.status !== "locked" && onLessonSelect(lesson.id)}
                disabled={lesson.status === "locked"}
                className={`w-full flex items-center gap-3 px-4 py-3 text-left ios-press ${
                  lesson.status === "locked" ? "opacity-50" : ""
                }`}
              >
                {/* 状态图标 */}
                <div className={`w-8 h-8 rounded-full flex items-center justify-center ${
                  lesson.status === "completed"
                    ? "bg-success text-success-foreground"
                    : lesson.status === "current"
                    ? "bg-accent text-accent-foreground"
                    : "bg-secondary text-muted-foreground"
                }`}>
                  {lesson.status === "completed" ? (
                    <Check className="w-4 h-4" />
                  ) : lesson.status === "current" ? (
                    <Play className="w-4 h-4" fill="currentColor" />
                  ) : (
                    <Lock className="w-4 h-4" />
                  )}
                </div>

                {/* 课时信息 */}
                <div className="flex-1 min-w-0">
                  <p className={`text-[15px] ${
                    lesson.status === "current" ? "font-semibold text-foreground" : "text-foreground"
                  }`}>
                    {index + 1}. {lesson.title}
                  </p>
                  <p className="text-[13px] text-muted-foreground">
                    {lesson.duration} 分钟
                  </p>
                </div>

                {/* 箭头 */}
                {lesson.status !== "locked" && (
                  <ChevronRight className="w-5 h-5 text-muted-foreground/50" />
                )}
              </button>
            ))}
          </div>
        </div>
      </div>
    </div>
  )
}
