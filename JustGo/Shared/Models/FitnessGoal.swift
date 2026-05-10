import Foundation
import SwiftData

@Model
final class FitnessGoal {
    var id: UUID = UUID()
    var title: String = ""
    var goalDescription: String = ""
    var typeRaw: String = GoalType.duration.rawValue
    var targetDuration: TimeInterval? = nil
    var targetReps: Int? = nil
    @Relationship(deleteRule: .cascade, inverse: \GoalPhase.goal)
    var phases: [GoalPhase]? = []
    var createdAt: Date = Date()
    var isArchived: Bool = false

    var type: GoalType {
        get { GoalType(rawValue: typeRaw) ?? .duration }
        set { typeRaw = newValue.rawValue }
    }

    init(
        title: String = "",
        goalDescription: String = "",
        type: GoalType = .duration,
        targetDuration: TimeInterval? = nil,
        targetReps: Int? = nil
    ) {
        self.title = title
        self.goalDescription = goalDescription
        self.typeRaw = type.rawValue
        self.targetDuration = targetDuration
        self.targetReps = targetReps
    }
}
