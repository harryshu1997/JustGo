import Foundation
import EventKit

@MainActor
final class CalendarService {
    static let shared = CalendarService()

    private let store = EKEventStore()
    private let enabledKey = "JustGo.calendarEnabled"

    var isEnabled: Bool {
        UserDefaults.standard.bool(forKey: enabledKey)
            && currentAuthorization == .fullAccess
    }

    var currentAuthorization: EKAuthorizationStatus {
        EKEventStore.authorizationStatus(for: .event)
    }

    func requestAccessAndEnable() async -> Bool {
        do {
            let granted = try await store.requestFullAccessToEvents()
            UserDefaults.standard.set(granted, forKey: enabledKey)
            print("[Calendar] permission granted=\(granted)")
            return granted
        } catch {
            print("[Calendar] permission error: \(error)")
            UserDefaults.standard.set(false, forKey: enabledKey)
            return false
        }
    }

    func disable() {
        UserDefaults.standard.set(false, forKey: enabledKey)
    }

    func removeEvent(identifier: String) -> Bool {
        guard isEnabled else { return false }
        guard let event = store.event(withIdentifier: identifier) else {
            print("[Calendar] event \(identifier) not found")
            return false
        }
        do {
            try store.remove(event, span: .thisEvent)
            print("[Calendar] event removed id=\(identifier)")
            return true
        } catch {
            print("[Calendar] remove error: \(error)")
            return false
        }
    }

    func writeEvent(
        title: String,
        startedAt: Date,
        endedAt: Date,
        durationSeconds: TimeInterval,
        points: Int,
        sourceDevice: String
    ) -> String? {
        guard isEnabled else {
            print("[Calendar] disabled, skip write")
            return nil
        }
        let event = EKEvent(eventStore: store)
        event.title = "💪 \(title)"
        event.startDate = startedAt
        event.endDate = endedAt
        let minutes = Int(durationSeconds / 60)
        let seconds = Int(durationSeconds) % 60
        event.notes = """
        用时：\(minutes) 分 \(seconds) 秒
        积分：+\(points)
        设备：\(sourceDevice)
        """
        event.calendar = store.defaultCalendarForNewEvents
        do {
            try store.save(event, span: .thisEvent)
            print("[Calendar] event saved id=\(event.eventIdentifier ?? "?")")
            return event.eventIdentifier
        } catch {
            print("[Calendar] save error: \(error)")
            return nil
        }
    }
}
