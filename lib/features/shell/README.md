# lib/features/shell

## 职责

负责五个主功能页的跨平台壳层和底部导航。

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
    if platform is iOS/macOS:
      return CupertinoTabScaffold(tabBar = tabs, tabBuilder = pages[index])
    return Scaffold(body = IndexedStack(pages), bottomNavigationBar = tabs)
```

## 注意事项

- 这里可以做轻量页面编排，不放复杂业务算法。
- 如果后续状态变复杂，可以再引入 Provider / Riverpod 等状态管理。
- Tab 文案和顺序应保持与 UI 示意图一致，除非产品讨论明确调整。
- iOS / macOS 使用 Cupertino tab、页面滚动和导航标题。
- Android / Windows / Linux / Web 使用 Material bottom navigation 和页面路由。
- 底部导航图标通过 `AppPlatformIcon` 映射，确保 iOS 使用 Cupertino 图标，Material 平台使用 Material Icons。
