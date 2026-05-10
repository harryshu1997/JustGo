import SwiftUI
import SwiftData

struct GoalEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    var existing: FitnessGoal? = nil

    @State private var title: String = ""
    @State private var description: String = ""
    @State private var type: GoalType = .duration
    @State private var minutes: Int = 30
    @State private var reps: Int = 30
    @State private var phaseDrafts: [PhaseDraft] = []

    private var canSave: Bool {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return false }
        if type == .phased { return !phaseDrafts.isEmpty }
        return true
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("基本信息") {
                    TextField("名称（如：晨跑）", text: $title)
                    TextField("描述（选填）", text: $description, axis: .vertical)
                        .lineLimit(2...4)
                }

                Section("类型") {
                    Picker("类型", selection: $type) {
                        ForEach(GoalType.allCases, id: \.self) { t in
                            Label(t.displayName, systemImage: t.sfSymbol)
                                .tag(t)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("目标值") {
                    switch type {
                    case .duration:
                        Stepper(value: $minutes, in: 1...180, step: 1) {
                            HStack {
                                Text("时长")
                                Spacer()
                                Text("\(minutes) 分钟").foregroundStyle(.secondary)
                            }
                        }
                    case .reps:
                        Stepper(value: $reps, in: 1...500, step: 1) {
                            HStack {
                                Text("次数")
                                Spacer()
                                Text("\(reps) 个").foregroundStyle(.secondary)
                            }
                        }
                    case .phased:
                        phasedEditor
                    }
                }
            }
            .navigationTitle(existing == nil ? "新建目标" : "编辑目标")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { save() }
                        .disabled(!canSave)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
            }
            .onAppear { loadExisting() }
        }
    }

    private var phasedEditor: some View {
        Group {
            if phaseDrafts.isEmpty {
                Text("点下方加号添加第一个阶段")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 4)
            }
            ForEach($phaseDrafts) { $draft in
                PhaseRowEditor(draft: $draft)
            }
            .onMove { from, to in
                phaseDrafts.move(fromOffsets: from, toOffset: to)
            }
            .onDelete { offsets in
                phaseDrafts.remove(atOffsets: offsets)
            }
            Button {
                phaseDrafts.append(PhaseDraft(
                    name: "阶段 \(phaseDrafts.count + 1)",
                    type: .duration,
                    value: 5
                ))
            } label: {
                Label("添加阶段", systemImage: "plus.circle.fill")
                    .foregroundStyle(Palette.primary)
            }
            if phaseDrafts.count >= 2 {
                Text("长按拖动可重排顺序，左滑可删除")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func loadExisting() {
        guard let g = existing else { return }
        title = g.title
        description = g.goalDescription
        type = g.type
        if let d = g.targetDuration { minutes = max(1, Int(d / 60)) }
        if let r = g.targetReps { reps = max(1, r) }
        let phases = (g.phases ?? []).sorted(by: { $0.order < $1.order })
        phaseDrafts = phases.map { p in
            PhaseDraft(
                id: p.id,
                name: p.name,
                type: p.type,
                value: p.type == .duration ? Int((p.targetDuration ?? 60) / 60) : (p.targetReps ?? 1)
            )
        }
    }

    private func save() {
        let goal = existing ?? FitnessGoal()
        goal.title = title.trimmingCharacters(in: .whitespaces)
        goal.goalDescription = description
        goal.type = type
        switch type {
        case .duration:
            goal.targetDuration = TimeInterval(minutes * 60)
            goal.targetReps = nil
        case .reps:
            goal.targetReps = reps
            goal.targetDuration = nil
        case .phased:
            goal.targetDuration = nil
            goal.targetReps = nil
        }
        if existing == nil {
            context.insert(goal)
        }

        if type == .phased {
            // 清空旧阶段，写入新阶段
            (goal.phases ?? []).forEach { context.delete($0) }
            goal.phases = []
            for (idx, draft) in phaseDrafts.enumerated() {
                let p = GoalPhase()
                p.id = draft.id
                p.name = draft.name.trimmingCharacters(in: .whitespaces)
                p.order = idx
                p.type = draft.type
                if draft.type == .duration {
                    p.targetDuration = TimeInterval(draft.value * 60)
                    p.targetReps = nil
                } else {
                    p.targetReps = draft.value
                    p.targetDuration = nil
                }
                p.goal = goal
                context.insert(p)
            }
        } else {
            (goal.phases ?? []).forEach { context.delete($0) }
            goal.phases = []
        }

        try? context.save()
        dismiss()
    }
}

struct PhaseDraft: Identifiable {
    var id: UUID = UUID()
    var name: String
    var type: PhaseType
    var value: Int    // 时长型：分钟；次数型：个数
}

struct PhaseRowEditor: View {
    @Binding var draft: PhaseDraft

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("阶段名称", text: $draft.name)
            HStack {
                Picker("类型", selection: $draft.type) {
                    Text("时长").tag(PhaseType.duration)
                    Text("次数").tag(PhaseType.reps)
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 160)

                Spacer()

                Stepper(value: $draft.value, in: 1...500) {
                    HStack(spacing: 4) {
                        Text("\(draft.value)")
                            .monospacedDigit()
                        Text(draft.type == .duration ? "分钟" : "个")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    GoalEditorView()
}
