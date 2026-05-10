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
    @State private var phaseIndex: Int = 0
    @State private var showEndConfirm: Bool = false

    private var isPhased: Bool { goal.type == .phased }
    private var currentPhase: ActiveGoalsPayload.PhaseSnapshot? {
        guard isPhased, phaseIndex < goal.phases.count else { return nil }
        return goal.phases[phaseIndex]
    }
    private var totalPhases: Int { goal.phases.count }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.5)) { timeline in
            content(now: timeline.date)
        }
        .navigationBarBackButtonHidden(true)
        .alert("确认结束?", isPresented: $showEndConfirm) {
            Button("结束", role: .destructive) { finish() }
            Button("取消", role: .cancel) {}
        } message: {
            Text(endConfirmMessage)
        }
        .onAppear {
            WKInterfaceDevice.current().play(.start)
        }
    }

    @ViewBuilder
    private func content(now: Date) -> some View {
        let elapsed = currentElapsed(now: now)
        VStack(spacing: 6) {
            header

            switch goal.type {
            case .duration:
                durationDisplay(elapsed: elapsed)
            case .reps:
                repsDisplay
            case .phased:
                phaseDisplay(elapsed: elapsed)
            }

            PixelBuddyView(
                stage: .baby,
                pose: isPaused ? .waiting : .excited,
                pixelSize: 3
            )

            ProgressView(value: progressFraction(elapsed: elapsed))
                .tint(Palette.primary)

            if isPhased {
                Text("单点 → 下一阶段 · 长按 → 结束")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
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

    private var header: some View {
        VStack(spacing: 0) {
            Text(goal.title).font(.caption).foregroundStyle(.secondary)
            if isPhased {
                Text("阶段 \(phaseIndex + 1) / \(totalPhases)")
                    .font(.caption2)
                    .foregroundStyle(Palette.primary)
            }
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

    @ViewBuilder
    private func phaseDisplay(elapsed: TimeInterval) -> some View {
        if let phase = currentPhase {
            VStack(spacing: 2) {
                Text(phase.name).font(.headline)
                switch phase.type {
                case .duration:
                    HStack(spacing: 4) {
                        Text(formatTime(elapsed))
                            .font(.system(size: 26, weight: .bold, design: .rounded).monospacedDigit())
                        if let t = phase.targetDuration {
                            Text("/ \(formatTime(t))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                case .reps:
                    HStack(spacing: 4) {
                        Text("\(reps)")
                            .font(.system(size: 26, weight: .bold, design: .rounded).monospacedDigit())
                        if let t = phase.targetReps {
                            Text("/ \(t) 个")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                if phaseIndex + 1 < totalPhases {
                    Text("下一: \(goal.phases[phaseIndex + 1].name)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        } else {
            Text("已完成全部阶段").font(.headline)
        }
    }

    private func handleSingleTap() {
        switch goal.type {
        case .duration:
            togglePause()
        case .reps:
            if !isPaused {
                reps += 1
                WKInterfaceDevice.current().play(.click)
            } else {
                togglePause()
            }
        case .phased:
            advancePhase()
        }
    }

    private func advancePhase() {
        guard isPhased else { return }
        // 当前阶段完成
        WKInterfaceDevice.current().play(.notification)
        let nextIndex = phaseIndex + 1
        if nextIndex >= totalPhases {
            // 最后一阶段完成 → 整个 session 结束
            phaseIndex = totalPhases
            finish(allPhasesDone: true)
        } else {
            phaseIndex = nextIndex
            reps = 0   // 重置每阶段计数
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
        case .duration:
            guard let target = goal.targetDuration, target > 0 else { return 0 }
            return min(1.0, elapsed / target)
        case .reps:
            guard let target = goal.targetReps, target > 0 else { return 0 }
            return min(1.0, Double(reps) / Double(target))
        case .phased:
            guard totalPhases > 0 else { return 0 }
            return min(1.0, Double(phaseIndex) / Double(totalPhases))
        }
    }

    private func formatTime(_ ti: TimeInterval) -> String {
        let total = Int(ti)
        return String(format: "%02d:%02d", total / 60, total % 60)
    }

    private var endConfirmMessage: String {
        if isPhased {
            return "已完成 \(phaseIndex) / \(totalPhases) 阶段，未完成的阶段不计入。"
        }
        return "当前进度会被记录"
    }

    private func finish(allPhasesDone: Bool = false) {
        if !isPaused, let last = lastResumedAt {
            accumulated += Date().timeIntervalSince(last)
        }
        WKInterfaceDevice.current().play(.success)
        let completedPhases = allPhasesDone ? totalPhases : phaseIndex
        let result = SessionResult(
            goal: goal,
            startedAt: startedAt,
            endedAt: Date(),
            duration: accumulated,
            reps: reps,
            completedPhases: completedPhases
        )
        path.append(.completion(result))
    }
}
