import SwiftUI

struct ContentView: View {
    @AppStorage("colorScheme") private var colorScheme: Int = 0

    var body: some View {
        TabView {
            PracticeTab()
                .tabItem {
                    Label("练习", systemImage: "music.note.list")
                }

            CourseTab()
                .tabItem {
                    Label("课程", systemImage: "book.closed")
                }

            TheoryTab()
                .tabItem {
                    Label("乐理", systemImage: "book")
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
