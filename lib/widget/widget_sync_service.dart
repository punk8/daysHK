import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class WidgetSummary {
  const WidgetSummary({
    required this.totalDays,
    required this.currentYearDays,
    required this.currentYear,
    required this.lastUpdatedAt,
  });

  final int totalDays;
  final int currentYearDays;
  final int currentYear;
  final DateTime lastUpdatedAt;

  Map<String, Object?> toMap() {
    return {
      'totalDays': totalDays,
      'currentYearDays': currentYearDays,
      'currentYear': currentYear,
      'lastUpdatedAt': lastUpdatedAt.toIso8601String(),
    };
  }
}

class WidgetSyncService {
  const WidgetSyncService([
    this._channel = const MethodChannel('days_in_hk/widget'),
  ]);

  final MethodChannel _channel;

  Future<void> updateWidgetSummary(WidgetSummary summary) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }

    try {
      await _channel.invokeMethod<void>('updateWidgetSummary', summary.toMap());
    } on MissingPluginException {
      debugPrint('DaysHK widget channel is not registered.');
    } on PlatformException catch (error) {
      debugPrint('DaysHK widget summary update failed: ${error.message}');
    }
  }
}
