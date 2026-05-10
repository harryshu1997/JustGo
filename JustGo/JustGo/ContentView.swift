import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("主页", systemImage: "house.fill") }

            ForestView()
                .tabItem { Label("森林", systemImage: "tree.fill") }

            HistoryView()
                .tabItem { Label("历史", systemImage: "clock.arrow.circlepath") }

            StatsView()
                .tabItem { Label("统计", systemImage: "chart.bar.fill") }

            ProfileView()
                .tabItem { Label("我的", systemImage: "person.fill") }
        }
        .tint(Palette.primary)
    }
}

#Preview {
    ContentView()
}
