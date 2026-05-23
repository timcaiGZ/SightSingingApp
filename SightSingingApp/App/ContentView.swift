import SwiftUI

// MARK: - 主应用视图 (严格匹配 v0.app: 4 Tab + 底部导航栏)
// v0 原型 Tab: 练习(Music) | 乐理(Library) | 测试(CheckCircle) | 我的(User)
struct ContentView: View {
    @AppStorage("notationType") private var globalNotationType: String = "guitar-tab"
    
    var body: some View {
        TabView {
            PracticeTab()
                .tabItem {
                    Label("练习", systemImage: "music.note")
                }
            
            TheoryTab()
                .tabItem {
                    Label("乐理", systemImage: "books.vertical")
                }
            
            TestTab()
                .tabItem {
                    Label("测试", systemImage: "checkmark.circle")
                }
            
            ProfileTab()
                .tabItem {
                    Label("我的", systemImage: "person.circle")
                }
        }
        .tint(AppTheme.accent)
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.white.withAlphaComponent(0.95)
            appearance.shadowColor = UIColor(AppTheme.tabBarBorder).withAlphaComponent(0.5)
            
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor(AppTheme.tabInactive)
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .font: UIFont.systemFont(ofSize: 10, weight: .regular),
                .foregroundColor: UIColor(AppTheme.tabInactive)
            ]
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor(AppTheme.tabActive)
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .font: UIFont.systemFont(ofSize: 10, weight: .medium),
                .foregroundColor: UIColor(AppTheme.tabActive)
            ]
            
            UITabBar.appearance().standardAppearance = appearance
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
        }
    }
}

#Preview { ContentView() }
