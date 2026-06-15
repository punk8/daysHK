# android/app/src/main/kotlin

## 职责

Android Kotlin 源码根目录。

当前用于承载 Flutter 原生桥接代码，后续可以扩展：

- `MainActivity.kt`：MethodChannel 注册和状态查询。
- `GeofenceBroadcastReceiver.kt`：接收系统地理围栏 enter / exit 事件。
- `NativeGeofenceStore.kt`：保存最近一次原生地理围栏事件。

## 伪代码

```pseudo
MethodChannel("days_in_hk/geofence"):
  getStatus -> return current native status
  startMonitoring -> register Android geofence
  stopMonitoring -> remove Android geofence
```

