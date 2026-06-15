# lib/domain/services

## 职责

实现核心业务规则：

- 估算在港天数。
- 年度 / 月度统计。
- 连续离港提醒。
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

  absenceAlerts = findContinuousAbsenceAlerts(records, thresholdMonths = 6)

  return AnnualStaySummary(
    year = year,
    estimatedStayDays = datesInYear.count,
    monthlyCounts = monthlyCounts,
    continuousAbsenceAlerts = absenceAlerts
  )
```

## 连续离港伪代码

```pseudo
function findContinuousAbsenceAlerts(records, thresholdMonths):
  sorted = records.sortBy(entryDate)
  alerts = []

  for each adjacent pair (previous, next):
    if previous.exitDate is null:
      continue

    absenceStart = previous.exitDate.plusDays(1)
    absenceEnd = next.entryDate.minusDays(1)

    if absenceStart <= absenceEnd and monthsBetween(absenceStart, absenceEnd) >= thresholdMonths:
      alerts.add(AbsenceAlert(absenceStart, absenceEnd))

  return alerts
```

