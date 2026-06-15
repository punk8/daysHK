# lib

## 职责

Flutter 应用主代码目录。

建议采用分层结构：

- `app/`：应用入口、路由、状态管理装配。
- `core/`：无业务依赖的通用基础能力。
- `domain/`：业务模型、接口、业务服务。
- `data/`：SQLite、导出、仓储实现。
- `features/`：面向页面和用户流程的功能模块。
- `location/`：定位、权限、地理围栏、边界判断。
- `shared/`：主题、通用组件、设计系统。
- `l10n/`：国际化文案。

## 依赖方向

```text
features -> domain -> core
features -> shared
data -> domain
location -> domain/core
app -> features/data/location/shared
```

避免：

- `domain` 依赖 Flutter UI。
- `core` 依赖具体业务。
- 页面直接操作 SQLite。
- 页面直接写复杂天数算法。

