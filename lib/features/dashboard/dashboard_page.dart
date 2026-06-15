import 'package:flutter/material.dart';

import '../../core/time/hk_date.dart';
import '../../domain/models/stay_record.dart';
import '../../domain/services/stay_statistics_service.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/badges.dart';
import '../../shared/widgets/page_scaffold.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    super.key,
    required this.records,
    required this.statisticsService,
    required this.today,
    required this.onManualEntry,
  });

  final List<StayRecord> records;
  final StayStatisticsService statisticsService;
  final DateTime today;
  final VoidCallback onManualEntry;

  @override
  Widget build(BuildContext context) {
    final summary = statisticsService.buildAnnualSummary(
      records: records,
      year: today.year,
      today: today,
    );
    final latest = records.isEmpty ? null : records.first;
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
        const SizedBox(height: 14),
        AppCard(
          color: AppColors.warning,
          child: Row(
            children: [
              const Icon(Icons.location_off_outlined, color: Colors.orange),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '定位权限：受限',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 4),
                    Text('建议开启“始终允许”，以获得更准确的自动记录。'),
                  ],
                ),
              ),
              TextButton(onPressed: () {}, child: const Text('去设置')),
            ],
          ),
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: onManualEntry,
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('手动补录'),
        ),
      ],
    );
  }

  _Presence _currentPresence(List<StayRecord> records) {
    if (records.any(
      (record) =>
          record.confirmationStatus == ConfirmationStatus.needsConfirmation,
    )) {
      return const _Presence('需要确认记录', '有自动检测记录等待确认', 0);
    }
    if (records.isEmpty) {
      return const _Presence('当前不在香港', '暂无入港记录', 0);
    }
    final sorted = [...records]
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
