# lib/app

## 职责

负责应用级装配：

- App 入口 widget。
- 路由配置。
- 全局状态管理。
- 依赖注入。
- 应用启动时的数据初始化。

## 建议文件

- `app.dart`：根组件。
- `router.dart`：路由和 Tab 结构。
- `bootstrap.dart`：初始化数据库、仓储、定位服务。
- `app_state.dart`：应用级状态，例如当前年份、权限健康状态。

## 启动伪代码

```pseudo
function main():
  ensureFlutterInitialized()
  database = openLocalDatabase()
  boundary = loadHongKongBoundaryAsset()
  repositories = createRepositories(database)
  services = createDomainServices(repositories, boundary)
  runApp(App(dependencies = services))
```

## 导航结构

```pseudo
tabs = [
  DashboardTab,
  StatisticsTab,
  RecordsTab,
  ManualEntryTab,
  SettingsTab
]
```

