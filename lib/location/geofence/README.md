# lib/location/geofence

## 职责

后续接入 iOS / Android 地理围栏和后台定位。

MVP 可以先保留接口和伪实现，待真机验证后再完善。

## 事件处理伪代码

```pseudo
function onGeofenceEvent(event):
  currentLocation = locationProvider.getCurrentLocation()
  classification = boundaryService.classify(
    currentLocation.lon,
    currentLocation.lat,
    currentLocation.accuracy
  )

  if classification == NEAR_BOUNDARY_NEEDS_CONFIRMATION:
    createCandidateRecord(status = NEEDS_CONFIRMATION)
    return

  transition = presenceStateMachine.handle(classification)
  if transition.changed:
    createCandidateRecordFromTransition(transition)
```

## 注意事项

- 不要因为一次低精度定位直接写入不可修正正式记录。
- iOS / Android 的后台行为必须通过真机验证。

