enum RecordSource {
  autoDetected('自动检测'),
  userConfirmed('用户确认'),
  manual('手动补录');

  const RecordSource(this.label);

  final String label;
}

enum ConfirmationStatus {
  confirmed('已确认'),
  needsConfirmation('需要确认'),
  rejected('已忽略');

  const ConfirmationStatus(this.label);

  final String label;
}

class StayRecord {
  const StayRecord({
    required this.id,
    required this.entryDate,
    this.exitDate,
    required this.sameDayRoundTrip,
    this.locationName,
    this.transportMode,
    this.note,
    required this.source,
    required this.confirmationStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final DateTime entryDate;
  final DateTime? exitDate;
  final bool sameDayRoundTrip;
  final String? locationName;
  final String? transportMode;
  final String? note;
  final RecordSource source;
  final ConfirmationStatus confirmationStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  StayRecord copyWith({
    String? id,
    DateTime? entryDate,
    DateTime? exitDate,
    bool clearExitDate = false,
    bool? sameDayRoundTrip,
    String? locationName,
    bool clearLocationName = false,
    String? transportMode,
    bool clearTransportMode = false,
    String? note,
    bool clearNote = false,
    RecordSource? source,
    ConfirmationStatus? confirmationStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StayRecord(
      id: id ?? this.id,
      entryDate: entryDate ?? this.entryDate,
      exitDate: clearExitDate ? null : exitDate ?? this.exitDate,
      sameDayRoundTrip: sameDayRoundTrip ?? this.sameDayRoundTrip,
      locationName: clearLocationName
          ? null
          : locationName ?? this.locationName,
      transportMode: clearTransportMode
          ? null
          : transportMode ?? this.transportMode,
      note: clearNote ? null : note ?? this.note,
      source: source ?? this.source,
      confirmationStatus: confirmationStatus ?? this.confirmationStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'entryDate': _encodeDate(entryDate),
      'exitDate': exitDate == null ? null : _encodeDate(exitDate!),
      'sameDayRoundTrip': sameDayRoundTrip,
      'locationName': locationName,
      'transportMode': transportMode,
      'note': note,
      'source': source.name,
      'confirmationStatus': confirmationStatus.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static StayRecord fromJson(Map<String, Object?> json) {
    return StayRecord(
      id: json['id']! as String,
      entryDate: _decodeDate(json['entryDate']! as String),
      exitDate: json['exitDate'] == null
          ? null
          : _decodeDate(json['exitDate']! as String),
      sameDayRoundTrip:
          json['sameDayRoundTrip'] == true || json['sameDayRoundTrip'] == 1,
      locationName: json['locationName'] as String?,
      transportMode: json['transportMode'] as String?,
      note: json['note'] as String?,
      source: RecordSource.values.byName(json['source']! as String),
      confirmationStatus: ConfirmationStatus.values.byName(
        json['confirmationStatus']! as String,
      ),
      createdAt: DateTime.parse(json['createdAt']! as String),
      updatedAt: DateTime.parse(json['updatedAt']! as String),
    );
  }

  static String _encodeDate(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return normalized.toIso8601String().split('T').first;
  }

  static DateTime _decodeDate(String value) {
    final parts = value.split('-').map(int.parse).toList();
    return DateTime(parts[0], parts[1], parts[2]);
  }
}
