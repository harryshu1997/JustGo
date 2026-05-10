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
    let sourceDevice: String

    static let messageKey = "JustGo.SessionPayload.v1"
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
