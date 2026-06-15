# ios

## 职责

iOS 原生工程目录，负责 Flutter 无法完全覆盖的系统能力：

- Core Location 权限说明。
- 后台定位模式配置。
- Region Monitoring 接入。
- Swift Platform Channel：`days_in_hk/geofence`。
- Xcode 工程、签名、Bundle ID 和 iOS 资源。

## Region Monitoring 伪代码

```pseudo
onStartMonitoring():
  if locationServicesDisabled:
    return status("unavailable")

  requestAlwaysAuthorizationIfNeeded()
  region = CLCircularRegion(
    center = approximateHongKongCenter,
    radius = safeWakeupRadius,
    identifier = "hk_boundary_wakeup"
  )
  region.notifyOnEntry = true
  region.notifyOnExit = true
  locationManager.startMonitoring(for = region)
  return status("running")

locationManager.didEnterRegion(region):
  saveLastNativeEvent("enter", detectedAt)

locationManager.didExitRegion(region):
  saveLastNativeEvent("exit", detectedAt)
```

## 注意事项

- iOS 后台定位和 region monitoring 必须真机验证。
- Xcode 缺少目标 iOS Platform 时，本机 iOS build 会失败，需要先安装对应组件。
- 原生层只负责系统事件，不负责在港天数计算。

