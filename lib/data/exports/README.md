# lib/data/exports

## 职责

实现 CSV 导出。

## CSV 建议字段

```text
record_id,entry_date,exit_date,stay_days,source,confirmation_status,location_name,transport_mode,note,created_at,updated_at
```

## 导出伪代码

```pseudo
function exportRecordsToCsv(records):
  rows = []
  rows.add(header)

  for record in records:
    stayDays = calculateStayDates([record], todayHkDate).count
    rows.add([
      record.id,
      record.entryDate,
      record.exitDate ?? "",
      stayDays,
      record.source,
      record.confirmationStatus,
      record.locationName ?? "",
      record.transportMode ?? "",
      sanitizeCsv(record.note ?? ""),
      record.createdAt,
      record.updatedAt
    ])

  return encodeCsv(rows)
```

