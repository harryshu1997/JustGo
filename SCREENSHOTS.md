# App Store 截图脚本

App Store 至少需要 **iPhone 6.9" 屏 3 张**，建议 5-8 张。Watch 截图 3-5 张提升通过率。

## 设备 + 分辨率

| 设备 | 分辨率（像素） | 在哪截 |
| --- | --- | --- |
| iPhone 6.9" | **1290 × 2796** | iPhone 16/17 Pro Max 模拟器 |
| Apple Watch Ultra 3 | **410 × 502** | Apple Watch Ultra 3 模拟器 |

> 直接用模拟器 ⌘S 截屏，会按设备物理分辨率存到桌面，App Store 直接接受。
> **不要用 Mac 自带的 ⌘⇧4 截图**，会带额外阴影/边距。

---

## 截图脚本（按顺序）

每张图需要先把模拟器/真机调整到指定状态再 ⌘S。

---

### iPhone 截图 1: 主页（早上好 + 今日计划）

**目的**：第一眼传达"双端联动 + 今日计划队列"。

**怎么准备**：

1. 模拟器 iPhone 17 Pro Max，运行 JustGo
2. 调系统时间到 **早上 8:30**（Settings → General → Date & Time → 关闭自动）
3. 提前建好 3 个目标：
   - "晨跑" 30 分钟
   - "俯卧撑" 50 个
   - "HIIT 训练" 3 阶段
4. 三个都加入今日计划
5. 完成第 1 个（在 Watch sim 跑一次 "晨跑"）
6. 主页应该显示：
   - 标题 JustGo
   - "早上好 🌱"
   - "今日已完成 1 / 3 个目标"
   - 今日计划列表：晨跑 ✓ / 俯卧撑 ▶ 当前 / HIIT 待开始

**⌘S 截图**

文件命名：`01-home.png`

---

### iPhone 截图 2: 森林（树 + buddy + 衰退提示）

**目的**：突出核心激励机制（像素森林 + buddy）。

**怎么准备**：

1. 模拟器先把时间调到 8 天前
2. 在 iPhone 上做几次完整的 session（10 个目标各完成一次，制造 10 棵不同 stage 的树）
3. 时间调回今天 → 触发衰退检查（最老的 1 棵变树桩）
4. 切到森林 tab
5. 应该看到：
   - 顶部 Lv 进度条
   - 橙色"X 棵树枯死了"警告
   - 5-10 棵不同生长阶段的彩色像素树
   - 左下 buddy 在漂动
   - 底部 3 个统计卡

**⌘S 截图**

文件名：`02-forest.png`

---

### iPhone 截图 3: 统计图表（年视图 + 热力图）

**目的**：展示数据可视化能力。

**怎么准备**：

1. 切到"统计" tab
2. 顶部分段切到 **本年**
3. 应该出现：
   - 顶部 3 个 summary 卡
   - 12 月柱状图
   - GitHub 风格热力图（有几个绿色格子，越多越好看）

**⌘S 截图**

文件名：`03-stats.png`

> 如果数据稀疏热力图全灰，模拟器里多刷几次完成 session（不同日期）撑一下数据。

---

### iPhone 截图 4: 历史详情页（含日历集成）

**目的**：展示完整记录追溯能力。

**怎么准备**：

1. 我的 tab → 打开"完成时写入日历" toggle
2. 再做一次完整 session
3. 切到历史 tab → 点其中一条记录进入详情页
4. 详情页应显示：
   - 目标名 / 来源设备
   - 开始时间 / 结束时间 / 用时
   - 获得积分（绿色）
   - **日历 section（已写入 + 从日历移除按钮）**
   - 底部"删除这条记录"红色按钮

**⌘S 截图**

文件名：`04-history-detail.png`

---

### iPhone 截图 5: 目标编辑（分阶段）

**目的**：展示分阶段编辑器（差异化卖点）。

**怎么准备**：

1. 主页 → 右上 +
2. 类型选"分阶段"
3. 名字填 "HIIT 上肢循环"
4. 添加 4 个阶段：
   - 热身 5 分钟
   - 俯卧撑 20 个
   - 平板 1 分钟
   - 拉伸 5 分钟

**⌘S 截图**

文件名：`05-goal-phased.png`

---

### Apple Watch 截图 1: Root 等待屏（buddy 漂动）

**目的**：展示 Watch 极简界面 + buddy 主角。

**怎么准备**：

1. iPhone 上清空今日计划
2. Watch sim 应该回到等待屏
3. buddy 跑来跑去，文案显示

**⌘S 截图**（模拟器顶部 Watch 选中状态下截）

文件名：`watch-01-waiting.png`

---

### Apple Watch 截图 2: 进行中（计时 + buddy）

**目的**：展示核心使用场景。

**怎么准备**：

1. iPhone 建一个时长目标 → 加入今日
2. Watch 上点开始 → 跑 20 秒等计时显示 "00:20" 左右
3. buddy 在跳跃

**⌘S**

文件名：`watch-02-active.png`

---

### Apple Watch 截图 3: 完成动画

**目的**：传达完成时的情感反馈。

**怎么准备**：

1. 跑完上面的 session 长按结束
2. 等完成动画第 2 帧（buddy 抱树苗）→ 立即截

> 完成动画 2.5 秒就过，多试几次抓时机

文件名：`watch-03-complete.png`

---

## 截好后

1. 全部 PNG 拖到 Mac 桌面新建的 `screenshots/` 文件夹
2. App Store Connect → JustGo → App Store 标签 → iPhone 6.9" → 拖入 5 张 iPhone 图
3. Apple Watch 那栏拖入 3 张 Watch 图

> 顺序就是 App Store 上展示的顺序。**第一张最关键**（决定 70% 用户是否点详情）。

---

## 进阶选项（可选）

想做更漂亮的"marketing screenshots"（带文字标语 + 设备 mockup 的那种）：

- [screenshots.pro](https://screenshots.pro) - 拖图自动生成
- [previewed.app](https://previewed.app) - 同类工具
- Figma "iOS App Store Screenshot Template" 自己排版

每张图加一行标语，例如：
- 01-home: "**双端联动** · iPhone 设目标，Watch 自动跟进"
- 02-forest: "**完成种树** · 长时间不练森林会衰退"
- 03-stats: "**完整数据** · 周/月/年视图 + 活跃日历"

不做 marketing 版直接用原始截图也行，审核都过。

---

## 截图清单

完成把这个清单 ✅：

- [ ] `01-home.png` — 主页早上好 + 今日计划
- [ ] `02-forest.png` — 森林全景 + 衰退提示
- [ ] `03-stats.png` — 统计年视图 + 热力图
- [ ] `04-history-detail.png` — 历史详情含日历
- [ ] `05-goal-phased.png` — 分阶段编辑
- [ ] `watch-01-waiting.png` — Watch 等待屏 buddy
- [ ] `watch-02-active.png` — Watch 进行中
- [ ] `watch-03-complete.png` — Watch 完成动画
