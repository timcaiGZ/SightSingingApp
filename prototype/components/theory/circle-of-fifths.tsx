"use client"

import { useState } from "react"

interface CircleOfFifthsProps {
  highlightKey?: string
  onKeySelect?: (key: string) => void
}

// 五度圈数据
const majorKeys = [
  { key: "C", sharps: 0, position: 0 },
  { key: "G", sharps: 1, position: 30 },
  { key: "D", sharps: 2, position: 60 },
  { key: "A", sharps: 3, position: 90 },
  { key: "E", sharps: 4, position: 120 },
  { key: "B", sharps: 5, position: 150 },
  { key: "F#", sharps: 6, position: 180 },
  { key: "Db", flats: 5, position: 210 },
  { key: "Ab", flats: 4, position: 240 },
  { key: "Eb", flats: 3, position: 270 },
  { key: "Bb", flats: 2, position: 300 },
  { key: "F", flats: 1, position: 330 },
]

const minorKeys = [
  { key: "Am", position: 0 },
  { key: "Em", position: 30 },
  { key: "Bm", position: 60 },
  { key: "F#m", position: 90 },
  { key: "C#m", position: 120 },
  { key: "G#m", position: 150 },
  { key: "D#m", position: 180 },
  { key: "Bbm", position: 210 },
  { key: "Fm", position: 240 },
  { key: "Cm", position: 270 },
  { key: "Gm", position: 300 },
  { key: "Dm", position: 330 },
]

export default function CircleOfFifths({ highlightKey, onKeySelect }: CircleOfFifthsProps) {
  const [selectedKey, setSelectedKey] = useState(highlightKey || "C")
  
  const handleKeyClick = (key: string) => {
    setSelectedKey(key)
    onKeySelect?.(key)
  }
  
  // 计算圆上的坐标
  const getPosition = (angle: number, radius: number) => {
    const radian = (angle - 90) * (Math.PI / 180)
    return {
      x: 150 + radius * Math.cos(radian),
      y: 150 + radius * Math.sin(radian),
    }
  }

  return (
    <div className="bg-card rounded-2xl p-4 border border-border">
      <div className="text-[15px] font-semibold text-foreground mb-3">五度圈</div>
      
      <svg viewBox="0 0 300 300" className="w-full max-w-[280px] mx-auto">
        {/* 外圈背景 */}
        <circle cx="150" cy="150" r="130" fill="none" stroke="currentColor" strokeWidth="1" className="text-border" />
        <circle cx="150" cy="150" r="85" fill="none" stroke="currentColor" strokeWidth="1" className="text-border" />
        
        {/* 升降号标记区域 */}
        <circle cx="150" cy="150" r="45" className="fill-secondary" />
        
        {/* 大调 (外圈) */}
        {majorKeys.map((item) => {
          const pos = getPosition(item.position, 107)
          const isSelected = selectedKey === item.key
          
          return (
            <g key={item.key} onClick={() => handleKeyClick(item.key)} className="cursor-pointer">
              <circle
                cx={pos.x}
                cy={pos.y}
                r="20"
                className={`transition-all ${
                  isSelected 
                    ? "fill-primary" 
                    : "fill-card hover:fill-secondary"
                }`}
                stroke="currentColor"
                strokeWidth="1"
              />
              <text
                x={pos.x}
                y={pos.y + 5}
                textAnchor="middle"
                className={`text-[14px] font-bold pointer-events-none ${
                  isSelected ? "fill-primary-foreground" : "fill-foreground"
                }`}
              >
                {item.key}
              </text>
            </g>
          )
        })}
        
        {/* 小调 (内圈) */}
        {minorKeys.map((item) => {
          const pos = getPosition(item.position, 62)
          const isSelected = selectedKey === item.key
          
          return (
            <g key={item.key} onClick={() => handleKeyClick(item.key)} className="cursor-pointer">
              <circle
                cx={pos.x}
                cy={pos.y}
                r="15"
                className={`transition-all ${
                  isSelected 
                    ? "fill-primary" 
                    : "fill-card hover:fill-secondary"
                }`}
                stroke="currentColor"
                strokeWidth="1"
              />
              <text
                x={pos.x}
                y={pos.y + 4}
                textAnchor="middle"
                className={`text-[10px] font-medium pointer-events-none ${
                  isSelected ? "fill-primary-foreground" : "fill-muted-foreground"
                }`}
              >
                {item.key}
              </text>
            </g>
          )
        })}
        
        {/* 中心文字 */}
        <text x="150" y="145" textAnchor="middle" className="fill-muted-foreground text-[10px]">
          升号
        </text>
        <text x="150" y="160" textAnchor="middle" className="fill-muted-foreground text-[10px]">
          降号
        </text>
      </svg>
      
      {/* 选中调的信息 */}
      <div className="mt-4 pt-4 border-t border-border">
        <div className="text-center">
          <span className="text-[20px] font-bold text-primary">{selectedKey}</span>
          <span className="text-[14px] text-muted-foreground ml-2">
            {selectedKey.includes("m") ? "小调" : "大调"}
          </span>
        </div>
        <div className="mt-2 text-[13px] text-muted-foreground text-center">
          {getKeyInfo(selectedKey)}
        </div>
      </div>
    </div>
  )
}

// 获取调的信息
function getKeyInfo(key: string): string {
  const info: Record<string, string> = {
    "C": "无升降号",
    "G": "1个升号 (F#)",
    "D": "2个升号 (F#, C#)",
    "A": "3个升号 (F#, C#, G#)",
    "E": "4个升号 (F#, C#, G#, D#)",
    "B": "5个升号 (F#, C#, G#, D#, A#)",
    "F#": "6个升号",
    "F": "1个降号 (Bb)",
    "Bb": "2个降号 (Bb, Eb)",
    "Eb": "3个降号 (Bb, Eb, Ab)",
    "Ab": "4个降号 (Bb, Eb, Ab, Db)",
    "Db": "5个降号",
    "Am": "关系大调: C",
    "Em": "关系大调: G",
    "Bm": "关系大调: D",
    "F#m": "关系大调: A",
    "C#m": "关系大调: E",
    "G#m": "关系大调: B",
    "D#m": "关系大调: F#",
    "Dm": "关系大调: F",
    "Gm": "关系大调: Bb",
    "Cm": "关系大调: Eb",
    "Fm": "关系大调: Ab",
    "Bbm": "关系大调: Db",
  }
  return info[key] || ""
}

// 迷你五度圈（用于卡片展示）
export function MiniCircleOfFifths({ highlightKey }: { highlightKey?: string }) {
  const getPosition = (angle: number, radius: number) => {
    const radian = (angle - 90) * (Math.PI / 180)
    return {
      x: 50 + radius * Math.cos(radian),
      y: 50 + radius * Math.sin(radian),
    }
  }

  return (
    <svg viewBox="0 0 100 100" className="w-20 h-20">
      <circle cx="50" cy="50" r="42" fill="none" stroke="currentColor" strokeWidth="1" className="text-border" />
      <circle cx="50" cy="50" r="28" fill="none" stroke="currentColor" strokeWidth="1" className="text-border" />
      
      {majorKeys.map((item) => {
        const pos = getPosition(item.position, 35)
        const isHighlighted = highlightKey === item.key
        
        return (
          <text
            key={item.key}
            x={pos.x}
            y={pos.y + 3}
            textAnchor="middle"
            className={`text-[7px] font-medium ${
              isHighlighted ? "fill-primary" : "fill-foreground"
            }`}
          >
            {item.key}
          </text>
        )
      })}
    </svg>
  )
}
