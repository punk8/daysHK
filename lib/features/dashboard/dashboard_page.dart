import 'package:flutter/material.dart';

import '../../core/time/hk_date.dart';
import '../../domain/models/stay_record.dart';
import '../../domain/services/stay_statistics_service.dart';
import '../../location/permissions/location_permission_status.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/badges.dart';
import '../../shared/widgets/page_scaffold.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    super.key,
    required this.records,
    required this.statisticsService,
    required this.locationPermissionStatus,
    required this.today,
    required this.onManualEntry,
    required this.onOpenSettings,
  });

  final List<StayRecord> records;
  final StayStatisticsService statisticsService;
  final AppLocationPermissionStatus locationPermissionStatus;
  final DateTime today;
  final VoidCallback onManualEntry;
  final Future<void> Function() onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final summary = statisticsService.buildAnnualSummary(
      records: records,
      year: today.year,
      today: today,
    );
    final recordsUpToToday = _recordsUpToToday(records);
    final latest = recordsUpToToday.isEmpty ? null : recordsUpToToday.first;
    final current = _currentPresence(records);
    final longest = _longestStay(records);

    return AppPage(
      title: '在港日记',
      subtitle: '按香港自然日统计',
      trailing: IconButton(
        tooltip: '通知',
        onPressed: () {},
        icon: const Icon(Icons.notifications_none),
      ),
      children: [
        AppCard(
          color: AppColors.info,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('当前状态'),
                    const SizedBox(height: 10),
                    Text(
                      current.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.teal,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(current.subtitle),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 34,
                backgroundColor: AppColors.teal.withValues(alpha: 0.12),
                child: const Icon(
                  Icons.location_city,
                  color: AppColors.teal,
                  size: 34,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        AppCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '今年估算在港天数',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text('${today.year}年（截至 ${today.month}月${today.day}日）'),
                    const SizedBox(height: 12),
                    RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium,
                        children: [
                          TextSpan(
                            text: '${summary.estimatedStayDays}',
                            style: const TextStyle(
                              color: AppColors.teal,
                              fontSize: 52,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const TextSpan(text: ' 天'),
                        ],
                      ),
                    ),
                    const Text('仅供个人记录参考'),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 130,
                color: AppColors.border,
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),
              SizedBox(
                width: 116,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('当前连续在港'),
                    const SizedBox(height: 6),
                    _SideMetric(value: current.continuousDays, unit: '天'),
                    const Divider(height: 28),
                    const Text('最长连续在港'),
                    const SizedBox(height: 6),
                    _SideMetric(value: longest, unit: '天'),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        AppCard(
          child: latest == null
              ? const _EmptyRecent()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '最近记录',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.teal,
                          child: Icon(
                            latest.exitDate == null
                                ? Icons.login
                                : Icons.compare_arrows,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                latest.exitDate == null ? '入港' : '入离港记录',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '${dateKey(latest.entryDate)}'
                                '${latest.exitDate == null ? '' : ' 至 ${dateKey(latest.exitDate!)}'}',
                              ),
                              if (latest.locationName != null)
                                Text(latest.locationName!),
                            ],
                          ),
                        ),
                        ConfirmationBadge(status: latest.confirmationStatus),
                      ],
                    ),
                  ],
                ),
        ),
        if (locationPermissionStatus != AppLocationPermissionStatus.ready) ...[
          const SizedBox(height: 14),
          AppCard(
            color: AppColors.warning,
            child: Row(
              children: [
                const Icon(Icons.location_off_outlined, color: Colors.orange),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _permissionTitle,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(_permissionMessage),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: onOpenSettings,
                  child: const Text('去设置'),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: onManualEntry,
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('手动补录'),
        ),
      ],
    );
  }

  String get _permissionTitle {
    return switch (locationPermissionStatus) {
      AppLocationPermissionStatus.serviceDisabled => '定位服务：关闭',
      AppLocationPermissionStatus.denied ||
      AppLocationPermissionStatus.deniedForever => '定位权限：未授权',
      AppLocationPermissionStatus.whileInUseOnly => '定位权限：受限',
      AppLocationPermissionStatus.unknown => '定位权限：未知',
      AppLocationPermissionStatus.ready => '定位权限：正常',
    };
  }

  String get _permissionMessage {
    return switch (locationPermissionStatus) {
      AppLocationPermissionStatus.serviceDisabled => '请开启 iOS 定位服务后再使用自动记录。',
      AppLocationPermissionStatus.denied ||
      AppLocationPermissionStatus.deniedForever => '请在系统设置中允许定位权限。',
      AppLocationPermissionStatus.whileInUseOnly => '建议开启“始终允许”，以获得更准确的自动记录。',
      AppLocationPermissionStatus.unknown => '建议检查定位权限，以确认自动记录可用。',
      AppLocationPermissionStatus.ready => '定位记录已准备就绪。',
    };
  }

  _Presence _currentPresence(List<StayRecord> records) {
    final recordsUpToToday = _recordsUpToToday(records);
    if (recordsUpToToday.any(
      (record) =>
          record.confirmationStatus == ConfirmationStatus.needsConfirmation,
    )) {
      return const _Presence('需要确认记录', '有自动检测记录等待确认', 0);
    }
    if (recordsUpToToday.isEmpty) {
      return const _Presence('当前不在香港', '暂无入港记录', 0);
    }
    final sorted = [...recordsUpToToday]
      ..sort((a, b) => b.entryDate.compareTo(a.entryDate));
    final latest = sorted.first;
    if (latest.exitDate == null) {
      return _Presence(
        '当前在香港',
        '自 ${dateKey(latest.entryDate)} 开始',
        inclusiveDateCount(latest.entryDate, today),
      );
    }
    return _Presence('当前不在香港', '最近离港 ${dateKey(latest.exitDate!)}', 0);
  }

  List<StayRecord> _recordsUpToToday(List<StayRecord> records) {
    final normalizedToday = normalizeDate(today);
    return records
        .where(
          (record) =>
              !normalizeDate(record.entryDate).isAfter(normalizedToday) &&
              record.confirmationStatus != ConfirmationStatus.rejected,
        )
        .toList();
  }

  int _longestStay(List<StayRecord> records) {
    var longest = 0;
    for (final record in records) {
      final days = statisticsService.stayDaysForRecord(record, today);
      if (days > longest) {
        longest = days;
      }
    }
    return longest;
  }
}

class _SideMetric extends StatelessWidget {
  const _SideMetric({required this.value, required this.unit});

  final int value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyMedium,
        children: [
          TextSpan(
            text: '$value',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          TextSpan(text: ' $unit'),
        ],
      ),
    );
  }
}

class _EmptyRecent extends StatelessWidget {
  const _EmptyRecent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('最近记录', style: TextStyle(fontWeight: FontWeight.w700)),
        SizedBox(height: 12),
        Text('暂无记录。可以先手动补录一次入港或离港。'),
      ],
    );
  }
}

class _Presence {
  const _Presence(this.title, this.subtitle, this.continuousDays);

  final String title;
  final String subtitle;
  final int continuousDays;
}
