import SwiftUI

// MARK: - 谱式切换器 (V2.1 简化)

///
/// 顶部谱式切换器组件（仅两个选项：五线谱 | 六线谱+简谱）
struct NotationSwitcher: View {
    @Binding var selectedNotation: NotationType
    let availableNotations: [NotationType]

    init(
        selectedNotation: Binding<NotationType>,
        availableNotations: [NotationType] = NotationType.allCases
    ) {
        self._selectedNotation = selectedNotation
        self.availableNotations = availableNotations
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(availableNotations) { notation in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedNotation = notation
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: notation.iconName)
                            .font(.system(size: 18))

                        Text(notation.rawValue)
                            .font(.caption2)
                            .fontWeight(selectedNotation == notation ? .semibold : .regular)
                    }
                    .foregroundStyle(selectedNotation == notation ? AppColors.primary : AppColors.secondaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        selectedNotation == notation ?
                        AppColors.primary.opacity(0.1) :
                        Color.clear
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(AppColors.separator, lineWidth: 0.5)
        )
    }
}

// MARK: - 紧凑版切换器

/// 紧凑版谱式切换器（仅图标）
struct CompactNotationSwitcher: View {
    @Binding var selectedNotation: NotationType
    let availableNotations: [NotationType]

    var body: some View {
        HStack(spacing: 4) {
            ForEach(availableNotations) { notation in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedNotation = notation
                    }
                } label: {
                    Image(systemName: notation.iconName)
                        .font(.system(size: 16))
                        .foregroundStyle(selectedNotation == notation ? AppColors.primary : AppColors.secondaryText)
                        .frame(width: 36, height: 36)
                        .background(
                            selectedNotation == notation ?
                            AppColors.primary.opacity(0.1) :
                            Color.clear
                        )
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Color(.systemGray6))
        .clipShape(Capsule())
    }
}

// MARK: - 预览

#Preview {
    VStack(spacing: 20) {
        NotationSwitcher(
            selectedNotation: .constant(.tabWithSolfege),
            availableNotations: [.staff, .tabWithSolfege]
        )
        .padding()

        CompactNotationSwitcher(
            selectedNotation: .constant(.tabWithSolfege),
            availableNotations: [.staff, .tabWithSolfege]
        )
    }
}
