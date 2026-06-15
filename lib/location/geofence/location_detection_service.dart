import 'package:geolocator/geolocator.dart';

import '../../domain/models/stay_record.dart';
import '../boundary/boundary_classification.dart';
import '../boundary/hk_boundary_service.dart';

class LocationDetectionResult {
  const LocationDetectionResult({
    required this.boundaryResult,
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    this.candidateRecord,
  });

  final BoundaryResult boundaryResult;
  final double latitude;
  final double longitude;
  final double accuracyMeters;
  final StayRecord? candidateRecord;
}

class LocationDetectionService {
  const LocationDetectionService(this.boundary);

  final HkBoundaryService boundary;

  Future<LocationDetectionResult> detectCurrentLocation(
    List<StayRecord> existingRecords,
  ) async {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    return detectCoordinate(
      existingRecords: existingRecords,
      longitude: position.longitude,
      latitude: position.latitude,
      accuracyMeters: position.accuracy,
    );
  }

  LocationDetectionResult detectCoordinate({
    required List<StayRecord> existingRecords,
    required double longitude,
    required double latitude,
    double accuracyMeters = 0,
    DateTime? now,
  }) {
    final boundaryResult = boundary.classify(
      longitude: longitude,
      latitude: latitude,
      accuracyMeters: accuracyMeters,
    );
    final candidate = buildCandidateRecord(
      existingRecords: existingRecords,
      boundaryResult: boundaryResult,
      now: now ?? DateTime.now(),
    );
    return LocationDetectionResult(
      boundaryResult: boundaryResult,
      latitude: latitude,
      longitude: longitude,
      accuracyMeters: accuracyMeters,
      candidateRecord: candidate,
    );
  }

  StayRecord? buildCandidateRecord({
    required List<StayRecord> existingRecords,
    required BoundaryResult boundaryResult,
    required DateTime now,
  }) {
    if (boundaryResult.needsConfirmation) {
      return _candidate(
        now: now,
        entryDate: DateTime(now.year, now.month, now.day),
        exitDate: DateTime(now.year, now.month, now.day),
        sameDayRoundTrip: true,
        note: '定位精度较低或靠近边界，需要确认',
      );
    }

    final latest = [...existingRecords]
      ..sort((a, b) => b.entryDate.compareTo(a.entryDate));
    final current = latest.isEmpty ? null : latest.first;
    final today = DateTime(now.year, now.month, now.day);

    if (boundaryResult.classification == BoundaryClassification.insideHk) {
      if (current != null &&
          current.exitDate == null &&
          current.confirmationStatus != ConfirmationStatus.rejected) {
        return null;
      }
      return _candidate(
        now: now,
        entryDate: today,
        exitDate: null,
        note: '定位检测：进入香港候选记录',
      );
    }

    if (boundaryResult.classification == BoundaryClassification.outsideHk) {
      if (current == null ||
          current.exitDate != null ||
          current.confirmationStatus == ConfirmationStatus.rejected) {
        return null;
      }
      return _candidate(
        now: now,
        entryDate: current.entryDate,
        exitDate: today,
        note: '定位检测：离开香港候选记录',
      );
    }

    return null;
  }

  StayRecord _candidate({
    required DateTime now,
    required DateTime entryDate,
    DateTime? exitDate,
    bool sameDayRoundTrip = false,
    required String note,
  }) {
    return StayRecord(
      id: 'candidate-${now.microsecondsSinceEpoch}',
      entryDate: entryDate,
      exitDate: exitDate,
      sameDayRoundTrip: sameDayRoundTrip,
      locationName: '定位检测',
      transportMode: null,
      note: note,
      source: RecordSource.autoDetected,
      confirmationStatus: ConfirmationStatus.needsConfirmation,
      createdAt: now,
      updatedAt: now,
    );
  }
}
