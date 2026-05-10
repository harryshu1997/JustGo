import Foundation

/// Watch 开始 session 时通知 iPhone 启动 Live Activity 的轻量消息
struct SessionStartedPayload: Codable {
    let goalID: UUID
    let goalTitle: String
    let goalTypeRaw: String
    let targetDuration: TimeInterval?
    let targetReps: Int?
    let startedAt: Date

    static let messageKey = "JustGo.SessionStarted.v1"
}

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
    var completedPhases: Int = 0
    var totalPhases: Int = 0

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
            return totalPhases > 0 && completedPhases >= totalPhases
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
        var phases: [PhaseSnapshot] = []
    }

    struct PhaseSnapshot: Codable, Hashable {
        let id: UUID
        let name: String
        let typeRaw: String
        let targetDuration: TimeInterval?
        let targetReps: Int?

        var type: PhaseType { PhaseType(rawValue: typeRaw) ?? .duration }
    }
}
