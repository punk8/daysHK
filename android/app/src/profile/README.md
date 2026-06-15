# android/app/src/profile

## 职责

Android profile 构建专用配置，用于性能分析和接近 release 的调试场景。

## 注意事项

- 不放业务逻辑。
- 不放只在正式版需要的权限。
- 如果 profile 行为与 release 不一致，需要在验收文档中明确说明。

