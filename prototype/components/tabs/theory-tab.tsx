"use client"

import { useState } from "react"
import { ChevronRight, ChevronDown, BookOpen, Music, Layers, Piano, Music2, Gauge, Search } from "lucide-react"

interface TheoryTabProps {
  onTopicSelect: (topicId: string) => void
}

// 分类图标映射
const categoryIcons: Record<string, React.ReactNode> = {
  basic: <BookOpen className="w-4 h-4 text-white" />,
  notation: <Music className="w-4 h-4 text-white" />,
  interval: <Layers className="w-4 h-4 text-white" />,
  chord: <Piano className="w-4 h-4 text-white" />,
  mode: <Music2 className="w-4 h-4 text-white" />,
  rhythm: <Gauge className="w-4 h-4 text-white" />,
}

// 分类颜色映射 - Solfeggio 风格
const categoryColors: Record<string, string> = {
  basic: "bg-primary",
  notation: "bg-success",
  interval: "bg-module-interval",
  chord: "bg-module-chord",
  mode: "bg-module-scale",
  rhythm: "bg-warning",
}

// 乐理知识结构
const theoryCategories = [
  {
    id: "basic",
    title: "基础乐理",
    topics: [
      { id: "notes", title: "认识音符", description: "音符的构成、时值关系" },
      { id: "pitch-names", title: "音名与唱名", description: "C-D-E-F-G-A-B 系统" },
      { id: "whole-half", title: "全音与半音", description: "吉他指板上的全半音关系" },
      { id: "note-duration", title: "音符时值", description: "全音符到十六分音符" },
      { id: "beat-signature", title: "节拍与拍号", description: "4/4, 3/4, 6/8 等常见拍号" },
      { id: "rhythm-basics", title: "节奏基础", description: "基本节奏型和休止符" },
    ],
  },
  {
    id: "notation",
    title: "识谱知识",
    topics: [
      { id: "staff-intro", title: "五线谱入门", description: "五线谱构成与谱号" },
      { id: "solfege-intro", title: "简谱入门", description: "数字记谱法" },
      { id: "tab-reading", title: "六线谱识谱", description: "吉他专用谱表" },
      { id: "clef-key", title: "谱号与调号", description: "调号的识别与应用" },
    ],
  },
  {
    id: "interval",
    title: "音程",
    topics: [
      { id: "interval-concept", title: "音程的概念", description: "度数与音数" },
      { id: "guitar-intervals", title: "吉他常用音程", description: "纯一度到纯八度" },
      { id: "interval-quality", title: "音程的性质", description: "大、小、纯、增、减" },
      { id: "interval-hearing", title: "音程的听辨技巧", description: "协和与不协和音程" },
    ],
  },
  {
    id: "chord",
    title: "和弦",
    topics: [
      { id: "triads", title: "三和弦", description: "大三、小三、增三、减三" },
      { id: "seventh-chords", title: "七和弦", description: "属七、大七、小七和弦" },
      { id: "inversions", title: "和弦转位", description: "第一、第二转位" },
      { id: "guitar-chords", title: "吉他和弦指法", description: "开放和弦与横按和弦" },
      { id: "chord-hearing", title: "和弦听辨", description: "和弦色彩与进行" },
    ],
  },
  {
    id: "mode",
    title: "调式",
    topics: [
      { id: "major-scale", title: "大调音阶", description: "自然大调结构" },
      { id: "minor-scale", title: "小调音阶", description: "自然、和声、旋律小调" },
      { id: "mode-relation", title: "调式关系", description: "关系大小调" },
      { id: "church-modes", title: "中古调式", description: "多利亚、弗里几亚等" },
    ],
  },
  {
    id: "rhythm",
    title: "节奏",
    topics: [
      { id: "time-signatures", title: "节拍与拍号", description: "单拍子、复拍子" },
      { id: "rhythm-patterns", title: "常用节奏型", description: "切分、附点节奏" },
      { id: "tuplets", title: "三连音与多连音", description: "连音的演奏" },
      { id: "compound-rhythm", title: "复合节奏", description: "复节奏训练" },
    ],
  },
]

// 知识点卡片组件
function TopicCard({ 
  title, 
  description, 
  onClick 
}: { 
  title: string
  description: string
  onClick: () => void 
}) {
  return (
    <button
      onClick={onClick}
      className="w-full flex items-center justify-between px-4 py-3.5 bg-card hover:bg-secondary/50 transition-colors ios-press"
    >
      <div className="flex-1 min-w-0 text-left">
        <p className="text-[15px] font-medium text-foreground">{title}</p>
        <p className="text-[13px] text-muted-foreground mt-0.5 truncate">
          {description}
        </p>
      </div>
      <ChevronRight className="w-5 h-5 text-muted-foreground/40 flex-shrink-0 ml-3" />
    </button>
  )
}

export default function TheoryTab({ onTopicSelect }: TheoryTabProps) {
  const [expandedCategories, setExpandedCategories] = useState<string[]>(["basic"])
  const [searchQuery, setSearchQuery] = useState("")

  const toggleCategory = (categoryId: string) => {
    setExpandedCategories((prev) =>
      prev.includes(categoryId)
        ? prev.filter((id) => id !== categoryId)
        : [...prev, categoryId]
    )
  }

  // 搜索过滤
  const filteredCategories = searchQuery
    ? theoryCategories.map(cat => ({
        ...cat,
        topics: cat.topics.filter(
          topic => 
            topic.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
            topic.description.toLowerCase().includes(searchQuery.toLowerCase())
        )
      })).filter(cat => cat.topics.length > 0)
    : theoryCategories

  return (
    <div className="pb-4">
      {/* 页面标题 */}
      <div className="px-4 pt-2 pb-4">
        <h1 className="text-[34px] font-bold text-foreground">乐理知识</h1>
        <p className="text-[15px] text-muted-foreground mt-1">音乐理论词典与学习资料</p>
      </div>
      
      {/* 搜索框 - Solfeggio 风格 */}
      <div className="px-4 mb-4">
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-muted-foreground" />
          <input
            type="text"
            placeholder="搜索乐理知识..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full h-11 pl-10 pr-4 bg-secondary/50 rounded-xl text-[15px] text-foreground placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-primary/20"
          />
        </div>
      </div>
      
      {/* 分类列表 */}
      <div className="space-y-4">
        {filteredCategories.map((category) => {
          const isExpanded = expandedCategories.includes(category.id) || searchQuery !== ""
          
          return (
            <div key={category.id}>
              {/* 分类标题 */}
              <button
                onClick={() => !searchQuery && toggleCategory(category.id)}
                className="w-full flex items-center gap-2 px-4 py-2 ios-press"
              >
                <div className={`w-8 h-8 rounded-lg ${categoryColors[category.id]} flex items-center justify-center`}>
                  {categoryIcons[category.id]}
                </div>
                <span className="text-[17px] font-semibold text-foreground flex-1 text-left">
                  {category.title}
                </span>
                <span className="text-[13px] text-muted-foreground mr-1">
                  {category.topics.length}
                </span>
                {!searchQuery && (
                  <ChevronDown
                    className={`w-5 h-5 text-muted-foreground transition-transform ${
                      isExpanded ? "rotate-180" : ""
                    }`}
                  />
                )}
              </button>

              {/* 知识点列表 */}
              {isExpanded && (
                <div className="mx-4 bg-card rounded-xl overflow-hidden divide-y divide-border shadow-sm mt-2">
                  {category.topics.map((topic) => (
                    <TopicCard
                      key={topic.id}
                      title={topic.title}
                      description={topic.description}
                      onClick={() => onTopicSelect(topic.id)}
                    />
                  ))}
                </div>
              )}
            </div>
          )
        })}
      </div>
      
      {/* 搜索无结果 */}
      {searchQuery && filteredCategories.length === 0 && (
        <div className="flex flex-col items-center justify-center py-12 px-4">
          <div className="w-16 h-16 rounded-full bg-secondary flex items-center justify-center mb-4">
            <Search className="w-8 h-8 text-muted-foreground" />
          </div>
          <p className="text-[17px] font-medium text-foreground mb-1">未找到结果</p>
          <p className="text-[14px] text-muted-foreground text-center">
            没有找到与"{searchQuery}"相关的乐理知识
          </p>
        </div>
      )}
    </div>
  )
}
