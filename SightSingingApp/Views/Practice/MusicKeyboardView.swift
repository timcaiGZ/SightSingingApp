import SwiftUI

/// 音符输入键盘（参考 Solfeggio 设计）
struct MusicKeyboardView: View {
    @Binding var inputText: String
    
    @State private var isSharpActive = false
    @State private var isFlatActive = false
    
    private let naturalNotes = ["C", "D", "E", "F", "G", "A", "B"]
    
    var body: some View {
        VStack(spacing: 12) {
            // 升降号选择
            accidentalSelector
            
            // 主键盘
            HStack(spacing: 8) {
                ForEach(naturalNotes, id: \.self) { note in
                    NoteKeyButton(note: note, inputText: $inputText)
                }
            }
            
            // 功能按钮
            functionButtons
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - 升降号选择
    
    private var accidentalSelector: some View {
        HStack(spacing: 16) {
            Button {
                isSharpActive.toggle()
                if isSharpActive { isFlatActive = false }
            } label: {
                Text("♯")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(isSharpActive ? .white : AppColors.accentBlue)
                    .frame(width: 48, height: 48)
                    .background(isSharpActive ? AppColors.accentBlue : AppColors.accentBlue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
            
            Button {
                isFlatActive.toggle()
                if isFlatActive { isSharpActive = false }
            } label: {
                Text("♭")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(isFlatActive ? .white : AppColors.accentBlue)
                    .frame(width: 48, height: 48)
                    .background(isFlatActive ? AppColors.accentBlue : AppColors.accentBlue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            // 当前输入预览
            if !inputText.isEmpty {
                Text(inputText)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(AppColors.accentBlue)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
    
    // MARK: - 功能按钮
    
    private var functionButtons: some View {
        HStack(spacing: 12) {
            // 清空按钮
            Button {
                inputText = ""
                isSharpActive = false
                isFlatActive = false
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("清空")
                }
                .font(.subheadline)
                .foregroundStyle(AppColors.error)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(AppColors.error.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
            
            // 确认按钮
            Button {
                // 确认输入
            } label: {
                HStack {
                    Image(systemName: "checkmark")
                    Text("确认")
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(inputText.isEmpty ? Color(.systemGray4) : AppColors.accentBlue)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
            .disabled(inputText.isEmpty)
        }
    }
}

// MARK: - 音符按键

struct NoteKeyButton: View {
    let note: String
    @Binding var inputText: String
    
    private let isBlackKey: Bool = false
    
    var body: some View {
        Button {
            inputText = note
        } label: {
            Text(note)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(inputText == note ? .white : AppColors.primaryText)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(inputText == note ? AppColors.accentBlue : Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 紧凑版钢琴键盘

struct CompactMusicKeyboard: View {
    @Binding var selectedNote: String?
    
    private let notes = ["C", "D", "E", "F", "G", "A", "B"]
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(notes, id: \.self) { note in
                Button {
                    selectedNote = note
                } label: {
                    Text(note)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(selectedNote == note ? .white : AppColors.primaryText)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(selectedNote == note ? AppColors.accentBlue : Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - 视唱用钢琴键盘

struct SingingKeyboard: View {
    @Binding var selectedNote: String?
    let onConfirm: () -> Void
    
    private let notes = ["1", "2", "3", "4", "5", "6", "7"]
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 6) {
                ForEach(notes, id: \.self) { note in
                    Button {
                        selectedNote = note
                    } label: {
                        Text(note)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(selectedNote == note ? .white : AppColors.primaryText)
                            .frame(maxWidth: .infinity)
                            .frame(height: 64)
                            .background(selectedNote == note ? AppColors.accentBlue : Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
            
            HStack(spacing: 12) {
                Button {
                    selectedNote = nil
                } label: {
                    Text("清空")
                        .font(.subheadline)
                        .foregroundStyle(AppColors.error)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(AppColors.error.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
                
                Button {
                    onConfirm()
                } label: {
                    Text("确认演唱")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(selectedNote == nil ? Color(.systemGray4) : AppColors.success)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
                .disabled(selectedNote == nil)
            }
        }
    }
}

#Preview {
    VStack {
        MusicKeyboardView(inputText: .constant(""))
        
        Divider()
        
        CompactMusicKeyboard(selectedNote: .constant(nil))
        
        Divider()
        
        SingingKeyboard(selectedNote: .constant("3"), onConfirm: {})
    }
    .padding()
}
