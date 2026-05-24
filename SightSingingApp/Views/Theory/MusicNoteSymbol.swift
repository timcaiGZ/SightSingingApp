import SwiftUI

// MARK: - 音符类型
enum NoteSymbolType: String, CaseIterable {
    case whole       // 全音符
    case half        // 二分音符
    case quarter     // 四分音符
    case eighth      // 八分音符
    case sixteenth   // 十六分音符

    var label: String {
        switch self {
        case .whole: return "全音符"
        case .half: return "二分"
        case .quarter: return "四分"
        case .eighth: return "八分"
        case .sixteenth: return "十六分"
        }
    }
}

// MARK: - 自定义音符符号绘制
struct MusicNoteSymbol: View {
    let type: NoteSymbolType
    var color: Color = AppTheme.primaryText
    var size: CGFloat = 32

    var body: some View {
        Canvas { context, canvasSize in
            let headWidth = size * 0.55
            let headHeight = size * 0.38
            let stemHeight = size * 1.1
            let stemWidth = max(1.5, size * 0.06)
            let centerX = canvasSize.width / 2
            let centerY = canvasSize.height / 2 + size * 0.15

            // 绘制符头
            let headRect = CGRect(
                x: centerX - headWidth / 2,
                y: centerY - headHeight / 2,
                width: headWidth,
                height: headHeight
            )

            switch type {
            case .whole:
                // 全音符：空心椭圆，无符干
                drawNoteHead(context: context, rect: headRect, filled: false, color: color)

            case .half:
                // 二分音符：空心椭圆 + 符干
                drawNoteHead(context: context, rect: headRect, filled: false, color: color)
                // 符干向上
                let stemPath = Path { path in
                    path.move(to: CGPoint(x: centerX + headWidth / 2 - stemWidth / 2, y: centerY))
                    path.addLine(to: CGPoint(x: centerX + headWidth / 2 - stemWidth / 2, y: centerY - stemHeight))
                }
                context.stroke(stemPath, with: .color(color), lineWidth: stemWidth)

            case .quarter:
                // 四分音符：实心椭圆 + 符干
                drawNoteHead(context: context, rect: headRect, filled: true, color: color)
                let stemPath = Path { path in
                    path.move(to: CGPoint(x: centerX + headWidth / 2 - stemWidth / 2, y: centerY))
                    path.addLine(to: CGPoint(x: centerX + headWidth / 2 - stemWidth / 2, y: centerY - stemHeight))
                }
                context.stroke(stemPath, with: .color(color), lineWidth: stemWidth)

            case .eighth:
                // 八分音符：实心椭圆 + 符干 + 一个符尾
                drawNoteHead(context: context, rect: headRect, filled: true, color: color)
                let stemX = centerX + headWidth / 2 - stemWidth / 2
                let stemTopY = centerY - stemHeight
                let stemPath = Path { path in
                    path.move(to: CGPoint(x: stemX, y: centerY))
                    path.addLine(to: CGPoint(x: stemX, y: stemTopY))
                }
                context.stroke(stemPath, with: .color(color), lineWidth: stemWidth)
                // 符尾（一个，向右弯曲）
                drawFlag(context: context, startX: stemX, startY: stemTopY, color: color, count: 1, size: size)

            case .sixteenth:
                // 十六分音符：实心椭圆 + 符干 + 两个符尾
                drawNoteHead(context: context, rect: headRect, filled: true, color: color)
                let stemX = centerX + headWidth / 2 - stemWidth / 2
                let stemTopY = centerY - stemHeight
                let stemPath = Path { path in
                    path.move(to: CGPoint(x: stemX, y: centerY))
                    path.addLine(to: CGPoint(x: stemX, y: stemTopY))
                }
                context.stroke(stemPath, with: .color(color), lineWidth: stemWidth)
                // 符尾（两个）
                drawFlag(context: context, startX: stemX, startY: stemTopY, color: color, count: 2, size: size)
            }
        }
        .frame(width: size * 1.4, height: size * 1.8)
    }

    // MARK: - 绘制符头
    private func drawNoteHead(context: GraphicsContext, rect: CGRect, filled: Bool, color: Color) {
        // 音符符头是一个倾斜的椭圆（约 15-20 度倾斜）
        let path = Path { path in
            path.addEllipse(in: rect)
        }

        // 应用倾斜变换
        var transform = CGAffineTransform.identity
        transform = transform.translatedBy(x: rect.midX, y: rect.midY)
        transform = transform.rotated(by: -15 * .pi / 180)
        transform = transform.translatedBy(x: -rect.midX, y: -rect.midY)

        let transformedPath = path.applying(transform)

        if filled {
            context.fill(transformedPath, with: .color(color))
        } else {
            context.stroke(transformedPath, with: .color(color), lineWidth: max(1.2, size * 0.05))
        }
    }

    // MARK: - 绘制符尾
    private func drawFlag(context: GraphicsContext, startX: CGFloat, startY: CGFloat, color: Color, count: Int, size: CGFloat) {
        let flagWidth = size * 0.55
        let flagHeight = size * 0.35
        let spacing = size * 0.22

        for i in 0..<count {
            let offsetY = CGFloat(i) * spacing
            let flagPath = Path { path in
                path.move(to: CGPoint(x: startX, y: startY + offsetY))
                path.addCurve(
                    to: CGPoint(x: startX + flagWidth, y: startY + flagHeight + offsetY),
                    control1: CGPoint(x: startX + flagWidth * 0.3, y: startY + offsetY),
                    control2: CGPoint(x: startX + flagWidth * 0.7, y: startY + flagHeight * 0.5 + offsetY)
                )
                path.addCurve(
                    to: CGPoint(x: startX, y: startY + flagHeight * 1.2 + offsetY),
                    control1: CGPoint(x: startX + flagWidth * 0.8, y: startY + flagHeight * 1.3 + offsetY),
                    control2: CGPoint(x: startX + flagWidth * 0.2, y: startY + flagHeight * 1.4 + offsetY)
                )
                path.closeSubpath()
            }
            context.fill(flagPath, with: .color(color))
        }
    }
}

// MARK: - 音符时值展示组件（替换旧版 Unicode 字符方案）
struct NoteDurationRow: View {
    let items: [(type: NoteSymbolType, label: String, midiNote: Int)]
    var audio: TheoryTapAudio? = nil

    var body: some View {
        HStack(spacing: 12) {
            ForEach(items, id: \.type) { item in
                VStack(spacing: 4) {
                    MusicNoteSymbol(type: item.type, size: 28)
                    Text(item.label)
                        .font(.system(size: 11))
                        .foregroundStyle(AppTheme.secondaryText)
                }
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    audio?.playNote(item.midiNote)
                }
            }
        }
        .padding(12)
        .background(AppTheme.secondaryBg)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    VStack(spacing: 20) {
        HStack(spacing: 16) {
            ForEach(NoteSymbolType.allCases, id: \.self) { type in
                VStack(spacing: 4) {
                    MusicNoteSymbol(type: type, size: 32)
                    Text(type.label)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
            }
        }
        NoteDurationRow(items: [
            (.whole, "全音符", 60),
            (.half, "二分", 62),
            (.quarter, "四分", 64),
            (.eighth, "八分", 65),
            (.sixteenth, "十六分", 67),
        ])
    }
    .padding()
}
