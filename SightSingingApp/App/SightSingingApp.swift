import SwiftUI

/// 主应用入口
@main
struct SightSingingApp: App {
    @AppStorage("colorScheme") private var colorScheme: Int = 0
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(colorScheme == 2 ? .dark : (colorScheme == 1 ? .light : nil))
        }
    }
}
