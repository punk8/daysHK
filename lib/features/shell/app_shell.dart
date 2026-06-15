import 'package:flutter/material.dart';

import '../../app/bootstrap.dart';
import '../../core/time/hk_date.dart';
import '../../data/exports/csv_exporter.dart';
import '../../domain/models/stay_record.dart';
import '../../domain/services/stay_statistics_service.dart';
import '../dashboard/dashboard_page.dart';
import '../manual_entry/manual_entry_page.dart';
import '../records/records_page.dart';
import '../settings/settings_page.dart';
import '../statistics/statistics_page.dart';

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
  var _isLoading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final records = await widget.dependencies.records.listRecords();
    setState(() {
      _records = records;
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

  @override
  Widget build(BuildContext context) {
    final today = hkToday();
    final pages = [
      DashboardPage(
        records: _records,
        statisticsService: _statisticsService,
        today: today,
        onManualEntry: () => setState(() => _selectedIndex = 3),
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
        boundary: widget.dependencies.boundary,
        locationDetection: widget.dependencies.locationDetection,
        locationPermission: widget.dependencies.locationPermission,
        nativeGeofence: widget.dependencies.nativeGeofence,
        exporter: CsvExporter(_statisticsService),
        today: today,
        onSaveCandidate: _saveRecord,
        onClearAll: _clearAll,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: pages[_selectedIndex],
              ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: '首页'),
          NavigationDestination(icon: Icon(Icons.map_outlined), label: '统计'),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            label: '记录',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            label: '补录',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: '设置',
          ),
        ],
      ),
    );
  }
}
