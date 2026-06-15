import 'package:geolocator/geolocator.dart';

import 'location_permission_status.dart';

class LocationPermissionService {
  Future<AppLocationPermissionStatus> checkStatus() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return AppLocationPermissionStatus.serviceDisabled;
    }

    final permission = await Geolocator.checkPermission();
    return _map(permission);
  }

  Future<AppLocationPermissionStatus> requestPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return AppLocationPermissionStatus.serviceDisabled;
    }

    final permission = await Geolocator.requestPermission();
    return _map(permission);
  }

  AppLocationPermissionStatus _map(LocationPermission permission) {
    return switch (permission) {
      LocationPermission.always => AppLocationPermissionStatus.ready,
      LocationPermission.whileInUse =>
        AppLocationPermissionStatus.whileInUseOnly,
      LocationPermission.denied => AppLocationPermissionStatus.denied,
      LocationPermission.deniedForever =>
        AppLocationPermissionStatus.deniedForever,
      LocationPermission.unableToDetermine =>
        AppLocationPermissionStatus.unknown,
    };
  }
}
