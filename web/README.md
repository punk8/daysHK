# web

## 职责

Flutter Web 壳目录，用于浏览器运行和 Codex 内置 Browser / Computer Use 验收。

当前用途：

- 本地 Web 预览。
- 验证核心 Flutter UI、手动补录、统计、记录、CSV 展示。
- 在没有 iOS / Android 真机构建条件时做基础可用性验收。

## 运行伪代码

```pseudo
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 5050
open Codex Browser at http://127.0.0.1:5050
perform manual acceptance flow
```

## 注意事项

- Web 验收不能证明后台定位、原生权限和地理围栏可用。
- Web 端本地存储使用 `shared_preferences` 适配，移动端使用 SQLite。
- 如果 Web 上原生地理围栏显示 unsupported，这是预期行为。

