import SwiftUI

struct WatchRootView: View {
    @EnvironmentObject private var sync: WatchSessionDelegate
    @State private var path: [WatchRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            content
                .navigationDestination(for: WatchRoute.self) { route in
                    switch route {
                    case .active(let goal):
                        // 用 goal.id 作为 view identity，每个不同目标 = 全新 ActiveSessionView
                        // 防止上一个 session 的 @State（计时/计数）残留到下一个
                        ActiveSessionView(goal: goal, path: $path)
                            .id(goal.id)
                    case .completion(let result):
                        CompletionView(result: result, path: $path)
                            .id(result.goal.id)
                    case .nextPrompt:
                        NextGoalPromptView(path: $path)
                    }
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        if let goal = sync.currentGoal {
            VStack(spacing: 12) {
                HStack {
                    Spacer()
                    Text(progressText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)

                PixelBuddyView(stage: .baby, pose: .idle, pixelSize: 4)

                VStack(spacing: 2) {
                    Image(systemName: goal.sfSymbol)
                        .foregroundStyle(Palette.primary)
                    Text(goal.title).font(.headline)
                    Text(goal.subtitle).font(.caption).foregroundStyle(.secondary)
                }

                Button {
                    path.append(.active(goal))
                } label: {
                    Label("开始", systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(Palette.primary)
            }
            .padding(.horizontal, 8)
        } else {
            WaitingBuddyView()
        }
    }

    private var progressText: String {
        let total = sync.todayTotal
        let done = sync.todayCompleted
        return total > 0 ? "今日 \(done)/\(total)" : ""
    }
}

enum WatchRoute: Hashable {
    case active(WatchGoalSnapshot)
    case completion(SessionResult)
    case nextPrompt
}

struct WatchGoalSnapshot: Hashable, Identifiable {
    let id: UUID
    let title: String
    let typeRaw: String
    let targetDuration: TimeInterval?
    let targetReps: Int?
    var phases: [ActiveGoalsPayload.PhaseSnapshot] = []

    var type: GoalType { GoalType(rawValue: typeRaw) ?? .duration }

    var sfSymbol: String { type.sfSymbol }

    var subtitle: String {
        switch type {
        case .duration:
            if let d = targetDuration { return "\(Int(d / 60)) 分钟" }
            return "时长型"
        case .reps:
            if let r = targetReps { return "\(r) 个" }
            return "次数型"
        case .phased:
            return "\(phases.count) 阶段"
        }
    }
}

struct SessionResult: Hashable {
    let goal: WatchGoalSnapshot
    let startedAt: Date
    let endedAt: Date
    let duration: TimeInterval
    let reps: Int
    var completedPhases: Int = 0
}

/// 等待 iPhone 同步今日计划时显示的活跃 buddy
struct WaitingBuddyView: View {
    @State private var wanderX: CGFloat = 0
    @State private var thoughtIndex: Int = 0

    private let thoughts = [
        "等 iPhone 同步今日计划...",
        "今天打算练点什么？",
        "去 iPhone 设个目标吧",
        "我准备好啦 \\(≧▽≦)/",
    ]

    var body: some View {
        VStack(spacing: 16) {
            // buddy 在屏幕里左右溜达
            PixelBuddyView(
                stage: .baby,
                pose: .idle,
                pixelSize: 4,
                animation: .lively
            )
            .offset(x: wanderX)
            .onAppear {
                withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
                    wanderX = 35
                }
                Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
                    Task { @MainActor in
                        thoughtIndex = (thoughtIndex + 1) % thoughts.count
                    }
                }
            }

            Text(thoughts[thoughtIndex])
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .transition(.opacity.combined(with: .scale))
                .id(thoughtIndex)  // 文案切换时触发过渡
                .animation(.easeInOut, value: thoughtIndex)
        }
        .padding()
    }
}
