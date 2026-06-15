# lib/location/boundary

## 职责

根据 GPS 坐标判断用户是否在香港范围内。

## 输入

- longitude
- latitude
- accuracyMeters

## 输出

```pseudo
enum BoundaryClassification:
  INSIDE_HK
  OUTSIDE_HK
  NEAR_BOUNDARY_NEEDS_CONFIRMATION
  UNKNOWN
```

## 伪代码

```pseudo
function classify(lon, lat, accuracyMeters):
  if not bbox.contains(lon, lat):
    return OUTSIDE_HK

  inside = pointInMultiPolygon(lon, lat, hkBoundary)
  distance = distanceToBoundary(lon, lat, hkBoundary)

  if distance <= max(accuracyMeters, 100):
    return NEAR_BOUNDARY_NEEDS_CONFIRMATION

  return inside ? INSIDE_HK : OUTSIDE_HK
```

