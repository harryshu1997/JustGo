import Foundation
import SwiftData

@Model
final class GoalPhase {
    var id: UUID = UUID()
    var name: String = ""
    var order: Int = 0
    var typeRaw: String = PhaseType.duration.rawValue
    var targetDuration: TimeInterval? = nil
    var targetReps: Int? = nil
    var goal: FitnessGoal?

    var type: PhaseType {
        get { PhaseType(rawValue: typeRaw) ?? .duration }
        set { typeRaw = newValue.rawValue }
    }

    init(
        name: String = "",
        order: Int = 0,
        type: PhaseType = .duration,
        targetDuration: TimeInterval? = nil,
        targetReps: Int? = nil
    ) {
        self.name = name
        self.order = order
        self.typeRaw = type.rawValue
        self.targetDuration = targetDuration
        self.targetReps = targetReps
    }
}
