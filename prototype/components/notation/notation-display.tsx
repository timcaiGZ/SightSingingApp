"use client"

import { useState } from "react"
import StaffNotation from "./staff-notation"
import GuitarTab from "./guitar-tab"
import SolfegeNotation from "./solfege-notation"

type NotationType = "staff" | "tabSolfege"

interface NotationDisplayProps {
  notationType?: NotationType
  showSwitcher?: boolean
  highlightIndex?: number
}

// 示例数据
const exampleStaffNotes = [
  { pitch: "C", octave: 4, duration: "quarter" as const },
  { pitch: "D", octave: 4, duration: "quarter" as const },
  { pitch: "E", octave: 4, duration: "quarter" as const },
  { pitch: "F", octave: 4, duration: "quarter" as const },
  { pitch: "G", octave: 4, duration: "half" as const },
]

const exampleTabNotes = [
  [{ string: 5, fret: 3 }],
  [{ string: 4, fret: 0 }],
  [{ string: 4, fret: 2 }],
  [{ string: 4, fret: 3 }],
  [{ string: 3, fret: 0 }],
]

const exampleSolfegeNotes = [
  { number: 1, octave: "middle" as const, duration: "quarter" as const },
  { number: 2, octave: "middle" as const, duration: "quarter" as const },
  { number: 3, octave: "middle" as const, duration: "quarter" as const },
  { number: 4, octave: "middle" as const, duration: "quarter" as const },
  { number: 5, octave: "middle" as const, duration: "half" as const },
]

export default function NotationDisplay({ 
  notationType: initialType = "tabSolfege",
  showSwitcher = true,
  highlightIndex,
}: NotationDisplayProps) {
  const [notationType, setNotationType] = useState<NotationType>(initialType)

  return (
    <div className="space-y-4">
      {/* 谱式切换器 */}
      {showSwitcher && (
        <div className="flex justify-center">
          <div className="flex p-1 bg-secondary rounded-full">
            <button
              onClick={() => setNotationType("staff")}
              className={`px-4 py-1.5 text-[13px] font-medium rounded-full transition-all ${
                notationType === "staff"
                  ? "bg-primary text-primary-foreground"
                  : "text-muted-foreground"
              }`}
            >
              五线谱
            </button>
            <button
              onClick={() => setNotationType("tabSolfege")}
              className={`px-4 py-1.5 text-[13px] font-medium rounded-full transition-all ${
                notationType === "tabSolfege"
                  ? "bg-primary text-primary-foreground"
                  : "text-muted-foreground"
              }`}
            >
              六线谱+简谱
            </button>
          </div>
        </div>
      )}

      {/* 谱式显示 */}
      {notationType === "staff" ? (
        <StaffNotation 
          notes={exampleStaffNotes} 
          highlightIndex={highlightIndex} 
        />
      ) : (
        <div className="space-y-3">
          <GuitarTab 
            notes={exampleTabNotes} 
            highlightIndex={highlightIndex} 
          />
          <SolfegeNotation 
            notes={exampleSolfegeNotes} 
            highlightIndex={highlightIndex} 
          />
        </div>
      )}
    </div>
  )
}
