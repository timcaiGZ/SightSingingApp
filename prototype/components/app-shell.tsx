"use client"

import { useState, createContext, useContext, type ReactNode } from "react"
import { Music, BookOpen, CheckCircle, User } from "lucide-react"

type TabType = "practice" | "theory" | "test" | "profile"

interface TabContextType {
  activeTab: TabType
  setActiveTab: (tab: TabType) => void
}

const TabContext = createContext<TabContextType | undefined>(undefined)

export function useTab() {
  const context = useContext(TabContext)
  if (!context) {
    throw new Error("useTab must be used within a TabProvider")
  }
  return context
}

const tabs: { id: TabType; label: string; icon: typeof Music }[] = [
  { id: "practice", label: "练习", icon: Music },
  { id: "theory", label: "乐理", icon: BookOpen },
  { id: "test", label: "测试", icon: CheckCircle },
  { id: "profile", label: "我的", icon: User },
]

export default function AppShell({ children }: { children: ReactNode }) {
  const [activeTab, setActiveTab] = useState<TabType>("practice")

  return (
    <TabContext.Provider value={{ activeTab, setActiveTab }}>
      <div className="min-h-screen bg-background">
        <main className="pb-[84px]">{children}</main>
        <nav className="fixed bottom-0 left-0 right-0 z-50 bg-tab-bar/95 ios-blur border-t border-tab-bar-border safe-area-bottom">
          <div className="flex items-center justify-around h-[50px] max-w-md mx-auto">
            {tabs.map(({ id, label, icon: Icon }) => {
              const isActive = activeTab === id
              return (
                <button
                  key={id}
                  onClick={() => setActiveTab(id)}
                  className={`flex flex-col items-center justify-center gap-0.5 w-full h-full ios-press ${
                    isActive ? "text-tab-active" : "text-tab-inactive"
                  }`}
                >
                  <Icon className="w-6 h-6" strokeWidth={isActive ? 2 : 1.5} />
                  <span className={`text-[10px] ${isActive ? "font-medium" : "font-normal"}`}>
                    {label}
                  </span>
                </button>
              )
            })}
          </div>
        </nav>
      </div>
    </TabContext.Provider>
  )
}
