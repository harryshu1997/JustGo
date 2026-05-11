# JustGo 隐私政策

**生效日期：2026 年 5 月 10 日**
**最后更新：2026 年 5 月 10 日**

JustGo（"我们"、"本 App"）非常重视你的隐私。本政策说明 JustGo 收集、使用和保护数据的方式。

---

## 简要总结

- **所有数据只存在你自己的设备上**（iPhone 和 Apple Watch）。
- **我们不收集、不上传、不分析任何个人数据**。
- 没有账号注册、没有第三方追踪、没有广告。
- 你卸载 App 即可彻底清除所有数据。

---

## 我们访问的数据

### 1. 你创建的内容

你在 JustGo 里输入或生成的所有数据（健身目标、完成记录、积分、buddy 信息、森林状态）都**仅保存在你设备的本地存储**（SwiftData / iCloud 私有数据库）。

**JustGo 不会将这些数据上传到任何远程服务器。**

### 2. Apple Health 数据（仅在你授权后）

- **读取**：心率、活动卡路里
- **写入**：完成的 workout 记录（HKWorkout）

这些数据在你的 Apple Health app 中，完全由你自己控制。JustGo 仅用于显示和记录运动 session，**不会以任何形式传输出你的设备**。

授权可在任何时候通过 **iPhone Settings → Health → Data Access & Devices → JustGo** 撤回。

### 3. Apple Calendar 数据（仅在你授权后）

JustGo 在完成 session 后会**写入**一条记录到你的 Apple 原生日历（仅限当前事件，不读取你已有的日历内容）。

授权可在 **iPhone Settings → JustGo → Calendars** 撤回。

### 4. WatchConnectivity 通信

JustGo 在你的 iPhone 与你已配对的 Apple Watch 之间传输数据（目标设置、运动记录）。**通信仅在你的两台设备之间发生**，由 Apple WatchConnectivity API 加密处理，不经过任何外部服务器。

### 5. Live Activity（灵动岛 / 锁屏）

当你在 Watch 上开始一个 session，iPhone 会通过 Apple ActivityKit 在锁屏 / 灵动岛显示进度。**这些数据仅渲染在本设备屏幕上**，不上传。

---

## 我们不做的

- **没有用户账号系统**。你无需登录、无需提供邮箱或电话。
- **没有第三方分析 SDK**（无 Firebase、无 Google Analytics、无 Sentry）。
- **没有广告 SDK**。
- **没有云存储默认上传**。所有数据本地保存在你的设备。
- **没有 cookies 或追踪 ID**。
- **不向 Apple 之外的任何第三方分享数据**。

---

## 数据保留与删除

- **保留**：你的数据保留在你设备本地，直到你主动删除或卸载 App。
- **删除**：你可以在 App 内删除单条记录（历史详情页 → 删除），或卸载 JustGo 来清除全部数据。
- iCloud 同步（如未来启用）：数据会出现在你登录同一 Apple ID 的其他设备的 iCloud 私有库，仅你可访问。

---

## 儿童隐私

JustGo 不针对 13 岁以下儿童。如果你是 13 岁以下的儿童，请在成人监护下使用。我们不会有意收集任何儿童的个人信息。

---

## 安全

由于所有数据仅保存在你的设备本地（受 iOS 沙盒和你设备解锁密码保护），不存在数据被远程窃取的可能。请保护好你的 iOS 设备解锁密码与 Apple ID。

---

## 政策变更

如果本政策有重要变更，我们会在此页面更新。继续使用 JustGo 即表示你同意更新后的政策。

---

## 联系我们

如对本隐私政策有疑问：

- **GitHub Issues**: https://github.com/harryshu1997/JustGo/issues
- **Email**: zshu9@wisc.edu

---

# JustGo Privacy Policy

**Effective Date: May 10, 2026**

## TL;DR

- All your data stays on **your own devices**. We do not upload, collect, or analyze anything.
- No account, no analytics, no ads, no third parties.
- Uninstalling JustGo erases all data.

## Data we access (only with your explicit permission)

- **You-generated content** (goals, sessions, trees, buddy state): stored locally via SwiftData.
- **Apple Health**: read heart rate / active energy, write completed workouts. Revoke any time in iOS Settings → Health.
- **Apple Calendar**: write a "💪 [goal]" event on session completion. Revoke in iOS Settings → JustGo → Calendars.
- **WatchConnectivity**: device-to-device sync between your iPhone and your Apple Watch only, via Apple's encrypted framework.
- **Live Activity**: rendered on lock screen / Dynamic Island via Apple ActivityKit, never transmitted.

## Data we do NOT collect

No user accounts, no third-party analytics (Firebase / GA / Sentry), no ads, no tracking IDs, no remote storage by default.

## Retention / deletion

Your data lives on your device until you delete it in-app or uninstall JustGo.

## Children

JustGo is not directed at children under 13.

## Contact

- GitHub: https://github.com/harryshu1997/JustGo/issues
- Email: zshu9@wisc.edu
