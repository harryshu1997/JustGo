import Foundation
import SwiftData

/// 森林衰退：长时间不运动，最老的树会逐周枯死成树桩。
///
/// 规则：
/// - 距离 `lastSessionDate` < 7 天：无衰退
/// - = 7 天：最老的 1 棵树死掉
/// - = 14 天：累计 2 棵死掉（最老两棵）
/// - 之后每多 7 天空闲 +1 棵
@MainActor
enum ForestDecayService {
    /// 在 ForestView / HomeView 出现时跑一次。返回这次新增的死亡数。
    @discardableResult
    static func applyDecay(in context: ModelContext, now: Date = Date()) -> Int {
        let profileDescriptor = FetchDescriptor<UserProfile>()
        guard let profile = try? context.fetch(profileDescriptor).first,
              let lastSession = profile.lastSessionDate
        else { return 0 }

        let cal = Calendar.current
        let lastDay = cal.startOfDay(for: lastSession)
        let today = cal.startOfDay(for: now)
        let daysIdle = cal.dateComponents([.day], from: lastDay, to: today).day ?? 0
        let shouldDeadCount = max(0, daysIdle / 7)

        guard shouldDeadCount > 0 else { return 0 }

        // 取所有活着的树，按 plantedAt 升序（最老的在前）
        let allTreesDescriptor = FetchDescriptor<Tree>(
            sortBy: [SortDescriptor(\.plantedAt, order: .forward)]
        )
        guard let allTrees = try? context.fetch(allTreesDescriptor) else { return 0 }
        let aliveTrees = allTrees.filter { $0.isAlive }
        let alreadyDead = allTrees.count - aliveTrees.count
        let toKillCount = max(0, shouldDeadCount - alreadyDead)

        var killed = 0
        for tree in aliveTrees.prefix(toKillCount) {
            tree.isAlive = false
            killed += 1
        }

        if killed > 0 {
            try? context.save()
            print("[Decay] idle=\(daysIdle)d shouldDead=\(shouldDeadCount) killed=\(killed) totalDead=\(alreadyDead + killed)")
        }
        return killed
    }
}
