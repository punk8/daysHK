import 'package:flutter/cupertino.dart';

import '../../core/time/hk_date.dart';
import '../../domain/models/stay_record.dart';
import '../../domain/services/stay_statistics_service.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_notice.dart';
import '../../shared/widgets/cupertino_controls.dart';
import '../../shared/widgets/app_haptics.dart';
import '../../shared/widgets/page_scaffold.dart';

class ManualEntryPage extends StatefulWidget {
  const ManualEntryPage({
    super.key,
    required this.records,
    required this.statisticsService,
    required this.today,
    required this.onSave,
  });

  final List<StayRecord> records;
  final StayStatisticsService statisticsService;
  final DateTime today;
  final Future<void> Function(StayRecord record) onSave;

  @override
  State<ManualEntryPage> createState() => _ManualEntryPageState();
}

class _ManualEntryPageState extends State<ManualEntryPage> {
  late var _entryDate = normalizeDate(widget.today);
  late DateTime? _exitDate = normalizeDate(widget.today);
  var _sameDayRoundTrip = true;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final previewDays = inclusiveDateCount(
      _entryDate,
      _exitDate ?? widget.today,
    );
    final openRecord = _latestOpenRecord();

    return AppPage(
      title: '手动补录',
      trailing: CupertinoButton(
        minimumSize: const Size(36, 36),
        padding: EdgeInsets.zero,
        onPressed: () => showAppInfoDialog(
          context: context,
          title: '补录说明',
          message: '离港日期为空时，代表你目前仍在香港。统计按香港自然日估算。',
        ),
        child: Icon(
          CupertinoIcons.info_circle,
          color: context.appColor(AppColors.ink),
          semanticLabel: '说明',
        ),
      ),
      children: [
        if (openRecord != null) ...[
          AppCard(
            color: AppColors.info,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  CupertinoIcons.info_circle,
                  color: context.appColor(AppColors.teal),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '当前已有一条 ${dateKey(openRecord.entryDate)} 起仍在香港的记录。'
                    '如果要补录这段期间内的离港或往返，请先到“记录”页修正这条进行中记录。',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
        AppCupertinoDateField(
          label: '入港日期',
          date: _entryDate,
          onTap: () async {
            final picked = await _pickDate(_entryDate);
            if (picked != null) {
              setState(() {
                _entryDate = picked;
                if (_sameDayRoundTrip) {
                  _exitDate = picked;
                }
              });
            }
          },
        ),
        const SizedBox(height: 12),
        AppCupertinoDateField(
          label: '离港日期（可选）',
          date: _exitDate,
          onTap: () async {
            final picked = await _pickDate(_exitDate ?? _entryDate);
            if (picked != null) {
              setState(() => _exitDate = picked);
            }
          },
          onClear: () => setState(() {
            _exitDate = null;
            _sameDayRoundTrip = false;
          }),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '当天往返',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '未选择离港日期时，视为仍在香港。',
                      style: TextStyle(
                        color: context.appColor(AppColors.muted),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              CupertinoSwitch(
                value: _sameDayRoundTrip,
                activeTrackColor: AppColors.teal,
                onChanged: (value) {
                  AppHaptics.selection(context);
                  setState(() {
                    _sameDayRoundTrip = value;
                    if (_sameDayRoundTrip) {
                      _exitDate = _entryDate;
                    }
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        AppCard(
          color: AppColors.info,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('本次将计入在港天数'),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        style: context.appTextStyle(AppTextStyles.body),
                        children: [
                          TextSpan(
                            text: '$previewDays',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: context.appColor(AppColors.teal),
                            ),
                          ),
                          const TextSpan(text: ' 天'),
                        ],
                      ),
                    ),
                    const Text('按香港自然日统计，离港当日也计入在港天数。'),
                  ],
                ),
              ),
              Icon(
                CupertinoIcons.calendar,
                color: context.appColor(AppColors.teal),
              ),
            ],
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 10),
          Text(
            _error!,
            style: TextStyle(color: context.appColor(AppColors.red)),
          ),
        ],
        const SizedBox(height: 14),
        AppCupertinoButton(label: '保存记录', onPressed: _save),
      ],
    );
  }

  Future<DateTime?> _pickDate(DateTime initial) {
    return showAppDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(widget.today.year + 5),
      title: '选择日期',
    );
  }

  Future<void> _save() async {
    final now = DateTime.now();
    final record = StayRecord(
      id: now.microsecondsSinceEpoch.toString(),
      entryDate: normalizeDate(_entryDate),
      exitDate: _exitDate == null ? null : normalizeDate(_exitDate!),
      sameDayRoundTrip: _sameDayRoundTrip,
      source: RecordSource.manual,
      confirmationStatus: ConfirmationStatus.confirmed,
      createdAt: now,
      updatedAt: now,
    );

    final error = widget.statisticsService.validateRecord(
      record,
      widget.records,
      widget.today,
    );
    if (error != null) {
      setState(() => _error = error);
      if (mounted) {
        AppNotice.show(context, error);
      }
      return;
    }

    setState(() => _error = null);
    await widget.onSave(record);
    if (mounted) {
      AppNotice.show(context, '记录已保存');
    }
  }

  StayRecord? _latestOpenRecord() {
    final active =
        widget.records
            .where(
              (record) =>
                  record.exitDate == null &&
                  record.confirmationStatus != ConfirmationStatus.rejected,
            )
            .toList()
          ..sort((a, b) => b.entryDate.compareTo(a.entryDate));
    return active.isEmpty ? null : active.first;
  }
}
