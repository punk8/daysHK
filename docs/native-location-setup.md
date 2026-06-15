# 原生定位配置说明

更新时间：2026-06-15

## 当前目标

为 iOS / Android 自动入离港候选记录打基础。原生层负责低功耗唤醒和最近事件回传，Dart 层负责香港边界判断、候选记录生成、用户确认和在港天数统计。

## 当前已经完成

- Flutter 前台定位依赖接入：`geolocator`
- 前台定位权限检查入口
- 前台当前位置检测入口
- 坐标检测与香港边界判断
- 自动生成“需要确认”的候选记录
- iOS 定位权限声明
- iOS 后台定位模式声明
- Android 前台 / 后台定位权限声明
- Flutter MethodChannel：`days_in_hk/geofence`
- iOS Core Location region monitoring 注册路径
- Android Google Play Services Geofencing API 注册路径
- 原生最近事件 `lastEvent` 回传
- 设置页后台自动检测状态卡片

## iOS 配置

文件：

- `ios/Runner/Info.plist`
- `ios/Runner/AppDelegate.swift`

已加入：

- `NSLocationWhenInUseUsageDescription`
- `NSLocationAlwaysAndWhenInUseUsageDescription`
- `NSLocationAlwaysUsageDescription`
- `UIBackgroundModes = location`

当前权限文案：

- 使用期间定位：用于检测你是否在香港附近，并生成可确认的入离港候选记录。
- 始终允许定位：用于在后台辅助检测进入或离开香港，并生成可确认的入离港候选记录。

当前原生实现：

- `AppDelegate.swift` 持有 `CLLocationManager`。
- `startMonitoring` 会检查定位服务、region monitoring 支持和“始终允许”权限。
- 使用 `CLCircularRegion` 注册香港附近唤醒区域：
  - center: `22.3193, 114.1694`
  - radius: `min(50000, maximumRegionMonitoringDistance)`
  - transitions: enter / exit
- `didEnterRegion` / `didExitRegion` 会把最近事件写入 `UserDefaults`。
- `getStatus` 会返回当前状态和最近原生事件。
- 为兼容低于 iOS 14 的 deployment target，权限读取通过 helper 在 iOS 14+ 使用实例属性，在更低版本使用 `CLLocationManager.authorizationStatus()`。

## Android 配置

文件：

- `android/app/src/main/AndroidManifest.xml`
- `android/app/build.gradle.kts`
- `android/app/src/main/kotlin/com/example/days_in_hk/MainActivity.kt`
- `android/app/src/main/kotlin/com/example/days_in_hk/GeofenceBroadcastReceiver.kt`
- `android/app/src/main/kotlin/com/example/days_in_hk/NativeGeofenceStore.kt`

已加入：

- `ACCESS_COARSE_LOCATION`
- `ACCESS_FINE_LOCATION`
- `ACCESS_BACKGROUND_LOCATION`
- `FOREGROUND_SERVICE`
- `FOREGROUND_SERVICE_LOCATION`
- `com.google.android.gms:play-services-location:21.3.0`

当前原生实现：

- `MainActivity.kt` 使用 `LocationServices.getGeofencingClient(this)`。
- `startMonitoring` 会检查定位服务、前台定位权限和 Android 10+ 后台定位权限。
- 使用 Google Play Services `Geofence` 注册香港附近唤醒区域：
  - center: `22.3193, 114.1694`
  - radius: `50000m`
  - transitions: enter / exit
  - initial trigger: enter
- `GeofenceBroadcastReceiver.kt` 接收系统 geofence broadcast。
- `NativeGeofenceStore.kt` 使用 `SharedPreferences` 保存 monitoring 状态和最近事件。
- `getStatus` 会返回当前状态和最近原生事件。

## 当前仍需真机验证

- iOS Core Location region monitoring 的真实后台触发稳定性。
- Android Geofencing API 的真实后台触发稳定性。
- Android 前台服务是否需要为长期后台健康状态补强。
- App 被用户强制关闭后的恢复策略。
- 真机跨口岸 / 机场 / 高铁 / 边界区域测试。
- 省电模式、后台刷新关闭、厂商后台限制下的行为。
- App Store / Google Play 后台定位审核材料。

## 验收建议

当前可验证：

- Web / Browser：模拟坐标检测生成候选记录。
- iOS 模拟器：权限文案是否出现，前台定位是否可调用。
- Android 模拟器：权限弹窗和前台定位调用。
- iOS 编译：`flutter build ios --no-codesign`。
- Android 编译：`flutter build apk --debug`。
- iOS / Android 真机：`startMonitoring` 后系统是否注册 region / geofence，并在进入或离开唤醒区域后更新 `lastEvent`。

后续必须验证：

- iPhone 真机进入 / 离开香港附近 geofence 的触发稳定性。
- Android 真机不同品牌后台触发稳定性。
- 省电模式、后台刷新关闭、用户强制结束 App 后的行为。

## MethodChannel 约定

Channel：

```text
days_in_hk/geofence
```

Methods：

- `getStatus`
- `startMonitoring`
- `stopMonitoring`

返回结构：

```json
{
  "status": "ready | running | stopped | unsupported | unavailable",
  "message": "用户可读状态说明",
  "lastEvent": {
    "transition": "enter | exit | unknown",
    "detectedAt": "ISO8601 timestamp",
    "source": "ios_region_monitoring | android_geofencing_api",
    "latitude": 22.3193,
    "longitude": 114.1694,
    "accuracyMeters": 1000
  }
}
```

当前状态：

- Web：返回 `unsupported`。
- iOS：通道已注册，`startMonitoring` / `stopMonitoring` 管理 Core Location region monitoring。
- Android：通道已注册，`startMonitoring` / `stopMonitoring` 管理 Google Play Services Geofencing API。

注意：原生注册路径已实现，但后台 geofence 是否稳定仍必须通过真机验证。Web 和模拟器验收不能替代跨口岸、后台、省电模式和强杀 App 等真实场景。
