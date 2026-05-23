import SwiftUI

/// 七和弦详情页
struct SeventhChordsView: View {
    @State private var selectedKey = "C"
    @Environment(\.dismiss) private var dismiss
    
    private let keys = ["C", "G", "D", "A", "E", "F", "Bb", "Eb", "Ab", "Db"]
    
    private let chords: [String: [String]] = [
        "C": ["Cmaj7", "Dm7", "Em7", "Fmaj7", "G7", "Am7", "Bm7b5"],
        "G": ["Gmaj7", "Am7", "Bm7", "Cmaj7", "D7", "Em7", "F#m7b5"],
        "D": ["Dmaj7", "Em7", "F#m7", "Gmaj7", "A7", "Bm7", "C#m7b5"],
        "A": ["Amaj7", "Bm7", "C#m7", "Dmaj7", "E7", "F#m7", "G#m7b5"],
        "E": ["Emaj7", "F#m7", "G#m7", "Amaj7", "B7", "C#m7", "D#m7b5"],
        "F": ["Fmaj7", "Gm7", "Am7", "Bbmaj7", "C7", "Dm7", "Em7b5"],
        "Bb": ["Bbmaj7", "Cm7", "Dm7", "Ebmaj7", "F7", "Gm7", "Am7b5"],
        "Eb": ["Ebmaj7", "Fm7", "Gm7", "Abmaj7", "Bb7", "Cm7", "Dm7b5"],
        "Ab": ["Abmaj7", "Bbm7", "Cm7", "Dbmaj7", "Eb7", "Fm7", "Gm7b5"],
        "Db": ["Dbmaj7", "Ebm7", "Fm7", "Gbmaj7", "Ab7", "Bbm7", "Cm7b5"]
    ]
    
    private let chordTypes = ["maj7", "m7", "m7", "maj7", "7", "m7", "m7b5"]
    private let chordColors: [String: Color] = [
        "maj7": Color(hex: "3B82F6"),
        "m7": Color(hex: "8B5CF6"),
        "7": Color(hex: "F59E0B"),
        "m7b5": Color(hex: "EF4444")
    ]
    private let degrees = ["Ⅰ", "Ⅱ", "Ⅲ", "Ⅳ", "Ⅴ", "Ⅵ", "Ⅶ"]
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部导航
            HStack {
                Button("← 返回") {
                    dismiss()
                }
                .foregroundStyle(AppTheme.accent)
                Spacer()
                Text("七和弦")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Color.clear.frame(width: 50)
            }
            .padding(16)
            .background(Color.white)
            
            // 调选择器
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(keys, id: \.self) { key in
                        Button {
                            selectedKey = key
                        } label: {
                            Text(key)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(selectedKey == key ? .white : AppTheme.primaryText)
                                .padding(.horizontal, 11)
                                .padding(.vertical, 6)
                                .background(selectedKey == key ? AppTheme.primary : Color.white)
                                .clipShape(Capsule())
                                .overlay {
                                    Capsule()
                                        .stroke(selectedKey == key ? AppTheme.primary : AppTheme.border, lineWidth: 1.5)
                                }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            
            // 和弦列表
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(Array((chords[selectedKey] ?? chords["C"]!).enumerated()), id: \.offset) { index, chord in
                        HStack {
                            Text(degrees[index])
                                .font(.system(size: 12))
                                .foregroundStyle(AppTheme.secondaryText)
                                .frame(width: 26)
                            
                            Text(chord)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(AppTheme.primaryText)
                            
                            Spacer()
                            
                            Text(chordTypes[index])
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(chordColors[chordTypes[index]] ?? AppTheme.secondaryText)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background((chordColors[chordTypes[index]] ?? AppTheme.secondaryText).opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 7))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        
                        if index < 6 {
                            Rectangle()
                                .fill(AppTheme.border)
                                .frame(height: 1)
                        }
                    }
                }
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
                .padding(16)
            }
        }
        .background(AppTheme.background)
        .navigationBarHidden(true)
    }
}

/// 五度圈视图
struct CircleOfFifthsView: View {
    @State private var selectedKey = "C"
    @Environment(\.dismiss) private var dismiss
    
    private let majorKeys = ["C", "G", "D", "A", "E", "B", "F#", "Db", "Ab", "Eb", "Bb", "F"]
    private let minorKeys = ["Am", "Em", "Bm", "F#m", "C#m", "G#m", "D#m", "Bbm", "Fm", "Cm", "Gm", "Dm"]
    
    private let sharpCounts: [String: Int] = [
        "C": 0, "G": 1, "D": 2, "A": 3, "E": 4, "B": 5, "F#": 6,
        "Db": 5, "Ab": 4, "Eb": 3, "Bb": 2, "F": 1
    ]
    
    private let sharpKeys = ["F#", "C#", "G#", "D#", "A#", "E#"]
    private let flatKeys = ["Bb", "Eb", "Ab", "Db", "Gb", "Cb"]
    
    private var keySignature: String {
        let count = sharpCounts[selectedKey] ?? 0
        if count == 0 { return "无升降号" }
        let keys = majorKeys.firstIndex(of: selectedKey)! < 7 ? sharpKeys : flatKeys
        let sig = Array(keys.prefix(count)).joined(separator: ", ")
        return "\(count)个升号: \(sig)"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部导航
            HStack {
                Button("← 返回") {
                    dismiss()
                }
                .foregroundStyle(AppTheme.accent)
                Spacer()
                Text("五度圈")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Color.clear.frame(width: 50)
            }
            .padding(16)
            .background(Color.white)
            
            ScrollView {
                VStack(spacing: 16) {
                    // 五度圈 SVG
                    ZStack {
                        // 外圈 - 大调
                        ForEach(Array(majorKeys.enumerated()), id: \.element) { index, key in
                            let angle = Double(index) * 30 - 90
                            let radians = angle * .pi / 180
                            let x = 140 + 92 * cos(radians)
                            let y = 140 + 92 * sin(radians)
                            
                            Button {
                                selectedKey = key
                            } label: {
                                VStack(spacing: 2) {
                                    Text(key)
                                        .font(.system(size: selectedKey == key ? 13 : 12, weight: selectedKey == key ? .bold : .regular))
                                        .foregroundStyle(selectedKey == key ? .white : AppTheme.primary)
                                }
                                .frame(width: 32, height: 32)
                                .background(
                                    selectedKey == key ? AppTheme.primary : Color(hex: "EFF6FF")
                                )
                                .clipShape(Circle())
                            }
                            .offset(x: x - 156, y: y - 156)
                        }
                        
                        // 内圈 - 小调
                        ForEach(Array(minorKeys.enumerated()), id: \.element) { index, key in
                            let angle = Double(index) * 30 - 90
                            let radians = angle * .pi / 180
                            let x = 140 + 56 * cos(radians)
                            let y = 140 + 56 * sin(radians)
                            
                            Text(key)
                                .font(.system(size: 10))
                                .foregroundStyle(AppTheme.primary)
                                .frame(width: 28, height: 28)
                                .background(Color(hex: "DBEAFE"))
                                .clipShape(Circle())
                                .offset(x: x - 156, y: y - 156)
                        }
                        
                        // 中心
                        Text(selectedKey)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(AppTheme.primaryText)
                            .frame(width: 60, height: 60)
                            .background(AppTheme.mutedBackground)
                            .clipShape(Circle())
                    }
                    .frame(width: 268, height: 268)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .padding(.top, 16)
                    
                    // 升降号信息
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(selectedKey) 大调")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(AppTheme.accent)
                            Text(keySignature)
                                .font(.system(size: 13))
                                .foregroundStyle(AppTheme.primaryText)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppTheme.accent.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
        .background(AppTheme.background)
        .navigationBarHidden(true)
    }
}

#Preview {
    CircleOfFifthsView()
}

/// 乐理知识点详情页
struct TheoryDetailView: View {
    let topic: TheoryTopicData
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部导航
            HStack {
                Button("← 返回") {
                    dismiss()
                }
                .foregroundStyle(AppTheme.accent)
                Spacer()
                Text(topic.title)
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Color.clear.frame(width: 50)
            }
            .padding(16)
            .background(Color.white)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 标题
                    VStack(alignment: .leading, spacing: 8) {
                        Text(topic.title)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(AppTheme.primaryText)
                        
                        Text(topic.description)
                            .font(.system(size: 14))
                            .foregroundStyle(AppTheme.secondaryText)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    
                    // 占位内容 - V3.0 实现详细知识点
                    VStack(alignment: .leading, spacing: 12) {
                        Text("知识点内容")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(AppTheme.primaryText)
                        
                        Text("本知识点的详细内容将在 V3.0 版本中提供。")
                            .font(.system(size: 14))
                            .foregroundStyle(AppTheme.secondaryText)
                            .padding(.top, 8)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                }
                .padding(16)
            }
        }
        .background(AppTheme.background)
        .navigationBarHidden(true)
    }
}
