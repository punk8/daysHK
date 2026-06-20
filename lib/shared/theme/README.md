# lib/shared/theme

## 职责

定义 App 设计系统。

## 视觉方向

- 浅色背景。
- 白色卡片。
- 深墨色正文。
- 克制香港红作为提醒 / 离港强调色。
- logo 蓝作为主要操作和在港状态色。
- 卡片圆角遵循 `design/components.md` 的 16pt。
- 信息密度适中，适合长期反复查看。
- 颜色 token 使用 `CupertinoDynamicColor`，并通过 `ThemeData` 暴露给 Material 平台。
- `platform_style.dart` 负责判断 Cupertino / Material 平台族，页面不直接判断 OS。
- `platform_icons.dart` 负责把同一业务语义映射为 SF Symbols / Material Icons，页面不直接为 Android 复用 iOS 图标。

## 建议 token

```pseudo
colors:
  background = dynamic(#F5F8FF / #0B1220)
  surface = dynamic(#FFFFFF / #182033)
  textPrimary = dynamic(#17233A / #F4F7FF)
  textSecondary = dynamic(#6D7890 / #A6AEC0)
  brandBlue = #326BFF
  hkRed = #D92D3A
  warningBg = dynamic(#FFF7E8 / #352817)
  infoBg = dynamic(#EFF5FF / #13213B)

radii:
  card = 16
  button = 14
```
