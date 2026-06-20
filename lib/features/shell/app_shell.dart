import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../app/bootstrap.dart';
import '../../core/time/hk_date.dart';
import '../../domain/models/stay_record.dart';
import '../../domain/services/stay_statistics_service.dart';
import '../../location/permissions/location_permission_status.dart';
import '../dashboard/dashboard_page.dart';
import '../manual_entry/manual_entry_page.dart';
import '../records/records_page.dart';
import '../settings/settings_page.dart';
import '../statistics/statistics_page.dart';
import '../../shared/widgets/app_notice.dart';
import '../../shared/widgets/app_haptics.dart';
import '../../shared/theme/platform_icons.dart';
import '../../shared/theme/platform_style.dart';
import '../../widget/widget_sync_service.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with WidgetsBindingObserver {
  final _statisticsService = StayStatisticsService();
  late final CupertinoTabController _tabController;
  var _selectedIndex = 0;
  final _materialTabVisited = <bool>[true, false, false, false, false];
  var _records = <StayRecord>[];
  var _locationPermissionStatus = AppLocationPermissionStatus.unknown;
  var _isLoading = true;
  var _contentVersion = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = CupertinoTabController(initialIndex: _selectedIndex);
    _tabController.addListener(_syncSelectedIndex);
    _reload();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController
      ..removeListener(_syncSelectedIndex)
      ..dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _reload();
    }
  }

  void _syncSelectedIndex() {
    if (_selectedIndex == _tabController.index) {
      return;
    }
    setState(() {
      _selectedIndex = _tabController.index;
      _materialTabVisited[_selectedIndex] = true;
    });
  }

  void _selectTab(int index) {
    if (index != _selectedIndex) {
      AppHaptics.selection(context);
    }
    if (AppPlatformStyle.isMaterial(context)) {
      setState(() {
        _selectedIndex = index;
        _materialTabVisited[index] = true;
      });
    }
    _tabController.index = index;
  }

  Future<void> _reload() async {
    final records = await widget.dependencies.records.listRecords();
    final locationPermissionStatus = await widget
        .dependencies
        .locationPermission
        .checkStatus();
    final today = hkToday();
    final widgetSummary = _buildWidgetSummary(records, today);
    if (!mounted) {
      return;
    }
    setState(() {
      _records = records;
      _locationPermissionStatus = locationPermissionStatus;
      _isLoading = false;
      _contentVersion += 1;
    });
    unawaited(_syncWidgetSummary(widgetSummary));
  }

  Future<void> _syncWidgetSummary(WidgetSummary summary) {
    return widget.dependencies.widgetSync.updateWidgetSummary(summary);
  }

  Future<void> _saveRecord(StayRecord record) async {
    await widget.dependencies.records.saveRecord(record);
    await _reload();
  }

  Future<void> _deleteRecord(String id) async {
    await widget.dependencies.records.deleteRecord(id);
    await _reload();
  }

  Future<void> _clearAll() async {
    await widget.dependencies.records.clearAll();
    await _reload();
  }

  Future<void> _openSystemSettings() async {
    final opened = await widget.dependencies.locationPermission
        .openSystemSettings();
    if (!opened && mounted) {
      AppNotice.show(context, '无法打开系统设置，请手动前往应用设置。');
    }
    await _reload();
  }

  WidgetSummary _buildWidgetSummary(List<StayRecord> records, DateTime today) {
    return WidgetSummary(
      totalDays: _statisticsService.stayDateKeys(records, today).length,
      currentYearDays: _statisticsService
          .buildAnnualSummary(records: records, year: today.year, today: today)
          .estimatedStayDays,
      currentYear: today.year,
      lastUpdatedAt: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = hkToday();
    if (_isLoading) {
      return AppLoadingScaffold(
        child: Center(
          child: AppPlatformStyle.isMaterial(context)
              ? const CircularProgressIndicator()
              : const CupertinoActivityIndicator(),
        ),
      );
    }

    if (AppPlatformStyle.isMaterial(context)) {
      return Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            for (var index = 0; index < 5; index++)
              _materialTabVisited[index]
                  ? Navigator(
                      key: ValueKey('material-tab-$index-$_contentVersion'),
                      onGenerateRoute: (_) => MaterialPageRoute<void>(
                        builder: (context) => _buildTabPage(index, today),
                      ),
                    )
                  : const SizedBox.shrink(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _selectTab,
          items: [
            BottomNavigationBarItem(
              icon: Icon(AppPlatformIcon.home(context)),
              activeIcon: Icon(AppPlatformIcon.home(context, filled: true)),
              label: '首页',
            ),
            BottomNavigationBarItem(
              icon: Icon(AppPlatformIcon.statistics(context)),
              activeIcon: Icon(
                AppPlatformIcon.statistics(context, filled: true),
              ),
              label: '统计',
            ),
            BottomNavigationBarItem(
              icon: Icon(AppPlatformIcon.records(context)),
              activeIcon: Icon(AppPlatformIcon.records(context, filled: true)),
              label: '记录',
            ),
            BottomNavigationBarItem(
              icon: Icon(AppPlatformIcon.addRecord(context)),
              activeIcon: Icon(
                AppPlatformIcon.addRecord(context, filled: true),
              ),
              label: '补录',
            ),
            BottomNavigationBarItem(
              icon: Icon(AppPlatformIcon.settings(context)),
              activeIcon: Icon(AppPlatformIcon.settings(context, filled: true)),
              label: '设置',
            ),
          ],
        ),
      );
    }

    return CupertinoTabScaffold(
      controller: _tabController,
      tabBar: CupertinoTabBar(
        currentIndex: _selectedIndex,
        onTap: _selectTab,
        items: [
          BottomNavigationBarItem(
            icon: Icon(AppPlatformIcon.home(context)),
            activeIcon: Icon(AppPlatformIcon.home(context, filled: true)),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(AppPlatformIcon.statistics(context)),
            activeIcon: Icon(AppPlatformIcon.statistics(context, filled: true)),
            label: '统计',
          ),
          BottomNavigationBarItem(
            icon: Icon(AppPlatformIcon.records(context)),
            activeIcon: Icon(AppPlatformIcon.records(context, filled: true)),
            label: '记录',
          ),
          BottomNavigationBarItem(
            icon: Icon(AppPlatformIcon.addRecord(context)),
            activeIcon: Icon(AppPlatformIcon.addRecord(context, filled: true)),
            label: '补录',
          ),
          BottomNavigationBarItem(
            icon: Icon(AppPlatformIcon.settings(context)),
            activeIcon: Icon(AppPlatformIcon.settings(context, filled: true)),
            label: '设置',
          ),
        ],
      ),
      tabBuilder: (context, index) => CupertinoTabView(
        key: ValueKey('tab-$index-$_contentVersion'),
        builder: (context) => _buildTabPage(index, today),
      ),
    );
  }

  Widget _buildTabPage(int index, DateTime today) {
    return switch (index) {
      0 => DashboardPage(
        records: _records,
        statisticsService: _statisticsService,
        locationPermissionStatus: _locationPermissionStatus,
        today: today,
        onManualEntry: () => _selectTab(3),
        onOpenSettings: _openSystemSettings,
      ),
      1 => StatisticsPage(
        records: _records,
        statisticsService: _statisticsService,
        today: today,
      ),
      2 => RecordsPage(
        records: _records,
        onSave: _saveRecord,
        onDelete: _deleteRecord,
        onManualEntry: () => _selectTab(3),
      ),
      3 => ManualEntryPage(
        records: _records,
        statisticsService: _statisticsService,
        today: today,
        onSave: (record) async {
          await _saveRecord(record);
          _selectTab(2);
        },
      ),
      4 => SettingsPage(
        records: _records,
        locationDetection: widget.dependencies.locationDetection,
        locationPermission: widget.dependencies.locationPermission,
        nativeGeofence: widget.dependencies.nativeGeofence,
        onSaveCandidate: _saveRecord,
        onClearAll: _clearAll,
        onShowRecords: () => _selectTab(2),
      ),
      _ => DashboardPage(
        records: _records,
        statisticsService: _statisticsService,
        locationPermissionStatus: _locationPermissionStatus,
        today: today,
        onManualEntry: () => _selectTab(3),
        onOpenSettings: _openSystemSettings,
      ),
    };
  }
}

class AppLoadingScaffold extends StatelessWidget {
  const AppLoadingScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (AppPlatformStyle.isMaterial(context)) {
      return Scaffold(body: child);
    }
    return CupertinoPageScaffold(child: child);
  }
}
