import '../../core/time/hk_date.dart';
import '../models/stay_record.dart';
import '../models/stay_summary.dart';

class StayStatisticsService {
  Set<String> stayDateKeys(List<StayRecord> records, DateTime today) {
    final keys = <String>{};
    for (final record in records) {
      if (record.confirmationStatus == ConfirmationStatus.rejected) {
        continue;
      }
      final end = record.exitDate ?? today;
      for (final date in enumerateInclusiveDates(record.entryDate, end)) {
        keys.add(dateKey(date));
      }
    }
    return keys;
  }

  int stayDaysForRecord(StayRecord record, DateTime today) {
    if (record.confirmationStatus == ConfirmationStatus.rejected) {
      return 0;
    }
    final end = record.exitDate ?? today;
    return inclusiveDateCount(record.entryDate, end);
  }

  AnnualStaySummary buildAnnualSummary({
    required List<StayRecord> records,
    required int year,
    required DateTime today,
  }) {
    final monthlyCounts = {for (var month = 1; month <= 12; month++) month: 0};
    for (final key in stayDateKeys(records, today)) {
      final date = DateTime.parse(key);
      if (date.year == year) {
        monthlyCounts[date.month] = (monthlyCounts[date.month] ?? 0) + 1;
      }
    }

    final estimatedStayDays = monthlyCounts.values.fold<int>(
      0,
      (sum, value) => sum + value,
    );

    return AnnualStaySummary(
      year: year,
      estimatedStayDays: estimatedStayDays,
      monthlyCounts: monthlyCounts,
    );
  }

  String? validateRecord(
    StayRecord candidate,
    List<StayRecord> existingRecords,
    DateTime today,
  ) {
    final exitDate = candidate.exitDate;
    if (exitDate != null && exitDate.isBefore(candidate.entryDate)) {
      return '离港日期不能早于入港日期';
    }

    final candidateEnd = exitDate ?? candidate.entryDate;
    for (final record in existingRecords) {
      if (record.id == candidate.id ||
          record.confirmationStatus == ConfirmationStatus.rejected) {
        continue;
      }
      final recordEnd = record.exitDate ?? today;
      final overlaps =
          !candidateEnd.isBefore(record.entryDate) &&
          !candidate.entryDate.isAfter(recordEnd);
      if (overlaps) {
        return '该记录与已有记录重叠：${_recordConflictLabel(record, today)}。请先修正后再保存。';
      }
    }

    return null;
  }

  String _recordConflictLabel(StayRecord record, DateTime today) {
    final end = record.exitDate ?? today;
    final dateRange = record.exitDate == null
        ? '${dateKey(record.entryDate)} 起仍在香港'
        : '${dateKey(record.entryDate)} 至 ${dateKey(end)}';
    final source = switch (record.source) {
      RecordSource.manual => '手动补录',
      RecordSource.autoDetected => '自动检测',
      RecordSource.userConfirmed => '用户确认',
    };
    final status = record.confirmationStatus.label;
    return '$dateRange（$source / $status）';
  }
}
