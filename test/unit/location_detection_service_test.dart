import 'package:flutter_test/flutter_test.dart';
import 'package:days_in_hk/domain/models/stay_record.dart';
import 'package:days_in_hk/location/geofence/location_detection_service.dart';
import 'package:days_in_hk/location/geofence/native_geofence_bridge.dart';
import 'package:days_in_hk/location/boundary/hk_boundary_service.dart';

void main() {
  final boundary = HkBoundaryService.fromGeoJson(const {
    'type': 'FeatureCollection',
    'features': [
      {
        'type': 'Feature',
        'geometry': {
          'type': 'Polygon',
          'coordinates': [
            [
              [113.8, 22.1],
              [114.6, 22.1],
              [114.6, 22.6],
              [113.8, 22.6],
              [113.8, 22.1],
            ],
          ],
        },
      },
    ],
  });
  final service = LocationDetectionService(boundary);
  final now = DateTime(2026, 6, 15, 10);

  StayRecord currentStay() {
    return StayRecord(
      id: 'current',
      entryDate: DateTime(2026, 6, 10),
      exitDate: null,
      sameDayRoundTrip: false,
      source: RecordSource.manual,
      confirmationStatus: ConfirmationStatus.confirmed,
      createdAt: now,
      updatedAt: now,
    );
  }

  test('在香港且无当前记录时生成入港候选记录', () {
    final result = service.detectCoordinate(
      existingRecords: const [],
      longitude: 114.1588,
      latitude: 22.2819,
      accuracyMeters: 15,
      now: now,
    );
    expect(result.candidateRecord, isNotNull);
    expect(result.candidateRecord!.entryDate, DateTime(2026, 6, 15));
    expect(result.candidateRecord!.exitDate, isNull);
    expect(
      result.candidateRecord!.confirmationStatus,
      ConfirmationStatus.needsConfirmation,
    );
  });

  test('离港且当前在港时生成离港候选记录', () {
    final result = service.detectCoordinate(
      existingRecords: [currentStay()],
      longitude: 115.0,
      latitude: 22.3,
      accuracyMeters: 15,
      now: now,
    );
    expect(result.candidateRecord, isNotNull);
    expect(result.candidateRecord!.entryDate, DateTime(2026, 6, 10));
    expect(result.candidateRecord!.exitDate, DateTime(2026, 6, 15));
  });

  test('低精度定位生成需要确认候选记录', () {
    final result = service.detectCoordinate(
      existingRecords: const [],
      longitude: 114.1588,
      latitude: 22.2819,
      accuracyMeters: 50000,
      now: now,
    );
    expect(result.candidateRecord, isNotNull);
    expect(result.candidateRecord!.sameDayRoundTrip, isTrue);
    expect(result.candidateRecord!.note, contains('需要确认'));
  });

  test('原生 geofence 状态支持解析最近事件', () {
    final state = NativeGeofenceState.fromMap({
      'status': 'running',
      'message': '后台检测运行中',
      'lastEvent': {
        'transition': 'enter',
        'detectedAt': '2026-06-15T09:30:00.000Z',
        'source': 'ios_region_monitoring',
        'latitude': 22.3193,
        'longitude': 114.1694,
        'accuracyMeters': 1000,
      },
    });

    expect(state.status, NativeGeofenceStatus.running);
    expect(state.lastEvent, isNotNull);
    expect(state.lastEvent!.transition, NativeGeofenceTransition.enter);
    expect(state.lastEvent!.source, 'ios_region_monitoring');
    expect(state.lastEvent!.latitude, 22.3193);
  });
}
