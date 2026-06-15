# lib/features/statistics

## 职责

展示年度和月度统计。

## 页面内容

- 年份切换。
- 年度估算在港天数。
- 与上一年同期对比。
- 月度分布热力图或条形图。
- 连续离港超过 6 个月提醒。

## 伪代码

```pseudo
function loadStatistics(year):
  records = repository.listRecords()
  summary = statsService.buildAnnualSummary(records, year, todayHkDate)
  previous = statsService.buildAnnualSummary(records, year - 1, equivalentDateLastYear)
  return StatisticsState(summary, previous)
```

## 文案要求

- 使用“估算在港天数”。
- 连续离港提醒使用“可能需要解释或留证”。
- 不显示“永居达标 / 不达标”。

