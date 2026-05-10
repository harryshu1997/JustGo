import Foundation

enum PointsCalculator {
    static func points(
        for type: GoalType,
        actualDuration: TimeInterval,
        actualReps: Int,
        completedFully: Bool,
        streakDays: Int
    ) -> Int {
        let base: Int
        switch type {
        case .duration:
            base = Int((actualDuration / 60).rounded(.down))
        case .reps:
            base = actualReps
        case .phased:
            base = Int(Double(actualReps + Int(actualDuration / 60)) * (completedFully ? 1.2 : 1.0))
        }
        let multiplier: Double = streakDays >= 7 ? 1.3
            : streakDays >= 3 ? 1.1
            : 1.0
        return Int(Double(base) * multiplier)
    }
}
