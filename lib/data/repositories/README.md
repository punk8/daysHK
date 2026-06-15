# lib/data/repositories

## 职责

把 SQLite DAO 转换为 domain repository。

## 伪代码

```pseudo
class SqliteStayRecordRepository implements StayRecordRepository:
  dao

  async function listRecords():
    rows = await dao.listStayRecords()
    return rows.map(rowToStayRecord)

  async function saveRecord(record):
    row = stayRecordToRow(record)
    await dao.upsertStayRecord(row)
```

## 注意事项

- 转换层要处理枚举值兼容。
- 不要让页面层知道数据库字段名。

