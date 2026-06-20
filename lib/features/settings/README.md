# lib/features/settings

## 职责

实现设置与隐私页面。

## 页面内容

- 定位权限状态。
- 本地数据存储说明。
- 清除所有数据。
- 隐私说明。
- 使用条款。
- 关于 App 和版本号。

## 清除数据伪代码

```pseudo
function clearAllData():
  confirmed = showConfirmDialog(
    title = "清除所有数据",
    message = "将删除本地所有入离港记录，无法恢复。"
  )
  if confirmed:
    repository.clearAll()
```

## 文案要求

- 明确数据默认保存在本地设备。
- 不暗示云端保存或多设备同步。
- 权限说明要解释为什么需要定位。
