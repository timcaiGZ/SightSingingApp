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

    var body: some View {
        // 键盘主体 (匹配 v0 MusicKeyboard: 灰色背景，三列布局)
        HStack(spacing: 4) {
                // 左侧升降号列
                VStack(spacing: 4) {
                    ForEach(accidentals, id: \.value) { acc in
                        Button {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                accidental = accidental == acc.value ? "" : acc.value
                            }
                            haptic()
                        } label: {
                            Text(acc.label)
                                .font(.system(size: 15, weight: .medium))
                                .frame(width: 44, height: 40)
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
                }

                // 中间音名区
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        restButton(symbol: "𝄽")
                        noteButton("C")
                        noteButton("D")
                    }
                    HStack(spacing: 4) {
                        noteButton("E")
                        noteButton("F")
                        noteButton("G")
                    }
                    HStack(spacing: 4) {
                        noteButton("A")
                        noteButton("B")
                        restButton(symbol: "𝄾")
                    }
                    HStack(spacing: 4) {
                        TextButton(label: "+8va")
                        TextButton(label: "-8va")
                        TextButton(label: "小节")
                    }
                }

                // 右侧功能键
                VStack(spacing: 4) {
                    Button {
                        onClear()
                        haptic()
                    } label: {
                        Text("⌫")
                            .font(.system(size: 16))
                            .frame(width: 44, height: 40)
                            .background(Color(hex: "ADB5BD"))
                            .foregroundStyle(AppTheme.primaryText)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)

                    Text("⇧")
                        .font(.system(size: 16))
                        .frame(width: 44, height: 40)
                        .background(Color(hex: "ADB5BD"))
                        .foregroundStyle(AppTheme.primaryText)
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    Button {
                        if canSubmit {
                            onSubmit()
                            haptic()
                        }
                    } label: {
                        Text("完成")
                            .font(.system(size: 15, weight: .medium))
                            .frame(width: 44)
                            .frame(maxHeight: .infinity)
                            .background(
                                canSubmit ? Color(hex: "ADB5BD") : Color(hex: "ADB5BD").opacity(0.5)
                            )
                            .foregroundStyle(AppTheme.primaryText)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                    .disabled(!canSubmit)
                }
            }
            .padding(4)
            .background(Color(hex: "D1D5DB"))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func noteButton(_ note: String) -> some View {
        Button {
            onNotePress(accidental + note)
            accidental = ""
            haptic()
        } label: {
            Text(note)
                .font(.system(size: 20, weight: .semibold))
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(Color.white)
                .foregroundStyle(AppTheme.primaryText)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }

    private func restButton(symbol: String) -> some View {
        Button {
            onNotePress(symbol)
            haptic()
        } label: {
            Text(symbol)
                .font(.system(size: 18))
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(Color.white)
                .foregroundStyle(AppTheme.secondaryText)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }

    private func TextButton(label: String) -> some View {
        Button {
            onNotePress(label)
            haptic()
        } label: {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(Color.white)
                .foregroundStyle(AppTheme.primaryText)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
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
