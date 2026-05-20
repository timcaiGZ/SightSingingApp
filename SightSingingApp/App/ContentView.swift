import SwiftUI

// MARK: - 主应用视图 (匹配 v0 AppShell: 5Tab + 底部导航栏)
// 原型 Tab: 练习(Music) | 课程(BookOpen) | 乐理(Library) | 测试(CheckCircle) | 我的(User)
struct ContentView: View {
    @AppStorage("colorScheme") private var colorScheme: Int = 0
    @AppStorage("notationType") private var globalNotationType: String = "guitar-tab"
    
    var body: some View {
        NavigationStack {
            TabView {
                PracticeTab()
                    .tabItem {
                        Label("练习", systemImage: "music.note")   // Music icon
                    }
                
                CourseTab()
                    .tabItem {
                        Label("课程", systemImage: "book")         // BookOpen icon
                    }
                
                TheoryTab()
                    .tabItem {
                        Label("乐理", systemImage: "books.vertical")// Library icon
                    }
                
                TestTab()
                    .tabItem {
                        Label("测试", systemImage: "checkmark.circle")  // CheckCircle icon
                    }
                
                ProfileTab()
                    .tabItem {
                        Label("我的", systemImage: "person.circle")     // User icon
                    }
            }
            .tint(AppTheme.accent)                                   // iOS Blue #007AFF
            .preferredColorScheme(colorScheme == 2 ? .dark : (colorScheme == 1 ? .light : nil))
        }
        .onAppear {
            // 设置标准 TabBar 外观 (匹配 v0: bg-tab-bar/95 ios-blur border-t)
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.white.withAlphaComponent(0.95)
            appearance.shadowColor = UIColor(AppTheme.tabBarBorder).withAlphaComponent(0.5)
            
            // 正常状态
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor(AppTheme.tabInactive)
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .font: UIFont.systemFont(ofSize: 10, weight: .regular),
                .foregroundColor: UIColor(AppTheme.tabInactive)
            ]
            // 选中状态
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