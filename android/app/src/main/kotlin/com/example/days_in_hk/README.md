# android/app/src/main/kotlin/com/example/days_in_hk

## 职责

Android 端应用包代码。这里是 Flutter 与 Android 系统定位能力之间的桥。

## 当前文件

- `MainActivity.kt`：注册 `days_in_hk/geofence` MethodChannel，返回原生后台检测状态。

## 后续建议文件

- `GeofenceBroadcastReceiver.kt`
- `NativeGeofenceStore.kt`
- `PermissionStatusMapper.kt`

## 事件载荷伪代码

```pseudo
NativeGeofenceEvent:
  transition = "enter" | "exit"
  detectedAt = ISO8601 timestamp
  latitude? = optional
  longitude? = optional
  accuracyMeters? = optional
  source = "android_geofencing_api"

statusPayload():
  return {
    "status": "running",
    "message": "...",
    "lastEvent": NativeGeofenceEvent?
  }
```

## 注意事项

Android 原生事件只能说明系统检测到进入或离开某个唤醒区域，最终是否生成在港记录仍由 Dart 的边界判断和用户确认流程决定。

