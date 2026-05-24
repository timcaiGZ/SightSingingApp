import SwiftUI

// MARK: - CAGED 形状数据模型

/// 单个 CAGED 形状的指法数据
struct CAGEDShapeData: Identifiable {
    let id = UUID()
    let shapeName: String        // "C型"/"A型"/"G型"/"E型"/"D型"
    let position: Int             // 把位（品格数）
    let frets: [Int?]            // 6根弦的品位 (nil=不弹, 0=空弦)
    let fingers: [Int?]          // 左手指法 (1-4, nil=开放/不弹)
    let barreFret: Int?          // 横按品格
    let barreStrings: Int        // 横按弦数
    let rootStrings: [Int]       // 根音所在弦 (0=6弦 .. 5=1弦)
}

// MARK: - CAGED 和弦完整数据

/// 一个和弦的 CAGED 五大形状集合
struct CAGEDChordData: Identifiable {
    let id = UUID()
    let chordName: String        // 和弦名 "C"/"Am"/"Dm"等
    let quality: String          // "大三和弦"/"小三和弦"
    let shapes: [CAGEDShapeData] // 五个形状
}

// MARK: - CAGED 和弦数据库

enum CAGEDDatabase {

    // 吉他标准定弦
    // 6弦=E2(40), 5弦=A2(45), 4弦=D3(50), 3弦=G3(55), 2弦=B3(59), 1弦=E4(64)
    // 空弦音名：E A D G B E
    private static let openStrings = ["E", "A", "D", "G", "B", "E"]

    // MARK: - C大调各级和弦

    /// C 大三和弦 (I级)
    static let cMajor = CAGEDChordData(
        chordName: "C",
        quality: "大三和弦",
        shapes: [
            // C型 - 开放把位
            CAGEDShapeData(shapeName: "C型", position: 0,
                           frets: [nil, 3, 2, 0, 1, 0],
                           fingers: [nil, 3, 2, nil, 1, nil],
                           barreFret: nil, barreStrings: 0,
                           rootStrings: [1, 4]),
            // A型 - 第3品横按
            CAGEDShapeData(shapeName: "A型", position: 3,
                           frets: [nil, 3, 5, 5, 5, 3],
                           fingers: [nil, 1, 3, 4, 4, 1],
                           barreFret: 3, barreStrings: 5,
                           rootStrings: [1, 3]),
            // G型 - 第5品
            CAGEDShapeData(shapeName: "G型", position: 5,
                           frets: [8, 7, 5, 5, 5, 8],
                           fingers: [2, 1, nil, nil, nil, 3],
                           barreFret: nil, barreStrings: 0,
                           rootStrings: [0, 2, 5]),
            // E型 - 第8品横按
            CAGEDShapeData(shapeName: "E型", position: 8,
                           frets: [8, 10, 10, 9, 8, 8],
                           fingers: [1, 3, 4, 2, 1, 1],
                           barreFret: 8, barreStrings: 6,
                           rootStrings: [0, 3, 5]),
            // D型 - 第10品
            CAGEDShapeData(shapeName: "D型", position: 10,
                           frets: [nil, nil, 10, 12, 13, 12],
                           fingers: [nil, nil, 1, 2, 4, 3],
                           barreFret: nil, barreStrings: 0,
                           rootStrings: [2, 5]),
        ])

    /// Dm 小三和弦 (ii级)
    static let dMinor = CAGEDChordData(
        chordName: "Dm",
        quality: "小三和弦",
        shapes: [
            // D型(开放)
            CAGEDShapeData(shapeName: "D型", position: 0,
                           frets: [nil, nil, 0, 2, 3, 1],
                           fingers: [nil, nil, nil, 1, 3, 2],
                           barreFret: nil, barreStrings: 0,
                           rootStrings: [3, 5]),
            // C型 - 第5品
            CAGEDShapeData(shapeName: "C型", position: 5,
                           frets: [nil, 5, 7, 7, 6, 5],
                           fingers: [nil, 1, 3, 4, 2, 1],
                           barreFret: 5, barreStrings: 5,
                           rootStrings: [1, 4]),
            // A型 - 第5品横按
            CAGEDShapeData(shapeName: "A型", position: 5,
                           frets: [nil, 5, 7, 7, 6, 5],
                           fingers: [nil, 1, 3, 4, 2, 1],
                           barreFret: 5, barreStrings: 5,
                           rootStrings: [1, 5]),
            // G型 - 第7品
            CAGEDShapeData(shapeName: "G型", position: 7,
                           frets: [10, 8, 7, 7, 6, 10],
                           fingers: [2, 1, nil, nil, nil, 3],
                           barreFret: nil, barreStrings: 0,
                           rootStrings: [0, 3]),
            // E型 - 第10品横按
            CAGEDShapeData(shapeName: "E型", position: 10,
                           frets: [10, 12, 12, 10, 10, 10],
                           fingers: [1, 3, 4, 1, 1, 1],
                           barreFret: 10, barreStrings: 6,
                           rootStrings: [0, 3, 5]),
        ])

    /// Em 小三和弦 (iii级)
    static let eMinor = CAGEDChordData(
        chordName: "Em",
        quality: "小三和弦",
        shapes: [
            // E型(开放)
            CAGEDShapeData(shapeName: "E型", position: 0,
                           frets: [0, 2, 2, 0, 0, 0],
                           fingers: [nil, 2, 3, nil, nil, nil],
                           barreFret: nil, barreStrings: 0,
                           rootStrings: [0, 3, 5]),
            // D型 - 第2品
            CAGEDShapeData(shapeName: "D型", position: 2,
                           frets: [nil, nil, 2, 4, 5, 3],
                           fingers: [nil, nil, 1, 2, 4, 3],
                           barreFret: nil, barreStrings: 0,
                           rootStrings: [2, 5]),
            // C型 - 第4品
            CAGEDShapeData(shapeName: "C型", position: 4,
                           frets: [nil, 7, 5, 4, 5, 4],
                           fingers: [nil, 3, 1, nil, 2, 1],
                           barreFret: nil, barreStrings: 0,
                           rootStrings: [1, 4]),
            // A型 - 第7品横按
            CAGEDShapeData(shapeName: "A型", position: 7,
                           frets: [nil, 7, 9, 9, 8, 7],
                           fingers: [nil, 1, 3, 4, 2, 1],
                           barreFret: 7, barreStrings: 5,
                           rootStrings: [1, 5]),
            // G型 - 第9品
            CAGEDShapeData(shapeName: "G型", position: 9,
                           frets: [12, 10, 9, 9, 8, 12],
                           fingers: [2, 1, nil, nil, nil, 3],
                           barreFret: nil, barreStrings: 0,
                           rootStrings: [0, 3]),
        ])

    /// F 大三和弦 (IV级)
    static let fMajor = CAGEDChordData(
        chordName: "F",
        quality: "大三和弦",
        shapes: [
            // E型 - 第1品横按
            CAGEDShapeData(shapeName: "E型", position: 1,
                           frets: [1, 3, 3, 2, 1, 1],
                           fingers: [1, 3, 4, 2, 1, 1],
                           barreFret: 1, barreStrings: 6,
                           rootStrings: [0, 3, 5]),
            // D型 - 第3品
            CAGEDShapeData(shapeName: "D型", position: 3,
                           frets: [nil, nil, 3, 5, 6, 5],
                           fingers: [nil, nil, 1, 2, 4, 3],
                           barreFret: nil, barreStrings: 0,
                           rootStrings: [2, 5]),
            // C型 - 第5品
            CAGEDShapeData(shapeName: "C型", position: 5,
                           frets: [nil, 8, 7, 5, 6, 5],
                           fingers: [nil, 3, 2, nil, 1, nil],
                           barreFret: nil, barreStrings: 0,
                           rootStrings: [1, 4]),
            // A型 - 第8品横按
            CAGEDShapeData(shapeName: "A型", position: 8,
                           frets: [nil, 8, 10, 10, 10, 8],
                           fingers: [nil, 1, 3, 4, 2, 1],
                           barreFret: 8, barreStrings: 5,
                           rootStrings: [1, 5]),
            // G型 - 第10品
            CAGEDShapeData(shapeName: "G型", position: 10,
                           frets: [13, 12, 10, 10, 10, 13],
                           fingers: [2, 1, nil, nil, nil, 3],
                           barreFret: nil, barreStrings: 0,
                           rootStrings: [0, 3]),
        ])

    /// G 大三和弦 (V级)
    static let gMajor = CAGEDChordData(
        chordName: "G",
        quality: "大三和弦",
        shapes: [
            // G型(开放)
            CAGEDShapeData(shapeName: "G型", position: 0,
                           frets: [3, 2, 0, 0, 0, 3],
                           fingers: [2, 1, nil, nil, nil, 3],
                           barreFret: nil, barreStrings: 0,
                           rootStrings: [0, 2, 5]),
            // E型 - 第3品横按
            CAGEDShapeData(shapeName: "E型", position: 3,
                           frets: [3, 5, 5, 4, 3, 3],
                           fingers: [1, 3, 4, 2, 1, 1],
                           barreFret: 3, barreStrings: 6,
                           rootStrings: [0, 3, 5]),
            // D型 - 第5品
            CAGEDShapeData(shapeName: "D型", position: 5,
                           frets: [nil, nil, 5, 7, 8, 7],
                           fingers: [nil, nil, 1, 2, 4, 3],
                           barreFret: nil, barreStrings: 0,
                           rootStrings: [2, 5]),
            // C型 - 第7品
            CAGEDShapeData(shapeName: "C型", position: 7,
                           frets: [nil, 10, 9, 7, 8, 7],
                           fingers: [nil, 3, 2, nil, 1, nil],
                           barreFret: nil, barreStrings: 0,
                           rootStrings: [1, 4]),
            // A型 - 第10品横按
            CAGEDShapeData(shapeName: "A型", position: 10,
                           frets: [nil, 10, 12, 12, 12, 10],
                           fingers: [nil, 1, 3, 4, 2, 1],
                           barreFret: 10, barreStrings: 5,
                           rootStrings: [1, 5]),
        ])

    /// Am 小三和弦 (vi级)
    static let aMinor = CAGEDChordData(
        chordName: "Am",
        quality: "小三和弦",
        shapes: [
            // A型(开放)
            CAGEDShapeData(shapeName: "A型", position: 0,
                           frets: [nil, 0, 2, 2, 1, 0],
                           fingers: [nil, nil, 2, 3, 1, nil],
                           barreFret: nil, barreStrings: 0,
                           rootStrings: [1, 5]),
            // G型 - 第2品
            CAGEDShapeData(shapeName: "G型", position: 2,
                           frets: [5, 3, 2, 2, 1, 5],
                           fingers: [2, 1, nil, nil, nil, 3],
                           barreFret: nil, barreStrings: 0,
                           rootStrings: [0, 3]),
            // E型 - 第5品横按
            CAGEDShapeData(shapeName: "E型", position: 5,
                           frets: [5, 7, 7, 5, 5, 5],
                           fingers: [1, 3, 4, 1, 1, 1],
                           barreFret: 5, barreStrings: 6,
                           rootStrings: [0, 3, 5]),
            // D型 - 第7品
            CAGEDShapeData(shapeName: "D型", position: 7,
                           frets: [nil, nil, 7, 9, 10, 8],
                           fingers: [nil, nil, 1, 2, 4, 3],
                           barreFret: nil, barreStrings: 0,
                           rootStrings: [2, 5]),
            // C型 - 第9品
            CAGEDShapeData(shapeName: "C型", position: 9,
                           frets: [nil, 12, 10, 9, 10, 8],
                           fingers: [nil, 4, 2, 1, 3, 1],
                           barreFret: nil, barreStrings: 0,
                           rootStrings: [1, 4]),
        ])

    /// Bdim 减三和弦 (vii°级) — 近似展示，用Bm7b5形状
    static let bDiminished = CAGEDChordData(
        chordName: "Bdim",
        quality: "减三和弦",
        shapes: [
            // A型 - 第1品
            CAGEDShapeData(shapeName: "A型", position: 1,
                           frets: [nil, 2, 3, 2, 3, nil],
                           fingers: [nil, 1, 3, 2, 4, nil],
                           barreFret: nil, barreStrings: 0,
                           rootStrings: [1]),
            // E型 - 第7品
            CAGEDShapeData(shapeName: "E型", position: 7,
                           frets: [7, 8, 10, 7, 9, 7],
                           fingers: [1, 2, 4, 1, 3, 1],
                           barreFret: 7, barreStrings: 6,
                           rootStrings: [0, 3]),
            // D型 - 第9品
            CAGEDShapeData(shapeName: "D型", position: 9,
                           frets: [nil, nil, 9, 10, 12, 10],
                           fingers: [nil, nil, 1, 2, 4, 2],
                           barreFret: nil, barreStrings: 0,
                           rootStrings: [2]),
            // C型 - 第10品
            CAGEDShapeData(shapeName: "C型", position: 10,
                           frets: [nil, 14, 12, 10, 12, 11],
                           fingers: [nil, 4, 3, 1, 2, 1],
                           barreFret: nil, barreStrings: 0,
                           rootStrings: [1]),
            // G型 - 第12品
            CAGEDShapeData(shapeName: "G型", position: 12,
                           frets: [15, 14, 12, 12, 11, nil],
                           fingers: [3, 2, 1, 1, nil, nil],
                           barreFret: nil, barreStrings: 0,
                           rootStrings: [0]),
        ])

    // MARK: - 常用开放和弦集合

    /// 获取C大调各级和弦的CAGED数据
    static func cMajorScaleChords() -> [(degree: String, data: CAGEDChordData)] {
        [
            ("Ⅰ", cMajor),
            ("ⅱ", dMinor),
            ("ⅲ", eMinor),
            ("Ⅳ", fMajor),
            ("Ⅴ", gMajor),
            ("ⅵ", aMinor),
            ("ⅶ°", bDiminished),
        ]
    }

    // MARK: - 额外常用和弦

    /// A 大三和弦
    static let aMajor = CAGEDChordData(
        chordName: "A",
        quality: "大三和弦",
        shapes: [
            CAGEDShapeData(shapeName: "A型", position: 0,
                           frets: [nil, 0, 2, 2, 2, 0],
                           fingers: [nil, nil, 2, 3, 4, nil],
                           barreFret: nil, barreStrings: 0,
                           rootStrings: [1, 5]),
            CAGEDShapeData(shapeName: "G型", position: 2,
                           frets: [5, 4, 2, 2, 2, 5],
                           fingers: [2, 1, nil, nil, nil, 3],
                           barreFret: nil, barreStrings: 0,
                           rootStrings: [0, 3]),
            CAGEDShapeData(shapeName: "E型", position: 5,
                           frets: [5, 7, 7, 6, 5, 5],
                           fingers: [1, 3, 4, 2, 1, 1],
                           barreFret: 5, barreStrings: 6,
                           rootStrings: [0, 3, 5]),
            CAGEDShapeData(shapeName: "D型", position: 7,
                           frets: [nil, nil, 7, 9, 10, 9],
                           fingers: [nil, nil, 1, 2, 4, 3],
                           barreFret: nil, barreStrings: 0,
                           rootStrings: [2, 5]),
            CAGEDShapeData(shapeName: "C型", position: 9,
                           frets: [nil, 12, 11, 9, 10, 9],
                           fingers: [nil, 3, 2, nil, 1, nil],
                           barreFret: nil, barreStrings: 0,
                           rootStrings: [1, 4]),
        ])

    /// D 大三和弦
    static let dMajor = CAGEDChordData(
        chordName: "D",
        quality: "大三和弦",
        shapes: [
            CAGEDShapeData(shapeName: "D型", position: 0,
                           frets: [nil, nil, 0, 2, 3, 2],
                           fingers: [nil, nil, nil, 1, 3, 2],
                           barreFret: nil, barreStrings: 0,
                           rootStrings: [3, 5]),
            CAGEDShapeData(shapeName: "C型", position: 2,
                           frets: [nil, 5, 4, 2, 3, 2],
                           fingers: [nil, 3, 2, nil, 1, nil],
                           barreFret: nil, barreStrings: 0,
                           rootStrings: [1, 4]),
            CAGEDShapeData(shapeName: "A型", position: 5,
                           frets: [nil, 5, 7, 7, 7, 5],
                           fingers: [nil, 1, 3, 4, 2, 1],
                           barreFret: 5, barreStrings: 5,
                           rootStrings: [1, 5]),
            CAGEDShapeData(shapeName: "G型", position: 7,
                           frets: [10, 9, 7, 7, 7, 10],
                           fingers: [2, 1, nil, nil, nil, 3],
                           barreFret: nil, barreStrings: 0,
                           rootStrings: [0, 3]),
            CAGEDShapeData(shapeName: "E型", position: 10,
                           frets: [10, 12, 12, 11, 10, 10],
                           fingers: [1, 3, 4, 2, 1, 1],
                           barreFret: 10, barreStrings: 6,
                           rootStrings: [0, 3, 5]),
        ])

    /// E 大三和弦
    static let eMajor = CAGEDChordData(
        chordName: "E",
        quality: "大三和弦",
        shapes: [
            CAGEDShapeData(shapeName: "E型", position: 0,
                           frets: [0, 2, 2, 1, 0, 0],
                           fingers: [nil, 2, 3, 1, nil, nil],
                           barreFret: nil, barreStrings: 0,
                           rootStrings: [0, 3, 5]),
            CAGEDShapeData(shapeName: "D型", position: 2,
                           frets: [nil, nil, 2, 4, 5, 4],
                           fingers: [nil, nil, 1, 2, 4, 3],
                           barreFret: nil, barreStrings: 0,
                           rootStrings: [2, 5]),
            CAGEDShapeData(shapeName: "C型", position: 4,
                           frets: [nil, 7, 6, 4, 5, 4],
                           fingers: [nil, 3, 2, nil, 1, nil],
                           barreFret: nil, barreStrings: 0,
                           rootStrings: [1, 4]),
            CAGEDShapeData(shapeName: "A型", position: 7,
                           frets: [nil, 7, 9, 9, 9, 7],
                           fingers: [nil, 1, 3, 4, 2, 1],
                           barreFret: 7, barreStrings: 5,
                           rootStrings: [1, 5]),
            CAGEDShapeData(shapeName: "G型", position: 9,
                           frets: [12, 11, 9, 9, 9, 12],
                           fingers: [2, 1, nil, nil, nil, 3],
                           barreFret: nil, barreStrings: 0,
                           rootStrings: [0, 3]),
        ])
}


// MARK: - CAGED 五大形状展示视图

/// 单个 CAGED 形状的指板图（竖版，含品位标记和横按指示）
struct CAGEDShapeDiagram: View {
    let shape: CAGEDShapeData
    var showRoot: Bool = true
    var audio: TheoryTapAudio? = nil

    private let shapeColors: [String: Color] = [
        "C型": Color(hex: "EF4444"),
        "A型": Color(hex: "F59E0B"),
        "G型": Color(hex: "10B981"),
        "E型": Color(hex: "3B82F6"),
        "D型": Color(hex: "8B5CF6"),
    ]

    var body: some View {
        VStack(spacing: 4) {
            // 形状标签
            Text(shape.shapeName)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(shapeColors[shape.shapeName] ?? AppTheme.secondaryText)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background((shapeColors[shape.shapeName] ?? AppTheme.secondaryText).opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 4))

            // 把位标记
            Text("\(shape.position)品")
                .font(.system(size: 10))
                .foregroundStyle(AppTheme.secondaryText)

            // 指板 SVG
            CAGEDFretboardSVG(shape: shape, showRoot: showRoot, color: shapeColors[shape.shapeName] ?? AppTheme.primaryText)
                .frame(width: 52, height: 80)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            audio?.playChord(named: "C") // TODO: 播放对应和弦
        }
    }
}

// MARK: - CAGED 指板 SVG 绘制

struct CAGEDFretboardSVG: View {
    let shape: CAGEDShapeData
    let showRoot: Bool
    let color: Color

    var body: some View {
        Canvas { ctx, size in
            let w = size.width
            let h = size.height
            let stringSpacing = w / 7  // 6弦+两边留白
            let fretSpacing = h / 6     // 5品显示空间+琴枕
            let startX = stringSpacing
            let topY: CGFloat = 6

            // 品位线 (显示最高品位及以下4品)
            let maxFret = shape.frets.compactMap { $0 }.max() ?? 5
            let showFrets = min(5, max(1, maxFret))
            for i in 0...showFrets {
                let y = topY + CGFloat(i) * fretSpacing
                let path = Path { p in
                    p.move(to: CGPoint(x: startX, y: y))
                    p.addLine(to: CGPoint(x: startX + stringSpacing * 5, y: y))
                }
                ctx.stroke(path, with: .color(i == 0 ? AppTheme.primaryText.opacity(0.5) : AppTheme.border), lineWidth: i == 0 ? 2 : 0.8)
            }

            // 横按指示条
            if let barre = shape.barreFret, barre > 0 {
                let barreIdx = barre - (maxFret - showFrets + 1)
                if barreIdx >= 0 && barreIdx <= showFrets {
                    let y = topY + CGFloat(barreIdx) * fretSpacing - fretSpacing / 2 + 2
                    let barreW = stringSpacing * CGFloat(shape.barreStrings - 1)
                    let barreX = startX

                    RoundedRectangle(cornerRadius: 3)
                        .fill(color.opacity(0.3))
                        .frame(width: barreW + 8, height: 8)
                        .position(x: barreX + barreW / 2 + 4, y: y)

                    // "B" 横按标记
                    Text("B")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(color)
                        .position(x: startX - 10, y: y)
                }
            }

            // 弦线
            for i in 0..<6 {
                let x = startX + CGFloat(i) * stringSpacing
                let path = Path { p in
                    p.move(to: CGPoint(x: x, y: topY))
                    p.addLine(to: CGPoint(x: x, y: topY + CGFloat(showFrets) * fretSpacing))
                }
                let lineW = 0.6 + CGFloat(5 - i) * 0.12
                ctx.stroke(path, with: .color(Color(hex: "94A3B8")), lineWidth: lineW)
            }

            // 品位标记和指法
            let baseFret = maxFret - showFrets
            for (i, fret) in shape.frets.enumerated() {
                let x = startX + CGFloat(i) * stringSpacing
                guard let f = fret else {
                    // 不弹：显示 ×
                    Text("×")
                        .font(.system(size: 8, weight: .medium))
                        .foregroundStyle(AppTheme.secondaryText)
                        .position(x: x, y: topY - 8)
                    continue
                }

                if f == 0 {
                    // 空弦：空心圆 + 数字0
                    Circle()
                        .stroke(AppTheme.primaryText, lineWidth: 1)
                        .frame(width: 11, height: 11)
                        .position(x: x, y: topY - 12)
                    Text("0")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(AppTheme.secondaryText)
                        .position(x: x, y: topY - 12)
                } else {
                    let relativeFret = f - baseFret - 1
                    if relativeFret >= 0 && relativeFret <= showFrets {
                        let y = topY + CGFloat(relativeFret) * fretSpacing + fretSpacing / 2

                        // 根音高亮
                        let isRoot = showRoot && shape.rootStrings.contains(i)
                        if isRoot {
                            Circle()
                                .fill(color.opacity(0.15))
                                .frame(width: 16, height: 16)
                                .position(x: x, y: y)
                        }

                        Circle()
                            .fill(isRoot ? color : AppTheme.primaryText)
                            .frame(width: 12, height: 12)
                            .position(x: x, y: y)

                        // 指法数字
                        if i < shape.fingers.count, let finger = shape.fingers[i] {
                            Text("\(finger)")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundStyle(.white)
                                .position(x: x, y: y)
                        }

                        // 根音标记 R
                        if isRoot {
                            Text("R")
                                .font(.system(size: 7, weight: .black))
                                .foregroundStyle(color)
                                .position(x: x + 10, y: y - 10)
                        }
                    }
                }
            }
        }
        .frame(width: 52, height: 80)
    }
}

// MARK: - CAGED 和弦集合概览视图（横向滚动）

struct CAGEDShapesRow: View {
    let chordData: CAGEDChordData
    var audio: TheoryTapAudio? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 和弦名称头部
            HStack(spacing: 6) {
                Text(chordData.chordName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(AppTheme.primaryText)
                Text("·")
                    .foregroundStyle(AppTheme.secondaryText)
                Text(chordData.quality)
                    .font(.system(size: 12))
                    .foregroundStyle(AppTheme.secondaryText)
                Spacer()
                Text("CAGED五大按法")
                    .font(.system(size: 11))
                    .foregroundStyle(AppTheme.accent)
            }

            // 五个形状水平排列
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(chordData.shapes) { shape in
                        CAGEDShapeDiagram(shape: shape, audio: audio)
                    }
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 6)
            }
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppTheme.border, lineWidth: 0.5))
    }
}

// MARK: - 完整CAGED调性和弦视图（用于和弦级数页面）

struct CAGEDScaleChordView: View {
    let scaleName: String
    let chords: [(degree: String, data: CAGEDChordData)]
    var audio: TheoryTapAudio? = nil

    @State private var expandedChord: String? = nil

    var body: some View {
        VStack(spacing: 12) {
            // 标题
            HStack(spacing: 6) {
                Image(systemName: "guitars")
                    .font(.system(size: 14))
                    .foregroundStyle(AppTheme.accent)
                Text("\(scaleName)大调 各级和弦CAGED按法")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppTheme.primaryText)
                Spacer()
            }
            .padding(.horizontal, 4)

            // 各级和弦
            ForEach(chords, id: \.degree) { item in
                VStack(spacing: 0) {
                    // 级数 + 和弦头部
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            expandedChord = expandedChord == item.degree ? nil : item.degree
                        }
                    }) {
                        HStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(AppTheme.accent.opacity(0.1))
                                    .frame(width: 32, height: 32)
                                Text(item.degree)
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(AppTheme.accent)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.data.chordName)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(AppTheme.primaryText)
                                Text(item.data.quality)
                                    .font(.system(size: 11))
                                    .foregroundStyle(AppTheme.secondaryText)
                            }

                            Spacer()

                            Image(systemName: expandedChord == item.degree ? "chevron.up" : "chevron.down")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(AppTheme.secondaryText)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)

                    // 展开的CAGED形状
                    if expandedChord == item.degree {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(item.data.shapes) { shape in
                                    CAGEDShapeDiagram(shape: shape, audio: audio)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 4)
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    Rectangle()
                        .fill(AppTheme.border)
                        .frame(height: 0.5)
                        .padding(.leading, 16)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.border, lineWidth: 0.5))
    }
}


// MARK: - Preview

#Preview("CAGED Single Chord") {
    ScrollView {
        VStack(spacing: 20) {
            CAGEDShapesRow(chordData: CAGEDDatabase.cMajor)
            CAGEDShapesRow(chordData: CAGEDDatabase.aMinor)
            CAGEDShapesRow(chordData: CAGEDDatabase.dMinor)
        }
        .padding()
        .background(AppTheme.background)
    }
}

#Preview("CAGED Scale Chords") {
    ScrollView {
        CAGEDScaleChordView(
            scaleName: "C",
            chords: CAGEDDatabase.cMajorScaleChords()
        )
        .padding()
        .background(AppTheme.background)
    }
}
