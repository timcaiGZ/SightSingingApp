import SwiftUI

/// 乐理知识详情页
struct TheoryDetailView: View {
    let topic: TheoryTopic

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 标题
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: topic.category.iconName)
                            .foregroundStyle(AppColors.primary)

                        Text(topic.category.displayName)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Text(topic.title)
                        .font(.title)
                        .fontWeight(.bold)

                    Text(topic.summary)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Divider()

                // 六线谱图示（如果有）
                if let tabData = topic.tabData {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("指法图示")
                            .font(.headline)

                        GuitarTabView(tabData: tabData)
                            .frame(height: 120)
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }

                // 内容（Markdown 风格渲染）
                MarkdownContentView(content: topic.content)

                Spacer(minLength: 32)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(topic.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// 简单的 Markdown 内容渲染
struct MarkdownContentView: View {
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(parseContent(), id: \.id) { block in
                switch block.type {
                case .heading2:
                    Text(block.text)
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top, 8)

                case .heading3:
                    Text(block.text)
                        .font(.headline)
                        .padding(.top, 4)

                case .paragraph:
                    Text(block.text)
                        .font(.body)
                        .lineSpacing(4)

                case .bulletList:
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(block.items, id: \.self) { item in
                            HStack(alignment: .top, spacing: 8) {
                                Text("•")
                                    .foregroundStyle(AppColors.primary)
                                Text(item)
                                    .font(.body)
                            }
                        }
                    }
                    .padding(.leading, 8)

                case .numberedList:
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(Array(block.items.enumerated()), id: \.offset) { index, item in
                            HStack(alignment: .top, spacing: 8) {
                                Text("\(index + 1).")
                                    .foregroundStyle(AppColors.primary)
                                    .frame(width: 20, alignment: .trailing)
                                Text(item)
                                    .font(.body)
                            }
                        }
                    }
                    .padding(.leading, 8)

                case .codeBlock:
                    Text(block.text)
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
    }

    enum BlockType {
        case heading2, heading3, paragraph, bulletList, numberedList, codeBlock
    }

    struct ContentBlock: Identifiable {
        let id = UUID()
        let type: BlockType
        let text: String
        let items: [String]
    }

    private func parseContent() -> [ContentBlock] {
        var blocks: [ContentBlock] = []
        let lines = content.components(separatedBy: "\n")

        var i = 0
        while i < lines.count {
            let line = lines[i].trimmingCharacters(in: .whitespaces)

            if line.isEmpty {
                i += 1
                continue
            }

            if line.hasPrefix("## ") {
                blocks.append(ContentBlock(type: .heading2, text: String(line.dropFirst(3)), items: []))
            } else if line.hasPrefix("### ") {
                blocks.append(ContentBlock(type: .heading3, text: String(line.dropFirst(4)), items: []))
            } else if line.hasPrefix("```") {
                // 代码块
                var codeLines: [String] = []
                i += 1
                while i < lines.count && !lines[i].hasPrefix("```") {
                    codeLines.append(lines[i])
                    i += 1
                }
                blocks.append(ContentBlock(type: .codeBlock, text: codeLines.joined(separator: "\n"), items: []))
            } else if line.hasPrefix("- ") {
                // 无序列表
                var items: [String] = []
                while i < lines.count && (lines[i].hasPrefix("- ") || lines[i].hasPrefix("  - ")) {
                    let item = lines[i].replacingOccurrences(of: "- ", with: "").trimmingCharacters(in: .whitespaces)
                    items.append(item)
                    i += 1
                }
                blocks.append(ContentBlock(type: .bulletList, text: "", items: items))
                continue
            } else if line.first?.isNumber == true && line.contains(".") {
                // 有序列表 - 使用 prefix(while:) 更安全
                var items: [String] = []
                while i < lines.count {
                    let currentLine = lines[i]
                    // 检查是否是有序列表项（数字开头）
                    guard let firstChar = currentLine.first, firstChar.isNumber else { break }
                    // 找到数字后的点和空格
                    var cleaned = currentLine
                    if let dotIndex = cleaned.firstIndex(where: { $0 == "." }) {
                        let startIndex = cleaned.index(after: dotIndex)
                        cleaned = String(cleaned[startIndex...]).trimmingCharacters(in: .whitespaces)
                    }
                    items.append(cleaned)
                    i += 1
                }
                blocks.append(ContentBlock(type: .numberedList, text: "", items: items))
                continue
            } else {
                blocks.append(ContentBlock(type: .paragraph, text: line, items: []))
            }

            i += 1
        }

        return blocks
    }
}

#Preview {
    NavigationStack {
        if let firstTopic = TheoryDataSource.allTopics.first {
            TheoryDetailView(topic: firstTopic)
        } else {
            Text("无可用的乐理主题")
                .navigationTitle("预览")
        }
    }
}
