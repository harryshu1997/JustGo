import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
    @Query(
        filter: #Predicate<WorkoutSession> { $0.statusRaw == "completed" },
        sort: \WorkoutSession.startedAt,
        order: .reverse
    )
    private var sessions: [WorkoutSession]

    @Query private var profiles: [UserProfile]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    summaryRow
                    weeklyChartCard
                    typeBreakdownCard
                }
                .padding()
            }
            .navigationTitle("统计")
            .background(Palette.bg)
        }
    }

    // MARK: - 顶部 3 个数字

    private var summaryRow: some View {
        HStack(spacing: 12) {
            summary(
                title: "本周",
                value: formatMinutes(thisWeekTotalSeconds),
                icon: "calendar"
            )
            summary(
                title: "完成",
                value: "\(thisWeekSessionCount) 次",
                icon: "checkmark.circle.fill"
            )
            summary(
                title: "连续",
                value: "\(profiles.first?.streakDays ?? 0) 天",
                icon: "flame.fill"
            )
        }
    }

    private func summary(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon).foregroundStyle(Palette.primary)
            Text(value).font(.headline)
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - 本周柱状图

    private var weeklyChartCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("过去 7 天 · 运动时长").font(.headline)
            Chart(weeklyData) { day in
                BarMark(
                    x: .value("Day", day.label),
                    y: .value("Minutes", day.minutes)
                )
                .foregroundStyle(day.minutes > 0 ? Palette.primary : Palette.primary.opacity(0.25))
                .cornerRadius(4)
            }
            .frame(height: 180)
            .chartYAxis {
                AxisMarks(position: .leading)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - 类型占比

    private var typeBreakdownCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("最近 30 天 · 类型分布").font(.headline)
            if typeBreakdown.isEmpty {
                Text("还没有数据，去运动几次再来看")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
            } else {
                Chart(typeBreakdown) { slice in
                    SectorMark(
                        angle: .value("Count", slice.count),
                        innerRadius: .ratio(0.55),
                        angularInset: 1
                    )
                    .foregroundStyle(by: .value("Type", slice.label))
                    .cornerRadius(4)
                }
                .frame(height: 200)
                .chartLegend(position: .bottom)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - 数据计算

    private var thisWeekTotalSeconds: TimeInterval {
        let start = Calendar.current.date(byAdding: .day, value: -6, to: Calendar.current.startOfDay(for: Date())) ?? Date()
        return sessions
            .filter { $0.startedAt >= start }
            .reduce(0) { $0 + $1.totalDuration }
    }

    private var thisWeekSessionCount: Int {
        let start = Calendar.current.date(byAdding: .day, value: -6, to: Calendar.current.startOfDay(for: Date())) ?? Date()
        return sessions.filter { $0.startedAt >= start }.count
    }

    private var weeklyData: [DailyStat] {
        let cal = Calendar.current
        let todayStart = cal.startOfDay(for: Date())
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_Hans_CN")
        formatter.dateFormat = "M/d"

        var data: [DailyStat] = []
        for offset in (0..<7).reversed() {
            guard let dayStart = cal.date(byAdding: .day, value: -offset, to: todayStart) else { continue }
            let dayEnd = cal.date(byAdding: .day, value: 1, to: dayStart) ?? dayStart
            let mins = sessions
                .filter { $0.startedAt >= dayStart && $0.startedAt < dayEnd }
                .reduce(0.0) { $0 + $1.totalDuration } / 60.0
            data.append(DailyStat(
                id: dayStart,
                label: formatter.string(from: dayStart),
                minutes: mins
            ))
        }
        return data
    }

    private var typeBreakdown: [TypeSlice] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        let recent = sessions.filter { $0.startedAt >= cutoff }
        // 由于 SessionStatus 已存，但 GoalType 不在 Session 上 —— 用 totalDuration / reps 推断
        var counts: [String: Int] = [:]
        for session in recent {
            let label: String
            if session.actualReps > 0 {
                label = "次数型"
            } else if session.totalDuration > 0 {
                label = "时长型"
            } else {
                label = "其他"
            }
            counts[label, default: 0] += 1
        }
        return counts.map { TypeSlice(id: $0.key, label: $0.key, count: $0.value) }
    }

    private func formatMinutes(_ seconds: TimeInterval) -> String {
        let total = Int(seconds / 60)
        if total >= 60 {
            return "\(total / 60)h \(total % 60)m"
        }
        return "\(total) 分钟"
    }
}

struct DailyStat: Identifiable {
    let id: Date
    let label: String
    let minutes: Double
}

struct TypeSlice: Identifiable {
    let id: String
    let label: String
    let count: Int
}

#Preview {
    StatsView()
}
