import '../../core/time/hk_date.dart';
import '../../domain/models/stay_record.dart';
import '../../domain/services/stay_statistics_service.dart';

class CsvExporter {
  CsvExporter(this.statisticsService);

  final StayStatisticsService statisticsService;

  String export(List<StayRecord> records, DateTime today) {
    final buffer = StringBuffer();
    buffer.writeln(
      'record_id,entry_date,exit_date,stay_days,source,confirmation_status,location_name,transport_mode,note,created_at,updated_at',
    );
    for (final record in records) {
      final values = [
        record.id,
        dateKey(record.entryDate),
        record.exitDate == null ? '' : dateKey(record.exitDate!),
        statisticsService.stayDaysForRecord(record, today).toString(),
        record.source.name,
        record.confirmationStatus.name,
        record.locationName ?? '',
        record.transportMode ?? '',
        record.note ?? '',
        record.createdAt.toIso8601String(),
        record.updatedAt.toIso8601String(),
      ];
      buffer.writeln(values.map(_escape).join(','));
    }
    return buffer.toString();
  }

  String _escape(String value) {
    final needsQuotes =
        value.contains(',') || value.contains('"') || value.contains('\n');
    final escaped = value.replaceAll('"', '""');
    return needsQuotes ? '"$escaped"' : escaped;
  }
}
