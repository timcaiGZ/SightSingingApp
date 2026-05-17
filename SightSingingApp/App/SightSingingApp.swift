import SwiftUI
import SwiftData

@main
struct SightSingingApp: App {
    let modelContainer: ModelContainer

    init() {
        do {
            let schema = Schema([
                PracticeRecord.self,
                TestHistory.self
            ])
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("无法初始化 SwiftData ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(modelContainer)
        }
    }
}
