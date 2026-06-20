import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum NativeGeofenceStatus { ready, running, stopped, unsupported, unavailable }

enum NativeGeofenceTransition {
  enter('进入唤醒区'),
  exit('离开唤醒区'),
  unknown('未知事件');

  const NativeGeofenceTransition(this.label);

  final String label;
}

class NativeGeofenceEvent {
  const NativeGeofenceEvent({
    required this.transition,
    required this.detectedAt,
    required this.source,
    this.latitude,
    this.longitude,
    this.accuracyMeters,
  });

  final NativeGeofenceTransition transition;
  final DateTime detectedAt;
  final String source;
  final double? latitude;
  final double? longitude;
  final double? accuracyMeters;

  factory NativeGeofenceEvent.fromMap(Map<dynamic, dynamic> value) {
    final transitionName = value['transition'] as String? ?? 'unknown';
    final detectedAtText = value['detectedAt'] as String?;
    return NativeGeofenceEvent(
      transition: NativeGeofenceTransition.values.firstWhere(
        (transition) => transition.name == transitionName,
        orElse: () => NativeGeofenceTransition.unknown,
      ),
      detectedAt: detectedAtText == null
          ? DateTime.fromMillisecondsSinceEpoch(0)
          : DateTime.tryParse(detectedAtText) ??
                DateTime.fromMillisecondsSinceEpoch(0),
      source: value['source'] as String? ?? 'native_geofence',
      latitude: _asDouble(value['latitude']),
      longitude: _asDouble(value['longitude']),
      accuracyMeters: _asDouble(value['accuracyMeters']),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'transition': transition.name,
      'detectedAt': detectedAt.toIso8601String(),
      'source': source,
      'latitude': latitude,
      'longitude': longitude,
      'accuracyMeters': accuracyMeters,
    };
  }

  static double? _asDouble(Object? value) {
    if (value is double) {
      return value;
    }
    if (value is int) {
      return value.toDouble();
    }
    return null;
  }
}

class NativeGeofenceState {
  const NativeGeofenceState({
    required this.status,
    required this.message,
    this.lastEvent,
  });

  final NativeGeofenceStatus status;
  final String message;
  final NativeGeofenceEvent? lastEvent;

  factory NativeGeofenceState.fromMap(Map<dynamic, dynamic> value) {
    final statusName = value['status'] as String? ?? 'unavailable';
    final rawLastEvent = value['lastEvent'];
    return NativeGeofenceState(
      status: NativeGeofenceStatus.values.firstWhere(
        (status) => status.name == statusName,
        orElse: () => NativeGeofenceStatus.unavailable,
      ),
      message: value['message'] as String? ?? '后台检测状态未知',
      lastEvent: rawLastEvent is Map
          ? NativeGeofenceEvent.fromMap(rawLastEvent)
          : null,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'status': status.name,
      'message': message,
      'lastEvent': lastEvent?.toMap(),
    };
  }
}

class NativeGeofenceBridge {
  const NativeGeofenceBridge([
    this._channel = const MethodChannel('days_in_hk/geofence'),
  ]);

  final MethodChannel _channel;

  Future<NativeGeofenceState> getStatus() async {
    if (kIsWeb) {
      return const NativeGeofenceState(
        status: NativeGeofenceStatus.unsupported,
        message: 'Web 环境不支持原生后台检测，请在 iOS 设备或模拟器上验收业务流程。',
      );
    }

    try {
      final result = await _channel.invokeMapMethod<String, Object?>(
        'getStatus',
      );
      return NativeGeofenceState.fromMap(result ?? const {});
    } on MissingPluginException {
      return const NativeGeofenceState(
        status: NativeGeofenceStatus.unavailable,
        message: '原生后台检测通道尚未注册。',
      );
    } on PlatformException catch (error) {
      return NativeGeofenceState(
        status: NativeGeofenceStatus.unavailable,
        message: error.message ?? '原生后台检测状态读取失败。',
      );
    }
  }

  Future<NativeGeofenceState> startMonitoring() async {
    if (kIsWeb) {
      return const NativeGeofenceState(
        status: NativeGeofenceStatus.unsupported,
        message: 'Web 环境不支持原生后台检测。',
      );
    }

    try {
      final result = await _channel.invokeMapMethod<String, Object?>(
        'startMonitoring',
      );
      return NativeGeofenceState.fromMap(result ?? const {});
    } on MissingPluginException {
      return const NativeGeofenceState(
        status: NativeGeofenceStatus.unavailable,
        message: '原生后台检测通道尚未注册。',
      );
    } on PlatformException catch (error) {
      return NativeGeofenceState(
        status: NativeGeofenceStatus.unavailable,
        message: error.message ?? '启动后台检测失败。',
      );
    }
  }

  Future<NativeGeofenceState> requestAlwaysAuthorization() async {
    if (kIsWeb) {
      return const NativeGeofenceState(
        status: NativeGeofenceStatus.unsupported,
        message: 'Web 环境不支持原生后台检测。',
      );
    }

    try {
      final result = await _channel.invokeMapMethod<String, Object?>(
        'requestAlwaysAuthorization',
      );
      return NativeGeofenceState.fromMap(result ?? const {});
    } on MissingPluginException {
      return const NativeGeofenceState(
        status: NativeGeofenceStatus.unavailable,
        message: '原生后台检测通道尚未注册。',
      );
    } on PlatformException catch (error) {
      return NativeGeofenceState(
        status: NativeGeofenceStatus.unavailable,
        message: error.message ?? '请求后台定位权限失败。',
      );
    }
  }

  Future<NativeGeofenceState> stopMonitoring() async {
    if (kIsWeb) {
      return const NativeGeofenceState(
        status: NativeGeofenceStatus.unsupported,
        message: 'Web 环境不支持原生后台检测。',
      );
    }

    try {
      final result = await _channel.invokeMapMethod<String, Object?>(
        'stopMonitoring',
      );
      return NativeGeofenceState.fromMap(result ?? const {});
    } on MissingPluginException {
      return const NativeGeofenceState(
        status: NativeGeofenceStatus.unavailable,
        message: '原生后台检测通道尚未注册。',
      );
    } on PlatformException catch (error) {
      return NativeGeofenceState(
        status: NativeGeofenceStatus.unavailable,
        message: error.message ?? '停止后台检测失败。',
      );
    }
  }
}
