"use client"

import { createContext, useContext, useEffect, useState, type ReactNode } from "react"

export type NotationType = "staff" | "tabSolfege"

interface SettingsContextType {
  notationType: NotationType
  setNotationType: (type: NotationType) => void
  darkMode: boolean
  setDarkMode: (mode: boolean) => void
}

const SettingsContext = createContext<SettingsContextType | undefined>(undefined)

const NOTATION_KEY = "sight-singing-notation"
const DARK_KEY = "sight-singing-dark"

export function SettingsProvider({ children }: { children: ReactNode }) {
  const [notationType, setNotationTypeState] = useState<NotationType>("tabSolfege")
  const [darkMode, setDarkModeState] = useState(false)
  const [hydrated, setHydrated] = useState(false)

  useEffect(() => {
    const savedNotation = localStorage.getItem(NOTATION_KEY) as NotationType | null
    const savedDark = localStorage.getItem(DARK_KEY)
    if (savedNotation === "staff" || savedNotation === "tabSolfege") {
      setNotationTypeState(savedNotation)
    }
    if (savedDark === "true") setDarkModeState(true)
    setHydrated(true)
  }, [])

  useEffect(() => {
    if (!hydrated) return
    document.documentElement.classList.toggle("dark", darkMode)
  }, [darkMode, hydrated])

  const setNotationType = (type: NotationType) => {
    setNotationTypeState(type)
    localStorage.setItem(NOTATION_KEY, type)
  }

  const setDarkMode = (mode: boolean) => {
    setDarkModeState(mode)
    localStorage.setItem(DARK_KEY, String(mode))
  }

  return (
    <SettingsContext.Provider
      value={{ notationType, setNotationType, darkMode, setDarkMode }}
    >
      {children}
    </SettingsContext.Provider>
  )
}

export function useSettings() {
  const context = useContext(SettingsContext)
  if (!context) {
    throw new Error("useSettings must be used within a SettingsProvider")
  }
  return context
}
