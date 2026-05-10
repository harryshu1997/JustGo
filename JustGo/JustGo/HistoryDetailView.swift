import SwiftUI
import SwiftData

struct HistoryDetailView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    let session: WorkoutSession

    @State private var showDeleteConfirm = false

    var body: some View {
        Form {
            Section("目标") {
                HStack {
                    Text("名称")
                    Spacer()
                    Text(session.goalSnapshotTitle).foregroundStyle(.secondary)
                }
                HStack {
                    Text("来源设备")
                    Spacer()
                    Text(session.sourceDevice == "watch" ? "Apple Watch" : "iPhone")
                        .foregroundStyle(.secondary)
                }
            }

            Section("用时与得分") {
                HStack {
                    Text("开始时间")
                    Spacer()
                    Text(formatDateTime(session.startedAt)).foregroundStyle(.secondary)
                }
                if let end = session.endedAt {
                    HStack {
                        Text("结束时间")
                        Spacer()
                        Text(formatDateTime(end)).foregroundStyle(.secondary)
                    }
                }
                if session.totalDuration > 0 {
                    HStack {
                        Text("实际用时")
                        Spacer()
                        Text(formatDuration(session.totalDuration)).foregroundStyle(.secondary)
                    }
                }
                if session.actualReps > 0 {
                    HStack {
                        Text("完成次数")
                        Spacer()
                        Text("\(session.actualReps) 个").foregroundStyle(.secondary)
                    }
                }
                HStack {
                    Text("获得积分")
                    Spacer()
                    Text("+\(session.earnedPoints)").foregroundStyle(Palette.primary).bold()
                }
            }

            if let calID = session.calendarEventIdentifier, !calID.isEmpty {
                Section("日历") {
                    HStack {
                        Image(systemName: "calendar").foregroundStyle(Palette.primary)
                        Text("已写入原生日历")
                        Spacer()
                    }
                    Button(role: .destructive) {
                        if CalendarService.shared.removeEvent(identifier: calID) {
                            session.calendarEventIdentifier = nil
                            try? context.save()
                        }
                    } label: {
                        Label("从日历移除", systemImage: "trash")
                    }
                }
            }

            Section {
                Button(role: .destructive) {
                    showDeleteConfirm = true
                } label: {
                    Label("删除这条记录", systemImage: "trash.fill")
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .navigationTitle("session")
        .navigationBarTitleDisplayMode(.inline)
        .alert("删除这条记录?", isPresented: $showDeleteConfirm) {
            Button("删除", role: .destructive) { deleteSession() }
            Button("取消", role: .cancel) {}
        } message: {
            Text("同时也会移除对应的日历事件（如果有）。该操作不可恢复。")
        }
    }

    private func deleteSession() {
        if let calID = session.calendarEventIdentifier {
            _ = CalendarService.shared.removeEvent(identifier: calID)
        }
        context.delete(session)
        try? context.save()
        dismiss()
    }

    private func formatDateTime(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "zh_Hans_CN")
        f.dateFormat = "M月d日 HH:mm"
        return f.string(from: date)
    }

    private func formatDuration(_ seconds: TimeInterval) -> String {
        let total = Int(seconds)
        let m = total / 60
        let s = total % 60
        return String(format: "%d:%02d", m, s)
    }
}
