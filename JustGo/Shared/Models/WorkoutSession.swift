import Foundation
import SwiftData

@Model
final class WorkoutSession {
    var id: UUID = UUID()
    var goalID: UUID = UUID()
    var goalSnapshotTitle: String = ""
    var startedAt: Date = Date()
    var endedAt: Date? = nil
    var totalDuration: TimeInterval = 0
    var actualReps: Int = 0
    var phaseRecordsJSON: String = "[]"
    var statusRaw: String = SessionStatus.active.rawValue
    var earnedPoints: Int = 0
    var sourceDevice: String = "phone"
    var calendarEventIdentifier: String? = nil

    var status: SessionStatus {
        get { SessionStatus(rawValue: statusRaw) ?? .active }
        set { statusRaw = newValue.rawValue }
    }

    init(
        goalID: UUID,
        goalSnapshotTitle: String,
        startedAt: Date = Date(),
        sourceDevice: String = "phone"
    ) {
        self.goalID = goalID
        self.goalSnapshotTitle = goalSnapshotTitle
        self.startedAt = startedAt
        self.sourceDevice = sourceDevice
    }
}
