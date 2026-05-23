import SwiftUI

/// 视唱评分结果视图
struct ScoreResultView: View {
    let totalScore: Int
    let pitchScore: Int
    let rhythmScore: Int
    let onNext: () -> Void
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // 总分
            VStack(spacing: 8) {
                Text("本题得分")
                    .font(.headline)
                    .foregroundStyle(AppTheme.secondaryText)
                
                Text("\(totalScore)")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundStyle(scoreColor(totalScore))
                
                Text(scoreLabel(totalScore))
                    .font(.title3)
                    .foregroundStyle(scoreColor(totalScore))
            }
            
            // 分项得分
            HStack(spacing: 32) {
                scoreItem(title: "音准", score: pitchScore, icon: "music.note")
                scoreItem(title: "节奏", score: rhythmScore, icon: "metronome")
            }
            .padding()
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
            
            Spacer()
            
            // 操作按钮
            VStack(spacing: 12) {
                Button {
                    onNext()
                } label: {
                    Text("下一题")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppTheme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button {
                    onRetry()
                } label: {
                    Text("重新练习")
                        .font(.headline)
                        .foregroundStyle(AppTheme.accent)
                }
            }
            .padding(.horizontal, 16)
        }
        .padding()
        .background(AppTheme.background)
    }
    
    private func scoreItem(title: String, score: Int, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(AppTheme.accent)
            
            Text("\(score)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(scoreColor(score))
            
            Text(title)
                .font(.caption)
                .foregroundStyle(AppColors.secondaryText)
        }
    }
    
    private func scoreColor(_ score: Int) -> Color {
        if score >= 90 { return AppTheme.success }
        else if score >= 70 { return AppTheme.warning }
        else { return AppTheme.error }
    }
    
    private func scoreLabel(_ score: Int) -> String {
        switch score {
        case 95...100: return "完美!"
        case 85..<95: return "优秀"
        case 70..<85: return "良好"
        case 60..<70: return "及格"
        default: return "继续加油"
        }
    }
}

#Preview {
    ScoreResultView(totalScore: 92, pitchScore: 95, rhythmScore: 85, onNext: {}, onRetry: {})
}
