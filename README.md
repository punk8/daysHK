# 在港日记 / Days in HK

一个用于记录和估算用户在香港停留天数的 Flutter 应用。目标用户是准备申请香港永久居民身份、需要长期整理入港和离港记录的大陆居民。

本项目定位是个人记录和统计辅助工具，不是永居资格判断工具。界面和导出文案应使用“估算在港天数”“个人记录参考”“可能需要解释或留证”等谨慎表达。

## 当前技术栈

- Flutter：iOS / Android / Web 共用 UI 和业务逻辑。
- 本地存储：移动端 SQLite，Web 验收使用 `shared_preferences` 适配。
- 定位：Dart `geolocator` + iOS Core Location + Android Geofencing API 方向。
- 原生桥接：Flutter MethodChannel `days_in_hk/geofence`。
- 边界判断：内置香港 18 区边界数据，运行时 bbox + point-in-polygon。
- 导出：CSV。

## 关键文档

- [项目入口说明](AGENTS.md)
- [产品讨论记录](product-notes.md)
- [项目结构规划](docs/project-structure.md)
- [开发验证标准](docs/development-verification.md)
- [原生定位配置](docs/native-location-setup.md)
- [UI 示意图](docs/ui-reference.png)

## 目录概览

```text
lib/       Flutter 应用主代码
assets/    打包资源，包含香港边界数据
android/   Android 原生工程和后台定位桥接
ios/       iOS 原生工程和后台定位桥接
web/       Flutter Web 验收入口
test/      单元、组件和集成测试
tools/     边界数据处理和 QA 辅助脚本
docs/      产品、技术、验证和设计文档
```

每个主要目录下都有 `README.md` 描述模块职责、边界和核心伪代码。

## 本地命令

当前 Flutter 安装路径：

```bash
/Users/chenshipeng/development/flutter/bin/flutter --version
```

常用验证命令：

```bash
/Users/chenshipeng/development/flutter/bin/flutter analyze
/Users/chenshipeng/development/flutter/bin/flutter test
/Users/chenshipeng/development/flutter/bin/flutter build web
/Users/chenshipeng/development/flutter/bin/flutter run -d web-server --web-hostname 127.0.0.1 --web-port 5050
```

Web 验收可用 Codex 内置 Browser / Computer Use 打开：

```text
http://127.0.0.1:5050
```

## 开发原则

- 优先保证手动补录、记录管理、年度统计和 CSV 导出稳定可用。
- 自动定位生成的记录应作为候选记录，允许用户确认、修正或忽略。
- 后台定位和地理围栏必须在 iOS / Android 真机上验证。
- 数据第一版默认只保存在本地，不做账号和云同步。
- UI 开发需参考 `product-notes.md` 中的 UI prompt 和 `docs/ui-reference.png`。

