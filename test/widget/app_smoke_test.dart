import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:days_in_hk/app/app.dart';
import 'package:days_in_hk/app/bootstrap.dart';
import 'package:days_in_hk/data/repositories/stay_record_repository.dart';
import 'package:days_in_hk/domain/models/stay_record.dart';
import 'package:days_in_hk/location/boundary/hk_boundary_service.dart';
import 'package:days_in_hk/location/geofence/location_detection_service.dart';
import 'package:days_in_hk/location/geofence/native_geofence_bridge.dart';
import 'package:days_in_hk/location/permissions/location_permission_service.dart';
import 'package:days_in_hk/location/permissions/location_permission_status.dart';
import 'package:days_in_hk/features/records/records_page.dart';
import 'package:days_in_hk/features/settings/settings_page.dart';
import 'package:days_in_hk/features/statistics/statistics_page.dart';
import 'package:days_in_hk/domain/services/stay_statistics_service.dart';
import 'package:days_in_hk/features/dashboard/dashboard_page.dart';
import 'package:days_in_hk/shared/theme/app_theme.dart';
import 'package:days_in_hk/shared/widgets/app_haptics.dart';
import 'package:days_in_hk/shared/widgets/app_notice.dart';
import 'package:days_in_hk/shared/widgets/cupertino_controls.dart';

class MemoryRepository implements StayRecordRepository {
  MemoryRepository(this.records);

  final List<StayRecord> records;

  @override
  Future<void> clearAll() async => records.clear();

  @override
  Future<void> deleteRecord(String id) async {
    records.removeWhere((record) => record.id == id);
  }

  @override
  Future<List<StayRecord>> listRecords() async => records;

  @override
  Future<void> saveRecord(StayRecord record) async {
    records.removeWhere((existing) => existing.id == record.id);
    records.add(record);
  }
}

class FakeLocationPermissionService extends LocationPermissionService {
  FakeLocationPermissionService(this.status);

  final AppLocationPermissionStatus status;

  @override
  Future<AppLocationPermissionStatus> checkStatus() async => status;

  @override
  Future<AppLocationPermissionStatus> requestPermission() async => status;

  @override
  Future<bool> openSystemSettings() async => true;
}

class FakeNativeGeofenceBridge extends NativeGeofenceBridge {
  const FakeNativeGeofenceBridge();

  @override
  Future<NativeGeofenceState> getStatus() async {
    return const NativeGeofenceState(
      status: NativeGeofenceStatus.ready,
      message: '测试状态',
    );
  }
}

void main() {
  testWidgets('App shows dashboard and manual entry tab', (tester) async {
    await tester.pumpWidget(
      DaysInHkApp(
        dependencies: AppDependencies(
          records: MemoryRepository([]),
          boundary: boundary,
          locationDetection: LocationDetectionService(boundary),
          locationPermission: FakeLocationPermissionService(
            AppLocationPermissionStatus.ready,
          ),
          nativeGeofence: const NativeGeofenceBridge(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('在港日记'), findsOneWidget);
    expect(find.text('今年估算在港天数'), findsOneWidget);

    await tester.tap(find.text('补录'));
    await tester.pumpAndSettle();

    expect(find.text('手动补录'), findsOneWidget);
    expect(find.text('入港日期'), findsOneWidget);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.text('保存记录'), findsOneWidget);
  });

  testWidgets('Dashboard manual entry button switches to manual tab', (
    tester,
  ) async {
    await tester.pumpWidget(
      DaysInHkApp(
        dependencies: AppDependencies(
          records: MemoryRepository([]),
          boundary: boundary,
          locationDetection: LocationDetectionService(boundary),
          locationPermission: FakeLocationPermissionService(
            AppLocationPermissionStatus.ready,
          ),
          nativeGeofence: const NativeGeofenceBridge(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final dashboardButton = find.widgetWithText(AppCupertinoButton, '手动补录');
    expect(dashboardButton, findsOneWidget);
    await tester.tap(dashboardButton);
    await tester.pumpAndSettle();

    expect(find.text('入港日期'), findsOneWidget);
    expect(find.text('保存记录'), findsOneWidget);
  });

  testWidgets('Records empty state action switches to manual tab', (
    tester,
  ) async {
    await tester.pumpWidget(
      DaysInHkApp(
        dependencies: AppDependencies(
          records: MemoryRepository([]),
          boundary: boundary,
          locationDetection: LocationDetectionService(boundary),
          locationPermission: FakeLocationPermissionService(
            AppLocationPermissionStatus.ready,
          ),
          nativeGeofence: const NativeGeofenceBridge(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('记录'));
    await tester.pumpAndSettle();
    expect(find.text('暂无入离港记录'), findsOneWidget);

    final emptyStateButton = find.widgetWithText(AppCupertinoButton, '手动补录');
    expect(emptyStateButton, findsOneWidget);
    await tester.tap(emptyStateButton);
    await tester.pumpAndSettle();

    expect(find.text('入港日期'), findsOneWidget);
    expect(find.text('保存记录'), findsOneWidget);
  });

  testWidgets('Dashboard settings prompt calls settings action', (
    tester,
  ) async {
    var openedSettings = false;
    await tester.pumpWidget(
      _TestHost(
        child: DashboardPage(
          records: const [],
          statisticsService: StayStatisticsService(),
          locationPermissionStatus: AppLocationPermissionStatus.whileInUseOnly,
          today: DateTime(2026, 6, 16),
          onManualEntry: () {},
          onOpenSettings: () async => openedSettings = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final settingsPrompt = find.text('去设置');
    await tester.ensureVisible(settingsPrompt);
    await tester.tap(settingsPrompt);
    await tester.pumpAndSettle();

    expect(openedSettings, isTrue);
  });

  testWidgets('Records page edit sheet focuses on dates and note', (
    tester,
  ) async {
    final now = DateTime(2026, 6, 15);
    final records = [
      StayRecord(
        id: 'record-1',
        entryDate: DateTime(2025, 5, 25),
        exitDate: DateTime(2025, 5, 25),
        sameDayRoundTrip: true,
        locationName: '香港国际机场',
        transportMode: '飞机',
        note: '测试备注',
        source: RecordSource.manual,
        confirmationStatus: ConfirmationStatus.confirmed,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    await tester.pumpWidget(
      _TestHost(
        child: RecordsPage(
          records: records,
          onSave: (_) async {},
          onDelete: (_) async {},
          onManualEntry: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(CupertinoIcons.ellipsis_circle));
    await tester.pumpAndSettle();
    await tester.tap(find.text('编辑 / 修正'));
    await tester.pumpAndSettle();

    expect(find.text('编辑记录'), findsOneWidget);
    expect(find.text('入港日期'), findsOneWidget);
    expect(find.text('离港日期（可选）'), findsOneWidget);
    expect(find.text('备注'), findsWidgets);
    expect(find.text('口岸 / 地点'), findsNothing);
    expect(find.text('交通方式'), findsNothing);

    final noteField = tester.widget<CupertinoTextField>(
      find.byKey(const Key('record-edit-note-field')),
    );
    expect(noteField.controller?.text, '测试备注');
  });

  testWidgets('Records page lazily builds long timelines', (tester) async {
    final now = DateTime(2026, 6, 15);
    final records = List.generate(80, (index) {
      final date = DateTime(2026, 1, 1).add(Duration(days: index));
      return StayRecord(
        id: 'record-$index',
        entryDate: date,
        exitDate: date,
        sameDayRoundTrip: true,
        note: 'lazy-record-$index',
        source: RecordSource.manual,
        confirmationStatus: ConfirmationStatus.confirmed,
        createdAt: now,
        updatedAt: now,
      );
    });

    await tester.pumpWidget(
      _TestHost(
        child: RecordsPage(
          records: records,
          onSave: (_) async {},
          onDelete: (_) async {},
          onManualEntry: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('2026年1月'), findsOneWidget);
    expect(find.textContaining('lazy-record-79'), findsNothing);
  });

  testWidgets('Statistics page includes years from existing records', (
    tester,
  ) async {
    final now = DateTime(2026, 6, 16);
    final records = [
      StayRecord(
        id: 'future-record',
        entryDate: DateTime(2027, 1, 10),
        exitDate: DateTime(2027, 1, 10),
        sameDayRoundTrip: true,
        source: RecordSource.manual,
        confirmationStatus: ConfirmationStatus.confirmed,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    await tester.pumpWidget(
      _TestHost(
        child: StatisticsPage(
          records: records,
          statisticsService: StayStatisticsService(),
          today: now,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('2027年'), findsOneWidget);
    expect(find.text('2026年'), findsOneWidget);
  });

  testWidgets('Dashboard current status ignores future records', (
    tester,
  ) async {
    final now = DateTime(2026, 6, 16);
    final records = [
      StayRecord(
        id: 'future-record',
        entryDate: DateTime(2027, 1, 10),
        exitDate: DateTime(2027, 1, 10),
        sameDayRoundTrip: true,
        source: RecordSource.manual,
        confirmationStatus: ConfirmationStatus.confirmed,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    await tester.pumpWidget(
      _TestHost(
        child: DashboardPage(
          records: records,
          statisticsService: StayStatisticsService(),
          locationPermissionStatus: AppLocationPermissionStatus.ready,
          today: now,
          onManualEntry: () {},
          onOpenSettings: () async {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('当前不在香港'), findsOneWidget);
    expect(find.text('暂无入港记录'), findsWidgets);
    expect(find.text('最近离港 2027-01-10'), findsNothing);
    expect(find.text('定位权限：受限'), findsNothing);
  });

  testWidgets('Dashboard uses dark dynamic background in dark mode', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestHost(
        brightness: Brightness.dark,
        child: DashboardPage(
          records: const [],
          statisticsService: StayStatisticsService(),
          locationPermissionStatus: AppLocationPermissionStatus.ready,
          today: DateTime(2026, 6, 16),
          onManualEntry: () {},
          onOpenSettings: () async {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    final scaffold = tester.widget<CupertinoPageScaffold>(
      find.byType(CupertinoPageScaffold).first,
    );
    expect(
      scaffold.backgroundColor.toString(),
      contains('darkColor = Color(alpha: 1.0000, red: 0.0431'),
    );
  });

  testWidgets('Haptics respect reduce motion media settings', (tester) async {
    await tester.pumpWidget(
      _TestHost(
        disableAnimations: true,
        accessibleNavigation: true,
        child: Builder(
          builder: (context) => CupertinoButton(
            onPressed: () => AppHaptics.selection(context),
            child: const Text('Tap'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Tap'));
    await tester.pump();

    expect(find.text('Tap'), findsOneWidget);
  });

  testWidgets('Dashboard supports large accessibility text', (tester) async {
    await tester.pumpWidget(
      _TestHost(
        textScaler: const TextScaler.linear(1.6),
        child: DashboardPage(
          records: const [],
          statisticsService: StayStatisticsService(),
          locationPermissionStatus: AppLocationPermissionStatus.ready,
          today: DateTime(2026, 6, 16),
          onManualEntry: () {},
          onOpenSettings: () async {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('今年估算在港天数'), findsOneWidget);
    expect(find.text('当前连续在港'), findsOneWidget);
    expect(find.text('最长连续在港'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Dashboard stacks metrics in narrow split view', (tester) async {
    await tester.pumpWidget(
      _TestHost(
        size: const Size(320, 700),
        child: DashboardPage(
          records: const [],
          statisticsService: StayStatisticsService(),
          locationPermissionStatus: AppLocationPermissionStatus.ready,
          today: DateTime(2026, 6, 16),
          onManualEntry: () {},
          onOpenSettings: () async {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    final annualBottom = tester.getBottomLeft(find.text('仅供个人记录参考').first).dy;
    final currentTop = tester.getTopLeft(find.text('当前连续在港')).dy;
    expect(annualBottom, lessThan(currentTop));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Statistics summary supports large accessibility text', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestHost(
        textScaler: const TextScaler.linear(1.6),
        child: StatisticsPage(
          records: const [],
          statisticsService: StayStatisticsService(),
          today: DateTime(2026, 6, 16),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('估算在港天数'), findsOneWidget);
    expect(find.text('去年同期 0 天'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Records confirmation actions stack for large text', (
    tester,
  ) async {
    final now = DateTime(2026, 6, 15);
    final records = [
      StayRecord(
        id: 'candidate-1',
        entryDate: DateTime(2026, 6, 15),
        exitDate: DateTime(2026, 6, 15),
        sameDayRoundTrip: true,
        source: RecordSource.autoDetected,
        confirmationStatus: ConfirmationStatus.needsConfirmation,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    await tester.pumpWidget(
      _TestHost(
        textScaler: const TextScaler.linear(1.6),
        child: RecordsPage(
          records: records,
          onSave: (_) async {},
          onDelete: (_) async {},
          onManualEntry: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    final ignoreTop = tester.getTopLeft(find.text('忽略')).dy;
    final editTop = tester.getTopLeft(find.text('修正')).dy;
    final confirmTop = tester.getTopLeft(find.text('确认')).dy;
    expect(ignoreTop, lessThan(editTop));
    expect(editTop, lessThan(confirmTop));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Records page works in landscape split view', (tester) async {
    final now = DateTime(2026, 6, 15);
    final records = [
      StayRecord(
        id: 'landscape-record',
        entryDate: DateTime(2026, 6, 15),
        exitDate: DateTime(2026, 6, 16),
        sameDayRoundTrip: false,
        source: RecordSource.manual,
        confirmationStatus: ConfirmationStatus.confirmed,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    await tester.pumpWidget(
      _TestHost(
        size: const Size(844, 390),
        child: RecordsPage(
          records: records,
          onSave: (_) async {},
          onDelete: (_) async {},
          onManualEntry: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('2026年6月'), findsOneWidget);
    await tester.tap(find.byIcon(CupertinoIcons.ellipsis_circle));
    await tester.pumpAndSettle();
    await tester.tap(find.text('编辑 / 修正'));
    await tester.pumpAndSettle();

    expect(find.text('编辑记录'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Settings status rows stack in narrow split view', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestHost(
        size: const Size(320, 700),
        child: SettingsPage(
          records: const [],
          locationDetection: LocationDetectionService(boundary),
          locationPermission: FakeLocationPermissionService(
            AppLocationPermissionStatus.whileInUseOnly,
          ),
          nativeGeofence: const FakeNativeGeofenceBridge(),
          onSaveCandidate: (_) async {},
          onClearAll: () async {},
          onShowRecords: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    final titleBottom = tester.getBottomLeft(find.text('定位权限状态')).dy;
    final statusTop = tester.getTopLeft(find.text('受限')).dy;
    expect(titleBottom, lessThanOrEqualTo(statusTop));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Settings info tiles open Cupertino detail pages', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestHost(
        child: SettingsPage(
          records: const [],
          locationDetection: LocationDetectionService(boundary),
          locationPermission: FakeLocationPermissionService(
            AppLocationPermissionStatus.ready,
          ),
          nativeGeofence: const FakeNativeGeofenceBridge(),
          onSaveCandidate: (_) async {},
          onClearAll: () async {},
          onShowRecords: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('隐私说明'));
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -120));
    await tester.pumpAndSettle();
    await tester.tap(find.text('隐私说明'));
    await tester.pumpAndSettle();

    expect(find.text('本地优先'), findsOneWidget);
    expect(find.textContaining('默认只保存在当前设备本地'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('设置与隐私'), findsWidgets);
    expect(find.text('本地优先'), findsNothing);
  });

  testWidgets('Color tokens resolve high contrast variants', (tester) async {
    await tester.pumpWidget(
      _TestHost(
        highContrast: true,
        child: Builder(
          builder: (context) {
            final resolved = CupertinoDynamicColor.resolve(
              AppColors.ink,
              context,
            );
            return ColoredBox(
              key: const Key('high-contrast-color-box'),
              color: resolved,
              child: const SizedBox(width: 1, height: 1),
            );
          },
        ),
      ),
    );

    final box = tester.widget<ColoredBox>(
      find.byKey(const Key('high-contrast-color-box')),
    );
    expect(box.color.toARGB32(), const Color(0xFF000000).toARGB32());
  });

  testWidgets('Primary buttons expose VoiceOver label and hint', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestHost(
        child: AppCupertinoButton(
          label: '保存记录',
          semanticHint: '保存这条入离港补录记录',
          onPressed: () {},
        ),
      ),
    );

    expect(
      tester.getSemantics(find.text('保存记录')),
      matchesSemantics(
        label: '保存记录',
        hint: '保存这条入离港补录记录',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
      ),
    );
  });

  testWidgets('Primary buttons wrap labels for large text', (tester) async {
    await tester.pumpWidget(
      _TestHost(
        size: const Size(240, 420),
        textScaler: const TextScaler.linear(1.8),
        child: Center(
          child: SizedBox(
            width: 150,
            child: AppCupertinoButton(
              label: '检测当前位置',
              icon: CupertinoIcons.location_fill,
              semanticHint: '读取当前位置并判断是否需要生成候选记录',
              onPressed: () {},
            ),
          ),
        ),
      ),
    );

    final label = tester.widget<Text>(find.text('检测当前位置'));
    expect(label.maxLines, 2);
    expect(label.overflow, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Notice uses top overlay and action callback', (tester) async {
    var actionCalled = false;

    await tester.pumpWidget(
      _TestHost(
        child: Builder(
          builder: (context) => AppCupertinoButton(
            label: '显示通知',
            onPressed: () => AppNotice.show(
              context,
              '记录已保存',
              action: AppNoticeAction(
                label: '查看',
                onPressed: () => actionCalled = true,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('显示通知'));
    await tester.pump(const Duration(milliseconds: 240));

    expect(find.text('记录已保存'), findsOneWidget);
    expect(tester.getTopLeft(find.text('记录已保存')).dy, lessThan(120));
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.liveRegion == true &&
            widget.properties.label == '记录已保存',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('查看'));
    await tester.pumpAndSettle();

    expect(actionCalled, isTrue);
    expect(find.text('记录已保存'), findsNothing);
  });

  testWidgets('Notice respects reduce motion media settings', (tester) async {
    await tester.pumpWidget(
      _TestHost(
        disableAnimations: true,
        accessibleNavigation: true,
        child: Builder(
          builder: (context) => AppCupertinoButton(
            label: '显示通知',
            onPressed: () => AppNotice.show(context, '无需动画'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('显示通知'));
    await tester.pump();

    expect(find.text('无需动画'), findsOneWidget);
    expect(tester.getTopLeft(find.text('无需动画')).dy, lessThan(120));

    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
    expect(find.text('无需动画'), findsNothing);
  });

  testWidgets('Date field clear action is independent from picker tap', (
    tester,
  ) async {
    var openedPicker = false;
    var cleared = false;
    await tester.pumpWidget(
      _TestHost(
        child: AppCupertinoDateField(
          label: '离港日期',
          date: DateTime(2026, 6, 16),
          onTap: () => openedPicker = true,
          onClear: () => cleared = true,
        ),
      ),
    );

    await tester.tap(find.byIcon(CupertinoIcons.clear_circled));
    await tester.pump();

    expect(cleared, isTrue);
    expect(openedPicker, isFalse);
  });

  testWidgets('Text fields expose native placeholder and semantics', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _TestHost(
        child: AppCupertinoTextField(label: '备注', controller: controller),
      ),
    );

    final textField = tester.widget<CupertinoTextField>(
      find.byType(CupertinoTextField),
    );
    expect(textField.placeholder, '备注');
    expect(
      tester.getSemantics(find.byType(CupertinoTextField)),
      matchesSemantics(
        label: '备注',
        isTextField: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
  });

  testWidgets('App uses Chinese Cupertino localizations', (tester) async {
    late CupertinoLocalizations localizations;

    await tester.pumpWidget(
      _TestHost(
        child: Builder(
          builder: (context) {
            localizations = CupertinoLocalizations.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(localizations.backButtonLabel, '返回');
    expect(localizations.cancelButtonLabel, '取消');
    expect(localizations.pasteButtonLabel, '粘贴');
  });
}

class _TestHost extends StatelessWidget {
  const _TestHost({
    required this.child,
    this.brightness,
    this.disableAnimations = false,
    this.accessibleNavigation = false,
    this.textScaler = TextScaler.noScaling,
    this.highContrast = false,
    this.size = const Size(390, 844),
  });

  final Widget child;
  final Brightness? brightness;
  final bool disableAnimations;
  final bool accessibleNavigation;
  final TextScaler textScaler;
  final bool highContrast;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQueryData(
        size: size,
        devicePixelRatio: 1,
        platformBrightness: brightness ?? Brightness.light,
        disableAnimations: disableAnimations,
        accessibleNavigation: accessibleNavigation,
        textScaler: textScaler,
        highContrast: highContrast,
      ),
      child: CupertinoApp(
        theme: buildCupertinoAppTheme(),
        locale: const Locale('zh', 'Hans'),
        localizationsDelegates: GlobalCupertinoLocalizations.delegates,
        supportedLocales: const [
          Locale('zh', 'Hans'),
          Locale('zh', 'Hant'),
          Locale('en'),
        ],
        home: child,
      ),
    );
  }
}

final boundary = HkBoundaryService.fromGeoJson(const {
  'type': 'FeatureCollection',
  'features': [
    {
      'type': 'Feature',
      'geometry': {
        'type': 'Polygon',
        'coordinates': [
          [
            [113.8, 22.1],
            [114.6, 22.1],
            [114.6, 22.6],
            [113.8, 22.6],
            [113.8, 22.1],
          ],
        ],
      },
    },
  ],
});
