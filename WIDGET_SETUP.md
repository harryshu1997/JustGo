# Live Activity / Widget Extension 配置

Phase 3.3 需要一个独立的 Widget Extension target 来注册 Live Activity 在
锁屏和灵动岛的 UI。iOS 主 app 已经有相应的 ActivityKit 调用（启动 /
更新 / 结束 activity），缺的就是这个负责显示的 widget。

---

## 1. 在 Xcode 创建 Widget Extension target

1. **File → New → Target...**
2. 选 **iOS** → **Widget Extension** → **Next**
3. 参数：
   - **Product Name**: `JustGoLiveActivity`
   - **Bundle Identifier**: 自动 `com.zhihaoshu.JustGo.JustGoLiveActivity`
   - **Include Configuration App Intent**: ✗ 不勾
   - **Include Live Activity**: ✓ 勾（如果 Xcode 版本提供这个选项）
4. **Finish**
5. 弹窗 "Activate JustGoLiveActivity scheme?" → 选 **Cancel**（我们通过
   主 app scheme 跑就够了，不需要单独 scheme）

## 2. 替换默认模板代码

Xcode 会在新创建的 `JustGoLiveActivity` 组下面生成几个文件，**全部删掉**：

- `JustGoLiveActivity.swift`
- `JustGoLiveActivityBundle.swift`
- `JustGoLiveActivityLiveActivity.swift`（如果有）
- `AppIntent.swift`（如果有）
- 任何 `Provider`/`Entry` 之类的样例

> 右键文件 → Move to Trash。Assets.xcassets 可以保留。

## 3. 把我们的 Widget 代码加进新 target

1. 从 Finder 拖 `prototypes/Widget/JustGoLiveActivityWidget.swift`
   到 Xcode 左侧的 `JustGoLiveActivity` 组
2. 弹出对话框：
   - **Destination**: ✓ "Copy items if needed"
   - **Add to targets**: ✓ **只勾 `JustGoLiveActivity`**（不勾 JustGo 主 app）

## 4. 把 SessionActivityAttributes 共享给 Widget

Widget 需要知道 `SessionActivityAttributes` 类型。但这个文件目前只在 JustGo
主 app target。需要把它**多加一个 target membership**：

1. 左侧栏点 `JustGo/SessionActivityAttributes.swift`
2. 右侧 **File Inspector** → **Target Membership**
3. 勾上 `JustGoLiveActivity`（除了已经勾的 JustGo）

> 现在两个 target 都能 import 这个类型。

## 5. 确认 Build Settings

`JustGoLiveActivity` target → Signing & Capabilities：

- **Team**: 选你的 Personal Team（同 JustGo）
- **Bundle Identifier**: `com.zhihaoshu.JustGo.JustGoLiveActivity` （保持默认）

主 app `JustGo` target → Info：

- 应该已经有 `INFOPLIST_KEY_NSSupportsLiveActivities = YES`（我已经在
  pbxproj 加了，Xcode 会显示为 `Supports Live Activities` 字段）

## 6. 编译

⌘B 编译 JustGo scheme。如果 widget 编译报 "Cannot find SessionActivityAttributes"
就是 step 4 没勾对 Target Membership，回去检查。

## 7. 测试

清模拟器 → ⌘R → 跑 paired (iPhone + Watch) →
- Watch 上点开始 session
- 看 iPhone 锁屏（按一下电源键熄屏后再点亮）→ 应该看到 Live Activity
- iPhone 17 Pro 模拟器顶部灵动岛位置应该有 buddy 跑步小图标

如果 Live Activity 没出现：
- 看 Xcode Console 有没有 `[LiveActivity] started id=...` 日志
- 检查 iPhone 模拟器 Settings → JustGo → Live Activity 开关是否被关
- 第一次启动可能要前后台切换一下才显示

---

完成后回 GitHub 仓库提交：

```bash
cd ~/Desktop/JustGo
git add -A
git commit -m "Widget Extension: JustGoLiveActivity for lock screen + dynamic island"
git push
```
