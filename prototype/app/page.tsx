"use client"

import { useState } from "react"
import AppShell, { useTab } from "@/components/app-shell"
import PracticeTab from "@/components/tabs/practice-tab"
import TheoryTab from "@/components/tabs/theory-tab"
import TestTab from "@/components/tabs/test-tab"
import ProfileTab from "@/components/tabs/profile-tab"
import ExerciseDetail from "@/components/exercise/exercise-detail"
import SightSingingView from "@/components/exercise/sight-singing-view"
import TestSession from "@/components/exercise/test-session"
import TheoryDetail from "@/components/theory/theory-detail"
import SeventhChordsDetail from "@/components/theory/seventh-chords-detail"

type ViewState =
  | { type: "tabs" }
  | { type: "exercise"; exerciseId: string; moduleId: string }
  | { type: "test"; testId: string }
  | { type: "theory"; topicId: string }

function MainContent() {
  const { activeTab } = useTab()
  const [viewState, setViewState] = useState<ViewState>({ type: "tabs" })

  const handleBack = () => setViewState({ type: "tabs" })

  if (viewState.type === "exercise") {
    if (viewState.exerciseId.endsWith("-sing") || viewState.exerciseId === "interval-construct") {
      return (
        <SightSingingView
          exerciseId={viewState.exerciseId}
          onBack={handleBack}
          onComplete={() => handleBack()}
        />
      )
    }
    return (
      <ExerciseDetail
        exerciseId={viewState.exerciseId}
        moduleId={viewState.moduleId}
        onBack={handleBack}
      />
    )
  }

  if (viewState.type === "test") {
    return <TestSession testId={viewState.testId} onBack={handleBack} />
  }

  if (viewState.type === "theory") {
    if (viewState.topicId === "seventh-chords") {
      return <SeventhChordsDetail onBack={handleBack} />
    }
    return <TheoryDetail topicId={viewState.topicId} onBack={handleBack} />
  }

  switch (activeTab) {
    case "practice":
      return (
        <PracticeTab
          onExerciseSelect={(exerciseId, moduleId) => {
            setViewState({ type: "exercise", exerciseId, moduleId })
          }}
        />
      )
    case "theory":
      return (
        <TheoryTab
          onTopicSelect={(topicId) => setViewState({ type: "theory", topicId })}
        />
      )
    case "test":
      return (
        <TestTab
          onTestSelect={(testId) => setViewState({ type: "test", testId })}
        />
      )
    case "profile":
      return <ProfileTab />
    default:
      return null
  }
}

export default function Home() {
  return (
    <AppShell>
      <MainContent />
    </AppShell>
  )
}
