# test/integration

## 职责

端到端验收测试，包括 Codex 内置 Browser / Computer Use 验证流程。

## Web 验收流程伪代码

```pseudo
openApp()
assertDashboardVisible()

tapManualEntry()
fillEntryDate("2025-06-01")
fillExitDate("2025-06-03")
tapSave()

assertDashboardStayDays(3)
tapRecords()
assertTimelineContains("2025年6月1日")

tapStatistics()
assertAnnualStayDays(2025, 3)
```

## 注意事项

Web 验收不能替代 iOS / Android 真机上的后台定位、系统权限和原生存储验证。

