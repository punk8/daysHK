# tools/qa

## 职责

存放验收和测试辅助脚本。

## 建议工具

- 生成模拟入离港记录。
- 校验 CSV 导出字段。
- 对比 App 统计结果和 fixture 预期。
- 生成验收报告。
- `ios_preview.sh`：使用 iOS 26 Simulator 部署 Flutter App，并通过 `serve-sim` 暴露浏览器预览。

## iOS 预览

本项目的 iOS 模拟器预览按 Build iOS Apps 插件的 simulator-browser 工作流执行：先部署到明确的 Simulator UDID，再启动 `serve-sim` 镜像服务。

```bash
tools/qa/ios_preview.sh
```

常用参数：

```bash
tools/qa/ios_preview.sh --device D16207F5-F789-42F4-961C-C37FF443E562 --port 3100
tools/qa/ios_preview.sh --no-flutter-run
```

脚本会优先使用 `/Applications/Xcode-beta.app/Contents/Developer`，自动选择可用的 iOS 26 iPhone 模拟器，并在终端保持 `serve-sim` 前台运行。预览地址会显示为 `http://localhost:<port>`。

## 伪代码

```pseudo
function generateSampleRecords():
  return [
    record("2025-06-01", "2025-06-03"),
    record("2025-12-31", "2026-01-02"),
    record("2026-05-25", null)
  ]
```
