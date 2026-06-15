# lib/features/dashboard

## 职责

实现首页 Dashboard。

## 页面内容

- 当前状态：在香港 / 不在香港 / 需要确认。
- 今年估算在港天数。
- 当前连续在港或连续离港天数。
- 最近一条入离港记录。
- 定位权限状态提示。
- 手动补录入口。

## 状态伪代码

```pseudo
function buildDashboardState(records, permissionStatus, today):
  currentPresence = inferCurrentPresence(records)
  annualSummary = statsService.buildAnnualSummary(records, today.year, today)
  latestRecord = records.sortBy(updatedAt).lastOrNull
  permissionCard = permissionPresenter.describe(permissionStatus)

  return DashboardState(
    currentPresence,
    estimatedStayDaysThisYear = annualSummary.estimatedStayDays,
    latestRecord,
    permissionCard
  )
```

## 必备状态

- 无记录空状态。
- 当前在香港。
- 当前不在香港。
- 需要确认。
- 定位权限受限。

