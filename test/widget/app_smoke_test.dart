import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:days_in_hk/app/app.dart';
import 'package:days_in_hk/app/bootstrap.dart';
import 'package:days_in_hk/data/repositories/stay_record_repository.dart';
import 'package:days_in_hk/domain/models/stay_record.dart';
import 'package:days_in_hk/location/boundary/hk_boundary_service.dart';
import 'package:days_in_hk/location/geofence/location_detection_service.dart';
import 'package:days_in_hk/location/geofence/native_geofence_bridge.dart';
import 'package:days_in_hk/location/permissions/location_permission_service.dart';
import 'package:days_in_hk/features/records/records_page.dart';
import 'package:days_in_hk/features/statistics/statistics_page.dart';
import 'package:days_in_hk/domain/services/stay_statistics_service.dart';
import 'package:days_in_hk/features/dashboard/dashboard_page.dart';

class MemoryRepository implements StayRecordRepository {
  MemoryRepository(this.records);

  final List<StayRecord> records;

  @override
  Future<void> clearAll() async => records.clear();

  @override
  Future<void> deleteRecord(String id) async {
    records.removeWhere((record) => record.id == id);
  }

  @override
  Future<List<StayRecord>> listRecords() async => records;

  @override
  Future<void> saveRecord(StayRecord record) async {
    records.removeWhere((existing) => existing.id == record.id);
    records.add(record);
  }
}

void main() {
  testWidgets('App shows dashboard and manual entry tab', (tester) async {
    await tester.pumpWidget(
      DaysInHkApp(
        dependencies: AppDependencies(
          records: MemoryRepository([]),
          boundary: boundary,
          locationDetection: LocationDetectionService(boundary),
          locationPermission: LocationPermissionService(),
          nativeGeofence: const NativeGeofenceBridge(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('在港日记'), findsOneWidget);
    expect(find.text('今年估算在港天数'), findsOneWidget);

    await tester.tap(find.text('补录'));
    await tester.pumpAndSettle();

    expect(find.text('手动补录'), findsOneWidget);
    expect(find.text('入港日期'), findsOneWidget);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.text('保存记录'), findsOneWidget);
  });

  testWidgets('Records page can open edit dialog', (tester) async {
    final now = DateTime(2026, 6, 15);
    final records = [
      StayRecord(
        id: 'record-1',
        entryDate: DateTime(2025, 5, 25),
        exitDate: DateTime(2025, 5, 25),
        sameDayRoundTrip: true,
        locationName: '香港国际机场',
        transportMode: '飞机',
        note: '测试备注',
        source: RecordSource.manual,
        confirmationStatus: ConfirmationStatus.confirmed,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RecordsPage(
            records: records,
            onSave: (_) async {},
            onDelete: (_) async {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('编辑 / 修正'));
    await tester.pumpAndSettle();

    expect(find.text('编辑记录'), findsOneWidget);
    expect(find.text('口岸 / 地点'), findsOneWidget);
    final locationField = tester.widget<TextField>(
      find.byKey(const Key('record-edit-location-field')),
    );
    expect(locationField.controller?.text, '香港国际机场');
  });

  testWidgets('Statistics page includes years from existing records', (
    tester,
  ) async {
    final now = DateTime(2026, 6, 16);
    final records = [
      StayRecord(
        id: 'future-record',
        entryDate: DateTime(2027, 1, 10),
        exitDate: DateTime(2027, 1, 10),
        sameDayRoundTrip: true,
        source: RecordSource.manual,
        confirmationStatus: ConfirmationStatus.confirmed,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatisticsPage(
            records: records,
            statisticsService: StayStatisticsService(),
            today: now,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('2027年'), findsOneWidget);
    expect(find.text('2026年'), findsOneWidget);
  });

  testWidgets('Dashboard current status ignores future records', (
    tester,
  ) async {
    final now = DateTime(2026, 6, 16);
    final records = [
      StayRecord(
        id: 'future-record',
        entryDate: DateTime(2027, 1, 10),
        exitDate: DateTime(2027, 1, 10),
        sameDayRoundTrip: true,
        source: RecordSource.manual,
        confirmationStatus: ConfirmationStatus.confirmed,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DashboardPage(
            records: records,
            statisticsService: StayStatisticsService(),
            today: now,
            onManualEntry: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('当前不在香港'), findsOneWidget);
    expect(find.text('暂无入港记录'), findsWidgets);
    expect(find.text('最近离港 2027-01-10'), findsNothing);
  });
}

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
