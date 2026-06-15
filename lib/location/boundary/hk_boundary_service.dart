import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/services.dart';

import 'boundary_classification.dart';

class Coordinate {
  const Coordinate(this.longitude, this.latitude);

  final double longitude;
  final double latitude;
}

class Ring {
  const Ring(this.points);

  final List<Coordinate> points;
}

class PolygonGeometry {
  const PolygonGeometry(this.rings);

  final List<Ring> rings;
}

class HkBoundaryService {
  HkBoundaryService._(this._polygons);

  final List<PolygonGeometry> _polygons;

  static const assetPath = 'assets/geo/hksar_18_district_boundary.json';
  static const minLon = 113.8;
  static const maxLon = 114.6;
  static const minLat = 22.1;
  static const maxLat = 22.6;

  static Future<HkBoundaryService> loadFromAsset() async {
    final raw = await rootBundle.loadString(assetPath);
    return fromGeoJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  static HkBoundaryService fromGeoJson(Map<String, dynamic> geoJson) {
    final polygons = <PolygonGeometry>[];
    final features = geoJson['features'] as List<dynamic>;
    for (final feature in features.cast<Map<String, dynamic>>()) {
      final geometry = feature['geometry'] as Map<String, dynamic>;
      final type = geometry['type'] as String;
      final coordinates = geometry['coordinates'] as List<dynamic>;
      if (type == 'Polygon') {
        polygons.add(_parsePolygon(coordinates));
      } else if (type == 'MultiPolygon') {
        for (final polygon in coordinates) {
          polygons.add(_parsePolygon(polygon as List<dynamic>));
        }
      }
    }
    return HkBoundaryService._(polygons);
  }

  BoundaryResult classify({
    required double longitude,
    required double latitude,
    double accuracyMeters = 0,
    double boundaryToleranceMeters = 100,
  }) {
    if (!_inBoundingBox(longitude, latitude)) {
      return const BoundaryResult(
        classification: BoundaryClassification.outsideHk,
      );
    }

    final point = Coordinate(longitude, latitude);
    final inside = _contains(point);
    final distance = _distanceToBoundaryMeters(point);
    final tolerance = math.max(accuracyMeters, boundaryToleranceMeters);

    if (distance != null && distance <= tolerance) {
      return BoundaryResult(
        classification: BoundaryClassification.nearBoundaryNeedsConfirmation,
        distanceToBoundaryMeters: distance,
      );
    }

    return BoundaryResult(
      classification: inside
          ? BoundaryClassification.insideHk
          : BoundaryClassification.outsideHk,
      distanceToBoundaryMeters: distance,
    );
  }

  bool _inBoundingBox(double longitude, double latitude) {
    return longitude >= minLon &&
        longitude <= maxLon &&
        latitude >= minLat &&
        latitude <= maxLat;
  }

  bool _contains(Coordinate point) {
    for (final polygon in _polygons) {
      if (_polygonContains(polygon, point)) {
        return true;
      }
    }
    return false;
  }

  bool _polygonContains(PolygonGeometry polygon, Coordinate point) {
    if (polygon.rings.isEmpty || !_ringContains(polygon.rings.first, point)) {
      return false;
    }
    for (final hole in polygon.rings.skip(1)) {
      if (_ringContains(hole, point)) {
        return false;
      }
    }
    return true;
  }

  bool _ringContains(Ring ring, Coordinate point) {
    var inside = false;
    final points = ring.points;
    if (points.length < 3) {
      return false;
    }

    for (var i = 0, j = points.length - 1; i < points.length; j = i++) {
      final pi = points[i];
      final pj = points[j];
      final intersects =
          ((pi.latitude > point.latitude) != (pj.latitude > point.latitude)) &&
          (point.longitude <
              (pj.longitude - pi.longitude) *
                      (point.latitude - pi.latitude) /
                      (pj.latitude - pi.latitude) +
                  pi.longitude);
      if (intersects) {
        inside = !inside;
      }
    }
    return inside;
  }

  double? _distanceToBoundaryMeters(Coordinate point) {
    double? best;
    for (final polygon in _polygons) {
      for (final ring in polygon.rings) {
        final points = ring.points;
        for (var index = 0; index < points.length - 1; index++) {
          final distance = _distanceToSegmentMeters(
            point,
            points[index],
            points[index + 1],
          );
          if (best == null || distance < best) {
            best = distance;
          }
        }
      }
    }
    return best;
  }

  static PolygonGeometry _parsePolygon(List<dynamic> ringsJson) {
    final rings = <Ring>[];
    for (final ringJson in ringsJson) {
      final points = <Coordinate>[];
      for (final pointJson in (ringJson as List<dynamic>)) {
        final pair = pointJson as List<dynamic>;
        points.add(
          Coordinate((pair[0] as num).toDouble(), (pair[1] as num).toDouble()),
        );
      }
      rings.add(Ring(points));
    }
    return PolygonGeometry(rings);
  }

  static double _distanceToSegmentMeters(
    Coordinate point,
    Coordinate start,
    Coordinate end,
  ) {
    const metersPerDegreeLat = 111320.0;
    final latRadians = point.latitude * math.pi / 180;
    final metersPerDegreeLon = metersPerDegreeLat * math.cos(latRadians);

    final px = point.longitude * metersPerDegreeLon;
    final py = point.latitude * metersPerDegreeLat;
    final ax = start.longitude * metersPerDegreeLon;
    final ay = start.latitude * metersPerDegreeLat;
    final bx = end.longitude * metersPerDegreeLon;
    final by = end.latitude * metersPerDegreeLat;

    final dx = bx - ax;
    final dy = by - ay;
    if (dx == 0 && dy == 0) {
      return math.sqrt(math.pow(px - ax, 2) + math.pow(py - ay, 2));
    }

    final t = (((px - ax) * dx + (py - ay) * dy) / (dx * dx + dy * dy)).clamp(
      0.0,
      1.0,
    );
    final closestX = ax + t * dx;
    final closestY = ay + t * dy;
    return math.sqrt(math.pow(px - closestX, 2) + math.pow(py - closestY, 2));
  }
}
