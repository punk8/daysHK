import 'package:flutter_test/flutter_test.dart';
import 'package:days_in_hk/domain/models/stay_record.dart';
import 'package:days_in_hk/domain/services/stay_statistics_service.dart';

void main() {
  final service = StayStatisticsService();
  final today = DateTime(2026, 6, 15);

  StayRecord record({
    required String id,
    required DateTime entry,
    DateTime? exit,
    ConfirmationStatus status = ConfirmationStatus.confirmed,
  }) {
    final now = DateTime(2026, 1, 1);
    return StayRecord(
      id: id,
      entryDate: entry,
      exitDate: exit,
      sameDayRoundTrip:
          exit != null &&
          entry.year == exit.year &&
          entry.month == exit.month &&
          entry.day == exit.day,
      source: RecordSource.manual,
      confirmationStatus: status,
      createdAt: now,
      updatedAt: now,
    );
  }

  test('6月1日到6月3日计3天', () {
    final days = service.stayDaysForRecord(
      record(id: '1', entry: DateTime(2025, 6, 1), exit: DateTime(2025, 6, 3)),
      today,
    );
    expect(days, 3);
  });

  test('当天往返计1天', () {
    final days = service.stayDaysForRecord(
      record(id: '1', entry: DateTime(2025, 6, 1), exit: DateTime(2025, 6, 1)),
      today,
    );
    expect(days, 1);
  });

  test('同一天多次入离港去重', () {
    final keys = service.stayDateKeys([
      record(id: '1', entry: DateTime(2025, 6, 1), exit: DateTime(2025, 6, 1)),
      record(id: '2', entry: DateTime(2025, 6, 1), exit: DateTime(2025, 6, 1)),
    ], today);
    expect(keys.length, 1);
  });

  test('跨年拆分到对应年份', () {
    final records = [
      record(
        id: '1',
        entry: DateTime(2025, 12, 31),
        exit: DateTime(2026, 1, 2),
      ),
    ];
    final summary2025 = service.buildAnnualSummary(
      records: records,
      year: 2025,
      today: today,
    );
    final summary2026 = service.buildAnnualSummary(
      records: records,
      year: 2026,
      today: today,
    );
    expect(summary2025.estimatedStayDays, 1);
    expect(summary2026.estimatedStayDays, 2);
  });

  test('离港日期早于入港日期校验失败', () {
    final error = service.validateRecord(
      record(id: '1', entry: DateTime(2025, 6, 3), exit: DateTime(2025, 6, 1)),
      const [],
      today,
    );
    expect(error, contains('离港日期不能早于入港日期'));
  });

  test('重叠记录给出提示', () {
    final existing = [
      record(id: '1', entry: DateTime(2025, 6, 1), exit: DateTime(2025, 6, 3)),
    ];
    final error = service.validateRecord(
      record(id: '2', entry: DateTime(2025, 6, 3), exit: DateTime(2025, 6, 4)),
      existing,
      today,
    );
    expect(error, contains('重叠'));
    expect(error, contains('2025-06-01 至 2025-06-03'));
    expect(error, contains('手动补录 / 已确认'));
  });

  test('进行中记录按今天作为重叠结束日期并说明仍在香港', () {
    final existing = [record(id: '1', entry: DateTime(2025, 6, 1))];
    final error = service.validateRecord(
      record(id: '2', entry: DateTime(2026, 1, 1), exit: DateTime(2026, 1, 2)),
      existing,
      today,
    );
    expect(error, contains('2025-06-01 起仍在香港'));
  });

  test('连续离港超过6个月产生提醒', () {
    final alerts = service.findContinuousAbsenceAlerts([
      record(id: '1', entry: DateTime(2025, 1, 1), exit: DateTime(2025, 1, 5)),
      record(id: '2', entry: DateTime(2025, 8, 1), exit: DateTime(2025, 8, 3)),
    ]);
    expect(alerts, hasLength(1));
    expect(alerts.first.days, greaterThanOrEqualTo(183));
  });

  test('copyWith 可以清空可选字段', () {
    final original = record(
      id: '1',
      entry: DateTime(2025, 6, 1),
      exit: DateTime(2025, 6, 2),
    ).copyWith(locationName: '机场', transportMode: '飞机', note: '备注');

    final updated = original.copyWith(
      clearExitDate: true,
      clearLocationName: true,
      clearTransportMode: true,
      clearNote: true,
    );

    expect(updated.exitDate, isNull);
    expect(updated.locationName, isNull);
    expect(updated.transportMode, isNull);
    expect(updated.note, isNull);
  });
}
