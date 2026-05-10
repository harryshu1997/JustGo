# JustGo · Xcode 工程搭建指南

> 这是一份给 Apple 生态新手的逐步说明。所有 Swift 源码在 `prototypes/` 已写好，
> 你按本文创建工程后，把 `prototypes/` 里的文件拖到对应组里即可。

---

## 0. 前置确认

```bash
xcodebuild -version
# Xcode 应 ≥ 15.0；本工程目标 iOS 17 / watchOS 10
swift --version
# Swift 应 ≥ 5.9
```

如果 Xcode 没装或版本太老：去 App Store 装/升级 Xcode。
首次启动 Xcode 时会要求安装 iOS / watchOS 模拟器，全部选上。

---

## 1. 创建主工程（iPhone App）

1. 打开 Xcode → **Create New Project**
2. 选 **iOS** → **App** → **Next**
3. 填写参数：
   - **Product Name**: `JustGo`
   - **Team**: `None`（无开发者账号也能本地跑模拟器；后期再换）
   - **Organization Identifier**: `com.zhihaoshu`（Bundle ID 会自动拼成 `com.zhihaoshu.JustGo`）
   - **Interface**: `SwiftUI`
   - **Language**: `Swift`
   - **Storage**: `SwiftData`
   - **Include Tests**: ✗ 不勾（MVP 先不写测试）
   - **Host in CloudKit**: ✗ 不勾（暂时本地，后期开启）
4. **Next** → 选 `~/Desktop` 作为存放位置（不要勾 Source Control 即可）
5. **Create Git repository on my Mac** ✓ 勾（方便后续版本管理）

> 这一步会生成 `JustGo.xcodeproj` + `JustGo/` 主目录 + 默认 `JustGoApp.swift` / `Item.swift` 模板。

### 1.1 修改部署目标

1. 选中工程根（蓝色图标）→ **TARGETS: JustGo** → **General**
2. **Minimum Deployments**: iOS `17.0`

### 1.2 删除 Xcode 模板自带文件

因为我们要用自己的 SwiftData 模型：

- 删除 `JustGo/Item.swift`（右键 Move to Trash）
- **保留** `JustGoApp.swift` 但内容会被替换

---

## 2. 添加 Watch App Target

1. **File → New → Target...**
2. 选 **watchOS** 标签 → **App** → **Next**
3. 参数：
   - **Product Name**: `JustGoWatch`
   - **Bundle Identifier**: 自动 `com.zhihaoshu.JustGo.watchkitapp`（保持默认）
   - **Interface**: `SwiftUI`
   - **Language**: `Swift`
   - **Include Tests**: ✗
   - **Pair with Companion App**: 选 `JustGo`（**关键**：让 Xcode 知道这是 iPhone App 的 Watch 配套）
4. **Finish**
5. 弹窗问 "Activate JustGoWatch scheme?" → 选 **Activate**

> 此时项目会出现 `JustGoWatch Watch App/` 目录。

### 2.1 部署目标

1. 选 **TARGETS: JustGoWatch Watch App** → **General**
2. **Minimum Deployments**: watchOS `10.0`

---

## 3. 创建共享代码组

iOS 和 Watch 必须用同一份 SwiftData 模型。MVP 阶段最简单的做法是**通过文件成员关系共享**（不需要 Swift Package）：

1. 在 Project Navigator 里右键工程根目录 → **New Group** → 命名 `Shared`
2. 把 `prototypes/Shared/` 里所有 `.swift` 文件**拖入这个 Group**
3. 弹窗时：
   - **Copy items if needed** ✓ 勾
   - **Added folders**: Create groups
   - **Add to targets**: **同时勾选 `JustGo` 和 `JustGoWatch Watch App`**（关键）

> 如果某个文件忘了勾两个 target，编译时会报"未定义"。检查方法：选中文件 → 右栏 File Inspector → Target Membership 必须两个都勾。

---

## 4. 拖入 iOS 和 Watch 各自的源码

### 4.1 iPhone

1. Project Navigator → `JustGo/` 组
2. 把 `prototypes/iOS/` 下所有 `.swift` 文件拖进来
3. **Add to targets**: 仅勾 `JustGo`，**不**勾 Watch
4. 当 Xcode 提示替换 `JustGoApp.swift` 时选 **Replace**

### 4.2 Watch

1. Project Navigator → `JustGoWatch Watch App/` 组
2. 把 `prototypes/Watch/` 下所有 `.swift` 文件拖进来
3. **Add to targets**: 仅勾 `JustGoWatch Watch App`
4. 当提示替换 `JustGoWatchApp.swift` 时选 **Replace**

---

## 5. 配置 Capabilities 和 Info.plist

### 5.1 iPhone target（Signing & Capabilities）

1. 选 `JustGo` target → **Signing & Capabilities**
2. **Team**: 选你的 Apple ID（免费个人 Team 也行）
3. 点 **+ Capability** 添加：
   - **Background Modes**：勾选 `Background fetch` 和 `Remote notifications`（后续推送预留）

### 5.2 iPhone Info.plist 隐私字符串

进入 **TARGETS: JustGo** → **Info** 标签 → 点 `+` 添加以下键：

| Key | Value |
| --- | --- |
| `NSCalendarsFullAccessUsageDescription` | "JustGo 在你完成健身目标时把记录写入日历，方便你回顾打卡。" |
| `NSHealthShareUsageDescription` | "JustGo 读取你的运动数据来更准确地记录目标完成情况。"（预留 Phase 3 用） |
| `NSHealthUpdateUsageDescription` | "JustGo 把你完成的健身记录同步到 Apple Health。"（预留 Phase 3 用） |

> Calendar 那条是 MVP 必需的；Health 两条是 Phase 3 才用，先填上免得后期再改。

### 5.3 Watch target Capabilities

1. 选 `JustGoWatch Watch App` target → **Signing & Capabilities**
2. **Team**: 同上选你的 Apple ID
3. 添加 **Background Modes**：勾 `Workout processing`（Phase 3 用 HKWorkoutSession 必需，先打开）

---

## 6. 第一次编译验证

1. Xcode 顶部 scheme 切换器选 `JustGo`（iPhone scheme）
2. 模拟器选 `iPhone 15`
3. 按 ⌘R 运行 → 应该看到 "JustGo" 主页

如果报错，常见两类：

**A. "Cannot find 'XXX' in scope"** → 共享文件没勾 Watch target，或 iOS 文件错勾了 Watch target。检查 File Inspector → Target Membership。

**B. SwiftData 报错** → 检查 `JustGoApp.swift` 里的 `.modelContainer(for: ...)` 列表是否包含所有 `@Model` 类。

---

## 7. 配对模拟器跑 Watch

1. Xcode → **Window → Devices and Simulators**
2. **Simulators** 标签 → 找 `iPhone 15` 那一行 → 右键 → **Pair with Watch...** → 选一个 watchOS 10 模拟器
3. Scheme 切到 `JustGoWatch Watch App`
4. Run destination 选 `iPhone 15 + Apple Watch Series 9`（成对的那个）
5. ⌘R 运行 → 同时启动两个模拟器

> 模拟器配对后 WatchConnectivity 才能跑通。**单独启动 Watch 模拟器**会让 `WCSession.isReachable` 一直是 false。

---

## 8. 最小验收（MVP Week 1 里程碑）

跑通以下流程即说明骨架就绪：

1. iPhone 模拟器：在主页点 `+` → 创建一个 30 分钟"晨跑"目标 → 加入今日计划
2. Watch 模拟器：自动出现"晨跑"作为当前目标（buddy 待命）
3. Watch：点开始 → 计时 → 长按结束
4. iPhone：在历史里看到这次记录

---

## 9. 后续里程碑（按 PLAN.md §9 推进）

每完成一个 Phase 回到本文，把对应的 capability / Info.plist 字段补齐：

- **Phase 2**：EventKit 写日历（隐私字符串已预填）
- **Phase 3**：HealthKit 工作流（在 capabilities 里补 HealthKit）
- **Phase 4**：注册 Apple Developer + 开启 CloudKit + iCloud sync

---

## 10. 常见坑速查

| 问题 | 原因 | 解决 |
| --- | --- | --- |
| Watch 模拟器看不到 iPhone 推送的目标 | 模拟器没配对 | 第 7 步 Pair with Watch |
| `WCSession.isPaired` 一直是 false | 需要 iPhone 上启动一次 App | 先在 iPhone 模拟器启动 App |
| SwiftData "Multiple model container" 错 | 多个 `.modelContainer` 重复定义 | 全工程只有一个，写在 `App.body` 上 |
| Watch App 编译说找不到 SwiftData 类型 | Shared 文件没勾 Watch target | File Inspector 里补勾 |
| 修改 `@Model` 后 App 启动崩溃 | SwiftData schema 变了，旧数据冲突 | 删模拟器里的 App 重装 |
