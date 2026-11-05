# Android 测试 APK 构建记录

## 2026-11-05 — 首轮设备测试包

- 构建分支：`build/android-debug-apk`，基于当前 `main`。
- 引擎：Godot 4.7.2，与项目正式目标版本一致。
- 包类型：Android Debug APK，临时调试签名；不是 Play 商店发布包。
- 包名：`com.heroworld.game`。
- 导出方式：Godot Android Gradle build template。
- CI：`.github/workflows/android.yml`，成功后上传 `hero-world-android-debug` artifact（保留 14 天）。
- 目的：先验证 Android 安装、竖屏显示、触控、主城建筑入口、地图切换、英雄/装备/背包/招募界面及基础运行稳定性。
- 限制：云端导出成功不等于真机验收；仍需在实际 Android 设备上检查启动、触控、画面适配、帧率、发热和存档重启。
- 签名说明：此 Debug APK 使用临时调试密钥；后续每次 CI 构建密钥可能不同。若设备已有同包名但不同签名的安装版本，需要先卸载旧版再安装。
- 后续：根据设备反馈修复问题，再建立固定发布密钥并制作可覆盖升级的 Release APK。
