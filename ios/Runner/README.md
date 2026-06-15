# ios/Runner

## 职责

iOS App 主 target 源码目录。

关键文件：

- `AppDelegate.swift`：注册 Flutter 插件和原生地理围栏 MethodChannel。
- `SceneDelegate.swift`：iOS scene 生命周期。
- `Info.plist`：定位权限文案、后台模式和 App 配置。
- `Assets.xcassets/`：App 图标和启动图资源。
- `Base.lproj/`：Storyboard 和启动屏。

## 原生桥接伪代码

```pseudo
Flutter calls MethodChannel("days_in_hk/geofence")

getStatus:
  return locationServices + monitoringState + lastEvent

startMonitoring:
  configure CLLocationManager
  request always location permission if needed
  start CLCircularRegion monitoring

stopMonitoring:
  stop monitored regions owned by this app
```

## 注意事项

- 定位权限文案必须清楚说明“用于自动记录入港 / 离港候选事件”。
- 后台检测结果应作为候选记录，允许用户确认、修正或忽略。

