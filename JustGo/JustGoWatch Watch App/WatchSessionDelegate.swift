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
        guard WCSession.isSupported() else {
            dlog("[Watch] WCSession unsupported")
            return
        }
        let session = WCSession.default
        session.delegate = self
        session.activate()
        dlog("[Watch] WCSession.activate() called")
    }

    func notifySessionStarted(_ goal: WatchGoalSnapshot, startedAt: Date) {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        guard session.activationState == .activated, session.isReachable else {
            dlog("[Watch] not reachable, skip session start notify")
            return
        }
        let payload = SessionStartedPayload(
            goalID: goal.id,
            goalTitle: goal.title,
            goalTypeRaw: goal.typeRaw,
            targetDuration: goal.targetDuration,
            targetReps: goal.targetReps,
            startedAt: startedAt
        )
        let dict = ConnectivityCoder.wrapForContext(payload, key: SessionStartedPayload.messageKey)
        session.sendMessage(
            dict,
            replyHandler: nil,
            errorHandler: { error in
                dlog("[Watch] sessionStarted sendMessage error: \(error)")
            }
        )
        dlog("[Watch] sessionStarted notified")
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
            targetDuration: result.goal.targetDuration,
            targetReps: result.goal.targetReps,
            sourceDevice: "watch",
            completedPhases: result.completedPhases,
            totalPhases: result.goal.phases.count
        )
        let dict = ConnectivityCoder.wrapForContext(
            payload,
            key: SessionPayload.messageKey
        )
        let session = WCSession.default
        dlog("[Watch] completeSession state=\(session.activationState.rawValue) " +
              "reachable=\(session.isReachable) duration=\(result.duration)s")
        guard session.activationState == .activated else {
            dlog("[Watch] WCSession not activated, payload dropped!")
            return
        }
        if session.isReachable {
            session.sendMessage(
                dict,
                replyHandler: { _ in
                    dlog("[Watch] sendMessage delivered")
                },
                errorHandler: { error in
                    dlog("[Watch] sendMessage error, falling back: \(error)")
                    session.transferUserInfo(dict)
                }
            )
        } else {
            dlog("[Watch] not reachable, using transferUserInfo")
            session.transferUserInfo(dict)
        }
    }

    // MARK: WCSessionDelegate

    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        if let error {
            dlog("[Watch] activation error: \(error)")
        }
        dlog("[Watch] activationDidComplete state=\(activationState.rawValue) " +
              "reachable=\(session.isReachable)")
    }

    nonisolated func session(
        _ session: WCSession,
        didReceiveApplicationContext applicationContext: [String: Any]
    ) {
        dlog("[Watch] didReceiveApplicationContext keys=\(applicationContext.keys.joined(separator: ","))")
        guard let payload = ConnectivityCoder.unwrapFromContext(
            applicationContext,
            key: ActiveGoalsPayload.contextKey,
            type: ActiveGoalsPayload.self
        ) else {
            dlog("[Watch] payload decode failed")
            return
        }
        dlog("[Watch] received \(payload.goals.count) goals")
        Task { @MainActor in
            self.applyActiveGoals(payload)
        }
    }

    nonisolated func sessionReachabilityDidChange(_ session: WCSession) {
        dlog("[Watch] reachability=\(session.isReachable)")
    }

    @MainActor
    private func applyActiveGoals(_ payload: ActiveGoalsPayload) {
        receivedGoals = payload.goals.map {
            WatchGoalSnapshot(
                id: $0.id,
                title: $0.title,
                typeRaw: $0.typeRaw,
                targetDuration: $0.targetDuration,
                targetReps: $0.targetReps,
                phases: $0.phases
            )
        }
        // 跨日清理：让新的一天 completedGoalIDs 重置
        let validIDs = Set(receivedGoals.map(\.id))
        completedGoalIDs = completedGoalIDs.intersection(validIDs)
    }
}
