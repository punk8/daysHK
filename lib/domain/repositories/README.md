# lib/domain/repositories

## 职责

定义业务层需要的数据访问接口，由 `data/` 提供具体实现。

## 建议接口伪代码

```pseudo
interface StayRecordRepository:
  Future<List<StayRecord>> listRecords()
  Future<StayRecord?> getRecord(id)
  Future<void> saveRecord(StayRecord record)
  Future<void> deleteRecord(id)
  Future<void> clearAll()

interface SettingsRepository:
  Future<AppSettings> loadSettings()
  Future<void> saveSettings(AppSettings settings)
```

## 原则

- 接口返回 domain model。
- 不暴露 SQLite row、JSON map 或 Flutter widget。

