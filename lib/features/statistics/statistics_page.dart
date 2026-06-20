import 'package:flutter/cupertino.dart';

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
    final years = _availableYears();
    if (!years.contains(_year)) {
      _year = years.first;
    }
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
    final delta = summary.estimatedStayDays - previous.estimatedStayDays;
    final stackedSummary = context.appPrefersStackedLayout;

    return AppPage(
      title: '年度统计',
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: CupertinoSlidingSegmentedControl<int>(
            groupValue: _year,
            backgroundColor: context.appColor(AppColors.monthZero),
            thumbColor: context.appColor(AppColors.surface),
            children: {
              for (final year in years)
                year: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text('$year年'),
                ),
            },
            onValueChanged: (value) {
              if (value != null) {
                setState(() => _year = value);
              }
            },
          ),
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
              _AnnualSummaryMetric(
                stayDays: summary.estimatedStayDays,
                previousDays: previous.estimatedStayDays,
                delta: delta,
                stacked: stackedSummary,
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
                  _Legend(color: AppColors.monthZero, text: '0'),
                  _Legend(color: AppColors.monthLow, text: '1-10'),
                  _Legend(color: AppColors.monthMedium, text: '11-20'),
                  _Legend(color: AppColors.teal, text: '21-31'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          '统计结果基于你的入离港记录估算，可能存在误差。',
          textAlign: TextAlign.center,
          style: TextStyle(color: context.appColor(AppColors.muted)),
        ),
      ],
    );
  }

  List<int> _availableYears() {
    final years = <int>{
      widget.today.year,
      widget.today.year - 1,
      widget.today.year - 2,
    };
    for (final record in widget.records) {
      if (record.confirmationStatus == ConfirmationStatus.rejected) {
        continue;
      }
      years.add(record.entryDate.year);
      years.add((record.exitDate ?? widget.today).year);
    }
    return years.toList()..sort((a, b) => b.compareTo(a));
  }
}

class _AnnualSummaryMetric extends StatelessWidget {
  const _AnnualSummaryMetric({
    required this.stayDays,
    required this.previousDays,
    required this.delta,
    required this.stacked,
  });

  final int stayDays;
  final int previousDays;
  final int delta;
  final bool stacked;

  @override
  Widget build(BuildContext context) {
    final metric = RichText(
      text: TextSpan(
        style: context.appTextStyle(AppTextStyles.body),
        children: [
          TextSpan(
            text: '$stayDays',
            style: TextStyle(
              color: context.appColor(AppColors.teal),
              fontSize: 54,
              fontWeight: FontWeight.w800,
            ),
          ),
          const TextSpan(text: ' 天'),
        ],
      ),
    );
    final comparison = Column(
      crossAxisAlignment: stacked
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: [
        Text('去年同期 $previousDays 天'),
        Text(
          '较去年 ${delta >= 0 ? '+' : ''}$delta 天',
          style: TextStyle(color: context.appColor(AppColors.teal)),
        ),
      ],
    );

    if (stacked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [metric, const SizedBox(height: 8), comparison],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [metric, const Spacer(), comparison],
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
        ? AppColors.monthZero
        : value <= 10
        ? AppColors.monthLow
        : value <= 20
        ? AppColors.monthMedium
        : AppColors.teal;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 32, child: Text('$month月')),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 12,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: context.appColor(AppColors.monthZero),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: (value / 31).clamp(0, 1),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: context.appColor(color),
                        ),
                      ),
                    ),
                  ),
                ),
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
          Container(width: 10, height: 10, color: context.appColor(color)),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
