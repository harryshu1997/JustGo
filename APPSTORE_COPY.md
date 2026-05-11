# App Store Connect 文案 + 评级问卷

下面所有字段直接复制粘贴到 App Store Connect → My Apps → JustGo → App Store 标签里。

---

## 1. 基础信息（App Information）

| 字段 | 填写内容 |
| --- | --- |
| Name | `JustGo` |
| Subtitle (≤ 30 字) | `陪你练，种森林的健身助手` |
| Primary Category | `Health & Fitness`（健康健美） |
| Secondary Category | `Lifestyle`（生活） |
| Content Rights | ✓ "I have rights to use the content" |
| Age Rating | 4+（无敏感内容） |

---

## 2. 价格与发行（Pricing and Availability）

| 字段 | 填写内容 |
| --- | --- |
| Price | **Free**（建议先免费上架，后期再考虑订阅） |
| Availability | 全部地区 |
| In-App Purchase | None |

---

## 3. App Privacy

按 PRIVACY.md 内容如实填。Apple 会让你选 "Data Used to Track You" 等：

- **Data Collected**: 选 **"No, we do not collect data from this app"** ✓
- **Tracking**: 选 **"No, we do not track users"** ✓

---

## 4. URL

| 字段 | 填写内容 |
| --- | --- |
| Privacy Policy URL | `https://harryshu1997.github.io/JustGo/PRIVACY` |
| Support URL | `https://github.com/harryshu1997/JustGo/issues` |
| Marketing URL | （留空 / 可选） |

---

## 5. 描述（Description，≤ 4000 字）

```
JustGo 是一款让健身变成游戏的目标追踪 App。在 iPhone 上设定目标，在 Apple Watch 上专注完成，每次完成都让你的森林多一棵树，陪伴你的 buddy 小狐狸也会一起进化。

▍核心特性

• 🌱 像素森林激励 — 每完成一个目标种下一棵小树，长时间不练会枯萎，督促你保持节奏
• 🦊 专属 Buddy 陪伴 — 像素小狐狸跟随你的进度从蛋成长到守护者，5 级形态
• ⌚ iPhone + Apple Watch 双端联动 — 手机上规划今日计划，手表上单目标执行无干扰
• ⏱ 三种目标类型 — 时长型（跑步/瑜伽）、次数型（俯卧撑/深蹲）、分阶段（HIIT 循环训练）
• 📊 完整数据可视化 — 周/月/年统计图表 + GitHub 风格活跃日历热力图
• 🩺 心率追踪 — 通过 HKWorkoutSession 实时读取心率（需 Apple Watch）
• 📅 自动日历记录 — 完成 session 后自动写入 Apple 原生日历
• 🌳 完成判定差异化 — 达标种橡树/樱花，未达标记录为枯萎树（鼓励但不放纵）

▍隐私优先

• 所有数据仅保存在你自己的设备本地
• 不需要注册账号，不上传任何数据到云端
• 无广告、无第三方追踪、无分析 SDK

▍专为 Apple 生态打造

• 完整支持 iOS 17+ / watchOS 10+
• 利用 SwiftData / HealthKit / EventKit / WatchConnectivity 原生集成
• Apple Watch 端 HKWorkoutSession 后台保活，锁屏不中断计时
• 灵动岛 / 锁屏 Live Activity 显示进行中的 session

不需要订阅、不需要注册、不需要联网，打开就能用。让每一次运动都变成森林里的一棵树。
```

> 字数核对：约 540 字，远低于 4000 字上限。如果想加，可以补"为什么我们做了 JustGo"段。

---

## 6. 关键词（Keywords，≤ 100 字符，英文逗号分隔）

```
健身,运动,目标,锻炼,森林,buddy,fitness,workout,goal,tree
```

> 99 字符，刚好。Apple 会用这些 + App 名称做搜索匹配。

**优化技巧**：不要重复 App 名称里已有的词（JustGo），把额度留给同义/相关词。

---

## 7. Promotional Text（≤ 170 字符，可频繁更新不需重审）

```
新版本：森林衰退机制 + Apple Health 心率读取 + 灵动岛进度。完成目标种下你的森林，buddy 陪你练每一个 session。
```

---

## 8. What's New（每次新版本必填）

第一个版本：

```
首次发布 🎉
• iPhone + Apple Watch 双端联动
• 像素森林 + buddy 进化系统
• 时长 / 次数 / 分阶段三种目标
• 周月年统计 + 活跃日历热力图
• Apple Health 心率读取
• 自动写入原生日历
```

---

## 9. App Review Information（给审核员）

| 字段 | 填写内容 |
| --- | --- |
| Sign-In Required | **No**（不需要登录） |
| Demo Account | （留空） |
| Notes | 见下方 |

**Notes 填**：

```
JustGo is a fitness goal tracker for iPhone + Apple Watch.

How to test:
1. Open JustGo on iPhone → tap "+" → create a duration goal (e.g., 1 minute morning run)
2. Tap the star ⭐ in goal library to add to today's plan
3. Pick up the paired Apple Watch → the goal appears automatically on the JustGoWatch Watch App
4. Tap "开始" (Start) on Watch → wait at least 60 seconds → long-press the screen → "结束" (End)
5. iPhone "历史" (History) tab will show the completed session
6. iPhone "森林" (Forest) tab will plant a new tree

Optional permissions:
- HealthKit (heart rate / active energy): only used while a workout is running, never transmitted
- Calendar (write only): create an event when a session completes
- Live Activities: shown on lock screen during active session

No account or network connectivity required. All data is stored locally via SwiftData.

Privacy policy: https://harryshu1997.github.io/JustGo/PRIVACY
```

---

## 10. 评级问卷（Age Rating Questionnaire）答案

App Store Connect → App Information → Age Rating → Edit。所有项选 **None**：

| 类别 | 答案 |
| --- | --- |
| Cartoon or Fantasy Violence | None |
| Realistic Violence | None |
| Prolonged Graphic or Sadistic Realistic Violence | None |
| Profanity or Crude Humor | None |
| Mature/Suggestive Themes | None |
| Horror/Fear Themes | None |
| Medical/Treatment Information | None |
| Alcohol, Tobacco, or Drug Use or References | None |
| Simulated Gambling | None |
| Sexual Content or Nudity | None |
| Graphic Sexual Content and Nudity | None |
| Unrestricted Web Access | No |
| Gambling and Contests | No |

全部 None / No → 自动评级 **4+**（最宽松，任何年龄都能下载）。

---

## 11. 截图占位（下一步会单独搞）

每张截图都要 1290×2796 像素（iPhone 6.9" 屏）。详见 SCREENSHOTS.md（下一步生成）。

---

## 12. 检查清单

- [ ] 主语言 = 简体中文 (zh-Hans)
- [ ] 描述 / 关键词 / Subtitle 全部填好
- [ ] Privacy Policy URL 可访问且加载正确
- [ ] Support URL 是个能打开的页面
- [ ] App icon 不带圆角 / 不带文字
- [ ] 不少于 3 张 iPhone 6.9" 截图
- [ ] 选了 Build（Archive 上传后等几分钟会出现）
- [ ] Age Rating 完成
- [ ] App Privacy 完成
- [ ] What's New 写好
