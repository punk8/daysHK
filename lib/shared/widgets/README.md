# lib/shared/widgets

## 职责

存放通用 UI 组件。

## 建议组件

- `StatusCard`
- `MetricCard`
- `PermissionWarningCard`
- `RecordTimelineItem`
- `SourceBadge`
- `ConfirmationBadge`
- `PrimaryActionButton`
- `EmptyState`
- `AppNotice`
- `CupertinoControls`

## 已实现

- `AppEmptyState`：用于空列表，包含图标、标题、描述和主动作。
- `AppNotice`：用于轻量状态反馈，避免 Android 风格 Snackbar。
- `AppCupertinoButton` / `AppIconButton`：统一 iOS 触控尺寸、圆角、haptic 和 VoiceOver 语义。

## 原则

- 组件应服务当前 UI 示意图，不要一开始做过度通用的设计系统。
- 文案应从调用方传入，避免组件里硬编码业务结论。
- iOS 主流程优先使用 Cupertino 弹窗、滚轮日期选择、tab 和页面脚手架。
