import SwiftUI

// MARK: - 音乐输入键盘 (匹配 v0 MusicKeyboard)

struct MusicKeyboard: View {
    let onNotePress: (String) -> Void
    let onClear: () -> Void
    let onSubmit: () -> Void
    let canSubmit: Bool

    @State private var accidental: String = ""

    private let accidentals = [
        (label: "无", value: ""),
        (label: "#", value: "#"),
        (label: "x", value: "x"),
        (label: "n", value: "n"),
        (label: "b", value: "b"),
        (label: "bb", value: "bb"),
    ]

    private let notes = ["C", "D", "E", "F", "G", "A", "B"]

    private let spacing: CGFloat = 3
    private let totalRows = 6
    private let rightBlockRows = 4

    var body: some View {
        GeometryReader { geo in
            let rh = max(32, (geo.size.height - spacing * 2 - spacing * CGFloat(totalRows - 1)) / CGFloat(totalRows))

            HStack(spacing: spacing) {
                // 列1：左侧变音号（6 行单列，灰色）
                VStack(spacing: spacing) {
                    accidentalButton(accidentals[0], rh: rh)
                    accidentalButton(accidentals[1], rh: rh)
                    accidentalButton(accidentals[2], rh: rh)
                    accidentalButton(accidentals[3], rh: rh)
                    accidentalButton(accidentals[4], rh: rh)
                    accidentalButton(accidentals[5], rh: rh)
                }
                .frame(width: 52)

                // 列2-4：中间音名区（3 列，4 行白键 + 2 行空行补齐）
                VStack(spacing: spacing) {
                    HStack(spacing: spacing) {
                        restButton(symbol: "𝄽", rh: rh)
                        noteButton("C", rh: rh)
                        noteButton("D", rh: rh)
                    }
                    HStack(spacing: spacing) {
                        noteButton("E", rh: rh)
                        noteButton("F", rh: rh)
                        noteButton("G", rh: rh)
                    }
                    HStack(spacing: spacing) {
                        noteButton("A", rh: rh)
                        noteButton("B", rh: rh)
                        restButton(symbol: "𝄾", rh: rh)
                    }
                    HStack(spacing: spacing) {
                        textButton(label: "+8va", rh: rh)
                        textButton(label: "-8va", rh: rh)
                        textButton(label: "小节", rh: rh)
                    }
                    Color.clear.frame(height: rh)
                    Color.clear.frame(height: rh)
                }

                // 列5：右侧功能键（⌫, ⇧ 各1行，完成占 4 行）
                VStack(spacing: spacing) {
                    deleteButton(rh: rh)
                    shiftButton(rh: rh)
                    submitButton(rh: rh)
                        .frame(height: CGFloat(rightBlockRows) * rh + CGFloat(rightBlockRows - 1) * spacing)
                }
                .frame(width: 52)
            }
            .padding(spacing)
            .background(Color(hex: "D1D5DB"))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func accidentalButton(_ acc: (label: String, value: String), rh: CGFloat) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                accidental = accidental == acc.value ? "" : acc.value
            }
            haptic()
        } label: {
            Text(acc.label)
                .font(.system(size: 17, weight: .medium))
                .frame(maxWidth: .infinity)
                .frame(height: rh)
                .background(
                    accidental == acc.value ? AppTheme.accent : Color(hex: "ADB5BD")
                )
                .foregroundStyle(
                    accidental == acc.value ? .white : AppTheme.primaryText
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }

    private func noteButton(_ note: String, rh: CGFloat) -> some View {
        Button {
            onNotePress(accidental + note)
            accidental = ""
            haptic()
        } label: {
            Text(note)
                .font(.system(size: 22, weight: .semibold))
                .frame(maxWidth: .infinity)
                .frame(height: rh)
                .background(Color.white)
                .foregroundStyle(AppTheme.primaryText)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }

    private func restButton(symbol: String, rh: CGFloat) -> some View {
        Button {
            onNotePress(symbol)
            haptic()
        } label: {
            Text(symbol)
                .font(.system(size: 20))
                .frame(maxWidth: .infinity)
                .frame(height: rh)
                .background(Color.white)
                .foregroundStyle(AppTheme.secondaryText)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }

    private func textButton(label: String, rh: CGFloat) -> some View {
        Button {
            onNotePress(label)
            haptic()
        } label: {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .frame(maxWidth: .infinity)
                .frame(height: rh)
                .background(Color.white)
                .foregroundStyle(AppTheme.primaryText)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }

    private func deleteButton(rh: CGFloat) -> some View {
        Button {
            onClear()
            haptic()
        } label: {
            Image(systemName: "delete.left")
                .font(.system(size: 18, weight: .medium))
                .frame(maxWidth: .infinity)
                .frame(height: rh)
                .background(Color(hex: "ADB5BD"))
                .foregroundStyle(AppTheme.primaryText)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }

    private func shiftButton(rh: CGFloat) -> some View {
        Button {
            haptic()
        } label: {
            Image(systemName: "arrow.up")
                .font(.system(size: 18, weight: .medium))
                .frame(maxWidth: .infinity)
                .frame(height: rh)
                .background(Color(hex: "ADB5BD"))
                .foregroundStyle(AppTheme.primaryText)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }

    private func submitButton(rh: CGFloat) -> some View {
        Button {
            if canSubmit {
                onSubmit()
                haptic()
            }
        } label: {
            Text("完成")
                .font(.system(size: 17, weight: .medium))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    canSubmit ? Color(hex: "ADB5BD") : Color(hex: "ADB5BD").opacity(0.5)
                )
                .foregroundStyle(AppTheme.primaryText)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .disabled(!canSubmit)
    }

    private func haptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

// MARK: - 预览

#Preview {
    MusicKeyboard(
        onNotePress: { _ in },
        onClear: {},
        onSubmit: {},
        canSubmit: true
    )
    .padding()
}
