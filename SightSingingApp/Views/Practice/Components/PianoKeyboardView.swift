import SwiftUI

// MARK: - 钢琴键盘视图（精简两行布局）

/// 音符输入键盘
struct PianoKeyboardView: View {
    @Binding var selectedNote: String?
    @Binding var selectedAccidental: AccidentalState
    let onConfirm: () -> Void
    let onDelete: () -> Void

    enum AccidentalState: String, CaseIterable {
        case natural = "♮"
        case sharp = "♯"
        case flat = "♭"
    }

    private let whiteNotes = ["C", "D", "E", "F", "G", "A", "B"]
    private let topRowNotes = ["C", "D", "E"]
    private let middleRowNotes = ["F", "G", "A"]
    private let bottomRowNotes = ["B"]

    var body: some View {
        VStack(spacing: 8) {
            // 升降号选择行
            accidentalRow

            // 键盘主体
            keyboardRows

            // 确认/删除按钮
            actionButtonsRow
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(.systemGray5))
    }

    /// 升降号选择行
    private var accidentalRow: some View {
        HStack(spacing: 6) {
            ForEach(AccidentalState.allCases, id: \.self) { acc in
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        selectedAccidental = acc
                    }
                    hapticFeedback()
                } label: {
                    Text(acc.rawValue)
                        .font(.system(size: 18, weight: .medium))
                        .frame(width: 50, height: 40)
                        .background(
                            selectedAccidental == acc ?
                            AppTheme.primary.opacity(0.15) :
                            Color(.systemGray4)
                        )
                        .foregroundStyle(
                            selectedAccidental == acc ?
                            AppTheme.primary: AppTheme.primaryText
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }

            Spacer()

            // 删除按钮
            Button {
                onDelete()
                hapticFeedback()
            } label: {
                Image(systemName: "delete.left")
                    .font(.system(size: 16))
                    .frame(width: 50, height: 40)
                    .background(Color(.systemGray4))
                    .foregroundStyle(AppTheme.error)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
        }
    }

    /// 键盘行
    private var keyboardRows: some View {
        VStack(spacing: 6) {
            // 上行：C D E
            HStack(spacing: 6) {
                ForEach(topRowNotes, id: \.self) { note in
                    pianoKey(note: note)
                }
            }

            // 中行：F G A
            HStack(spacing: 6) {
                ForEach(middleRowNotes, id: \.self) { note in
                    pianoKey(note: note)
                }
            }

            // 下行：B
            HStack(spacing: 6) {
                pianoKey(note: "B")
                Spacer()
            }
        }
    }

    /// 单个琴键
    private func pianoKey(note: String) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                selectedNote = note
            }
            hapticFeedback()
        } label: {
            Text(note)
                .font(.system(size: 18, weight: .semibold))
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(
                    selectedNote == note ?
                    AppTheme.primary:
                    Color(.systemBackground)
                )
                .foregroundStyle(
                    selectedNote == note ?
                    .white : AppTheme.primaryText
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }

    /// 确认/取消按钮行
    private var actionButtonsRow: some View {
        HStack(spacing: 12) {
            // 取消按钮
            Button {
                onDelete()
                hapticFeedback()
            } label: {
                Text("取消")
                    .font(.body)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color(.systemGray4))
                    .foregroundStyle(AppTheme.primaryText)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)

            // 确认按钮
            Button {
                onConfirm()
                hapticFeedback()
            } label: {
                Text("确认")
                    .font(.body)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        selectedNote != nil ?
                        AppTheme.primary:
                        AppTheme.primary.opacity(0.3)
                    )
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
            .disabled(selectedNote == nil)
        }
    }

    private func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

// MARK: - 完整版钢琴键盘（十二平均律）

/// 十二平均律钢琴键盘
struct FullPianoKeyboardView: View {
    let startOctave: Int
    let octaveCount: Int
    let highlightedKeys: Set<Int>
    let onKeyTap: (Int) -> Void

    private let whiteKeyWidth: CGFloat = 44
    private let blackKeyWidth: CGFloat = 28
    private let whiteKeyHeight: CGFloat = 120
    private let blackKeyHeight: CGFloat = 70

    private let whiteKeys = [0, 2, 4, 5, 7, 9, 11] // C D E F G A B 的半音偏移
    private let blackKeys = [1, 3, 6, 8, 10] // C# D# F# G# A# 的半音偏移

    init(
        startOctave: Int = 4,
        octaveCount: Int = 1,
        highlightedKeys: Set<Int> = [],
        onKeyTap: @escaping (Int) -> Void
    ) {
        self.startOctave = startOctave
        self.octaveCount = octaveCount
        self.highlightedKeys = highlightedKeys
        self.onKeyTap = onKeyTap
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            // 白键
            HStack(spacing: 2) {
                ForEach(0..<(octaveCount * 7 + 1), id: \.self) { index in
                    let midiNote = startOctave * 12 + whiteKeys[index % 7] + (index / 7) * 12
                    whiteKey(midiNote: midiNote, index: index)
                }
            }

            // 黑键
            HStack(spacing: 2) {
                ForEach(0..<(octaveCount * 7 + 1), id: \.self) { index in
                    let midiNote = startOctave * 12 + whiteKeys[index % 7] + (index / 7) * 12
                    if index % 7 < 7 {
                        if let blackOffset = blackKeyOffset(for: index % 7) {
                            blackKey(midiNote: midiNote + blackOffset, index: index)
                                .offset(x: whiteKeyWidth / 2 + 2)
                        }
                    }
                    Spacer()
                        .frame(width: whiteKeyWidth)
                }
            }
        }
        .frame(height: whiteKeyHeight)
        .padding(.horizontal, 4)
        .background(Color(.systemGray5))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func whiteKey(midiNote: Int, index: Int) -> some View {
        Button {
            onKeyTap(midiNote)
        } label: {
            RoundedRectangle(cornerRadius: 4)
                .fill(highlightedKeys.contains(midiNote) ? AppTheme.primary: Color(.systemBackground))
                .frame(width: whiteKeyWidth, height: whiteKeyHeight)
                .overlay(
                    Rectangle()
                        .fill(Color(.systemGray4))
                        .frame(height: 1),
                    alignment: .bottom
                )
        }
        .buttonStyle(.plain)
    }

    private func blackKey(midiNote: Int, index: Int) -> some View {
        Button {
            onKeyTap(midiNote)
        } label: {
            RoundedRectangle(cornerRadius: 4)
                .fill(highlightedKeys.contains(midiNote) ? AppTheme.primary: Color(.black))
                .frame(width: blackKeyWidth, height: blackKeyHeight)
        }
        .buttonStyle(.plain)
    }

    private func blackKeyOffset(for whiteIndex: Int) -> Int? {
        let offsets = [1, 3, nil, 6, 8, 10, nil] // E和B后面没有黑键
        return offsets[whiteIndex]
    }
}

// MARK: - 预览

#Preview {
    VStack(spacing: 20) {
        // 精简版
        PianoKeyboardView(
            selectedNote: .constant(nil),
            selectedAccidental: .constant(.natural),
            onConfirm: {},
            onDelete: {}
        )

        // 完整版
        FullPianoKeyboardView(
            startOctave: 4,
            octaveCount: 1,
            highlightedKeys: [60, 64, 67],
            onKeyTap: { midi in
                print("Tapped MIDI: \(midi)")
            }
        )
    }
    .padding()
}
