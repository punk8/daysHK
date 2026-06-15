# lib/data/database

## 职责

管理本地 SQLite 数据库。

## 建议表结构

```pseudo
table stay_records:
  id TEXT PRIMARY KEY
  entry_date TEXT NOT NULL
  exit_date TEXT NULL
  is_same_day_round_trip INTEGER NOT NULL
  location_name TEXT NULL
  transport_mode TEXT NULL
  note TEXT NULL
  source TEXT NOT NULL
  confirmation_status TEXT NOT NULL
  created_at TEXT NOT NULL
  updated_at TEXT NOT NULL

table settings:
  key TEXT PRIMARY KEY
  value TEXT NOT NULL
```

后续自动定位可增加：

```pseudo
table location_events:
  id TEXT PRIMARY KEY
  event_type TEXT NOT NULL
  detected_at TEXT NOT NULL
  latitude REAL NOT NULL
  longitude REAL NOT NULL
  accuracy_meters REAL NULL
  boundary_classification TEXT NOT NULL
  generated_record_id TEXT NULL
```

## 保存记录伪代码

```pseudo
function insertStayRecord(record):
  validate(record)
  db.insert("stay_records", mapDomainToRow(record))
```

