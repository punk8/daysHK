# lib/location/permissions

## 职责

管理定位权限和权限健康状态展示。

## 需要识别

- 未请求定位权限。
- 拒绝定位权限。
- 仅使用期间允许。
- 始终允许。
- 后台刷新关闭。
- 省电模式可能影响后台检测。

## 展示伪代码

```pseudo
function describePermission(status):
  if status.alwaysAllowed:
    return PermissionCard(ok, "定位记录已准备就绪")

  if status.whenInUseOnly:
    return PermissionCard(warning, "后台自动记录可能受影响")

  if status.denied:
    return PermissionCard(actionRequired, "需要开启定位权限")
```

