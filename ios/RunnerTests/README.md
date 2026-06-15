# ios/RunnerTests

## 职责

iOS 原生测试目录。

后续适合补充：

- 原生 geofence bridge 的状态序列测试。
- 权限状态映射测试。
- last event 持久化测试。

## 伪代码

```pseudo
testStartMonitoringWithoutLocationService():
  fakeLocationServicesEnabled(false)
  result = bridge.startMonitoring()
  expect(result.status == "unavailable")

testLastEventPayload():
  store.save(event = enter)
  expect(bridge.getStatus().lastEvent.transition == "enter")
```

