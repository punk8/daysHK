import 'package:flutter/widgets.dart';

import '../../core/time/hk_date.dart';
import '../../domain/models/stay_record.dart';
import '../../domain/services/stay_statistics_service.dart';
import '../../location/permissions/location_permission_status.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/theme/platform_icons.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/badges.dart';
import '../../shared/widgets/cupertino_controls.dart';
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
    final stackedMetrics = context.appPrefersStackedLayout;

    return AppPage(
      title: '在港日记',
      subtitle: '按香港自然日统计',
      trailing: AppIconButton(
        icon: AppPlatformIcon.notifications(context),
        label: '通知',
        hint: '打开通知设置',
        onPressed: () {},
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
                      style: AppTextStyles.title.copyWith(
                        color: AppColors.teal,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(current.subtitle),
                  ],
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: context
                      .appColor(AppColors.teal)
                      .withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: SizedBox(
                  width: 68,
                  height: 68,
                  child: ExcludeSemantics(
                    child: Icon(
                      AppPlatformIcon.building(context),
                      color: context.appColor(AppColors.teal),
                      size: 34,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        AppCard(
          child: stackedMetrics
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AnnualMetric(
                      year: today.year,
                      month: today.month,
                      day: today.day,
                      stayDays: summary.estimatedStayDays,
                    ),
                    Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      color: context.appColor(AppColors.border),
                    ),
                    _SideMetrics(
                      currentDays: current.continuousDays,
                      longestDays: longest,
                      stacked: true,
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _AnnualMetric(
                        year: today.year,
                        month: today.month,
                        day: today.day,
                        stayDays: summary.estimatedStayDays,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 130,
                      color: context.appColor(AppColors.border),
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    SizedBox(
                      width: 116,
                      child: _SideMetrics(
                        currentDays: current.continuousDays,
                        longestDays: longest,
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
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: context.appColor(AppColors.teal),
                            shape: BoxShape.circle,
                          ),
                          child: SizedBox(
                            width: 40,
                            height: 40,
                            child: ExcludeSemantics(
                              child: Icon(
                                latest.exitDate == null
                                    ? AppPlatformIcon.entry(context)
                                    : AppPlatformIcon.roundTrip(context),
                                color: const Color(0xFFFFFFFF),
                              ),
                            ),
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
                ExcludeSemantics(
                  child: Icon(
                    AppPlatformIcon.locationOff(context),
                    color: context.appColor(AppColors.warningText),
                  ),
                ),
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
                AppTextButton(
                  label: '去设置',
                  hint: '打开系统设置调整定位权限',
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  onPressed: onOpenSettings,
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 14),
        AppButton(
          label: '手动补录',
          icon: AppPlatformIcon.addRecord(context),
          fullWidth: true,
          semanticHint: '打开手动补录页面',
          onPressed: onManualEntry,
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
      AppLocationPermissionStatus.serviceDisabled => '请开启系统定位服务后再使用自动记录。',
      AppLocationPermissionStatus.denied ||
      AppLocationPermissionStatus.deniedForever => '请在系统设置中允许定位权限。',
      AppLocationPermissionStatus.whileInUseOnly => '建议开启后台定位权限，以获得更准确的自动记录。',
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

class _AnnualMetric extends StatelessWidget {
  const _AnnualMetric({
    required this.year,
    required this.month,
    required this.day,
    required this.stayDays,
  });

  final int year;
  final int month;
  final int day;
  final int stayDays;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('今年估算在港天数', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text('$year年（截至 $month月$day日）'),
        const SizedBox(height: 12),
        RichText(
          text: TextSpan(
            style: context.appTextStyle(AppTextStyles.body),
            children: [
              TextSpan(
                text: '$stayDays',
                style: TextStyle(
                  color: context.appColor(AppColors.teal),
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
    );
  }
}

class _SideMetrics extends StatelessWidget {
  const _SideMetrics({
    required this.currentDays,
    required this.longestDays,
    this.stacked = false,
  });

  final int currentDays;
  final int longestDays;
  final bool stacked;

  @override
  Widget build(BuildContext context) {
    if (stacked) {
      return Wrap(
        spacing: 24,
        runSpacing: 14,
        children: [
          _SideMetricBlock(label: '当前连续在港', value: currentDays),
          _SideMetricBlock(label: '最长连续在港', value: longestDays),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SideMetricBlock(label: '当前连续在港', value: currentDays),
        Container(
          height: 1,
          margin: const EdgeInsets.symmetric(vertical: 14),
          color: context.appColor(AppColors.border),
        ),
        _SideMetricBlock(label: '最长连续在港', value: longestDays),
      ],
    );
  }
}

class _SideMetricBlock extends StatelessWidget {
  const _SideMetricBlock({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label$value天',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 6),
          _SideMetric(value: value, unit: '天'),
        ],
      ),
    );
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
        style: context.appTextStyle(AppTextStyles.body),
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
