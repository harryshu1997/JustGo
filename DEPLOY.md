# 真机部署指南（Personal Team 免费版）

把 JustGo + Watch app 装到你真实的 iPhone 和 Apple Watch 上跑。

## ⚠️ Personal Team 的限制

| 项 | 限制 |
| --- | --- |
| 签名有效期 | **7 天**，过期后 app 在设备上无法启动 |
| 每年设备数 | 100 个 |
| 同时 active app | 10 个 |
| 推送 / CloudKit / Game Center | ✗ 不支持，需要付费 $99/年 |
| HealthKit / Live Activity / Background Modes | ✓ 支持 |

7 天后要重新插到 Mac 上 ⌘R 一次刷新签名。

---

## 1. 把 iPhone 接到 Mac

**1.1** 用数据线把 iPhone 插到 Mac

**1.2** iPhone 弹 "信任此电脑?" → 选 **信任**，输入锁屏密码

**1.3** Xcode 顶部菜单 **Window → Devices and Simulators**（⌃⇧2）

**1.4** 左栏选 **Devices** 标签 → 应该看到你的 iPhone 出现

如果没出现：
- 检查 iPhone 是否解锁
- 换一根数据线（很多线只通电不通数据）
- iPhone 上信任弹窗有没有点 Trust

**1.5** Devices and Simulators 窗口里点到你的 iPhone，右侧应该看到型号 + iOS 版本

> iOS 版本必须 ≥ 17.0（我们的最低部署目标）

## 2. iPhone 必须已和 Apple Watch 配对

iPhone 上打开 **Watch app**，确认 Apple Watch 显示 "Connected"。

> 真机配对是 iPhone 端 Watch app 干的事，不是 Xcode。如果还没配过，按 Watch 开机引导完成。

## 3. 在 Xcode 给 4 个 target 全部设 Team

左侧栏点最顶 `JustGo` 项目 → 中间 **TARGETS** 列表里：

依次对每个 target：

- **JustGo**
- **JustGoWatch**
- **JustGoWatch Watch App**
- **JustGoLiveActivityExtension**

切到 **Signing & Capabilities** 标签 → **Team** 下拉 → 选你的 `Zhihao Shu (Personal Team)`。

> 4 个都要设。漏一个就会签名失败。

## 4. 检查 Bundle ID 唯一

Personal Team 不能跟其他人/你已存在的 app 冲突 Bundle ID。我们当前是：

| Target | Bundle ID |
| --- | --- |
| JustGo | `com.zhihaoshu.JustGo` |
| JustGoWatch | `com.zhihaoshu.JustGoWatch`（用不到了，但留着） |
| JustGoWatch Watch App | `com.zhihaoshu.JustGo.watchkitapp` |
| JustGoLiveActivityExtension | `com.zhihaoshu.JustGo.JustGoLiveActivity` |

如果 Xcode 报 "Bundle ID already taken"，把 4 个的中间都加个尾缀（比如 `com.zhihaoshu.JustGo2026`、`com.zhihaoshu.JustGo2026.watchkitapp`），保持父子层级关系。

## 5. 选目标设备 + 编译

**5.1** Xcode 顶部 scheme = **`JustGo`**

**5.2** destination 下拉 → 选 **你的 iPhone（真机）** + paired Watch

> 真机配对后 destination 列表里会出现 `[iPhone 名字] + Apple Watch ...`

**5.3** ⌘R 运行

Xcode 会：
1. 编译 iOS + Watch + Widget Extension
2. 自动生成 provisioning profile
3. 把 JustGo iOS app 装到你的 iPhone
4. iPhone 上的 Watch app 自动把 JustGoWatch Watch App 装到你 Watch

## 6. 第一次跑：信任 Developer Profile

iPhone 屏幕会弹 "Untrusted Developer"，按这个流程信任：

**iPhone：Settings → General → VPN & Device Management → Developer App** → 找到你的 Apple ID → 点 **Trust** → **Trust** 确认

**Apple Watch：iPhone 上的 Watch app → General → Device Management** → 同样信任

然后回 iPhone 主屏，点 JustGo 图标启动。Apple Watch 上拉一下手腕找 JustGoWatch 图标。

## 7. 第一次运行权限

- **HealthKit**: Watch app 会弹权限请求
- **Live Activities**: iPhone Settings → JustGo → 可手动开/关
- **日历**: 在我的 tab 里手动打开开关时弹

## 8. 验证

在 paired iPhone + Watch 上跑一遍：

- iPhone 建目标 → 加入今日 → Watch 同步 → Watch 开始 → 长按结束 → iPhone 历史出现
- buddy 心率应该有真实读数（不再是 0）
- Watch 锁屏期间计时不停（HKWorkoutSession 后台保活）
- iPhone 锁屏看 Live Activity（如果你做了 Phase 3.3b widget setup）

## 9. 常见报错

| 报错 | 修复 |
| --- | --- |
| `No profiles for ... were found` | 等几秒 / 关掉 app 再 ⌘R / Xcode > Settings > Accounts > 重新登录 |
| `Could not launch ... LaunchServices error` | 第 6 步 trust developer profile |
| Watch 上图标没出现 | Watch app 安装慢，等 30 秒；或 iPhone Watch app → 我的 Watch → 滚到底打开 JustGoWatch 的 Show App on Apple Watch |
| `Personal Team device limit reached` | 一年 100 设备上限，你装太多了；删几个 |
| HealthKit 拒绝授权 | iPhone Settings → Health → Data Access & Devices → JustGo → 允许 |

---

## 10. 7 天后的循环

签名过期后：

```bash
cd ~/Desktop/JustGo
git pull       # 如果远端有更新
```

Xcode 连接 iPhone → ⌘R → 重新装一遍。这就是 Personal Team 的代价 ¯\\_(ツ)_/¯

要彻底脱离这个束缚就只能买 Apple Developer Program $99/年。
