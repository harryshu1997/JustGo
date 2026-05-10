import Foundation

enum TreeSpawnRules {
    static func species(
        for type: GoalType,
        actualDuration: TimeInterval,
        completedFully: Bool
    ) -> TreeSpecies? {
        guard completedFully else { return nil }
        switch type {
        case .duration:
            if actualDuration >= 45 * 60 { return .sequoia }
            if actualDuration >= 15 * 60 { return .oak }
            return .shrub
        case .reps:
            return .oak
        case .phased:
            return .sakura
        }
    }
}
