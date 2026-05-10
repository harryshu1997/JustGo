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

    private var canSave: Bool { !title.trimmingCharacters(in: .whitespaces).isEmpty }

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
                        Text("分阶段编辑器将在 Phase 2 提供。当前可保存名称占位，每完成视为 1 阶段。")
                            .foregroundStyle(.secondary)
                            .font(.callout)
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

    private func loadExisting() {
        guard let g = existing else { return }
        title = g.title
        description = g.goalDescription
        type = g.type
        if let d = g.targetDuration { minutes = max(1, Int(d / 60)) }
        if let r = g.targetReps { reps = max(1, r) }
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
        try? context.save()
        dismiss()
    }
}

#Preview {
    GoalEditorView()
}
