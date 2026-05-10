import Foundation

struct SessionPayload: Codable {
    let id: UUID
    let goalID: UUID
    let goalSnapshotTitle: String
    let startedAt: Date
    let endedAt: Date
    let totalDuration: TimeInterval
    let actualReps: Int
    let goalTypeRaw: String
    let targetDuration: TimeInterval?
    let targetReps: Int?
    let sourceDevice: String

    static let messageKey = "JustGo.SessionPayload.v1"

    var completedFully: Bool {
        switch GoalType(rawValue: goalTypeRaw) ?? .duration {
        case .duration:
            guard let target = targetDuration else { return true }
            return totalDuration >= target
        case .reps:
            guard let target = targetReps else { return true }
            return actualReps >= target
        case .phased:
            return true  // 分阶段当下用户走完算完成；后续 Phase 2.5 细化
        }
    }
}

struct ActiveGoalsPayload: Codable {
    let dailyPlanGoalIDs: [UUID]
    let goals: [GoalSnapshot]

    static let contextKey = "JustGo.ActiveGoals.v1"

    struct GoalSnapshot: Codable {
        let id: UUID
        let title: String
        let typeRaw: String
        let targetDuration: TimeInterval?
        let targetReps: Int?
    }
}
