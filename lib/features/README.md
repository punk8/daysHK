# lib/features

## 职责

按用户可见功能组织页面、状态和交互。

子目录：

- `dashboard/`：首页。
- `statistics/`：年度统计。
- `records/`：入离港记录。
- `manual_entry/`：手动补录。
- `settings/`：设置与隐私。

## 原则

- 页面只负责展示和用户交互。
- 复杂统计交给 `domain/services`。
- 数据读写通过 repository 或用例层完成。

