# JustGo · 健身目标 + 种树系统 (iPhone + Apple Watch)

## 1. 产品定位

一个 Apple 原生生态的健身目标管理 + 游戏化激励 App：

- **iPhone**：定制健身目标、查看历史、查看森林、统计、写入日历
- **Apple Watch**：显示当前目标、开始/结束、计时/计数、阶段引导
- **激励机制**：每完成一次目标种一棵小树，累计积分让森林整体进化（季节、昼夜、解锁新树种）
- **生态集成**：HealthKit (后期)、EventKit (写入日历)、WatchConnectivity (双向同步)、SwiftData + CloudKit-ready

---

## 2. 关键决策（基于你的回答）

| 维度 | 决策 | 理由 |
| --- | --- | --- |
| 数据栈 | **SwiftData 本地起步，模型 CloudKit-ready** | 你想要 iCloud，但还没付费账号；先用本地，模型按 CloudKit 兼容约束设计，后期注册账号后一键开启 |
| 种树 | **每 session 种 1 棵 + 全局森林进化** | 单棵成就感 + 长期积累的史诗感都要 |
| 目标类型 | **三类都做**（时长 / 次数 / 分阶段） | MVP 先做时长型，第二阶段补次数 + 分阶段 |
| 平台 | iOS 17+ / watchOS 10+ | SwiftData、新版 SwiftUI、WatchConnectivity 现代化 API |
| 真机调试 | 暂无 Watch 真机 | 模拟器 + 配对模拟器开发，HealthKit / 加速度自动计数推迟到拿到真机 |
| 账号 | 暂无 Apple Developer | 免费 Apple ID 也可以本地真机签名（7 天有效），CloudKit / HealthKit 上 App Store 才需要付费账号 ($99/年) |

---

## 3. 技术栈

```
SwiftUI                  # iOS + watchOS UI
SwiftData                # 持久化（CloudKit-ready 模型）
WatchConnectivity        # iPhone <-> Watch 同步
EventKit                 # 写入日历
HealthKit (Phase 3)      # HKWorkoutSession 后台运行 + 心率
ActivityKit (可选)       # 灵动岛 / 锁屏实时计时
Charts                   # 统计图表
```

---

## 4. 项目结构

```
JustGo/                          # Xcode 工程根目录
├── JustGo.xcodeproj
├── JustGo/                      # iOS App target
│   ├── App/
│   │   └── JustGoApp.swift
│   ├── Features/
│   │   ├── Goals/               # 目标 CRUD + 模板
│   │   ├── Forest/              # 种树/森林视图
│   │   ├── History/             # 历史记录
│   │   ├── Stats/               # 统计图表
│   │   └── Settings/            # 日历授权、同步状态
│   ├── Sync/
│   │   └── PhoneSessionDelegate.swift   # WCSession 委托
│   └── Resources/
│       ├── Assets.xcassets
│       └── TreeAssets/          # 树种 SVG/PNG
├── JustGoWatch Watch App/       # watchOS App target
│   ├── App/
│   │   └── JustGoWatchApp.swift
│   ├── Views/
│   │   ├── CurrentGoalView.swift
│   │   ├── ActiveSessionView.swift   # 计时 + 计数 UI
│   │   └── PhaseGuideView.swift      # 分阶段引导
│   └── Sync/
│       └── WatchSessionDelegate.swift
└── JustGoShared/                # 共享 Swift Package（被两端引用）
    ├── Models/                  # SwiftData @Model（必须共享）
    │   ├── FitnessGoal.swift
    │   ├── WorkoutSession.swift
    │   ├── Tree.swift
    │   └── UserProfile.swift
    ├── DTO/                     # 跨设备消息编解码
    │   └── SessionPayload.swift
    ├── Sync/
    │   └── ConnectivityProtocol.swift
    └── Logic/
        ├── PointsCalculator.swift
        └── TreeSpawnRules.swift
```

> 把 Models 和同步 DTO 放在共享 Swift Package 里是**关键**：iOS 和 watchOS 必须用同一份 Codable 结构，否则同步会经常崩。

---

## 5. 数据模型（SwiftData，CloudKit-ready）

> CloudKit 兼容约束：所有属性必须可选或带默认值；不能用 `@Attribute(.unique)`；关系必须是双向。

```swift
@Model
final class FitnessGoal {
    @Attribute(.unique) var id: UUID = UUID()      // 本地用，迁 CloudKit 时去掉 unique
    var title: String = ""
    var goalDescription: String = ""
    var typeRaw: String = GoalType.duration.rawValue
    var targetDuration: TimeInterval? = nil        // 时长型
    var targetReps: Int? = nil                     // 次数型
    @Relationship(deleteRule: .cascade, inverse: \GoalPhase.goal)
    var phases: [GoalPhase]? = []                  // 分阶段
    var createdAt: Date = Date()
    var isArchived: Bool = false
}

@Model
final class GoalPhase {
    var id: UUID = UUID()
    var name: String = ""
    var order: Int = 0
    var typeRaw: String = PhaseType.duration.rawValue
    var targetDuration: TimeInterval? = nil
    var targetReps: Int? = nil
    var goal: FitnessGoal?
}

@Model
final class WorkoutSession {
    var id: UUID = UUID()
    var goalID: UUID = UUID()
    var goalSnapshotTitle: String = ""             // 防止目标删除后历史丢失
    var startedAt: Date = Date()
    var endedAt: Date? = nil
    var totalDuration: TimeInterval = 0
    var phaseRecordsJSON: String = "[]"            // 阶段记录序列化
    var statusRaw: String = SessionStatus.active.rawValue
    var earnedPoints: Int = 0
    var sourceDevice: String = "phone"             // "watch" / "phone"
    var calendarEventIdentifier: String? = nil
}

@Model
final class Tree {
    var id: UUID = UUID()
    var sessionID: UUID? = nil
    var speciesRaw: String = TreeSpecies.oak.rawValue
    var plantedAt: Date = Date()
    var growthStage: Int = 3                       // 0~3：苗 → 小树 → 中树 → 大树
    var isAlive: Bool = true
    var x: Double = 0                              // 森林视图坐标
    var y: Double = 0
}

@Model
final class UserProfile {
    var id: UUID = UUID()
    var totalPoints: Int = 0
    var level: Int = 1
    var unlockedSpeciesRaw: [String] = ["oak"]
    var forestSeasonRaw: String = Season.spring.rawValue
    var streakDays: Int = 0
    var lastSessionDate: Date? = nil

    // Buddy（森林守护者，唯一同伴会进化）
    var buddySpeciesRaw: String = "fox"        // 当前品种（默认像素小狐狸）
    var buddyExp: Int = 0                      // 累计经验
    var buddyStage: Int = 0                    // 0=蛋 1=幼体 2=成长 3=成熟 4=守护
    var buddyMoodRaw: String = "calm"          // 当前情绪：兴奋/平静/疲倦
}

@Model
final class DailyPlan {
    var id: UUID = UUID()
    var date: Date = Date()                    // 截断到 0:00（当地时区）
    var orderedGoalIDsJSON: String = "[]"      // 队列顺序：["uuid1","uuid2",...]
    var completedGoalIDsJSON: String = "[]"    // 已完成的子集
    var currentIndex: Int = 0                  // 队列指针，指向"当前目标"
    var allCompletedAt: Date? = nil            // 全部完成时刻
}
```

---

## 6. iPhone ↔ Watch 同步策略

`WatchConnectivity` 三种通道，按用途分工：

| 通道 | 用途 | 特性 |
| --- | --- | --- |
| `updateApplicationContext` | iPhone → Watch：当前活跃目标列表（最新覆盖） | 后台送达，最新值覆盖旧值，适合"当前状态" |
| `transferUserInfo` | Watch → iPhone：已完成的 WorkoutSession | 队列保证送达，即使 iPhone 不在身边也会缓存 |
| `sendMessage` | 双向实时指令（开始/暂停/结束） | 要求双方激活，掉线时降级到 transferUserInfo |

**典型流程**：

```
[iPhone] 创建/编辑目标 → SwiftData → updateApplicationContext({活跃目标列表}) → [Watch]
[Watch]  显示当前目标 → 用户点击 Start → 本地开始计时 (本地存草稿)
[Watch]  用户点击 End → 封装 SessionPayload → transferUserInfo → [iPhone]
[iPhone] 收到 → 写入 SwiftData → 写入日历(EventKit) → 计算积分 → 种树 → 更新森林
```

**离线 / 锁屏处理**：Watch 端 session 必须先写本地 SwiftData，等 iPhone 唤醒后由 `transferUserInfo` 补传，绝不能依赖实时连接。

---

## 7. 积分 + 多树进化系统

### 单次完成奖励（每次种 1 棵小树）

```
时长型：基础分 = floor(实际时长 / 60)              // 每分钟 1 分
次数型：基础分 = 实际次数
分阶段：所有阶段分之和 × 1.2（完整完成加成）
连续天数加成：streak ≥ 3 天 → ×1.1，≥7 天 → ×1.3
```

树种由**目标类型 + 完成情况**决定（举例）：

| 条件 | 树种 |
| --- | --- |
| 时长 < 15 分 | 灌木 (shrub) |
| 时长 15–45 分 | 橡树 (oak) |
| 时长 ≥ 45 分 | 红杉 (sequoia) |
| 完整 HIIT | 樱花 (sakura) |
| 提前结束/未达标 | 干草丛（仍然记录，但不进森林） |

### Buddy 经验值（陪你的森林守护者）

每次 session 完成，buddy 也获得经验值，**与积分独立计算**：

```text
buddy 经验 = floor(实际有效时长 / 60) + 完成阶段数
连续打卡奖励 = +5 / 天（streakDays >= 2）
首次完成新目标 = +10 一次性
今日队列全部完成 = +15
```

进化阶段（5 级，"守护者"为最终态）：

| 阶段 | 名称 | 累计经验 | 像素形态 | 解锁能力 |
| --- | --- | --- | --- | --- |
| 0 | 蛋 | 0 | 静止圆球 + 偶尔抖动 | 只在森林可见，不陪运动 |
| 1 | 幼体 | 50 | 圆滚滚小狐狸，呆萌 | 开始陪运动；待命呼吸动画 |
| 2 | 成长 | 200 | 灵动小狐狸 | 阶段切换有伸展动画 |
| 3 | 成熟 | 500 | 戴叶冠的狐狸 | Crown 切换 buddy 表情/姿势 |
| 4 | 守护 | 1500 | 巨大化，毛色随森林季节变 | 长按 buddy 召唤"专注模式"（屏蔽通知 + 双倍积分） |

进化触发：buddy 升阶时整树触发金光遮罩 + 触觉 `.success × 3` + 升级铃。

### 全局森林进化（用累计积分解锁）

```
Level 1 (0 分)        : 春季草地，仅橡树
Level 2 (200 分)      : 解锁樱花
Level 3 (500 分)      : 昼夜循环
Level 4 (1000 分)     : 解锁红杉 + 夏季
Level 5 (2000 分)     : 鸟类/鹿出没
Level 6 (5000 分)     : 解锁四季自动切换
...
```

森林视图：可滚动 / 缩放，每棵树点进去能看到对应的 WorkoutSession 详情。

---

## 8. Calendar 集成

```swift
import EventKit

let store = EKEventStore()
try await store.requestFullAccessToEvents()  // iOS 17+

let event = EKEvent(eventStore: store)
event.title = "💪 \(session.goalSnapshotTitle)"
event.startDate = session.startedAt
event.endDate = session.endedAt ?? Date()
event.notes = """
用时：\(formatted(session.totalDuration))
积分：+\(session.earnedPoints)
设备：\(session.sourceDevice)
"""
event.calendar = store.defaultCalendarForNewEvents
try store.save(event, span: .thisEvent)

session.calendarEventIdentifier = event.eventIdentifier  // 存起来方便后续修改/删除
```

可选：第一次启动时让用户选择**新建一个"健身"专属日历**，这样事件不会污染主日历。

---

## 9. 分阶段实施路线（按周排）

### MVP · Week 1–2（先跑通一条最小完整链路）

- [ ] Xcode 工程：iOS App + Watch App + Shared Package（双 target 引用）
- [ ] SwiftData schema（FitnessGoal / WorkoutSession / Tree / UserProfile）
- [ ] iPhone：目标列表 + 新建/编辑（**只做时长型**）
- [ ] WatchConnectivity：iPhone → Watch 推送活跃目标列表
- [ ] Watch：显示当前目标 + 开始/结束按钮 + 计时器
- [ ] Watch → iPhone：完成后回传 session
- [ ] iPhone：历史记录列表
- [ ] **里程碑**：从 iPhone 创建目标 → Watch 完成 → iPhone 看到记录

### Phase 2 · Week 3–4

- [ ] 次数型目标（Watch 上手动 +1 / Digital Crown 滚轮）
- [ ] 分阶段目标 + Watch 阶段引导（Haptic 提醒切换阶段）
- [ ] EventKit 写入日历
- [ ] 积分计算 + 种树逻辑
- [ ] 简单的森林视图（2D 网格摆放）

### Phase 3 · Week 5–6

- [ ] 森林进化（季节、昼夜、新树种）
- [ ] 统计图表（Swift Charts）：周/月用时、连续天数
- [ ] HealthKit 集成：用 HKWorkoutSession 让 Watch 后台保活，自动记录心率
- [ ] 灵动岛 / 锁屏 Live Activity

### Phase 4 · Week 7+ （需要 Apple Developer 账号）

- [ ] 开启 CloudKit，多设备数据同步
- [ ] 加速度计自动计数（俯卧撑/深蹲）
- [ ] App Store 上架

---

## 10. 立即要做的准备

1. **环境**
   - 确认 Xcode 版本 ≥ 15（支持 SwiftData / iOS 17）
   - 创建 iOS + Watch 配对模拟器（iPhone 15 + Apple Watch S9 模拟器配对）
2. **账号**
   - 用免费 Apple ID 登录 Xcode → 个人 Team 即可本地真机运行
   - 真要上架或开 CloudKit 时再考虑 $99/年的开发者账号
3. **设计资产**
   - 确定主色调 + 树种风格（拟物 / 扁平 / 像素）→ 影响后续工作量
   - 树的 4 个生长阶段图 × 至少 3 个树种 = 12 张资源（MVP 可以先用 SF Symbol 占位）

---

## 11. 风险与对策

| 风险 | 影响 | 对策 |
| --- | --- | --- |
| Watch 模拟器不支持加速度计 / HealthKit | 自动计数功能没法测 | MVP 阶段不做自动计数，手动 +1 即可 |
| WatchConnectivity 在模拟器有时不稳定 | 同步开发体验差 | 抽象成 Protocol，模拟器用 NotificationCenter mock |
| SwiftData + CloudKit 后期切换有 schema 兼容坑 | 重写成本 | 一开始就按 CloudKit 约束写 model（已在第 5 节体现） |
| 没真机调试不知道交互手感 | 设计可能脱离现实 | 用 Watch 模拟器 + 经常看官方 HIG 视频 |
| 后台运行被 watchOS 杀掉 | 长时间训练计时被中断 | 用 HKWorkoutSession 保活（Phase 3 必做） |

---

## 12. 命名 / 品牌占位

工程名：**JustGo**（与目录名一致）
Bundle ID 占位：`com.zhihaoshu.justgo`（注册账号后改）
