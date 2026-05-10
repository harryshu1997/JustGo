import ActivityKit
import Foundation

/// 用于 Live Activity 的 ActivityAttributes（iOS-only，Watch 不参与）。
///
/// `attributes` 部分是 session 的静态信息（开始后不变），
/// `ContentState` 部分是每次 update 时刷新的动态状态。
struct SessionActivityAttributes: ActivityAttributes {
    public typealias ContentState = SessionActivityState

    var goalID: UUID
    var goalTitle: String
    var goalTypeRaw: String
    var targetDurationSeconds: TimeInterval?
    var targetReps: Int?
    var startedAt: Date
}

public struct SessionActivityState: Codable, Hashable {
    public var elapsedSeconds: TimeInterval
    public var currentReps: Int
    public var phaseIndex: Int
    public var totalPhases: Int
    public var currentPhaseName: String?
    public var isPaused: Bool
    public var heartRate: Double

    public init(
        elapsedSeconds: TimeInterval = 0,
        currentReps: Int = 0,
        phaseIndex: Int = 0,
        totalPhases: Int = 0,
        currentPhaseName: String? = nil,
        isPaused: Bool = false,
        heartRate: Double = 0
    ) {
        self.elapsedSeconds = elapsedSeconds
        self.currentReps = currentReps
        self.phaseIndex = phaseIndex
        self.totalPhases = totalPhases
        self.currentPhaseName = currentPhaseName
        self.isPaused = isPaused
        self.heartRate = heartRate
    }
}
