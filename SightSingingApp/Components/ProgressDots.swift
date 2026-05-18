import SwiftUI

/// 进度指示器（圆点样式）
struct ProgressDots: View {
    let total: Int
    let completed: Int
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<total, id: \.self) { index in
                Circle()
                    .fill(index < completed ? AppColors.primaryBlue : Color(hex: "E2E8F0"))
                    .frame(width: 8, height: 8)
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ProgressDots(total: 5, completed: 0)
        ProgressDots(total: 5, completed: 2)
        ProgressDots(total: 5, completed: 5)
    }
    .padding()
}
