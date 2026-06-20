# lib/core/validation

## 职责

提供通用校验结果类型，供表单和记录保存使用。

## 建议类型

```pseudo
class ValidationResult:
  bool isValid
  List<ValidationIssue> issues

class ValidationIssue:
  String code
  String message
  Severity severity
```

## 常见错误

- 离港日期早于入港日期。
- 记录与现有记录重叠。
- 日期为空。
- 备注超出长度限制。
