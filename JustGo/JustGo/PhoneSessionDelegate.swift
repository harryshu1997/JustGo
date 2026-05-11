import Foundation
import WatchConnectivity
import SwiftData

final class PhoneSessionDelegate: NSObject, WCSessionDelegate {
    static let shared = PhoneSessionDelegate()

    private var container: ModelContainer?
    private var pendingPayload: ActiveGoalsPayload?

    func activate(container: ModelContainer) {
        self.container = container
        guard WCSession.isSupported() else {
            dlog("[Phone] WCSession unsupported on this device")
            return
        }
        let session = WCSession.default
        session.delegate = self
        session.activate()
        dlog("[Phone] WCSession.activate() called")
    }

    func pushActiveGoals(_ payload: ActiveGoalsPayload) {
        pendingPayload = payload
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        dlog("[Phone] pushActiveGoals state=\(session.activationState.rawValue) " +
              "paired=\(session.isPaired) installed=\(session.isWatchAppInstalled) " +
              "reachable=\(session.isReachable) goals=\(payload.goals.count)")
        guard session.activationState == .activated else {
            dlog("[Phone] not activated yet, payload queued")
            return
        }
        let dict = ConnectivityCoder.wrapForContext(
            payload,
            key: ActiveGoalsPayload.contextKey
        )
        do {
            try session.updateApplicationContext(dict)
            dlog("[Phone] updateApplicationContext sent ok")
        } catch {
            dlog("[Phone] updateApplicationContext error: \(error)")
        }
    }

    // MARK: WCSessionDelegate

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        if let error {
            dlog("[Phone] activation error: \(error)")
        }
        dlog("[Phone] activationDidComplete state=\(activationState.rawValue) " +
              "paired=\(session.isPaired) installed=\(session.isWatchAppInstalled) " +
              "reachable=\(session.isReachable)")
        if activationState == .activated, let pending = pendingPayload {
            pushActiveGoals(pending)
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        dlog("[Phone] reachability=\(session.isReachable)")
        if let pending = pendingPayload {
            pushActiveGoals(pending)
        }
    }

    func sessionWatchStateDidChange(_ session: WCSession) {
        dlog("[Phone] watch state changed installed=\(session.isWatchAppInstalled)")
        if session.isWatchAppInstalled, let pending = pendingPayload {
            pushActiveGoals(pending)
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        dlog("[Phone] didReceiveUserInfo keys=\(userInfo.keys.joined(separator: ","))")
        handleSessionPayload(userInfo)
    }

    func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        dlog("[Phone] didReceiveMessage keys=\(message.keys.joined(separator: ","))")
        handleSessionPayload(message)
        replyHandler(["ack": true])
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        dlog("[Phone] didReceiveMessage (no reply) keys=\(message.keys.joined(separator: ","))")
        handleSessionPayload(message)
    }

    private func handleSessionPayload(_ dict: [String: Any]) {
        if let started = ConnectivityCoder.unwrapFromContext(
            dict,
            key: SessionStartedPayload.messageKey,
            type: SessionStartedPayload.self
        ) {
            dlog("[Phone] received session START goal=\(started.goalTitle)")
            Task { @MainActor in
                LiveActivityManager.shared.start(
                    goalID: started.goalID,
                    title: started.goalTitle,
                    goalTypeRaw: started.goalTypeRaw,
                    targetDuration: started.targetDuration,
                    targetReps: started.targetReps,
                    startedAt: started.startedAt
                )
            }
            return
        }
        guard let payload = ConnectivityCoder.unwrapFromContext(
            dict,
            key: SessionPayload.messageKey,
            type: SessionPayload.self
        ) else {
            dlog("[Phone] session payload decode failed")
            return
        }
        dlog("[Phone] received session goal=\(payload.goalSnapshotTitle) duration=\(payload.totalDuration)s")
        Task { @MainActor in
            persist(payload)
            LiveActivityManager.shared.endCurrent()
        }
    }

    @MainActor
    private func persist(_ payload: SessionPayload) {
        guard let container else { return }
        let context = container.mainContext

        let session = WorkoutSession(
            goalID: payload.goalID,
            goalSnapshotTitle: payload.goalSnapshotTitle,
            startedAt: payload.startedAt,
            sourceDevice: payload.sourceDevice
        )
        session.endedAt = payload.endedAt
        session.totalDuration = payload.totalDuration
        session.actualReps = payload.actualReps
        session.status = .completed

        let type = GoalType(rawValue: payload.goalTypeRaw) ?? .duration
        let completedFully = payload.completedFully
        session.earnedPoints = PointsCalculator.points(
            for: type,
            actualDuration: payload.totalDuration,
            actualReps: payload.actualReps,
            completedFully: completedFully,
            streakDays: 0
        )

        context.insert(session)

        // 先把已有所有活着的树往上长一阶段（最大 3）
        let existingDescriptor = FetchDescriptor<Tree>()
        if let existingTrees = try? context.fetch(existingDescriptor) {
            for t in existingTrees where t.isAlive && t.growthStage < 3 {
                t.growthStage += 1
            }
        }

        // 然后种新树（初始 0 阶段，等下次完成 session 再长）
        let species = TreeSpawnRules.species(
            for: type,
            actualDuration: payload.totalDuration,
            completedFully: true
        ) ?? .shrub
        let tree = Tree(
            sessionID: session.id,
            species: species,
            isWilted: !completedFully,
            x: Double.random(in: 20...240),
            y: Double.random(in: (-280)...(-40))
        )
        tree.growthStage = 0
        context.insert(tree)
        dlog("[Phone] tree planted species=\(species.rawValue) wilted=\(!completedFully) stage=0")

        let exp = BuddyExpCalculator.exp(
            actualDuration: payload.totalDuration,
            completedPhases: 0,
            streakDays: 0,
            isFirstTimeForGoal: false,
            isLastInDailyPlan: false
        )
        let profile = fetchOrCreateProfile(in: context)
        profile.totalPoints += session.earnedPoints
        profile.buddyExp += exp
        profile.lastSessionDate = session.endedAt
        profile.recomputeBuddyStage()

        markPlanCompletion(goalID: payload.goalID, in: context)

        try? context.save()

        let calendarID = CalendarService.shared.writeEvent(
            title: session.goalSnapshotTitle,
            startedAt: session.startedAt,
            endedAt: session.endedAt ?? Date(),
            durationSeconds: session.totalDuration,
            points: session.earnedPoints,
            sourceDevice: session.sourceDevice
        )
        if let calendarID {
            session.calendarEventIdentifier = calendarID
            try? context.save()
        }
    }

    @MainActor
    private func fetchOrCreateProfile(in context: ModelContext) -> UserProfile {
        let descriptor = FetchDescriptor<UserProfile>()
        if let existing = try? context.fetch(descriptor).first {
            return existing
        }
        let p = UserProfile()
        context.insert(p)
        return p
    }

    @MainActor
    private func markPlanCompletion(goalID: UUID, in context: ModelContext) {
        let start = Calendar.current.startOfDay(for: Date())
        let descriptor = FetchDescriptor<DailyPlan>()
        guard let plans = try? context.fetch(descriptor) else { return }
        if let plan = plans.first(where: {
            Calendar.current.isDate($0.date, inSameDayAs: start)
        }) {
            plan.markCompleted(goalID)
        }
    }
}
