import SwiftUI

/// 模块徽章
struct ModuleBadge: View {
    let title: String
    let color: Color
    
    var body: some View {
        Text(title)
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color)
            .clipShape(Capsule())
    }
}

#Preview {
    HStack {
        ModuleBadge(title: "音名", color: AppColors.noteName)
        ModuleBadge(title: "音程", color: AppColors.interval)
        ModuleBadge(title: "和弦", color: AppColors.chord)
    }
}
