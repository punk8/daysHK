# tools/qa

## 职责

存放验收和测试辅助脚本。

## 建议工具

- 生成模拟入离港记录。
- 校验 CSV 导出字段。
- 对比 App 统计结果和 fixture 预期。
- 生成验收报告。

## 伪代码

```pseudo
function generateSampleRecords():
  return [
    record("2025-06-01", "2025-06-03"),
    record("2025-12-31", "2026-01-02"),
    record("2026-05-25", null)
  ]
```

