import SwiftUI

// MARK: - 谱式展示视图 (V2.1 新增复用组件)

/// 统一的谱式展示组件，支持五线谱和六线谱+简谱组合
struct NotationDisplayView: View {
    let notationType: NotationType
    let guitarNotes: [GuitarTabNote]
    let solfegeNotes: [SolfegeNote]
    let staffNotes: [StaffNote]
    let highlightedIndex: Int
    let fretRange: ClosedRange<Int>

    init(
        notationType: NotationType,
        guitarNotes: [GuitarTabNote] = [],
        solfegeNotes: [SolfegeNote] = [],
        staffNotes: [StaffNote] = [],
        highlightedIndex: Int = 0,
        fretRange: ClosedRange<Int> = 0...5
    ) {
        self.notationType = notationType
        self.guitarNotes = guitarNotes
        self.solfegeNotes = solfegeNotes
        self.staffNotes = staffNotes
        self.highlightedIndex = highlightedIndex
        self.fretRange = fretRange
    }

    var body: some View {
        Group {
            switch notationType {
            case .tabWithSolfege:
                tabWithSolfegeDisplay
            case .staff:
                StaffNotationView(notes: staffNotes)
            }
        }
    }

    // MARK: - 六线谱+简谱组合视图

    private var tabWithSolfegeDisplay: some View {
        VStack(spacing: 12) {
            // 六线谱
            if !guitarNotes.isEmpty {
                GuitarTablatureView(
                    notes: guitarNotes,
                    fretRange: fretRange
                )
            }

            Divider()

            // 简谱
            if !solfegeNotes.isEmpty {
                SolfegeView(
                    notes: solfegeNotes,
                    highlightedIndex: highlightedIndex
                )
            }
        }
    }
}

// MARK: - 简化版谱式展示视图

/// 简化版谱式展示，无需传入所有参数
struct SimpleNotationDisplayView: View {
    let notationType: NotationType
    let solfegeNotes: [SolfegeNote]
    let highlightedIndex: Int

    var body: some View {
        switch notationType {
        case .tabWithSolfege:
            SolfegeView(
                notes: solfegeNotes,
                highlightedIndex: highlightedIndex
            )
        case .staff:
            StaffNotationView(
                notes: solfegeNotes.map { note in
                    StaffNote(
                        pitch: StaffPitch(line: 0),
                        duration: note.duration,
                        accidental: nil
                    )
                }
            )
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        // 五线谱预览
        NotationDisplayView(
            notationType: .staff,
            staffNotes: [
                StaffNote(pitch: StaffPitch(line: 0), duration: .quarter, accidental: nil),
                StaffNote(pitch: StaffPitch(line: 2), duration: .quarter, accidental: nil)
            ],
            highlightedIndex: 0
        )

        // 六线谱+简谱预览
        NotationDisplayView(
            notationType: .tabWithSolfege,
            guitarNotes: [
                GuitarTabNote(string: 5, fret: 0, technique: nil),
                GuitarTabNote(string: 5, fret: 2, technique: nil)
            ],
            solfegeNotes: [
                SolfegeNote(solfege: "C", octave: 4, duration: .quarter),
                SolfegeNote(solfege: "D", octave: 4, duration: .quarter)
            ],
            highlightedIndex: 0
        )
    }
    .padding()
}
