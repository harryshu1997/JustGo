import Foundation
import HealthKit
import Combine

@MainActor
final class WorkoutManager: NSObject, ObservableObject {
    static let shared = WorkoutManager()

    @Published private(set) var heartRate: Double = 0
    @Published private(set) var activeEnergyKcal: Double = 0
    @Published private(set) var isAuthorized: Bool = false
    @Published private(set) var isRunning: Bool = false

    private let healthStore = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?

    func requestAuthorization() async {
        guard HKHealthStore.isHealthDataAvailable() else {
            dlog("[Health] not available")
            return
        }
        let typesToShare: Set<HKSampleType> = [HKWorkoutType.workoutType()]
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.activitySummaryType()
        ]
        do {
            try await healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead)
            isAuthorized = true
            dlog("[Health] authorization completed")
        } catch {
            dlog("[Health] auth error: \(error)")
            isAuthorized = false
        }
    }

    func start(activityType: HKWorkoutActivityType = .traditionalStrengthTraining) {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let config = HKWorkoutConfiguration()
        config.activityType = activityType
        config.locationType = .indoor
        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: config)
            builder = session?.associatedWorkoutBuilder()
            builder?.dataSource = HKLiveWorkoutDataSource(
                healthStore: healthStore,
                workoutConfiguration: config
            )
            session?.delegate = self
            builder?.delegate = self

            let now = Date()
            session?.startActivity(with: now)
            builder?.beginCollection(withStart: now) { success, error in
                if let error {
                    dlog("[Health] beginCollection error: \(error)")
                } else {
                    dlog("[Health] workout started success=\(success)")
                }
            }
            isRunning = true
        } catch {
            dlog("[Health] start error: \(error)")
        }
    }

    func stop() {
        guard let session, let builder else { return }
        session.end()
        builder.endCollection(withEnd: Date()) { [weak self] success, error in
            if let error {
                dlog("[Health] endCollection error: \(error)")
            }
            builder.finishWorkout { _, _ in
                dlog("[Health] workout finished success=\(success)")
                Task { @MainActor in
                    self?.session = nil
                    self?.builder = nil
                    self?.isRunning = false
                    self?.heartRate = 0
                    self?.activeEnergyKcal = 0
                }
            }
        }
    }
}

extension WorkoutManager: HKWorkoutSessionDelegate {
    nonisolated func workoutSession(
        _ workoutSession: HKWorkoutSession,
        didFailWithError error: any Error
    ) {
        dlog("[Health] session failed: \(error)")
    }

    nonisolated func workoutSession(
        _ workoutSession: HKWorkoutSession,
        didChangeTo toState: HKWorkoutSessionState,
        from fromState: HKWorkoutSessionState,
        date: Date
    ) {
        dlog("[Health] state \(fromState.rawValue) → \(toState.rawValue)")
    }
}

extension WorkoutManager: HKLiveWorkoutBuilderDelegate {
    nonisolated func workoutBuilder(
        _ workoutBuilder: HKLiveWorkoutBuilder,
        didCollectDataOf collectedTypes: Set<HKSampleType>
    ) {
        for type in collectedTypes {
            guard let qType = type as? HKQuantityType,
                  let stats = workoutBuilder.statistics(for: qType) else { continue }
            switch qType.identifier {
            case HKQuantityTypeIdentifier.heartRate.rawValue:
                let unit = HKUnit.count().unitDivided(by: .minute())
                let v = stats.mostRecentQuantity()?.doubleValue(for: unit) ?? 0
                Task { @MainActor in self.heartRate = v }
            case HKQuantityTypeIdentifier.activeEnergyBurned.rawValue:
                let v = stats.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
                Task { @MainActor in self.activeEnergyKcal = v }
            default: break
            }
        }
    }

    nonisolated func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {}
}
