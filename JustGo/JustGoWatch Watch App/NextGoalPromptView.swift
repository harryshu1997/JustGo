import SwiftUI
import WatchKit

struct NextGoalPromptView: View {
    @Binding var path: [WatchRoute]
    @EnvironmentObject private var sync: WatchSessionDelegate

    var body: some View {
        Group {
            if let next = sync.currentGoal {
                next_(goal: next)
            } else {
                allDone
            }
        }
        .padding(.horizontal, 8)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            WKInterfaceDevice.current().play(.notification)
        }
    }

    private func next_(goal: WatchGoalSnapshot) -> some View {
        VStack(spacing: 10) {
            Text("下一个目标").font(.caption).foregroundStyle(.secondary)
            HStack {
                Image(systemName: goal.sfSymbol)
                Text(goal.title)
            }
            .font(.headline)
            Text(goal.subtitle).font(.caption).foregroundStyle(.secondary)

            VStack(spacing: 6) {
                Button {
                    path.removeAll()
                    path.append(.active(goal))
                } label: {
                    Label("立即开始", systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(Palette.primary)

                Button("稍后再说") {
                    path.removeAll()
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)
            }
        }
    }

    private var allDone: some View {
        VStack(spacing: 8) {
            Text("今日全部完成 🎉").font(.headline)
            PixelBuddyView(stage: .baby, pose: .excited, pixelSize: 5)
            Text("Buddy 今日很满意").font(.caption).foregroundStyle(.secondary)
            Button("回到主页") {
                path.removeAll()
            }
            .buttonStyle(.bordered)
        }
    }
}
