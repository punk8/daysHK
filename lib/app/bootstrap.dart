import 'package:flutter/foundation.dart';

import '../data/repositories/local_stay_record_repository.dart';
import '../data/repositories/stay_record_repository.dart';
import '../location/boundary/hk_boundary_service.dart';
import '../location/geofence/location_detection_service.dart';
import '../location/geofence/native_geofence_bridge.dart';
import '../location/permissions/location_permission_service.dart';
import '../widget/widget_sync_service.dart';

class AppDependencies {
  const AppDependencies({
    required this.records,
    required this.boundary,
    required this.locationDetection,
    required this.locationPermission,
    required this.nativeGeofence,
    required this.widgetSync,
  });

  final StayRecordRepository records;
  final HkBoundaryService boundary;
  final LocationDetectionService locationDetection;
  final LocationPermissionService locationPermission;
  final NativeGeofenceBridge nativeGeofence;
  final WidgetSyncService widgetSync;
}

Future<AppDependencies> bootstrapDependencies() async {
  final repository = await LocalStayRecordRepository.create(
    useSharedPreferences: kIsWeb,
  );
  final boundary = await HkBoundaryService.loadFromAsset();
  return AppDependencies(
    records: repository,
    boundary: boundary,
    locationDetection: LocationDetectionService(boundary),
    locationPermission: LocationPermissionService(),
    nativeGeofence: const NativeGeofenceBridge(),
    widgetSync: const WidgetSyncService(),
  );
}
