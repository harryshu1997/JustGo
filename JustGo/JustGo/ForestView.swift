import SwiftUI
import SwiftData

struct ForestView: View {
    @Environment(\.modelContext) private var context
    @Query private var trees: [Tree]
    @Query private var profiles: [UserProfile]

    private var profile: UserProfile? { profiles.first }

    private var aliveCount: Int { trees.filter(\.isAlive).count }
    private var deadCount: Int { trees.count - aliveCount }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    levelCard
                    if deadCount > 0 { decayWarning }
                    forestCanvas
                    stats
                }
                .padding()
            }
            .navigationTitle("我的森林")
            .background(Palette.bg)
            .onAppear {
                ForestDecayService.applyDecay(in: context)
            }
        }
    }

    private var decayWarning: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
            VStack(alignment: .leading, spacing: 2) {
                Text("\(deadCount) 棵树枯死了").font(.subheadline.bold())
                Text("最近运动太少，每空闲 7 天最老的一棵会变树桩。继续完成目标，新树会继续种下。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color.orange.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var levelCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Lv. \(profile?.level ?? 1)")
                    .font(.title.bold())
                Spacer()
                Text("\(profile?.totalPoints ?? 0) 分")
                    .foregroundStyle(.secondary)
            }
            ProgressView(value: progressFraction)
                .tint(Palette.primary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var forestCanvas: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient(
                    colors: [Palette.primaryLight.opacity(0.3), Palette.bg],
                    startPoint: .top,
                    endPoint: .bottom
                ))
                .frame(height: 320)

            if trees.isEmpty {
                VStack {
                    Spacer()
                    Text("完成第一个目标后会种下第一棵树")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: 320)
            } else {
                TimelineView(.periodic(from: .now, by: 0.5)) { context in
                    ZStack {
                        ForEach(trees) { tree in
                            PixelTreeView(
                                pattern: pattern(for: tree, at: context.date),
                                pixelSize: 4,
                                isWilted: tree.isWilted
                            )
                            .offset(x: tree.x, y: tree.y)
                            .scaleEffect(scaleForStage(currentStage(for: tree, at: context.date)))
                            .animation(.easeInOut(duration: 0.6), value: currentStage(for: tree, at: context.date))
                        }
                    }
                }
            }

            RoamingBuddyView(stage: profile?.buddyStage ?? .baby)
                .padding(.leading, 16)
                .padding(.bottom, 16)
        }
    }

    private var stats: some View {
        HStack(spacing: 16) {
            stat(
                title: "存活 / 总数",
                value: "\(aliveCount) / \(trees.count)",
                icon: "tree.fill"
            )
            stat(title: profile?.buddyName ?? "Buddy",
                 value: profile?.buddyStage.displayName ?? "—",
                 icon: "pawprint.fill")
            stat(title: "连续", value: "\(profile?.streakDays ?? 0) 天", icon: "flame.fill")
        }
    }

    private func stat(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon).foregroundStyle(Palette.primary)
            Text(value).font(.headline)
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var progressFraction: Double {
        guard let p = profile else { return 0 }
        let target = max(100, p.level * 1000)
        return min(1.0, Double(p.totalPoints) / Double(target))
    }

    private func currentStage(for tree: Tree, at now: Date) -> Int {
        if !tree.isAlive { return 3 }
        let elapsed = now.timeIntervalSince(tree.plantedAt)
        if elapsed < 10 { return 0 }
        if elapsed < 25 { return 1 }
        if elapsed < 45 { return 2 }
        return 3
    }

    private func scaleForStage(_ stage: Int) -> CGFloat {
        switch stage {
        case 0: return 0.6
        case 1: return 0.75
        case 2: return 0.9
        default: return 1.0
        }
    }

    private func pattern(for tree: Tree, at now: Date) -> [[PixelColor]] {
        if !tree.isAlive { return PixelTreePatterns.stump }
        let stage = currentStage(for: tree, at: now)
        switch tree.species {
        case .sakura:
            return PixelTreePatterns.sakura(stage: stage)
        case .shrub, .oak, .sequoia:
            return PixelTreePatterns.oak(stage: stage)
        }
    }
}

/// Buddy 在森林角落随机漂动
struct RoamingBuddyView: View {
    let stage: BuddyStage

    @State private var dx: CGFloat = 0
    @State private var dy: CGFloat = 0

    var body: some View {
        PixelBuddyView(stage: stage, pixelSize: 4)
            .offset(x: dx, y: dy)
            .onAppear { startRoaming() }
    }

    private func startRoaming() {
        roam()
        Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
            roam()
        }
    }

    private func roam() {
        let nextX = CGFloat.random(in: 0...60)
        let nextY = CGFloat.random(in: (-20)...20)
        withAnimation(.easeInOut(duration: 2.0)) {
            dx = nextX
            dy = nextY
        }
    }
}

#Preview {
    ForestView()
}
