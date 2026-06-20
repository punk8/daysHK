# lib/domain/models

## 职责

定义核心业务模型。

## 建议模型

```pseudo
enum StayEventType:
  ENTRY
  EXIT

enum RecordSource:
  AUTO_DETECTED
  USER_CONFIRMED
  MANUAL

enum ConfirmationStatus:
  CONFIRMED
  NEEDS_CONFIRMATION
  REJECTED

class StayRecord:
  id
  entryDate
  exitDate?
  isSameDayRoundTrip
  locationName?
  transportMode?
  note?
  source
  confirmationStatus
  createdAt
  updatedAt

class StayDay:
  date
  recordIds

class AnnualStaySummary:
  year
  estimatedStayDays
  monthlyCounts
```

## 注意事项

- `entryDate` 和 `exitDate` 面向统计展示用香港自然日。
- 后续自动定位可以额外保存精确时间、坐标、定位精度和来源。
- 不要把 UI 文案写进模型。
