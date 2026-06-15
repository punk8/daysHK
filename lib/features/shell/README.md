# lib/features/shell

## 职责

负责五个主功能页的壳层和底部导航。

当前 Tab：

- 首页：`dashboard/`
- 统计：`statistics/`
- 记录：`records/`
- 补录：`manual_entry/`
- 设置：`settings/`

## 状态职责

`AppShell` 维护当前页面索引和当前内存中的 `StayRecord` 列表。它负责在保存、删除、清空记录后重新从 repository 读取数据，并把刷新后的记录传给各页面。

## 伪代码

```pseudo
class AppShell:
  selectedIndex = 0
  records = []

  function initState():
    reloadRecords()

  function reloadRecords():
    records = repository.listRecords()

  function saveRecord(record):
    repository.saveRecord(record)
    reloadRecords()

  function deleteRecord(id):
    repository.deleteRecord(id)
    reloadRecords()

  function build():
    pages = [
      DashboardPage(records),
      StatisticsPage(records),
      RecordsPage(records, saveRecord, deleteRecord),
      ManualEntryPage(records, saveRecord),
      SettingsPage(records, clearAll)
    ]
    return Scaffold(body = pages[selectedIndex], bottomNav = tabs)
```

## 注意事项

- 这里可以做轻量页面编排，不放复杂业务算法。
- 如果后续状态变复杂，可以再引入 Provider / Riverpod 等状态管理。
- Tab 文案和顺序应保持与 UI 示意图一致，除非产品讨论明确调整。

