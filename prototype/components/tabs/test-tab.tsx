"use client"

import { Clock, Target, Trophy, ChevronRight } from "lucide-react"

interface TestTabProps {
  onTestSelect: (testId: string) => void
}

// 测试数据
const tests = [
  {
    id: "basic-theory",
    title: "乐理基础测试",
    questionCount: 20,
    timeLimit: 15,
    bestScore: 85,
    attempts: 3,
    category: "乐理",
  },
  {
    id: "interval-test",
    title: "音程听辨测试",
    questionCount: 15,
    timeLimit: 10,
    bestScore: 72,
    attempts: 2,
    category: "听力",
  },
  {
    id: "chord-test",
    title: "和弦辨认测试",
    questionCount: 15,
    timeLimit: 12,
    bestScore: null,
    attempts: 0,
    category: "听力",
  },
  {
    id: "rhythm-test",
    title: "节奏测试",
    questionCount: 10,
    timeLimit: 8,
    bestScore: 90,
    attempts: 5,
    category: "节奏",
  },
  {
    id: "sight-singing-test",
    title: "视唱综合测试",
    questionCount: 10,
    timeLimit: 15,
    bestScore: null,
    attempts: 0,
    category: "视唱",
  },
]

export default function TestTab({ onTestSelect }: TestTabProps) {
  return (
    <div className="px-4 py-4 space-y-4">
      <h2 className="text-[28px] font-bold text-foreground px-1">测试中心</h2>
      
      {/* 统计卡片 */}
      <div className="grid grid-cols-3 gap-3">
        <div className="bg-card rounded-xl p-3 border border-border text-center">
          <Trophy className="w-6 h-6 text-warning mx-auto mb-1" />
          <p className="text-[20px] font-bold text-foreground">5</p>
          <p className="text-[11px] text-muted-foreground">已完成</p>
        </div>
        <div className="bg-card rounded-xl p-3 border border-border text-center">
          <Target className="w-6 h-6 text-success mx-auto mb-1" />
          <p className="text-[20px] font-bold text-foreground">82%</p>
          <p className="text-[11px] text-muted-foreground">平均分</p>
        </div>
        <div className="bg-card rounded-xl p-3 border border-border text-center">
          <Clock className="w-6 h-6 text-accent mx-auto mb-1" />
          <p className="text-[20px] font-bold text-foreground">45</p>
          <p className="text-[11px] text-muted-foreground">分钟</p>
        </div>
      </div>

      {/* 测试列表 */}
      <div className="bg-card rounded-2xl border border-border overflow-hidden">
        <div className="px-4 py-3 border-b border-border">
          <h3 className="text-[15px] font-semibold text-foreground">可用测试</h3>
        </div>
        <div className="divide-y divide-border">
          {tests.map((test) => (
            <button
              key={test.id}
              onClick={() => onTestSelect(test.id)}
              className="w-full flex items-center justify-between px-4 py-3 ios-press text-left"
            >
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2 mb-1">
                  <span className="text-[15px] font-medium text-foreground">
                    {test.title}
                  </span>
                  <span className="px-2 py-0.5 bg-secondary rounded-full text-[11px] text-muted-foreground">
                    {test.category}
                  </span>
                </div>
                <div className="flex items-center gap-3 text-[13px] text-muted-foreground">
                  <span>{test.questionCount} 题</span>
                  <span>{test.timeLimit} 分钟</span>
                  {test.bestScore !== null && (
                    <span className="text-success">最高 {test.bestScore} 分</span>
                  )}
                </div>
              </div>
              <ChevronRight className="w-5 h-5 text-muted-foreground/50 flex-shrink-0" />
            </button>
          ))}
        </div>
      </div>
    </div>
  )
}
