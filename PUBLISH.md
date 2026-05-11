# App Store 发布完整流程

预计总时间：**2-4 周**（不算研发，含审核等待）。预计费用：**$99/年** Apple Developer Program。

---

## 前置：必须满足的条件

| 项 | 当前状态 |
| --- | --- |
| 应用能在真机跑通 iPhone 端 | ✅（HarryShu 真机已部署） |
| 应用能在真机跑通 Watch 端 | ⚠️ 未完成（建议用 Apple Developer 账号再试一次） |
| Bundle ID 唯一 | ✅ `com.zhihaoshu.JustGo` 等 |
| App icon 1024×1024 | ✅ 已加 |
| 隐私字符串完整（Calendar/Health/Live Activities） | ✅ 已在 pbxproj |
| 已加入 Apple Developer Program | ❌ **必须做** |
| App Store Connect 注册了 App | ❌ 待做 |
| 截图 + 描述文案 + 隐私政策 URL | ❌ 待做 |

---

## Step 1: 加入 Apple Developer Program（$99/年）

**1.1** 浏览器打开 https://developer.apple.com/programs/enroll/

**1.2** 用你的 Apple ID 登录（建议用 zshu9@wisc.edu 或你的私人 Apple ID）

**1.3** 选 **Individual / Sole Proprietor**（不需要公司）

**1.4** 填地址、电话、付费 $99（信用卡或 Apple Pay）

**1.5** 等审核：**最快几小时，最长 48 小时**。审核通过后会收邮件。

> 你之前 "We are unable to process your request" 这一步可能是 Apple ID 太新 / 没开 2FA。
> 先确认 Apple ID 有：
> - 启用 Two-Factor Authentication
> - 账号已使用 ≥ 30 天
> - Apple ID 个人信息完整（真实姓名、地址）

---

## Step 2: App Store Connect 注册 App

加入 Developer Program 后：

**2.1** 打开 https://appstoreconnect.apple.com

**2.2** **My Apps → `+ New App`**

**2.3** 填：
- Platform: **iOS**
- Name: **JustGo**（这是 App Store 上显示的名字，可以和 bundle ID 不同）
- Primary Language: **Simplified Chinese**
- Bundle ID: 下拉选 **`com.zhihaoshu.JustGo`**（如果没出现，先去 developer.apple.com → Certificates, Identifiers & Profiles → Identifiers → `+` 注册一个）
- SKU: **JUSTGO001**（自定义编号，自己记就行）
- User Access: Full Access

**2.4** Create

---

## Step 3: 准备 App Store 元数据

**3.1 截图（必需）**

App Store 要求每种屏幕尺寸至少 1 张截图：
- 6.9" iPhone（iPhone 16 Pro Max 屏幕）至少 3 张
- 6.5" iPhone（iPhone 15 Pro Max）至少 3 张（可选）
- Apple Watch（Series 9 46mm）3-5 张

最快方法：用 iPhone 17 Pro 模拟器跑 JustGo，按 **⌘S** 截屏，把生成的 PNG 上传到 App Store Connect 的 App Information → App Store Preview 那一栏。

要的关键截图：
- 主页（今日计划 + 目标库）
- 森林（带 buddy 和几棵树）
- 统计图表
- Watch 进行中（buddy 陪伴计时）
- 完成动画 / 历史详情页

**3.2 App 描述（必需）**

写 4000 字以内的中文描述。建议模板：

```
JustGo 是一款让健身变得有趣的目标追踪 App。

特性：
• 在 iPhone 上设定健身目标，Apple Watch 上自动同步执行
• 像素风格的 buddy 狐狸陪你完成每个 session
• 完成目标种下小树，逐步长成你的专属森林
• 长时间不练森林会衰退，督促你保持活力
• 三种目标类型：时长 / 次数 / 分阶段（HIIT）
• 历史时间线 + 周/月/年统计图表 + 热力图
• 完成后自动写入 Apple 原生日历

支持 iPhone + Apple Watch 双端联动，所有运动数据存在你设备上，不上传任何云端。
```

**3.3 关键词（必需）**

100 字符以内，用逗号分隔。例：

```
健身,运动,目标,锻炼,森林,buddy,fitness,workout,goal,tree
```

**3.4 隐私政策 URL（必需）**

App Store 强制要求一个 URL 公开列出 app 的数据处理。最快做法：

- 去 **github.com/harryshu1997/JustGo** 项目仓库
- 新建文件 `PRIVACY.md`（我可以帮你写）
- 用 GitHub Pages 把这个文件发布成 HTML
- 把那个 URL 填进 App Store Connect

或者用 [iubenda.com](https://www.iubenda.com)（免费 generator）生成。

**3.5 联系方式 + 支持 URL**

- Support URL: 可以填 GitHub repo 地址
- Marketing URL: 可选

**3.6 App 评级**

填一个评级问卷（暴力 / 性 / 烟酒 / 赌博 等）—— 我们这种健身 app 全选 None，最后得到 4+ 分级（最宽松）。

---

## Step 4: Archive + 上传

回到 Xcode：

**4.1** scheme = **`JustGo`**，destination = **`Any iOS Device (arm64)`**（不是模拟器）

**4.2** **Product → Archive**（菜单栏，没快捷键）

Xcode 编译 Release 构建。完成后弹出 Organizer 窗口。

**4.3** Organizer → 选刚 archive 的版本 → 右侧 **`Distribute App`**

**4.4** 选 **`App Store Connect`** → Next

**4.5** 选 **`Upload`** → Next

**4.6** 选你的 Distribution Certificate（Xcode 自动建好）→ Upload

上传约 5-15 分钟。

**4.7** 上传完后 App Store Connect 网页：**My Apps → JustGo → TestFlight** 标签 → 等几分钟 → build 出现

---

## Step 5: TestFlight 内测（可选但强烈推荐）

正式提交前先用 TestFlight 给朋友测：

**5.1** App Store Connect → TestFlight 标签 → 上传的 build 旁点 **Submit for Review**（很快，TestFlight review 通常几小时）

**5.2** Internal Testing → Add Testers → 输入朋友的 Apple ID 邮箱

**5.3** 朋友收到邮件链接 → iPhone 装 TestFlight app → 装 JustGo beta

收集反馈，修 bug，重新 archive + upload，再发新 build。

---

## Step 6: 提交正式审核

TestFlight 跑稳定后：

**6.1** App Store Connect → JustGo → **App Store** 标签 → 顶部"Prepare for Submission"

**6.2** 把所有截图、描述、关键词、隐私政策 URL 填齐

**6.3** 选刚才上传的 Build

**6.4** 滚到底 → **Submit for Review**

**6.5** 等待审核 **1-7 天**（健身 app 通常 24-48 小时）

---

## Step 7: 上架

审核通过后：

- 默认会自动发布到 App Store（你也可以选手动发布）
- 上架后用户在 App Store 搜 "JustGo" 就能找到
- 第一周通常下载量 100-1000，之后看你怎么推广

---

## 常见审核拒绝原因 + 对策

| 拒绝原因 | 修复 |
| --- | --- |
| Privacy strings 模糊 | 隐私字符串描述要明确，不能写 "用于改善体验" |
| 必须真机跑通且无 crash | 部署到真 iPhone + 真 Watch 全流程过一遍 |
| HealthKit 用途不明 | 描述里要说明读心率/卡路里是为啥 |
| Login required for basic use | JustGo 不需要登录就能用 ✅ |
| Debug logs / TODO 字样 | Release 模式编译会自动剥离 print，但代码里别留可见的 "TODO" |
| App icon 内有文字 | 我们的 icon 没文字 ✅ |
| Live Activity 不工作 | 要么修好要么从 Info.plist 移除 `NSSupportsLiveActivities` |

---

## 当前 JustGo 距离发布还差什么

按急到缓：

1. **🚨 Apple Developer Program 加入**（$99，必需）
2. **🚨 隐私政策**（必需，最简单是 GitHub Pages 发个 PRIVACY.md）
3. **🚨 截图**（至少 iPhone 6.9" 3 张 + Watch 3 张）
4. **🚨 App 描述 + 关键词**
5. **⚠️ 真机 Watch 部署修通**（不是必需，但 reviewer 会测 Watch 端）
6. **⚠️ Live Activity 修通**（如果保留这个 capability）
7. **🟢 清理 debug `print` 日志**（不会拒，但 Release 编译更干净）
8. **🟢 加上 onboarding 首屏**（不是必需，但提升通过率）

---

## 我能帮的

告诉我从哪里开始，我帮你：
- 写 PRIVACY.md 模板 + GitHub Pages 部署步骤
- 写 App 描述 / 关键词 / 评级问卷答案
- 设置 archive 配置 + Release 配置清理 debug log
- 截图清单 + 拍摄脚本

倾向先做哪个？
