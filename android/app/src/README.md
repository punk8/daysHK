# android/app/src

## 职责

按 Android 构建变体组织源码。

常见子目录：

- `main/`：正式应用源码和 Manifest。
- `debug/`：调试构建专用 Manifest 或配置。
- `profile/`：性能分析构建专用配置。

## 规则

```pseudo
buildVariant = debug | profile | release
mergedManifest = merge(src/main, src/buildVariant)
compileResources(mergedManifest, res)
```

业务能力默认放在 `main/`，只有调试或性能分析专用配置才放进 `debug/` / `profile/`。

