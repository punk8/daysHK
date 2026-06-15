# tools/geo

## 职责

处理香港边界数据。

## 建议脚本

- `download_had_boundary.dart` 或 `download_had_boundary.js`
- `build_hk_multipolygon.dart` 或 `build_hk_multipolygon.js`
- `validate_boundary.dart` 或 `validate_boundary.js`

## 构建伪代码

```pseudo
download source json
parse features
union 18 district polygons
fix invalid geometry
simplify geometry for mobile runtime
write assets/geo/hk_boundary.compact.geojson
write assets/geo/hk_boundary.meta.json
```

## QA 坐标建议

- 香港国际机场。
- 中环。
- 落马洲。
- 深圳湾口岸附近。
- 港珠澳大桥香港口岸。
- 深圳市区。
- 澳门。

