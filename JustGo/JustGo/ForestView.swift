import SwiftUI
import SwiftData

struct ForestView: View {
    @Query private var trees: [Tree]
    @Query private var profiles: [UserProfile]

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    levelCard
                    forestCanvas
                    stats
                }
                .padding()
            }
            .navigationTitle("我的森林")
            .background(Palette.bg)
        }
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
                .frame(maxWidth: .infinity)
            } else {
                ForEach(trees) { tree in
                    PixelTreeView(
                        pattern: PixelTreePatterns.oak(stage: tree.growthStage),
                        pixelSize: 4
                    )
                    .offset(x: tree.x, y: tree.y)
                }
            }

            PixelBuddyView(stage: profile?.buddyStage ?? .baby, pixelSize: 4)
                .padding(.leading, 16)
                .padding(.bottom, 16)
        }
    }

    private var stats: some View {
        HStack(spacing: 16) {
            stat(
                title: "已种",
                value: "\(trees.count) 棵",
                icon: "tree.fill"
            )
            stat(
                title: "Buddy",
                value: profile?.buddyStage.displayName ?? "—",
                icon: "pawprint.fill"
            )
            stat(
                title: "连续",
                value: "\(profile?.streakDays ?? 0) 天",
                icon: "flame.fill"
            )
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
}

#Preview {
    ForestView()
}
