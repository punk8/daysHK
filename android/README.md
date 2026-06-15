# android

## 职责

Android 原生工程目录，负责 Flutter 无法完全覆盖的系统能力：

- 定位权限声明。
- 后台定位和前台服务权限。
- Geofencing API 接入。
- Kotlin Platform Channel：`days_in_hk/geofence`。
- Android 构建、签名、应用包名和资源配置。

## 当前边界

Dart 侧负责业务模型、天数统计、记录确认和 UI。Android 原生侧只负责把系统地理围栏事件转换为可解释的原生事件，不能在这里实现“在港天数”规则。

## Geofence 伪代码

```pseudo
onStartMonitoring():
  if missingLocationPermission:
    return status("unavailable", "需要定位权限")

  geofence = Geofence(
    requestId = "hk_boundary_wakeup",
    center = approximateHongKongCenter,
    radius = wakeupRadiusMeters,
    transitions = ENTER | EXIT
  )
  geofencingClient.addGeofences(geofence, pendingIntent)
  return status("running")

onGeofenceBroadcast(intent):
  transition = parseTransition(intent)
  saveLastNativeEvent(transition, detectedAt)
  notifyFlutterWhenAppIsAlive()
```

## 不放在这里

- 页面 UI。
- SQLite 业务 schema。
- 在港天数计算口径。
- 用户可见的法律或永居资格判断。

