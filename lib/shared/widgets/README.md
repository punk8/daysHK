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
- `CupertinoControls` / adaptive controls

## 已实现

- `AppEmptyState`：用于空列表，包含图标、标题、描述和主动作。
- `AppNotice`：iOS / macOS 使用顶部轻提示，Material 平台使用 `SnackBar`。
- `AppButton` / `AppIconButton`：按平台切换 Cupertino / Material 控件；旧的 `AppCupertinoButton` 仅保留为兼容壳。
- `AppAdaptiveSwitch` / `AppSegmentedControl`：用于需要原生开关和分段选择体验的场景。

## 原则

- 组件应服务当前 UI 示意图，不要一开始做过度通用的设计系统。
- 文案应从调用方传入，避免组件里硬编码业务结论。
- iOS / macOS 主流程优先使用 Cupertino 弹窗、滚轮日期选择、tab 和页面脚手架。
- Android / Windows / Linux / Web 主流程优先使用 Material 3 对话框、日期选择、底部导航和页面路由。
