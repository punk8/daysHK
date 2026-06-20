import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:days_in_hk/widget/widget_sync_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('days_in_hk/widget');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    debugDefaultTargetPlatformOverride = null;
  });

  test('iOS sends widget summary through platform channel', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return null;
        });

    await const WidgetSyncService(channel).updateWidgetSummary(
      WidgetSummary(
        totalDays: 658,
        currentYearDays: 128,
        currentYear: 2026,
        lastUpdatedAt: DateTime.parse('2026-06-20T14:00:00+08:00'),
      ),
    );

    expect(calls, hasLength(1));
    expect(calls.single.method, 'updateWidgetSummary');
    expect(calls.single.arguments, {
      'totalDays': 658,
      'currentYearDays': 128,
      'currentYear': 2026,
      'lastUpdatedAt': '2026-06-20T06:00:00.000Z',
    });
  });

  test('non-iOS skips widget platform channel', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return null;
        });

    await const WidgetSyncService(channel).updateWidgetSummary(
      WidgetSummary(
        totalDays: 1,
        currentYearDays: 1,
        currentYear: 2026,
        lastUpdatedAt: DateTime(2026),
      ),
    );

    expect(calls, isEmpty);
  });
}
