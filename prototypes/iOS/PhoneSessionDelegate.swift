import Foundation
import WatchConnectivity
import SwiftData

final class PhoneSessionDelegate: NSObject, WCSessionDelegate {
    static let shared = PhoneSessionDelegate()

    private var container: ModelContainer?

    func activate(container: ModelContainer) {
        self.container = container
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }

    func pushActiveGoals(_ payload: ActiveGoalsPayload) {
        guard WCSession.isSupported(),
              WCSession.default.activationState == .activated
        else { return }
        let dict = ConnectivityCoder.wrapForContext(
            payload,
            key: ActiveGoalsPayload.contextKey
        )
        do {
            try WCSession.default.updateApplicationContext(dict)
        } catch {
            print("[Phone] updateApplicationContext error: \(error)")
        }
    }

    // MARK: WCSessionDelegate

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        if let error {
            print("[Phone] activation error: \(error)")
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        guard let payload = ConnectivityCoder.unwrapFromContext(
            userInfo,
            key: SessionPayload.messageKey,
            type: SessionPayload.self
        ) else { return }
        Task { @MainActor in
            persist(payload)
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
        session.earnedPoints = PointsCalculator.points(
            for: type,
            actualDuration: payload.totalDuration,
            actualReps: payload.actualReps,
            completedFully: true,
            streakDays: 0
        )

        context.insert(session)

        if let species = TreeSpawnRules.species(
            for: type,
            actualDuration: payload.totalDuration,
            completedFully: true
        ) {
            let tree = Tree(
                sessionID: session.id,
                species: species,
                x: Double.random(in: -120...120),
                y: Double.random(in: -180...0)
            )
            context.insert(tree)
        }

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
