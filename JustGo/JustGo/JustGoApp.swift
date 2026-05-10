import SwiftUI
import SwiftData

@main
struct JustGoApp: App {
    let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(
                for:
                    FitnessGoal.self,
                    GoalPhase.self,
                    WorkoutSession.self,
                    DailyPlan.self,
                    Tree.self,
                    UserProfile.self
            )
        } catch {
            fatalError("ModelContainer init failed: \(error)")
        }
        PhoneSessionDelegate.shared.activate(container: modelContainer)
        Task { @MainActor in
            LiveActivityManager.shared.reconcileOnLaunch()
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
}
