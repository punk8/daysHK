# 项目结构规划

更新时间：2026-06-15

## 目标

本文件描述「在港日记 / Days in HK」当前 Flutter 工程的目录分工。后续开发应优先沿用这里的模块边界：页面负责交互，业务规则放在 `domain/`，本地数据适配放在 `data/`，定位和边界判断放在 `location/`，原生后台能力通过 iOS / Android Platform Channel 接入。

## 当前目录树

```text
.
├── AGENTS.md
├── README.md
├── product-notes.md
├── pubspec.yaml
├── docs/
├── assets/
│   ├── geo/
│   └── images/
├── lib/
│   ├── main.dart
│   ├── app/
│   ├── core/
│   │   ├── time/
│   │   └── validation/
│   ├── domain/
│   │   ├── models/
│   │   ├── repositories/
│   │   └── services/
│   ├── data/
│   │   ├── database/
│   │   ├── exports/
│   │   └── repositories/
│   ├── features/
│   │   ├── dashboard/
│   │   ├── manual_entry/
│   │   ├── records/
│   │   ├── settings/
│   │   ├── shell/
│   │   └── statistics/
│   ├── location/
│   │   ├── boundary/
│   │   ├── geofence/
│   │   └── permissions/
│   ├── shared/
│   │   ├── theme/
│   │   └── widgets/
│   └── l10n/
├── android/
├── ios/
├── web/
├── test/
│   ├── fixtures/
│   ├── integration/
│   ├── unit/
│   └── widget/
└── tools/
    ├── geo/
    └── qa/
```

生成目录如 `.dart_tool/`、`build/`、`ios/Flutter/ephemeral/` 不纳入人工维护结构。

## 模块职责

| 目录 | 职责 |
| --- | --- |
| `lib/app/` | App 根组件、依赖装配、启动流程 |
| `lib/core/` | 无业务依赖的通用时间、校验能力 |
| `lib/domain/` | 记录模型、仓储接口和天数统计规则 |
| `lib/data/` | SQLite / Web 本地存储、repository 实现 |
| `lib/features/` | 首页、统计、记录、补录、设置等用户可见功能 |
| `lib/location/` | 香港边界、定位权限、自动检测、原生地理围栏桥接 |
| `lib/shared/` | 主题和通用 UI 组件 |
| `assets/` | 香港边界数据、图片等打包资源 |
| `android/` | Android 权限、Geofencing API、Kotlin 原生桥接 |
| `ios/` | iOS 权限、Core Location、Swift 原生桥接 |
| `web/` | Flutter Web 壳，用于 Codex Browser / Computer Use 验收 |
| `test/` | 单元、组件、集成验收测试 |
| `tools/` | 边界数据处理和 QA 辅助脚本 |

## 依赖方向

```text
main -> app -> features
features -> domain
features -> shared
features -> location
data -> domain
location -> domain/core
domain -> core
```

禁止方向：

- `domain/` 依赖 Flutter UI。
- `core/` 访问数据库、定位或页面状态。
- 页面直接操作 SQLite 表结构。
- 原生 iOS / Android 代码直接实现业务统计口径。

## 启动流程伪代码

```pseudo
function main():
  ensureFlutterBinding()
  dependencies = bootstrapDependencies()
  runApp(DaysInHkApp(dependencies))

function bootstrapDependencies():
  records = LocalStayRecordRepository.create(
    useSharedPreferences = isWeb
  )
  boundary = HkBoundaryService.loadFromAsset()
  locationDetection = LocationDetectionService(boundary)
  permission = LocationPermissionService()
  nativeGeofence = NativeGeofenceBridge(channel = "days_in_hk/geofence")

  return AppDependencies(
    records,
    boundary,
    locationDetection,
    permission,
    nativeGeofence
  )
```

## 核心业务流伪代码

### 手动补录

```pseudo
user opens ManualEntryTab
form validates entryDate and exitDate
preview = StayStatisticsService.previewStayDays(form)
record = StayRecord.fromManualForm(form, confirmed = true)
repository.saveRecord(record)
AppShell.reloadRecords()
show RecordsTab
```

### 自动检测候选记录

```pseudo
native geofence wakes app
location = getCurrentLocation()
classification = boundary.classify(location)

if classification is NEAR_BOUNDARY or accuracy is low:
  create candidate record(status = NEEDS_CONFIRMATION)
else if presence changed:
  create candidate record(status = NEEDS_CONFIRMATION)

user confirms or edits candidate in RecordsTab
confirmed records enter statistics
```

### 年度统计

```pseudo
records = repository.listRecords()
confirmed = records.exclude(status = REJECTED)
dates = enumerateInclusiveHkDates(confirmed)
deduped = Set(dates)
summary = groupByYearAndMonth(deduped)
```

## 开发顺序建议

1. 继续稳定手动记录、统计和记录管理。
2. 完善候选记录确认、修正和忽略流程。
3. 完成 iOS / Android 原生地理围栏真实实现。
4. 用真机验证后台定位、权限、系统唤醒和低电量行为。
5. 增加更完整的隐私文案和上架材料。

## 文档约定

每个长期维护的目录应放置一个 `README.md`，说明：

- 这个目录负责什么。
- 不应该放什么。
- 与其他模块如何交互。
- 有必要时提供核心伪代码。
