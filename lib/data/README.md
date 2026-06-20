# lib/data

## 职责

实现数据持久化和仓储适配。

子目录：

- `database/`：SQLite schema、DAO、迁移。
- `repositories/`：domain repository 的具体实现。

## 原则

- UI 不直接访问 `data/database`。
- schema 变化必须有迁移策略。
- 所有敏感数据默认保存在本地设备。
