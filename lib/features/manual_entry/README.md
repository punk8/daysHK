# lib/features/manual_entry

## 职责

实现手动补录表单。

## 表单字段

- 类型：入港 / 离港或停留区间。
- 入港日期。
- 离港日期，可为空。
- 当天往返。
- 口岸 / 地点。
- 交通方式。
- 备注。
- 本次计入在港天数预览。

## 校验伪代码

```pseudo
function validateManualEntry(form):
  if form.entryDate is null:
    return error("请选择入港日期")

  if form.exitDate != null and form.exitDate < form.entryDate:
    return error("离港日期不能早于入港日期")

  if overlapsExistingRecords(form.toRecord(), existingRecords):
    return warning("该记录与已有记录重叠，请确认")

  return ok()
```

## 天数预览伪代码

```pseudo
function previewStayDays(entryDate, exitDate, today):
  end = exitDate ?? today
  return enumerateInclusiveDates(entryDate, end).count
```

## 保存伪代码

```pseudo
function saveManualEntry(form):
  validation = validateManualEntry(form)
  if not validation.isValid:
    showIssues(validation.issues)
    return

  record = StayRecord(
    entryDate = form.entryDate,
    exitDate = form.exitDate,
    source = MANUAL,
    confirmationStatus = CONFIRMED
  )
  repository.saveRecord(record)
```

