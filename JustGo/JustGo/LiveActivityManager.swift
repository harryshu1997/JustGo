import Foundation
import ActivityKit

@MainActor
final class LiveActivityManager {
    static let shared = LiveActivityManager()

    private var current: Activity<SessionActivityAttributes>?
    private var pendingAttrs: SessionActivityAttributes?

    var isSupported: Bool {
        ActivityAuthorizationInfo().areActivitiesEnabled
    }

    func start(
        goalID: UUID,
        title: String,
        goalTypeRaw: String,
        targetDuration: TimeInterval?,
        targetReps: Int?,
        startedAt: Date
    ) {
        guard isSupported else {
            dlog("[LiveActivity] not supported / disabled by user")
            return
        }
        endCurrent()
        let attrs = SessionActivityAttributes(
            goalID: goalID,
            goalTitle: title,
            goalTypeRaw: goalTypeRaw,
            targetDurationSeconds: targetDuration,
            targetReps: targetReps,
            startedAt: startedAt
        )
        attemptStart(attrs: attrs)
    }

    /// JustGoApp.scenePhase 切回 .active 时调用
    func flushPending() {
        guard let attrs = pendingAttrs else { return }
        dlog("[LiveActivity] flushing pending activity (app became foreground)")
        attemptStart(attrs: attrs)
    }

    private func attemptStart(attrs: SessionActivityAttributes) {
        let state = SessionActivityState(elapsedSeconds: 0)
        let content = ActivityContent(state: state, staleDate: nil)
        do {
            current = try Activity.request(attributes: attrs, content: content, pushType: nil)
            pendingAttrs = nil
            dlog("[LiveActivity] started id=\(current?.id ?? "?")")
        } catch {
            let msg = "\(error)"
            if msg.contains("visibility") {
                pendingAttrs = attrs
                dlog("[LiveActivity] backgrounded → queued; will start on next foreground")
            } else {
                pendingAttrs = nil
                dlog("[LiveActivity] start error: \(error)")
            }
        }
    }

    func update(state: SessionActivityState) {
        guard let activity = current else { return }
        let content = ActivityContent(state: state, staleDate: nil)
        Task {
            await activity.update(content)
        }
    }

    func endCurrent(finalState: SessionActivityState? = nil) {
        pendingAttrs = nil   // 如果还没启动就被结束了，清掉队列
        guard let activity = current else { return }
        Task {
            let content = finalState.map { ActivityContent(state: $0, staleDate: nil) }
            await activity.end(content, dismissalPolicy: .after(.now.addingTimeInterval(3)))
            dlog("[LiveActivity] ended id=\(activity.id)")
        }
        current = nil
    }

    /// 用于 app 启动后清理上次没结束的 activity（崩溃/强退导致残留）
    func reconcileOnLaunch() {
        for activity in Activity<SessionActivityAttributes>.activities {
            Task { await activity.end(nil, dismissalPolicy: .immediate) }
        }
    }
}
