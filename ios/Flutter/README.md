# ios/Flutter

## 职责

Flutter iOS 构建配置目录。

常见文件：

- `Debug.xcconfig`
- `Release.xcconfig`
- `Generated.xcconfig`
- `AppFrameworkInfo.plist`

## 注意事项

- `Generated.xcconfig` 通常由 Flutter 工具生成，不手动维护。
- `ephemeral/` 是生成目录，不应提交业务逻辑或手写文档。
- 原生定位桥接代码应放在 `ios/Runner/`。

