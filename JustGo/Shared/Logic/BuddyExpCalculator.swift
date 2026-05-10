import Foundation

enum BuddyExpCalculator {
    static func exp(
        actualDuration: TimeInterval,
        completedPhases: Int,
        streakDays: Int,
        isFirstTimeForGoal: Bool,
        isLastInDailyPlan: Bool
    ) -> Int {
        var total = Int((actualDuration / 60).rounded(.down))
        total += completedPhases
        if streakDays >= 2 { total += 5 }
        if isFirstTimeForGoal { total += 10 }
        if isLastInDailyPlan { total += 15 }
        return total
    }
}
