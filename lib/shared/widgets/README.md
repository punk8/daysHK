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

## 原则

- 组件应服务当前 UI 示意图，不要一开始做过度通用的设计系统。
- 文案应从调用方传入，避免组件里硬编码业务结论。
- iOS 主流程优先使用 Cupertino 弹窗、滚轮日期选择、tab 和页面脚手架。
