# 开发与验收记录

更新时间：2026-06-15

## 已完成范围

本轮已完成 Flutter MVP 开发和一轮原生后台检测桥接推进：

- iOS / Android / Web Flutter 工程骨架。
- 首页 Dashboard。
- 年度统计页。
- 入离港记录页。
- 手动补录页。
- 设置与隐私页。
- 本地记录仓储：
  - iOS / Android 使用 SQLite (`sqflite`)。
  - Web 验收环境使用 `shared_preferences`。
- 按香港自然日统计在港天数。
- 入港日、离港日均计入。
- 当天往返计 1 天。
- 同日多段记录去重。
- 跨年度拆分统计。
- 清除所有本地数据二次确认。
- 香港政府 18 区边界数据 asset 接入。
- 离线 bbox + point-in-polygon 边界判断。
- 边界判断三态：在香港、不在香港、边界附近需确认。
- 设置页香港边界判断自检。
- 前台定位权限检查与当前位置检测入口。
- 模拟坐标检测入口，用于 Web / Browser 验收自动候选记录流程。
- 定位检测结果可生成“需要确认”的候选入港 / 离港记录。
- iOS 定位权限说明和后台定位模式配置。
- Android 前台 / 后台定位权限配置。
- Flutter 到原生后台检测 MethodChannel。
- iOS Core Location region monitoring 注册路径。
- Android Google Play Services Geofencing API 注册路径。
- iOS / Android 最近原生地理围栏事件 `lastEvent` 回传。
- 原生应用显示名统一为「在港日记」。
- 设置页后台自动检测状态卡片。
- 记录页支持已确认记录的编辑，以及候选记录的忽略 / 修正 / 确认。
- 设置页支持把原生 `lastEvent` 转为需要确认的候选记录。

## 自动化验证

本轮执行：

```bash
/Users/chenshipeng/development/flutter/bin/flutter analyze
/Users/chenshipeng/development/flutter/bin/flutter test
/Users/chenshipeng/development/flutter/bin/flutter build web
/Users/chenshipeng/development/flutter/bin/flutter build apk --debug
/Users/chenshipeng/development/flutter/bin/flutter build ios --no-codesign
```

结果：

- `flutter analyze`：通过，无 issues。
- `flutter test`：通过，19 个测试全部通过。
- `flutter build web`：通过，产物输出到 `build/web`。
- `flutter build apk --debug`：通过，产物输出到 `build/app/outputs/flutter-apk/app-debug.apk`。
- `flutter build ios --no-codesign`：通过，产物输出到 `build/ios/iphoneos/Runner.app`。

## iOS 26 Simulator 预览

可使用 `tools/qa/ios_preview.sh` 走 Build iOS Apps 插件的模拟器预览流程：

```bash
tools/qa/ios_preview.sh --device D16207F5-F789-42F4-961C-C37FF443E562 --port 3100
```

该脚本会：

- 使用 `/Applications/Xcode-beta.app/Contents/Developer`。
- 启动或复用 iOS 26 Simulator。
- 通过 `flutter run -d <udid> --debug` 部署应用。
- 通过 `serve-sim` 在浏览器中暴露模拟器画面。

本机已验证可用的模拟器：

- iPhone 17 Pro / iOS 26.5：`D16207F5-F789-42F4-961C-C37FF443E562`

本轮补齐的原生构建环境：

- 已通过 Homebrew 安装 Android command-line tools：`android-commandlinetools`。
- 已通过 `sdkmanager` 安装 Android SDK：
  - `platform-tools`
  - `platforms;android-36`
  - `build-tools;36.0.0`
  - 构建过程中自动补齐 NDK `28.2.13676358` 和 CMake `3.22.1`
- 已接受 Android SDK licenses。
- 已通过 `flutter config --android-sdk /opt/homebrew/share/android-commandlinetools` 配置 Flutter Android SDK。
- 已在 `android/local.properties` 写入 `sdk.dir=/opt/homebrew/share/android-commandlinetools`。
- 已通过 `xcodebuild -downloadPlatform iOS` 下载并安装 iOS 26.5 platform / simulator 组件。
- 已修复 iOS Swift 兼容性问题：`CLLocationManager.authorizationStatus` 在 iOS 14 以下使用静态 API fallback。

注意：

- Android build 仍有 `package_info_plus` 使用 Kotlin Gradle Plugin 的未来兼容警告，但当前构建通过。
- iOS build 使用 `--no-codesign`，说明代码编译和打包通过；上真机和上架仍需要正式签名配置。

## 单元测试覆盖

当前测试覆盖：

- 6 月 1 日入港、6 月 3 日离港，计 3 天。
- 当天往返计 1 天。
- 同一天多次入离港去重。
- 12 月 31 日入港、1 月 2 日离港，跨年拆分为上一年 1 天、下一年 2 天。
- 离港日期早于入港日期时校验失败。
- 重叠记录校验失败。
- 中环坐标判断为在香港。
- 香港国际机场坐标判断为在香港。
- 深圳市区坐标判断为不在香港。
- 澳门坐标判断为不在香港。
- 低精度定位在香港内时标记为需要确认。
- 在香港且无当前记录时生成入港候选记录。
- 离港且当前在港时生成离港候选记录。
- 低精度定位生成需要确认候选记录。
- 原生 geofence 状态支持解析最近事件 `lastEvent`。
- `StayRecord.copyWith` 可以清空地点、交通方式、备注等可选字段。
- 记录页可打开「编辑 / 修正」弹窗，并回填原记录字段。

## Codex Browser 验收

使用 Codex 内置 Browser 打开：

```text
http://127.0.0.1:5050
```

本轮已验证流程：

1. 页面启动：
   - 页面标题为“在港日记”。
   - 首页 Dashboard 正常渲染。

2. 清除数据：
   - 设置页可见“清除所有数据”。
   - 点击后出现二次确认弹窗。
   - 点击“清除”后显示“本地数据已清除”。

3. 首页空状态：
   - 显示“当前不在香港”。
   - 今年估算在港天数显示 0 天。
   - 最近记录显示暂无记录。

4. 手动补录：
   - 补录页显示默认入港 / 离港日期、当天往返、地点、交通方式、备注。
   - 本次计入在港天数显示 1 天。
   - 点击保存后跳转记录页。

5. 记录页：
   - 显示 2025 年 5 月入离港记录。
   - 来源为“手动补录”。
   - 状态为“已确认”。
   - 地点为“香港国际机场”。

6. 首页同步：
   - 最近记录显示新增记录。
   - 2026 年估算仍为 0 天，因为补录记录在 2025 年。
   - 最长连续在港显示 1 天。

7. 年度统计：
   - 2026 年显示 0 天。
   - 切换到 2025 年后显示 1 天。
   - 2025 年 5 月显示 1 天。

8. 香港边界判断：
   - 设置页显示中环“在香港”。
   - 深圳市区显示“不在香港”。
   - 低精度定位显示“边界附近，需确认”。

10. 后台自动检测状态：
    - 设置页显示“后台自动检测”卡片。
    - Web 环境显示“不支持”。
    - Web 环境说明可使用模拟检测验收业务流程。

11. 模拟定位候选记录（入港候选）：
    - 点击“中环”后显示“检测结果：在香港，已生成需要确认的候选记录”。
    - 记录页出现 2026 年 6 月“自动检测 / 需要确认”的入港候选记录。
    - 点击“确认”后，该记录变为“用户确认 / 已确认”。

12. 记录编辑 / 修正：
    - 记录页可通过更多菜单打开“编辑 / 修正”。
    - 弹窗显示入港日期、离港日期、口岸 / 地点、交通方式和备注。
    - 已有记录字段可正常回填，例如“香港国际机场”“飞机”和备注内容。

13. 模拟定位候选记录（离港候选）：
    - 当前已有在港记录时，点击“中环”会提示当前无需新增候选记录。
    - 点击“深圳市区”后显示“检测结果：不在香港，已生成需要确认的候选记录”。
    - 记录页出现“自动检测 / 需要确认”的入离港候选记录。
    - 候选记录显示“忽略 / 修正 / 确认”三个处理入口。
    - 点击“确认”后，该记录变为“用户确认 / 已确认”。

14. 统计联动：
    - 确认候选记录后，年度统计页 2026 年 6 月显示 1 天。
    - 统计页继续使用“估算在港天数”“仅供个人记录参考”等谨慎文案。

## 当前限制

以下内容仍需后续真机验证或产品迭代：

- iOS Core Location region monitoring 的真实后台触发稳定性。
- Android Geofencing API 的真实后台触发稳定性。
- 香港边界数据已接入，当前使用官方 18 区边界 feature 直接判断；后续可增加构建期 union / simplify 产物优化运行时体积。
- iOS / Android 系统权限弹窗和后台定位行为。
- Android 不同厂商后台限制。
- App Store / Google Play 后台定位审核材料。
- PDF 报告导出。
- 多语言。
- iOS 真机部署需要签名、Bundle ID 和 Apple Developer Team 配置。

## 当前结论

MVP 的手动记录、日期统计、记录管理、本地存储、边界判断、前台定位检测管线和 Web 交互验收已完成。

后台 geofence 注册路径已实现，且 iOS / Android 原生构建已经通过。系统唤醒、真机权限和后台稳定性仍属于下一阶段真机验收能力，不影响当前 MVP 的手动记录、前台检测与候选记录闭环。
