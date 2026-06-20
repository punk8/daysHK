import 'package:flutter/cupertino.dart';

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

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final _statisticsService = StayStatisticsService();
  var _selectedIndex = 0;
  var _records = <StayRecord>[];
  var _locationPermissionStatus = AppLocationPermissionStatus.unknown;
  var _isLoading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final records = await widget.dependencies.records.listRecords();
    final locationPermissionStatus = await widget
        .dependencies
        .locationPermission
        .checkStatus();
    setState(() {
      _records = records;
      _locationPermissionStatus = locationPermissionStatus;
      _isLoading = false;
    });
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
      AppNotice.show(context, '无法打开系统设置，请手动前往 iOS 设置。');
    }
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final today = hkToday();
    final pages = [
      DashboardPage(
        records: _records,
        statisticsService: _statisticsService,
        locationPermissionStatus: _locationPermissionStatus,
        today: today,
        onManualEntry: () => setState(() => _selectedIndex = 3),
        onOpenSettings: _openSystemSettings,
      ),
      StatisticsPage(
        records: _records,
        statisticsService: _statisticsService,
        today: today,
      ),
      RecordsPage(
        records: _records,
        onSave: _saveRecord,
        onDelete: _deleteRecord,
      ),
      ManualEntryPage(
        records: _records,
        statisticsService: _statisticsService,
        today: today,
        onSave: (record) async {
          await _saveRecord(record);
          setState(() => _selectedIndex = 2);
        },
      ),
      SettingsPage(
        records: _records,
        locationDetection: widget.dependencies.locationDetection,
        locationPermission: widget.dependencies.locationPermission,
        nativeGeofence: widget.dependencies.nativeGeofence,
        onSaveCandidate: _saveRecord,
        onClearAll: _clearAll,
        onShowRecords: () => setState(() => _selectedIndex = 2),
      ),
    ];

    if (_isLoading) {
      return const CupertinoPageScaffold(
        child: Center(child: CupertinoActivityIndicator()),
      );
    }

    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index != _selectedIndex) {
            AppHaptics.selection(context);
          }
          setState(() => _selectedIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.house),
            activeIcon: Icon(CupertinoIcons.house_fill),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chart_bar),
            activeIcon: Icon(CupertinoIcons.chart_bar_fill),
            label: '统计',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.list_bullet),
            activeIcon: Icon(CupertinoIcons.list_bullet),
            label: '记录',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.plus_circle),
            activeIcon: Icon(CupertinoIcons.plus_circle_fill),
            label: '补录',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.gear),
            activeIcon: Icon(CupertinoIcons.gear_solid),
            label: '设置',
          ),
        ],
      ),
      tabBuilder: (context, index) => CupertinoTabView(
        builder: (context) => pages[index],
      ),
    );
  }
}
