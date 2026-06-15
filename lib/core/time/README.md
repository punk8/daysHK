# lib/core/time

## 职责

统一处理香港本地日期和时间规则。

本项目所有统计都应以香港自然日为准。

## 需要支持

- 将任意时间转换为香港本地日期。
- 生成两个日期之间的自然日列表。
- 按年份拆分日期集合。
- 处理离港日期为空的进行中记录。

## 核心伪代码

```pseudo
function toHongKongDate(instant):
  return instant.atTimezone("Asia/Hong_Kong").date

function enumerateInclusiveDates(startDate, endDate):
  dates = []
  current = startDate
  while current <= endDate:
    dates.add(current)
    current = current.plusDays(1)
  return dates

function splitDatesByYear(dates):
  result = Map<Year, Set<Date>>()
  for date in dates:
    result[date.year].add(date)
  return result
```

