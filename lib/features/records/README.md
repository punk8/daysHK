# lib/features/records

## 职责

展示和管理入离港记录时间线。

## 页面内容

- 全部 / 入港 / 离港筛选。
- 按月份分组。
- 记录来源：自动检测、用户确认、手动补录。
- 确认状态：已确认、需要确认、已忽略。
- 编辑、删除、确认、修正入口。

## 伪代码

```pseudo
function loadTimeline(filter):
  records = repository.listRecords()
  filtered = applyFilter(records, filter)
  grouped = groupByMonth(filtered)
  return TimelineState(grouped)

function confirmRecord(recordId):
  record = repository.getRecord(recordId)
  updated = record.copy(confirmationStatus = CONFIRMED, source = USER_CONFIRMED)
  repository.saveRecord(updated)
```

## 注意事项

- 需要确认的记录必须在视觉上明显。
- 删除记录前需要确认。
- 长期使用后记录很多，应支持筛选和分组。

