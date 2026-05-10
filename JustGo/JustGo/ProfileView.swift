import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var context
    @Query private var profiles: [UserProfile]
    @State private var calendarEnabled: Bool = false

    private var profile: UserProfile {
        if let p = profiles.first { return p }
        let p = UserProfile()
        context.insert(p)
        try? context.save()
        return p
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Buddy") {
                    HStack {
                        PixelBuddyView(stage: profile.buddyStage, pixelSize: 4)
                        VStack(alignment: .leading) {
                            Text(profile.buddyStage.displayName).font(.headline)
                            Text("\(profile.buddyExp) / \(nextStageExp) 经验")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            ProgressView(value: stageProgress)
                                .tint(Palette.primary)
                        }
                    }
                }

                Section("数据") {
                    HStack { Text("总积分"); Spacer(); Text("\(profile.totalPoints)") }
                    HStack { Text("等级"); Spacer(); Text("Lv.\(profile.level)") }
                    HStack { Text("连续打卡"); Spacer(); Text("\(profile.streakDays) 天") }
                }

                Section("日历集成") {
                    Toggle("完成时写入日历", isOn: $calendarEnabled)
                        .onChange(of: calendarEnabled) { _, newValue in
                            Task {
                                if newValue {
                                    let granted = await CalendarService.shared.requestAccessAndEnable()
                                    if !granted { calendarEnabled = false }
                                } else {
                                    CalendarService.shared.disable()
                                }
                            }
                        }
                    Text("授权后，每次完成 session 会在原生日历自动创建一条记录")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("关于") {
                    HStack { Text("版本"); Spacer(); Text("Phase 2") }
                }
            }
            .navigationTitle("我的")
            .onAppear {
                calendarEnabled = CalendarService.shared.isEnabled
            }
        }
    }

    private var nextStageExp: Int {
        let next = BuddyStage.allCases.first { $0.rawValue > profile.buddyStage.rawValue }
        return next?.requiredExp ?? profile.buddyStage.requiredExp
    }

    private var stageProgress: Double {
        let cur = profile.buddyStage.requiredExp
        let next = nextStageExp
        guard next > cur else { return 1.0 }
        let frac = Double(profile.buddyExp - cur) / Double(next - cur)
        return min(1.0, max(0, frac))
    }
}

#Preview {
    ProfileView()
}
