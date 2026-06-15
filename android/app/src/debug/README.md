# android/app/src/debug

## 职责

Android debug 构建专用配置。

这里适合放仅调试时需要的 Manifest 片段，例如：

- 调试网络安全配置。
- 本地开发专用权限开关。
- Debug-only Activity 或 Provider。

## 注意事项

正式发布需要的定位权限和后台能力应放在 `src/main/`，不要只放在 debug 目录。

