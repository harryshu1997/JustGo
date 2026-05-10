import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(
        filter: #Predicate<WorkoutSession> { $0.statusRaw == "completed" },
        sort: \WorkoutSession.startedAt,
        order: .reverse
    )
    private var sessions: [WorkoutSession]

    private var grouped: [(String, [WorkoutSession])] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy 年 M 月 d 日"
        formatter.locale = Locale(identifier: "zh_Hans_CN")
        let dict = Dictionary(grouping: sessions) { session in
            formatter.string(from: session.startedAt)
        }
        return dict.sorted { lhs, rhs in
            (dict[lhs.key]?.first?.startedAt ?? .distantPast)
                > (dict[rhs.key]?.first?.startedAt ?? .distantPast)
        }
    }

    var body: some View {
        NavigationStack {
            if sessions.isEmpty {
                ContentUnavailableView(
                    "还没有完成记录",
                    systemImage: "clock.arrow.circlepath",
                    description: Text("从 Watch 上完成第一个目标后会出现在这里")
                )
            } else {
                List {
                    ForEach(grouped, id: \.0) { day, items in
                        Section(day) {
                            ForEach(items) { session in
                                HistoryRow(session: session)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("历史")
    }
}

struct HistoryRow: View {
    let session: WorkoutSession

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(session.goalSnapshotTitle).font(.headline)
                Text(detailLine)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(timeStr)
                    .font(.subheadline.monospacedDigit())
                Text("+\(session.earnedPoints)")
                    .font(.caption)
                    .foregroundStyle(Palette.primary)
            }
        }
    }

    private var timeStr: String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: session.startedAt)
    }

    private var detailLine: String {
        if session.totalDuration > 0 {
            let m = Int(session.totalDuration / 60)
            let s = Int(session.totalDuration) % 60
            return String(format: "用时 %d:%02d", m, s)
        }
        if session.actualReps > 0 {
            return "完成 \(session.actualReps) 个"
        }
        return "完成"
    }
}

#Preview {
    HistoryView()
}
