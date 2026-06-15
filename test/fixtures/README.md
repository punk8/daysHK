# test/fixtures

## 职责

存放测试用固定记录和预期统计结果。

## 建议 fixture

```pseudo
case_same_day_round_trip:
  entryDate = 2025-06-01
  exitDate = 2025-06-01
  expectedStayDays = 1

case_multi_day:
  entryDate = 2025-06-01
  exitDate = 2025-06-03
  expectedStayDays = 3

case_cross_year:
  entryDate = 2025-12-31
  exitDate = 2026-01-02
  expected:
    2025 = 1
    2026 = 2
```

