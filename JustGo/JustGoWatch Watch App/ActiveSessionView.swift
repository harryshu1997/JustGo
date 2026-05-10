import SwiftUI
import WatchKit

struct ActiveSessionView: View {
    let goal: WatchGoalSnapshot
    @Binding var path: [WatchRoute]

    @State private var startedAt: Date = Date()
    @State private var accumulated: TimeInterval = 0
    @State private var lastResumedAt: Date? = Date()
    @State private var isPaused: Bool = false
    @State private var reps: Int = 0
    @State private var showEndConfirm: Bool = false

    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.5)) { timeline in
            content(now: timeline.date)
        }
        .navigationBarBackButtonHidden(true)
        .alert("确认结束?", isPresented: $showEndConfirm) {
            Button("结束", role: .destructive) { finish() }
            Button("取消", role: .cancel) {}
        } message: {
            Text("当前进度会被记录")
        }
        .onAppear {
            WKInterfaceDevice.current().play(.start)
        }
    }

    @ViewBuilder
    private func content(now: Date) -> some View {
        let elapsed = currentElapsed(now: now)
        VStack(spacing: 8) {
            Text(goal.title).font(.caption).foregroundStyle(.secondary)

            switch goal.type {
            case .duration:
                durationDisplay(elapsed: elapsed)
            case .reps:
                repsDisplay
            case .phased:
                durationDisplay(elapsed: elapsed)
            }

            PixelBuddyView(
                stage: .baby,
                pose: isPaused ? .waiting : .excited,
                pixelSize: 3
            )

            ProgressView(value: progressFraction(elapsed: elapsed))
                .tint(Palette.primary)
        }
        .padding(.horizontal, 6)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            handleSingleTap()
        }
        .onLongPressGesture(minimumDuration: 1.0) {
            WKInterfaceDevice.current().play(.retry)
            showEndConfirm = true
        }
    }

    private func durationDisplay(elapsed: TimeInterval) -> some View {
        VStack(spacing: 0) {
            Text(formatTime(elapsed))
                .font(.system(size: 36, weight: .bold, design: .rounded).monospacedDigit())
                .foregroundStyle(isPaused ? .secondary : .primary)
            if let target = goal.targetDuration {
                Text("/ \(formatTime(target))")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var repsDisplay: some View {
        VStack {
            Text("\(reps)")
                .font(.system(size: 48, weight: .bold, design: .rounded).monospacedDigit())
            if let target = goal.targetReps {
                Text("/ \(target) 个").font(.caption2).foregroundStyle(.secondary)
            }
        }
    }

    private func handleSingleTap() {
        switch goal.type {
        case .reps:
            if !isPaused {
                reps += 1
                WKInterfaceDevice.current().play(.click)
                return
            }
            // 暂停状态下，单点恢复
            fallthrough
        case .duration, .phased:
            togglePause()
        }
    }

    private func togglePause() {
        if isPaused {
            isPaused = false
            lastResumedAt = Date()
            WKInterfaceDevice.current().play(.click)
        } else {
            if let last = lastResumedAt {
                accumulated += Date().timeIntervalSince(last)
            }
            lastResumedAt = nil
            isPaused = true
            WKInterfaceDevice.current().play(.click)
        }
    }

    private func currentElapsed(now: Date) -> TimeInterval {
        if isPaused { return accumulated }
        if let last = lastResumedAt {
            return accumulated + now.timeIntervalSince(last)
        }
        return accumulated
    }

    private func progressFraction(elapsed: TimeInterval) -> Double {
        switch goal.type {
        case .duration, .phased:
            guard let target = goal.targetDuration, target > 0 else { return 0 }
            return min(1.0, elapsed / target)
        case .reps:
            guard let target = goal.targetReps, target > 0 else { return 0 }
            return min(1.0, Double(reps) / Double(target))
        }
    }

    private func formatTime(_ ti: TimeInterval) -> String {
        let total = Int(ti)
        return String(format: "%02d:%02d", total / 60, total % 60)
    }

    private func finish() {
        if !isPaused, let last = lastResumedAt {
            accumulated += Date().timeIntervalSince(last)
        }
        WKInterfaceDevice.current().play(.success)
        let result = SessionResult(
            goal: goal,
            startedAt: startedAt,
            endedAt: Date(),
            duration: accumulated,
            reps: reps
        )
        path.append(.completion(result))
    }
}
