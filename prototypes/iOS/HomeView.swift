import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var context

    @Query(sort: \FitnessGoal.createdAt, order: .reverse)
    private var goals: [FitnessGoal]

    @Query private var plans: [DailyPlan]
    @Query private var sessions: [WorkoutSession]

    @State private var showEditor = false
    @State private var showPlanEditor = false

    private var today: DailyPlan? {
        let start = Calendar.current.startOfDay(for: Date())
        return plans.first { Calendar.current.isDate($0.date, inSameDayAs: start) }
    }

    private var todayCompleted: Int {
        today?.completedGoalIDs.count ?? 0
    }

    private var todayTotal: Int {
        today?.orderedGoalIDs.count ?? 0
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    greeting
                    inProgressCard
                    todayPlanSection
                    goalLibrarySection
                }
                .padding()
            }
            .navigationTitle("JustGo")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showEditor = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showEditor) {
                GoalEditorView()
            }
            .sheet(isPresented: $showPlanEditor) {
                if let plan = today {
                    DailyPlanEditorView(plan: plan, library: goals)
                }
            }
            .onAppear { ensureTodayPlan() }
            .onChange(of: today?.orderedGoalIDs ?? []) { _, _ in
                pushToWatch()
            }
            .onChange(of: goals) { _, _ in
                pushToWatch()
            }
        }
    }

    private var greeting: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("早上好 🌱")
                .font(.title2.bold())
            Text("今日已完成 \(todayCompleted) / \(todayTotal) 个目标")
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var inProgressCard: some View {
        if let active = sessions.first(where: { $0.status == .active }) {
            HStack {
                Image(systemName: "play.circle.fill")
                    .foregroundStyle(Palette.primary)
                    .font(.title)
                VStack(alignment: .leading) {
                    Text("进行中（来自手表）")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(active.goalSnapshotTitle)
                        .font(.headline)
                }
                Spacer()
            }
            .padding()
            .background(Palette.primary.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var todayPlanSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("今日计划").font(.headline)
                Spacer()
                Button {
                    showPlanEditor = true
                } label: {
                    Image(systemName: "pencil")
                }
                .disabled(today == nil)
            }
            if let plan = today, !plan.orderedGoalIDs.isEmpty {
                let ids = plan.orderedGoalIDs
                let completed = Set(plan.completedGoalIDs)
                let currentID = plan.currentGoalID
                VStack(spacing: 8) {
                    ForEach(Array(ids.enumerated()), id: \.element) { idx, gid in
                        if let goal = goals.first(where: { $0.id == gid }) {
                            DailyPlanRow(
                                index: idx + 1,
                                goal: goal,
                                isCompleted: completed.contains(gid),
                                isCurrent: gid == currentID
                            )
                        }
                    }
                }
            } else {
                Text("还没有今日计划。从下方目标库点击 ★ 加入今日。")
                    .foregroundStyle(.secondary)
                    .font(.callout)
                    .padding(.vertical, 8)
            }
        }
    }

    private var goalLibrarySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("目标库").font(.headline)
            if goals.isEmpty {
                Text("还没有目标，点右上角 + 创建第一个。")
                    .foregroundStyle(.secondary)
                    .font(.callout)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 8) {
                    ForEach(goals) { goal in
                        let isInToday = today?.orderedGoalIDs.contains(goal.id) ?? false
                        GoalLibraryRow(
                            goal: goal,
                            isInToday: isInToday,
                            onToggleToday: { toggleInTodayPlan(goal) }
                        )
                    }
                }
            }
        }
    }

    private func ensureTodayPlan() {
        let start = Calendar.current.startOfDay(for: Date())
        if !plans.contains(where: { Calendar.current.isDate($0.date, inSameDayAs: start) }) {
            let plan = DailyPlan(date: start)
            context.insert(plan)
            try? context.save()
        }
    }

    private func toggleInTodayPlan(_ goal: FitnessGoal) {
        guard let plan = today else { return }
        var ids = plan.orderedGoalIDs
        if let idx = ids.firstIndex(of: goal.id) {
            ids.remove(at: idx)
        } else {
            ids.append(goal.id)
        }
        plan.orderedGoalIDs = ids
        try? context.save()
        pushToWatch()
    }

    private func pushToWatch() {
        let ids = today?.orderedGoalIDs ?? []
        let snapshots = ids.compactMap { id -> ActiveGoalsPayload.GoalSnapshot? in
            guard let g = goals.first(where: { $0.id == id }) else { return nil }
            return .init(
                id: g.id,
                title: g.title,
                typeRaw: g.typeRaw,
                targetDuration: g.targetDuration,
                targetReps: g.targetReps
            )
        }
        let payload = ActiveGoalsPayload(dailyPlanGoalIDs: ids, goals: snapshots)
        PhoneSessionDelegate.shared.pushActiveGoals(payload)
    }
}

struct DailyPlanRow: View {
    let index: Int
    let goal: FitnessGoal
    let isCompleted: Bool
    let isCurrent: Bool

    var body: some View {
        HStack {
            Text("\(index).")
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(.secondary)
            Image(systemName: goal.type.sfSymbol)
                .foregroundStyle(Palette.primary)
            Text(goal.title)
                .strikethrough(isCompleted)
            Spacer()
            if isCompleted {
                Label("已完成", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(Palette.primary)
                    .font(.caption)
            } else if isCurrent {
                Label("当前", systemImage: "play.circle.fill")
                    .foregroundStyle(Palette.primary)
                    .font(.caption)
            } else {
                Text("待开始").foregroundStyle(.secondary).font(.caption)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct GoalLibraryRow: View {
    let goal: FitnessGoal
    let isInToday: Bool
    let onToggleToday: () -> Void

    var body: some View {
        HStack {
            Image(systemName: goal.type.sfSymbol)
                .foregroundStyle(Palette.primary)
            VStack(alignment: .leading, spacing: 2) {
                Text(goal.title)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button(action: onToggleToday) {
                Image(systemName: isInToday ? "star.fill" : "star")
                    .foregroundStyle(isInToday ? Palette.primary : Color.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var subtitle: String {
        switch goal.type {
        case .duration:
            if let d = goal.targetDuration {
                return "\(Int(d / 60)) 分钟"
            }
            return "时长型"
        case .reps:
            if let r = goal.targetReps {
                return "\(r) 个"
            }
            return "次数型"
        case .phased:
            let count = goal.phases?.count ?? 0
            return "\(count) 阶段"
        }
    }
}

struct DailyPlanEditorView: View {
    @Environment(\.dismiss) private var dismiss
    let plan: DailyPlan
    let library: [FitnessGoal]
    @State private var ids: [UUID] = []

    var body: some View {
        NavigationStack {
            List {
                ForEach(ids, id: \.self) { id in
                    if let g = library.first(where: { $0.id == id }) {
                        Label(g.title, systemImage: g.type.sfSymbol)
                    }
                }
                .onMove { indices, dest in
                    ids.move(fromOffsets: indices, toOffset: dest)
                }
                .onDelete { indices in
                    ids.remove(atOffsets: indices)
                }
            }
            .environment(\.editMode, .constant(.active))
            .navigationTitle("调整今日计划")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        plan.orderedGoalIDs = ids
                        try? plan.modelContext?.save()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
            }
            .onAppear { ids = plan.orderedGoalIDs }
        }
    }
}
