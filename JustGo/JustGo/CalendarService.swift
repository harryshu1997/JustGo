import Foundation
import EventKit

@MainActor
final class CalendarService {
    static let shared = CalendarService()

    private let store = EKEventStore()
    private let enabledKey = "JustGo.calendarEnabled"

    var isEnabled: Bool {
        guard UserDefaults.standard.bool(forKey: enabledKey) else { return false }
        let status = currentAuthorization
        return status == .fullAccess || status == .writeOnly
    }

    var canRemoveEvents: Bool {
        currentAuthorization == .fullAccess
    }

    var currentAuthorization: EKAuthorizationStatus {
        EKEventStore.authorizationStatus(for: .event)
    }

    func requestAccessAndEnable() async -> Bool {
        let before = currentAuthorization
        dlog("[Calendar] requesting access, current status=\(before.rawValue)")
        do {
            let granted = try await store.requestFullAccessToEvents()
            let after = currentAuthorization
            UserDefaults.standard.set(granted, forKey: enabledKey)
            dlog("[Calendar] granted=\(granted) status=\(after.rawValue) (1=restricted 2=denied 3=fullAccess 4=writeOnly)")
            return granted
        } catch {
            dlog("[Calendar] permission error: \(error)")
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
            dlog("[Calendar] event \(identifier) not found")
            return false
        }
        do {
            try store.remove(event, span: .thisEvent)
            dlog("[Calendar] event removed id=\(identifier)")
            return true
        } catch {
            dlog("[Calendar] remove error: \(error)")
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
            dlog("[Calendar] disabled, skip write")
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
            dlog("[Calendar] event saved id=\(event.eventIdentifier ?? "?")")
            return event.eventIdentifier
        } catch {
            dlog("[Calendar] save error: \(error)")
            return nil
        }
    }
}
