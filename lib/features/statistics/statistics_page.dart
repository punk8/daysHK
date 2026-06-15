import 'package:flutter/material.dart';

import '../../core/time/hk_date.dart';
import '../../domain/models/stay_record.dart';
import '../../domain/services/stay_statistics_service.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/page_scaffold.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({
    super.key,
    required this.records,
    required this.statisticsService,
    required this.today,
  });

  final List<StayRecord> records;
  final StayStatisticsService statisticsService;
  final DateTime today;

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  late int _year = widget.today.year;

  @override
  Widget build(BuildContext context) {
    final summary = widget.statisticsService.buildAnnualSummary(
      records: widget.records,
      year: _year,
      today: widget.today,
    );
    final previous = widget.statisticsService.buildAnnualSummary(
      records: widget.records,
      year: _year - 1,
      today: widget.today,
    );

    return AppPage(
      title: '年度统计',
      children: [
        SegmentedButton<int>(
          segments: [
            for (final year in [
              widget.today.year,
              widget.today.year - 1,
              widget.today.year - 2,
            ])
              ButtonSegment(value: year, label: Text('$year年')),
          ],
          selected: {_year},
          onSelectionChanged: (selection) =>
              setState(() => _year = selection.first),
        ),
        const SizedBox(height: 14),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$_year年（截至 ${widget.today.month}月${widget.today.day}日）'),
              const SizedBox(height: 6),
              const Text('估算在港天数'),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${summary.estimatedStayDays}',
                    style: const TextStyle(
                      color: AppColors.teal,
                      fontSize: 54,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 11),
                    child: Text(' 天'),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('去年同期 ${previous.estimatedStayDays} 天'),
                      Text(
                        '较去年 ${summary.estimatedStayDays - previous.estimatedStayDays >= 0 ? '+' : ''}${summary.estimatedStayDays - previous.estimatedStayDays} 天',
                        style: const TextStyle(color: AppColors.teal),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text('仅供个人记录参考'),
            ],
          ),
        ),
        const SizedBox(height: 14),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('按月分布', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),
              for (var month = 1; month <= 12; month++)
                _MonthBar(
                  month: month,
                  value: summary.monthlyCounts[month] ?? 0,
                ),
              const SizedBox(height: 8),
              const Row(
                children: [
                  _Legend(color: Color(0xFFE8EEF0), text: '0'),
                  _Legend(color: Color(0xFF9DDADB), text: '1-10'),
                  _Legend(color: Color(0xFF36B9BA), text: '11-20'),
                  _Legend(color: AppColors.teal, text: '21-31'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        AppCard(
          color: summary.absenceAlerts.isEmpty
              ? AppColors.info
              : const Color(0xFFFFF1F1),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                summary.absenceAlerts.isEmpty
                    ? Icons.check_circle_outline
                    : Icons.warning_amber_rounded,
                color: summary.absenceAlerts.isEmpty
                    ? AppColors.teal
                    : AppColors.red,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '连续离港提醒',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      summary.absenceAlerts.isEmpty
                          ? '暂未发现连续离港超过 6 个月的记录。'
                          : '发现连续离港超过 6 个月的期间，可能需要解释或留证。',
                    ),
                    for (final alert in summary.absenceAlerts) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${dateKey(alert.startDate)} 至 ${dateKey(alert.endDate)}，共 ${alert.days} 天',
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          '统计结果基于你的入离港记录估算，可能存在误差。',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.muted),
        ),
      ],
    );
  }
}

class _MonthBar extends StatelessWidget {
  const _MonthBar({required this.month, required this.value});

  final int month;
  final int value;

  @override
  Widget build(BuildContext context) {
    final color = value == 0
        ? const Color(0xFFE8EEF0)
        : value <= 10
        ? const Color(0xFF9DDADB)
        : value <= 20
        ? const Color(0xFF36B9BA)
        : AppColors.teal;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 32, child: Text('$month月')),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value / 31,
                minHeight: 12,
                backgroundColor: const Color(0xFFE8EEF0),
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(width: 34, child: Text('$value天')),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.text});

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Row(
        children: [
          Container(width: 10, height: 10, color: color),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
