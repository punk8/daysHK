import '../../domain/models/stay_record.dart';

abstract class StayRecordRepository {
  Future<List<StayRecord>> listRecords();
  Future<void> saveRecord(StayRecord record);
  Future<void> deleteRecord(String id);
  Future<void> clearAll();
}
