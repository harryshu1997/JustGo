import SwiftUI
import SwiftData
import Charts

enum StatsRange: String, CaseIterable, Identifiable {
    case week, month, year
    var id: String { rawValue }
    var label: String {
        switch self {
        case .week:  return "本周"
        case .month: return "本月"
        case .year:  return "本年"
        }
    }
    var days: Int {
        switch self {
        case .week:  return 7
        case .month: return 30
        case .year:  return 365
        }
    }
}

struct StatsView: View {
    @Query(
        filter: #Predicate<WorkoutSession> { $0.statusRaw == "completed" },
        sort: \WorkoutSession.startedAt,
        order: .reverse
    )
    private var sessions: [WorkoutSession]

    @Query private var profiles: [UserProfile]
    @State private var range: StatsRange = .week

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Picker("范围", selection: $range) {
                        ForEach(StatsRange.allCases) { r in
                            Text(r.label).tag(r)
                        }
                    }
                    .pickerStyle(.segmented)

                    summaryRow
                    rangeChart
                    if range == .year {
                        heatmapCard
                    }
                    typeBreakdownCard
                }
                .padding()
            }
            .navigationTitle("统计")
            .background(Palette.bg)
        }
    }

    // MARK: - 顶部三数字

    private var summaryRow: some View {
        HStack(spacing: 12) {
            summary(title: range.label, value: formatMinutes(rangeTotalSeconds), icon: "calendar")
            summary(title: "完成", value: "\(rangeSessionCount) 次", icon: "checkmark.circle.fill")
            summary(title: "连续", value: "\(profiles.first?.streakDays ?? 0) 天", icon: "flame.fill")
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

    // MARK: - 主图（柱状图 / 周分组）

    private var rangeChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(chartTitle).font(.headline)
            Chart(chartData) { item in
                BarMark(
                    x: .value(xAxisLabel, item.id, unit: xUnit),
                    y: .value("Minutes", item.minutes)
                )
                .foregroundStyle(item.minutes > 0 ? Palette.primary : Palette.primary.opacity(0.25))
                .cornerRadius(3)
            }
            .frame(height: 180)
            .chartYAxis { AxisMarks(position: .leading) }
            .chartXAxis {
                AxisMarks(values: .stride(by: xUnit, count: xStrideCount)) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: xAxisFormat, centered: false)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var xAxisLabel: String {
        switch range {
        case .week, .month: return "Day"
        case .year:         return "Month"
        }
    }

    private var xUnit: Calendar.Component {
        switch range {
        case .week, .month: return .day
        case .year:         return .month
        }
    }

    private var xStrideCount: Int {
        switch range {
        case .week:  return 1
        case .month: return 5
        case .year:  return 2
        }
    }

    private var xAxisFormat: Date.FormatStyle {
        switch range {
        case .week:  return .dateTime.month(.abbreviated).day()
        case .month: return .dateTime.day()
        case .year:  return .dateTime.month(.abbreviated)
        }
    }

    private var chartTitle: String {
        switch range {
        case .week:  return "过去 7 天 · 运动时长"
        case .month: return "过去 30 天 · 运动时长"
        case .year:  return "过去 12 个月 · 运动时长"
        }
    }

    // MARK: - 热力图（仅年视图）

    private var heatmapCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("活跃日历").font(.headline)
                Spacer()
                Text("\(activeDayCount) 个活跃日")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            HeatmapGrid(values: dailyMinutes(days: 365))
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var activeDayCount: Int {
        dailyMinutes(days: range.days).filter { $0.minutes > 0 }.count
    }

    // MARK: - 类型分布

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

    private var rangeStart: Date {
        Calendar.current.date(byAdding: .day, value: -(range.days - 1),
                              to: Calendar.current.startOfDay(for: Date())) ?? Date()
    }

    private var rangeTotalSeconds: TimeInterval {
        sessions.filter { $0.startedAt >= rangeStart }.reduce(0) { $0 + $1.totalDuration }
    }

    private var rangeSessionCount: Int {
        sessions.filter { $0.startedAt >= rangeStart }.count
    }

    private var chartData: [DailyStat] {
        switch range {
        case .week:
            return dailyMinutes(days: 7).map { DailyStat(id: $0.day, label: shortDay($0.day), minutes: $0.minutes) }
        case .month:
            return dailyMinutes(days: 30).map { DailyStat(id: $0.day, label: dayOfMonth($0.day), minutes: $0.minutes) }
        case .year:
            return monthlyMinutes()
        }
    }

    private func dailyMinutes(days: Int) -> [HeatmapDay] {
        let cal = Calendar.current
        let todayStart = cal.startOfDay(for: Date())
        var result: [HeatmapDay] = []
        for offset in (0..<days).reversed() {
            guard let dayStart = cal.date(byAdding: .day, value: -offset, to: todayStart) else { continue }
            let dayEnd = cal.date(byAdding: .day, value: 1, to: dayStart) ?? dayStart
            let mins = sessions
                .filter { $0.startedAt >= dayStart && $0.startedAt < dayEnd }
                .reduce(0.0) { $0 + $1.totalDuration } / 60.0
            result.append(HeatmapDay(id: dayStart, minutes: mins))
        }
        return result
    }

    private func monthlyMinutes() -> [DailyStat] {
        let cal = Calendar.current
        var result: [DailyStat] = []
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_Hans_CN")
        formatter.dateFormat = "M月"
        for offset in (0..<12).reversed() {
            guard let monthStart = cal.date(byAdding: .month, value: -offset,
                                            to: cal.date(from: cal.dateComponents([.year, .month], from: Date())) ?? Date())
            else { continue }
            let monthEnd = cal.date(byAdding: .month, value: 1, to: monthStart) ?? monthStart
            let mins = sessions
                .filter { $0.startedAt >= monthStart && $0.startedAt < monthEnd }
                .reduce(0.0) { $0 + $1.totalDuration } / 60.0
            result.append(DailyStat(id: monthStart, label: formatter.string(from: monthStart), minutes: mins))
        }
        return result
    }

    private var typeBreakdown: [TypeSlice] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        let recent = sessions.filter { $0.startedAt >= cutoff }
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

    private func shortDay(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "zh_Hans_CN")
        f.dateFormat = "M/d"
        return f.string(from: date)
    }

    private func dayOfMonth(_ date: Date) -> String {
        let d = Calendar.current.component(.day, from: date)
        return "\(d)"
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

// MARK: - GitHub 风格热力图

struct HeatmapDay: Identifiable {
    let id: Date
    let minutes: Double
    var day: Date { id }
}

struct HeatmapGrid: View {
    let values: [HeatmapDay]

    var body: some View {
        let columns = chunked(into: 7)
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 3) {
                ForEach(columns.indices, id: \.self) { col in
                    VStack(spacing: 3) {
                        ForEach(0..<7, id: \.self) { row in
                            let cell = columns[col][safe: row]
                            Rectangle()
                                .fill(color(for: cell?.minutes ?? 0))
                                .frame(width: 10, height: 10)
                                .cornerRadius(2)
                        }
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .frame(height: 90)
    }

    private func chunked(into size: Int) -> [[HeatmapDay]] {
        stride(from: 0, to: values.count, by: size).map {
            Array(values[$0 ..< Swift.min($0 + size, values.count)])
        }
    }

    private func color(for minutes: Double) -> Color {
        if minutes <= 0 { return Color.gray.opacity(0.18) }
        let intensity = Swift.min(1.0, minutes / 60.0)
        return Palette.primary.opacity(0.25 + 0.75 * intensity)
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    StatsView()
}
