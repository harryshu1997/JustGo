# JustGo

> 一个 iPhone + Apple Watch 健身目标追踪 App，自带像素风格的森林守护者（buddy）陪伴你完成每个目标。

每完成一次健身就在森林里种下一棵树，buddy 会随累计运动逐步进化（蛋 → 幼体 → 成长 → 成熟 → 守护者）。手机上规划今日队列，手表上专注执行 —— 单目标流，无干扰。

---

## ✨ 核心特性（MVP）

- **iPhone 端**：目标库 + 今日计划队列、像素森林、历史时间线、buddy 进度
- **Apple Watch 端**：当前目标卡片、buddy 陪伴计时、长按结束、完成动画
- **跨设备同步**：WCSession (`sendMessage` 实时 + `transferUserInfo` 兜底)
- **本地持久化**：SwiftData，模型按 CloudKit 兼容规范设计，后期可一键开启 iCloud
- **三种目标类型**：时长型（跑步/瑜伽）、次数型（俯卧撑/深蹲）、分阶段（HIIT）
- **视觉风格**：100% 纯 SwiftUI Shape 拼接的像素艺术，零位图依赖

---

## 🏗 技术栈

| 层 | 技术 |
| --- | --- |
| UI | SwiftUI |
| 持久化 | SwiftData（CloudKit-ready） |
| 双端同步 | WatchConnectivity |
| 日历集成 | EventKit（Phase 2） |
| 健康数据 | HealthKit（Phase 3） |
| 部署目标 | iOS 17+ / watchOS 10+ |

---

## 📁 项目结构

```
JustGo/
├── PLAN.md                       架构 / 数据模型 / 同步策略 / 路线图
├── UI.md                         线框 / 视觉规范 / 像素资产代码
├── BUILD.md                      Xcode 工程搭建逐步指南
├── JustGo/                       Xcode 工程根
│   ├── JustGo.xcodeproj
│   ├── Shared/                   双端共享（@Model + DTO + Theme + Logic）
│   ├── JustGo/                   iOS App 源码
│   ├── JustGoWatch/              iOS 包装 target
│   └── JustGoWatch Watch App/    watchOS App 源码
└── prototypes/                   原型源码副本（设计参考）
```

---

## 🚀 快速开始

```bash
git clone https://github.com/harryshu1997/JustGo.git
cd JustGo/JustGo
open JustGo.xcodeproj
```

详细配置（签名、模拟器配对、Watch companion bundle ID）见 [BUILD.md](BUILD.md)。

### 跑通 MVP

1. Xcode 配对 iPhone 17 Pro + Apple Watch S11 模拟器（或 `xcrun simctl pair <watch> <iphone>`）
2. 选 scheme `JustGo`，destination 选 paired 模拟器
3. ⌘R 运行 → iPhone 上创建目标 → 加入今日计划 → Watch 自动同步 → 开始 / 结束 → iPhone 历史 + 森林更新

---

## 📋 路线图

| 阶段 | 时间 | 内容 |
| --- | --- | --- |
| **MVP** ✅ | 已完成 | iPhone-Watch 同步、积分、种树、buddy 进化、3 种目标类型 |
| **Phase 2** | Week 3-4 | EventKit 日历集成、森林生长动画、Live Activity |
| **Phase 3** | Week 5-6 | HKWorkoutSession 后台保活、灵动岛、统计图表 |
| **Phase 4** | Week 7+ | Apple Developer 账号、CloudKit 多设备同步、上架 |

详细路线见 [PLAN.md §9](PLAN.md)。

---

## 🎨 视觉

- **主色调**：清新草绿 `#34C759`（与 Apple Health 系一致）
- **树种**：灌木 / 橡树 / 红杉 / 樱花（按目标类型 + 时长决定）
- **buddy**：像素小狐狸，5 阶段形态（蛋 → 幼体 → 成长 → 成熟 → 守护者）

像素资产全部由 `Rectangle` 网格拼接，可在 [UI.md §9](UI.md) 看到原始 SwiftUI 代码。

---

## 📚 文档

- [PLAN.md](PLAN.md) — 完整架构、数据模型、同步策略、积分规则、路线图
- [UI.md](UI.md) — 8 屏 ASCII 线框、视觉规范、像素树/buddy 代码
- [BUILD.md](BUILD.md) — Xcode 工程搭建逐步指南，含模拟器配对与常见坑

---

## 🛠 开发记录

本项目由 Claude Code (Opus 4.7) 协作完成，从需求澄清 → 设计 → 实现 → 调试 → 上手 Xcode 全程对话推进。
