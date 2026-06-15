import 'package:flutter/material.dart';

import '../../core/time/hk_date.dart';
import '../../domain/models/stay_record.dart';
import '../../domain/services/stay_statistics_service.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/app_card.dart';
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
  final _locationController = TextEditingController();
  final _noteController = TextEditingController();
  late var _entryDate = normalizeDate(widget.today);
  late DateTime? _exitDate = normalizeDate(widget.today);
  var _sameDayRoundTrip = true;
  String? _transportMode;
  String? _error;

  @override
  void dispose() {
    _locationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final previewDays = inclusiveDateCount(
      _entryDate,
      _exitDate ?? widget.today,
    );
    final openRecord = _latestOpenRecord();

    return AppPage(
      title: '手动补录',
      trailing: IconButton(
        tooltip: '说明',
        onPressed: () => showDialog<void>(
          context: context,
          builder: (context) => const AlertDialog(
            title: Text('补录说明'),
            content: Text('离港日期为空时，代表你目前仍在香港。统计按香港自然日估算。'),
          ),
        ),
        icon: const Icon(Icons.info_outline),
      ),
      children: [
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: true, label: Text('入港')),
            ButtonSegment(value: false, label: Text('离港')),
          ],
          selected: const {true},
          onSelectionChanged: (_) {},
        ),
        const SizedBox(height: 14),
        if (openRecord != null) ...[
          AppCard(
            color: AppColors.info,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: AppColors.teal),
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
        _DateField(
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
        _DateField(
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
        CheckboxListTile(
          value: _sameDayRoundTrip,
          onChanged: (value) {
            setState(() {
              _sameDayRoundTrip = value ?? false;
              if (_sameDayRoundTrip) {
                _exitDate = _entryDate;
              }
            });
          },
          title: const Text('当天往返'),
          subtitle: const Text('未选择离港日期时，视为仍在香港。'),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        TextField(
          controller: _locationController,
          decoration: const InputDecoration(
            labelText: '口岸 / 地点',
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.place_outlined),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _transportMode,
          decoration: const InputDecoration(
            labelText: '交通方式（可选）',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: '', child: Text('未选择')),
            DropdownMenuItem(value: '飞机', child: Text('飞机')),
            DropdownMenuItem(value: '高铁', child: Text('高铁')),
            DropdownMenuItem(value: '巴士', child: Text('巴士')),
            DropdownMenuItem(value: '口岸步行', child: Text('口岸步行')),
          ],
          onChanged: (value) => setState(
            () => _transportMode = value?.isEmpty == true ? null : value,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _noteController,
          maxLength: 100,
          minLines: 2,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: '备注（可选）',
            border: OutlineInputBorder(),
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
                        style: Theme.of(context).textTheme.bodyMedium,
                        children: [
                          TextSpan(
                            text: '$previewDays',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: AppColors.teal,
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
              const Icon(Icons.calendar_month_outlined, color: AppColors.teal),
            ],
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 10),
          Text(_error!, style: const TextStyle(color: AppColors.red)),
        ],
        const SizedBox(height: 14),
        FilledButton(onPressed: _save, child: const Text('保存记录')),
      ],
    );
  }

  Future<DateTime?> _pickDate(DateTime initial) {
    return showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(widget.today.year + 5),
      helpText: '选择日期',
    );
  }

  Future<void> _save() async {
    final now = DateTime.now();
    final record = StayRecord(
      id: now.microsecondsSinceEpoch.toString(),
      entryDate: normalizeDate(_entryDate),
      exitDate: _exitDate == null ? null : normalizeDate(_exitDate!),
      sameDayRoundTrip: _sameDayRoundTrip,
      locationName: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      transportMode: _transportMode,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
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
      return;
    }

    setState(() => _error = null);
    await widget.onSave(record);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('记录已保存')));
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

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
    this.onClear,
  });

  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onClear != null && date != null)
                IconButton(
                  tooltip: '清空',
                  onPressed: onClear,
                  icon: const Icon(Icons.close),
                ),
              const Icon(Icons.calendar_today_outlined),
              const SizedBox(width: 10),
            ],
          ),
        ),
        child: Text(date == null ? '未选择' : dateKey(date!)),
      ),
    );
  }
}
