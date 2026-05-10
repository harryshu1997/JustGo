import Foundation
import WatchConnectivity
import Combine

@MainActor
final class WatchSessionDelegate: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = WatchSessionDelegate()

    @Published private(set) var receivedGoals: [WatchGoalSnapshot] = []
    @Published private(set) var completedGoalIDs: Set<UUID> = []

    var currentGoal: WatchGoalSnapshot? {
        receivedGoals.first { !completedGoalIDs.contains($0.id) }
    }

    var todayTotal: Int { receivedGoals.count }
    var todayCompleted: Int { completedGoalIDs.count }

    nonisolated func activate() {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }

    func completeSession(_ result: SessionResult) {
        completedGoalIDs.insert(result.goal.id)
        let payload = SessionPayload(
            id: UUID(),
            goalID: result.goal.id,
            goalSnapshotTitle: result.goal.title,
            startedAt: result.startedAt,
            endedAt: result.endedAt,
            totalDuration: result.duration,
            actualReps: result.reps,
            goalTypeRaw: result.goal.typeRaw,
            sourceDevice: "watch"
        )
        let dict = ConnectivityCoder.wrapForContext(
            payload,
            key: SessionPayload.messageKey
        )
        if WCSession.default.activationState == .activated {
            WCSession.default.transferUserInfo(dict)
        }
    }

    // MARK: WCSessionDelegate

    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        if let error {
            print("[Watch] activation error: \(error)")
        }
    }

    nonisolated func session(
        _ session: WCSession,
        didReceiveApplicationContext applicationContext: [String: Any]
    ) {
        guard let payload = ConnectivityCoder.unwrapFromContext(
            applicationContext,
            key: ActiveGoalsPayload.contextKey,
            type: ActiveGoalsPayload.self
        ) else { return }
        Task { @MainActor in
            self.applyActiveGoals(payload)
        }
    }

    @MainActor
    private func applyActiveGoals(_ payload: ActiveGoalsPayload) {
        receivedGoals = payload.goals.map {
            WatchGoalSnapshot(
                id: $0.id,
                title: $0.title,
                typeRaw: $0.typeRaw,
                targetDuration: $0.targetDuration,
                targetReps: $0.targetReps
            )
        }
        // 跨日清理：让新的一天 completedGoalIDs 重置
        let validIDs = Set(receivedGoals.map(\.id))
        completedGoalIDs = completedGoalIDs.intersection(validIDs)
    }
}
