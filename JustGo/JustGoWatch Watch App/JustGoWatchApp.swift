import SwiftUI
import SwiftData

@main
struct JustGoWatchApp: App {
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
        WatchSessionDelegate.shared.activate()
    }

    var body: some Scene {
        WindowGroup {
            WatchRootView()
                .environmentObject(WatchSessionDelegate.shared)
        }
        .modelContainer(modelContainer)
    }
}
