import SwiftUI

/// 音符输入键盘（参考 Solfeggio 设计）
struct MusicKeyboardView: View {
    let onNoteSelected: (String) -> Void
    
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
                    NoteKeyButton(note: note) { selectedNote in
                        let finalNote = applyAccidental(to: selectedNote)
                        onNoteSelected(finalNote)
                        isSharpActive = false
                        isFlatActive = false
                    }
                }
            }
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
        }
    }
    
    /// 应用升降号
    private func applyAccidental(to note: String) -> String {
        if isSharpActive {
            return note + "♯"
        } else if isFlatActive {
            return note + "♭"
        }
        return note
    }
}

// MARK: - 音符按键

struct NoteKeyButton: View {
    let note: String
    let onTap: (String) -> Void
    
    var body: some View {
        Button {
            onTap(note)
        } label: {
            Text(note)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(AppColors.primaryText)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color(.systemBackground))
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
        MusicKeyboardView { note in
            print("Selected: \(note)")
        }
        
        Divider()
        
        CompactMusicKeyboard(selectedNote: .constant(nil))
        
        Divider()
        
        SingingKeyboard(selectedNote: .constant("3"), onConfirm: {})
    }
    .padding()
}
