# lib/domain/services

## 职责

实现核心业务规则：

- 估算在港天数。
- 年度 / 月度统计。
- 记录冲突检测。
- 需要确认状态判断。

## 在港天数伪代码

```pseudo
function calculateStayDates(records, todayHkDate):
  stayDates = Set<Date>()

  for record in records where record.confirmationStatus != REJECTED:
    start = record.entryDate
    end = record.exitDate ?? todayHkDate

    for date in enumerateInclusiveDates(start, end):
      stayDates.add(date)

  return stayDates
```

## 年度统计伪代码

```pseudo
function buildAnnualSummary(records, year, todayHkDate):
  stayDates = calculateStayDates(records, todayHkDate)
  datesInYear = stayDates.filter(date.year == year)

  monthlyCounts = Map<Month, Int>()
  for date in datesInYear:
    monthlyCounts[date.month] += 1

  return AnnualStaySummary(
    year = year,
    estimatedStayDays = datesInYear.count,
    monthlyCounts = monthlyCounts
  )
```
