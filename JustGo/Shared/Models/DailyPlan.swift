import Foundation
import SwiftData

@Model
final class DailyPlan {
    var id: UUID = UUID()
    var date: Date = Date()
    var orderedGoalIDsJSON: String = "[]"
    var completedGoalIDsJSON: String = "[]"
    var currentIndex: Int = 0
    var allCompletedAt: Date? = nil

    init(date: Date = Date(), orderedGoalIDs: [UUID] = []) {
        self.date = Calendar.current.startOfDay(for: date)
        self.orderedGoalIDs = orderedGoalIDs
    }

    var orderedGoalIDs: [UUID] {
        get { decodeUUIDs(orderedGoalIDsJSON) }
        set { orderedGoalIDsJSON = encodeUUIDs(newValue) }
    }

    var completedGoalIDs: [UUID] {
        get { decodeUUIDs(completedGoalIDsJSON) }
        set { completedGoalIDsJSON = encodeUUIDs(newValue) }
    }

    var currentGoalID: UUID? {
        let ids = orderedGoalIDs
        let completed = Set(completedGoalIDs)
        return ids.first { !completed.contains($0) }
    }

    func markCompleted(_ id: UUID) {
        var done = completedGoalIDs
        if !done.contains(id) {
            done.append(id)
            completedGoalIDs = done
        }
        if completedGoalIDs.count >= orderedGoalIDs.count, allCompletedAt == nil {
            allCompletedAt = Date()
        }
    }

    private func encodeUUIDs(_ ids: [UUID]) -> String {
        let strings = ids.map(\.uuidString)
        return (try? String(
            data: JSONEncoder().encode(strings),
            encoding: .utf8
        )) ?? "[]"
    }

    private func decodeUUIDs(_ json: String) -> [UUID] {
        guard let data = json.data(using: .utf8),
              let strings = try? JSONDecoder().decode([String].self, from: data)
        else { return [] }
        return strings.compactMap(UUID.init)
    }
}
