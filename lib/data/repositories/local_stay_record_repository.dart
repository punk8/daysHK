import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

import '../../domain/models/stay_record.dart';
import 'stay_record_repository.dart';

class LocalStayRecordRepository implements StayRecordRepository {
  LocalStayRecordRepository._({this.database, this.preferences});

  final Database? database;
  final SharedPreferences? preferences;

  static const _preferencesKey = 'days_in_hk.stay_records.v1';

  static Future<LocalStayRecordRepository> create({
    required bool useSharedPreferences,
  }) async {
    if (useSharedPreferences) {
      return LocalStayRecordRepository._(
        preferences: await SharedPreferences.getInstance(),
      );
    }

    final dbPath = await getDatabasesPath();
    final database = await openDatabase(
      p.join(dbPath, 'days_in_hk.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE stay_records (
            id TEXT PRIMARY KEY,
            entry_date TEXT NOT NULL,
            exit_date TEXT,
            same_day_round_trip INTEGER NOT NULL,
            location_name TEXT,
            transport_mode TEXT,
            note TEXT,
            source TEXT NOT NULL,
            confirmation_status TEXT NOT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
      },
    );

    return LocalStayRecordRepository._(database: database);
  }

  @override
  Future<List<StayRecord>> listRecords() async {
    if (kIsWeb || preferences != null) {
      final encoded = preferences?.getString(_preferencesKey);
      if (encoded == null || encoded.isEmpty) {
        return [];
      }
      final values = jsonDecode(encoded) as List<dynamic>;
      return values
          .cast<Map<String, Object?>>()
          .map(StayRecord.fromJson)
          .toList()
        ..sort((a, b) => b.entryDate.compareTo(a.entryDate));
    }

    final rows = await database!.query(
      'stay_records',
      orderBy: 'entry_date DESC',
    );
    if (rows.isEmpty) {
      return [];
    }
    return rows.map(_fromRow).toList();
  }

  @override
  Future<void> saveRecord(StayRecord record) async {
    if (kIsWeb || preferences != null) {
      final records = await listRecords();
      final next = [
        for (final existing in records)
          if (existing.id != record.id) existing,
        record,
      ]..sort((a, b) => b.entryDate.compareTo(a.entryDate));
      await preferences!.setString(
        _preferencesKey,
        jsonEncode(next.map((record) => record.toJson()).toList()),
      );
      return;
    }

    await database!.insert(
      'stay_records',
      _toRow(record),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteRecord(String id) async {
    if (kIsWeb || preferences != null) {
      final records = await listRecords();
      final next = records.where((record) => record.id != id).toList();
      await preferences!.setString(
        _preferencesKey,
        jsonEncode(next.map((record) => record.toJson()).toList()),
      );
      return;
    }
    await database!.delete('stay_records', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> clearAll() async {
    if (kIsWeb || preferences != null) {
      await preferences!.setString(_preferencesKey, '[]');
      return;
    }
    await database!.delete('stay_records');
  }

  Map<String, Object?> _toRow(StayRecord record) {
    final json = record.toJson();
    return {
      'id': json['id'],
      'entry_date': json['entryDate'],
      'exit_date': json['exitDate'],
      'same_day_round_trip': record.sameDayRoundTrip ? 1 : 0,
      'location_name': json['locationName'],
      'transport_mode': json['transportMode'],
      'note': json['note'],
      'source': json['source'],
      'confirmation_status': json['confirmationStatus'],
      'created_at': json['createdAt'],
      'updated_at': json['updatedAt'],
    };
  }

  StayRecord _fromRow(Map<String, Object?> row) {
    return StayRecord.fromJson({
      'id': row['id'],
      'entryDate': row['entry_date'],
      'exitDate': row['exit_date'],
      'sameDayRoundTrip': row['same_day_round_trip'],
      'locationName': row['location_name'],
      'transportMode': row['transport_mode'],
      'note': row['note'],
      'source': row['source'],
      'confirmationStatus': row['confirmation_status'],
      'createdAt': row['created_at'],
      'updatedAt': row['updated_at'],
    });
  }
}
