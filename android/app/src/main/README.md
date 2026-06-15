# android/app/src/main

## 职责

Android 主源码集，存放发布版本会使用的 Manifest、Kotlin 代码和资源。

## 模块内容

- `AndroidManifest.xml`：权限、Activity、Receiver、Service 声明。
- `kotlin/`：Kotlin 原生桥接代码。
- `res/`：Android 资源。

## 后台检测流程伪代码

```pseudo
Flutter SettingsPage calls nativeGeofence.startMonitoring()
MethodChannel receives "startMonitoring"
MainActivity checks permission and location service
Android registers geofence PendingIntent
System later sends enter/exit broadcast
Receiver persists last event
Flutter reads getStatus and displays event
```

