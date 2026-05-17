import SwiftUI

struct ContentView: View {
    @AppStorage("colorScheme") private var colorScheme: Int = 0
    // 0 = system, 1 = light, 2 = dark

    var body: some View {
        TabView {
            PracticeTab()
                .tabItem {
                    Label("练习", systemImage: "music.note.list")
                }

            TestTab()
                .tabItem {
                    Label("测试", systemImage: "waveform.path.ecg")
                }

            TheoryTab()
                .tabItem {
                    Label("乐理", systemImage: "book.closed")
                }

            ProfileTab()
                .tabItem {
                    Label("我的", systemImage: "person.circle")
                }
        }
        .preferredColorScheme(colorScheme == 2 ? .dark : (colorScheme == 1 ? .light : nil))
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [PracticeRecord.self, TestHistory.self], inMemory: true)
}
