"use client"

import { CourseCard } from "@/components/module-card"
import { BookOpen, Mic, Music, Headphones } from "lucide-react"

interface CourseTabProps {
  onCourseSelect: (courseId: string) => void
}

// 课程数据
const courses = [
  {
    id: "music-theory",
    title: "乐理基础",
    icon: <BookOpen className="w-5 h-5 text-primary" />,
    lessonCount: 9,
    status: "in-progress" as const,
    progress: 4,
    total: 9,
    accentColor: "bg-primary",
  },
  {
    id: "sight-singing",
    title: "视唱入门",
    icon: <Mic className="w-5 h-5 text-module-melody" />,
    lessonCount: 5,
    status: "not-started" as const,
    progress: 0,
    total: 5,
    accentColor: "bg-module-melody",
  },
  {
    id: "rhythm",
    title: "节奏训练",
    icon: <Music className="w-5 h-5 text-module-rhythm" />,
    lessonCount: 6,
    status: "not-started" as const,
    progress: 0,
    total: 6,
    accentColor: "bg-module-rhythm",
  },
  {
    id: "ear-training",
    title: "听力训练",
    icon: <Headphones className="w-5 h-5 text-module-pitch" />,
    lessonCount: 5,
    status: "not-started" as const,
    progress: 0,
    total: 5,
    accentColor: "bg-module-pitch",
  },
]

export default function CourseTab({ onCourseSelect }: CourseTabProps) {
  return (
    <div className="px-4 py-4 space-y-4">
      <h2 className="text-[28px] font-bold text-foreground px-1">课程学习</h2>
      
      <div className="space-y-3">
        {courses.map((course) => (
          <CourseCard
            key={course.id}
            title={course.title}
            icon={course.icon}
            lessonCount={course.lessonCount}
            status={course.status}
            progress={course.progress}
            total={course.total}
            accentColor={course.accentColor}
            onClick={() => onCourseSelect(course.id)}
          />
        ))}
      </div>
    </div>
  )
}
