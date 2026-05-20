"use client"

import { Headphones, Mic, Music, Layers, Piano } from "lucide-react"
import { ModuleCard, ModuleItem } from "../module-card"

interface PracticeTabProps {
  onExerciseSelect: (exerciseId: string, moduleId: string) => void
}

// 练习模块数据
const practiceModules = [
  {
    id: "hearing",
    title: "听力训练",
    icon: <Headphones className="w-4 h-4" />,
    accentColor: "bg-primary",
    exercises: [
      { id: "single-note", title: "单音辨认", progress: 8, total: 10, percentage: 85 },
      { id: "interval", title: "音程听辨", progress: 7, total: 10, percentage: 72 },
      { id: "chord", title: "和弦辨认", progress: 0, total: 10, percentage: 0 },
      { id: "rhythm-hear", title: "节奏辨认", progress: 5, total: 10, percentage: 60 },
      { id: "melody-dictation", title: "旋律听写", progress: 2, total: 10, percentage: 25 },
    ],
  },
  {
    id: "sightSinging",
    title: "视唱练习",
    icon: <Mic className="w-4 h-4" />,
    accentColor: "bg-success",
    exercises: [
      { id: "single-sing", title: "单音视唱", progress: 9, total: 10, percentage: 90 },
      { id: "interval-sing", title: "音程构唱", progress: 6, total: 10, percentage: 55 },
      { id: "melody-sing", title: "旋律视唱", progress: 4, total: 10, percentage: 62 },
      { id: "rhythm-sing", title: "节奏视唱", progress: 5, total: 10, percentage: 50 },
    ],
  },
  {
    id: "rhythm",
    title: "节奏训练",
    icon: <Music className="w-4 h-4" />,
    accentColor: "bg-warning",
    exercises: [
      { id: "quarter-rhythm", title: "四分音符节奏", progress: 10, total: 10, percentage: 100 },
      { id: "eighth-rhythm", title: "八分音符节奏", progress: 7, total: 10, percentage: 78 },
      { id: "sixteenth-rhythm", title: "十六分音符节奏", progress: 3, total: 10, percentage: 35 },
      { id: "syncopation", title: "切分节奏", progress: 2, total: 10, percentage: 20 },
      { id: "triplet", title: "三连音", progress: 1, total: 10, percentage: 15 },
    ],
  },
  {
    id: "intervalTraining",
    title: "音程训练",
    icon: <Layers className="w-4 h-4" />,
    accentColor: "bg-module-interval",
    exercises: [
      { id: "interval-compare", title: "音程比较", progress: 6, total: 10, percentage: 65 },
      { id: "interval-identify", title: "音程辨认", progress: 5, total: 10, percentage: 58 },
      { id: "interval-construct", title: "音程构唱", progress: 4, total: 10, percentage: 48 },
    ],
  },
  {
    id: "chordTraining",
    title: "和弦训练",
    icon: <Piano className="w-4 h-4" />,
    accentColor: "bg-module-chord",
    exercises: [
      { id: "triad", title: "三和弦辨认", progress: 4, total: 10, percentage: 52 },
      { id: "seventh-chord", title: "七和弦辨认", progress: 2, total: 10, percentage: 28 },
      { id: "chord-inversion", title: "和弦转位辨认", progress: 1, total: 10, percentage: 12 },
    ],
  },
]

export default function PracticeTab({ onExerciseSelect }: PracticeTabProps) {
  return (
    <div className="pb-4">
      {/* 页面标题 */}
      <div className="px-4 pt-2 pb-4">
        <h1 className="text-[28px] font-bold text-foreground">自由练习</h1>
      </div>
      
      {/* 练习模块列表 */}
      <div className="px-4 space-y-4">
        {practiceModules.map((module) => (
          <ModuleCard
            key={module.id}
            title={module.title}
            icon={module.icon}
            accentColor={module.accentColor}
          >
            {module.exercises.map((exercise) => (
              <ModuleItem
                key={exercise.id}
                title={exercise.title}
                percentage={exercise.percentage}
                onClick={() => onExerciseSelect(exercise.id, module.id)}
              />
            ))}
          </ModuleCard>
        ))}
      </div>
    </div>
  )
}
