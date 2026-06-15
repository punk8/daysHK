# assets/geo

## 职责

存放香港边界判断所需的离线地理数据。

MVP 推荐数据源：

- DATA.GOV.HK / 民政及青年事务局 District boundary
- 数据页面：https://data.gov.hk/en-data/dataset/hk-had-json1-hong-kong-administrative-boundaries
- JSON 文件：https://www.had.gov.hk/psi/hong-kong-administrative-boundaries/hksar_18_district_boundary.json

## 预期产物

后续可生成：

- `hk_boundary.source.json`：原始下载文件，不直接给运行时使用。
- `hk_boundary.compact.geojson`：合并、修复、简化后的 MultiPolygon。
- `hk_boundary.meta.json`：来源、下载日期、许可、处理脚本版本。

## 核心处理伪代码

```pseudo
raw = download(HAD_18_DISTRICT_BOUNDARY_JSON)
features = parseGeoJson(raw)
districtPolygons = extractPolygons(features)
hkPolygon = union(districtPolygons)
hkPolygon = fixInvalidGeometry(hkPolygon)
hkPolygon = simplify(hkPolygon, tolerance = safeSmallTolerance)
writeGeoJson("hk_boundary.compact.geojson", hkPolygon)
writeMeta(sourceUrl, downloadedAt, license, processingVersion)
```

## 运行时判断伪代码

```pseudo
function classifyCoordinate(lon, lat, accuracyMeters):
  if not inHongKongBoundingBox(lon, lat):
    return OUTSIDE

  distance = distanceToBoundary(lon, lat)
  if distance <= max(accuracyMeters, 100):
    return NEAR_BOUNDARY_REQUIRES_CONFIRMATION

  if pointInPolygon(lon, lat, hkBoundary):
    return INSIDE_HK

  return OUTSIDE
```

