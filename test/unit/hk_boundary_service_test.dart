import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:days_in_hk/location/boundary/boundary_classification.dart';
import 'package:days_in_hk/location/boundary/hk_boundary_service.dart';

void main() {
  late HkBoundaryService service;

  setUpAll(() {
    final raw = File(
      'assets/geo/hksar_18_district_boundary.json',
    ).readAsStringSync();
    service = HkBoundaryService.fromGeoJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  });

  test('中环坐标判断为在香港', () {
    final result = service.classify(longitude: 114.1588, latitude: 22.2819);
    expect(result.classification, BoundaryClassification.insideHk);
  });

  test('香港国际机场坐标判断为在香港', () {
    final result = service.classify(longitude: 113.9185, latitude: 22.3080);
    expect(result.classification, BoundaryClassification.insideHk);
  });

  test('深圳市区坐标判断为不在香港', () {
    final result = service.classify(longitude: 114.0579, latitude: 22.5431);
    expect(result.classification, BoundaryClassification.outsideHk);
  });

  test('澳门坐标判断为不在香港', () {
    final result = service.classify(longitude: 113.5439, latitude: 22.1987);
    expect(result.classification, BoundaryClassification.outsideHk);
  });

  test('低精度定位在香港内也会标记为需要确认', () {
    final result = service.classify(
      longitude: 114.1588,
      latitude: 22.2819,
      accuracyMeters: 10000,
    );
    expect(
      result.classification,
      BoundaryClassification.nearBoundaryNeedsConfirmation,
    );
  });
}
