import ActivityKit
import SwiftUI
import WidgetKit

/// Live Activity 锁屏视图 + 灵动岛配置
///
/// 用法：
/// 1. 在 Xcode 创建 Widget Extension 后，替换默认模板里的 Widget 类型为这个文件
/// 2. SessionActivityAttributes.swift 也要加入 Widget target（Target Membership 勾上）
/// 3. JustGo iOS target 在 Info / Build Settings 加 INFOPLIST_KEY_NSSupportsLiveActivities = YES
struct JustGoLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SessionActivityAttributes.self) { context in
            // 锁屏 / 横幅视图
            LockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // 展开状态（用户长按灵动岛）
                DynamicIslandExpandedRegion(.leading) {
                    Label {
                        Text(context.attributes.goalTitle)
                            .font(.headline)
                            .lineLimit(1)
                    } icon: {
                        Image(systemName: "figure.run")
                            .foregroundStyle(.green)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(timerInterval: context.attributes.startedAt...Date().addingTimeInterval(60 * 60),
                         countsDown: false)
                        .font(.title2.monospacedDigit())
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    if context.state.totalPhases > 0 {
                        HStack {
                            Text("阶段 \(context.state.phaseIndex + 1)/\(context.state.totalPhases)")
                            if let name = context.state.currentPhaseName {
                                Text("· \(name)").foregroundStyle(.secondary)
                            }
                            Spacer()
                            if context.state.heartRate > 0 {
                                Label("\(Int(context.state.heartRate))", systemImage: "heart.fill")
                                    .foregroundStyle(.red)
                            }
                        }
                        .font(.caption)
                    } else {
                        progressBar(state: context.state, attrs: context.attributes)
                    }
                }
            } compactLeading: {
                Image(systemName: "figure.run")
                    .foregroundStyle(.green)
            } compactTrailing: {
                Text(timerInterval: context.attributes.startedAt...Date().addingTimeInterval(60 * 60),
                     countsDown: false,
                     showsHours: false)
                    .font(.caption.monospacedDigit())
                    .frame(maxWidth: 50)
            } minimal: {
                Image(systemName: "figure.run")
                    .foregroundStyle(.green)
            }
            .widgetURL(URL(string: "justgo://session"))
            .keylineTint(.green)
        }
    }

    @ViewBuilder
    private func progressBar(state: SessionActivityState, attrs: SessionActivityAttributes) -> some View {
        if let target = attrs.targetDurationSeconds, target > 0 {
            ProgressView(value: min(1.0, state.elapsedSeconds / target))
                .tint(.green)
        } else if let target = attrs.targetReps, target > 0 {
            ProgressView(value: min(1.0, Double(state.currentReps) / Double(target)))
                .tint(.green)
        }
    }
}

/// 锁屏 / 通知中心展开视图
struct LockScreenView: View {
    let context: ActivityViewContext<SessionActivityAttributes>

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "figure.run")
                    .foregroundStyle(.green)
                Text(context.attributes.goalTitle)
                    .font(.headline)
                Spacer()
                Text(timerInterval: context.attributes.startedAt...Date().addingTimeInterval(60 * 60),
                     countsDown: false)
                    .font(.title3.monospacedDigit())
            }

            if context.state.totalPhases > 0 {
                HStack(spacing: 6) {
                    Text("阶段 \(context.state.phaseIndex + 1) / \(context.state.totalPhases)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if let name = context.state.currentPhaseName {
                        Text(name).font(.caption.bold())
                    }
                    Spacer()
                    if context.state.heartRate > 0 {
                        Label("\(Int(context.state.heartRate))", systemImage: "heart.fill")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
            }

            if let target = context.attributes.targetDurationSeconds, target > 0 {
                ProgressView(value: min(1.0, context.state.elapsedSeconds / target))
                    .tint(.green)
            } else if let target = context.attributes.targetReps, target > 0 {
                ProgressView(value: min(1.0, Double(context.state.currentReps) / Double(target)))
                    .tint(.green)
            }
        }
        .padding()
        .activityBackgroundTint(.clear)
    }
}

/// Widget bundle 入口（Widget Extension 的 @main）
@main
struct JustGoLiveActivityBundle: WidgetBundle {
    var body: some Widget {
        JustGoLiveActivityWidget()
    }
}
