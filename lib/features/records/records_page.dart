import 'package:flutter/material.dart';

import '../../core/time/hk_date.dart';
import '../../domain/models/stay_record.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/badges.dart';
import '../../shared/widgets/page_scaffold.dart';

class RecordsPage extends StatelessWidget {
  const RecordsPage({
    super.key,
    required this.records,
    required this.onSave,
    required this.onDelete,
  });

  final List<StayRecord> records;
  final Future<void> Function(StayRecord record) onSave;
  final Future<void> Function(String id) onDelete;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: '入离港记录',
      children: [
        if (records.isEmpty)
          const AppCard(child: Text('暂无记录。可以先去“补录”添加一条记录。'))
        else
          for (final group in _groupByMonth(records).entries) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 10, top: 4),
              child: Text(
                group.key,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            for (final record in group.value)
              _RecordTile(
                record: record,
                onSave: onSave,
                onDelete: onDelete,
              ),
            const SizedBox(height: 8),
          ],
      ],
    );
  }

  Map<String, List<StayRecord>> _groupByMonth(List<StayRecord> records) {
    final groups = <String, List<StayRecord>>{};
    for (final record in records) {
      final key = '${record.entryDate.year}年${record.entryDate.month}月';
      groups.putIfAbsent(key, () => []).add(record);
    }
    return groups;
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({
    required this.record,
    required this.onSave,
    required this.onDelete,
  });

  final StayRecord record;
  final Future<void> Function(StayRecord record) onSave;
  final Future<void> Function(String id) onDelete;

  @override
  Widget build(BuildContext context) {
    final isExit = record.exitDate != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: isExit ? AppColors.red : AppColors.teal,
                  child: Icon(
                    isExit ? Icons.logout : Icons.login,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isExit ? '入离港记录' : '入港记录',
                        style: TextStyle(
                          color: isExit ? AppColors.red : AppColors.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${dateKey(record.entryDate)}'
                        '${record.exitDate == null ? '' : ' 至 ${dateKey(record.exitDate!)}'}',
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'confirm') {
                      await onSave(
                        record.copyWith(
                          confirmationStatus: ConfirmationStatus.confirmed,
                          source: RecordSource.userConfirmed,
                          updatedAt: DateTime.now(),
                        ),
                      );
                    } else if (value == 'edit') {
                      await _showEditRecordDialog(
                        context: context,
                        record: record,
                        onSave: onSave,
                      );
                    } else if (value == 'delete') {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('删除记录'),
                          content: const Text('删除后将同步更新统计结果。'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('取消'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('删除'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        await onDelete(record.id);
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    if (record.confirmationStatus ==
                        ConfirmationStatus.needsConfirmation)
                      const PopupMenuItem(
                        value: 'confirm',
                        child: Text('确认记录'),
                      ),
                    const PopupMenuItem(value: 'edit', child: Text('编辑 / 修正')),
                    const PopupMenuItem(value: 'delete', child: Text('删除')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                SourceBadge(source: record.source),
                ConfirmationBadge(status: record.confirmationStatus),
                if (record.locationName != null)
                  Chip(
                    avatar: const Icon(Icons.place_outlined, size: 16),
                    label: Text(record.locationName!),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            if (record.confirmationStatus ==
                ConfirmationStatus.needsConfirmation) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => onSave(
                        record.copyWith(
                          confirmationStatus: ConfirmationStatus.rejected,
                          updatedAt: DateTime.now(),
                        ),
                      ),
                      child: const Text('忽略'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => _showEditRecordDialog(
                        context: context,
                        record: record,
                        onSave: onSave,
                        confirmAfterSave: true,
                      ),
                      child: const Text('修正'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => onSave(
                        record.copyWith(
                          confirmationStatus: ConfirmationStatus.confirmed,
                          source: RecordSource.userConfirmed,
                          updatedAt: DateTime.now(),
                        ),
                      ),
                      child: const Text('确认'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Future<void> _showEditRecordDialog({
  required BuildContext context,
  required StayRecord record,
  required Future<void> Function(StayRecord record) onSave,
  bool confirmAfterSave = false,
}) async {
  final updated = await showDialog<StayRecord>(
    context: context,
    builder: (context) =>
        _EditRecordDialog(record: record, confirmAfterSave: confirmAfterSave),
  );
  if (updated != null) {
    await onSave(updated);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('记录已更新')));
    }
  }
}

class _EditRecordDialog extends StatefulWidget {
  const _EditRecordDialog({
    required this.record,
    required this.confirmAfterSave,
  });

  final StayRecord record;
  final bool confirmAfterSave;

  @override
  State<_EditRecordDialog> createState() => _EditRecordDialogState();
}

class _EditRecordDialogState extends State<_EditRecordDialog> {
  late var _entryDate = widget.record.entryDate;
  late DateTime? _exitDate = widget.record.exitDate;
  late final TextEditingController _locationController = TextEditingController(
    text: widget.record.locationName ?? '',
  );
  late final TextEditingController _transportController = TextEditingController(
    text: widget.record.transportMode ?? '',
  );
  late final TextEditingController _noteController = TextEditingController(
    text: widget.record.note ?? '',
  );
  String? _error;

  @override
  void dispose() {
    _locationController.dispose();
    _transportController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('编辑记录'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _EditableDateField(
                label: '入港日期',
                date: _entryDate,
                onTap: () async {
                  final picked = await _pickDate(_entryDate);
                  if (picked != null) {
                    setState(() => _entryDate = picked);
                  }
                },
              ),
              const SizedBox(height: 12),
              _EditableDateField(
                label: '离港日期（可选）',
                date: _exitDate,
                onTap: () async {
                  final picked = await _pickDate(_exitDate ?? _entryDate);
                  if (picked != null) {
                    setState(() => _exitDate = picked);
                  }
                },
                onClear: () => setState(() => _exitDate = null),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('record-edit-location-field'),
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: '口岸 / 地点',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _transportController,
                decoration: const InputDecoration(
                  labelText: '交通方式',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _noteController,
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: '备注',
                  border: OutlineInputBorder(),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!, style: const TextStyle(color: AppColors.red)),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(onPressed: _save, child: const Text('保存')),
      ],
    );
  }

  Future<DateTime?> _pickDate(DateTime initial) {
    return showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      helpText: '选择日期',
    );
  }

  void _save() {
    if (_exitDate != null && _exitDate!.isBefore(_entryDate)) {
      setState(() => _error = '离港日期不能早于入港日期');
      return;
    }

    final now = DateTime.now();
    final locationName = _emptyToNull(_locationController.text);
    final transportMode = _emptyToNull(_transportController.text);
    final note = _emptyToNull(_noteController.text);
    Navigator.pop(
      context,
      widget.record.copyWith(
        entryDate: normalizeDate(_entryDate),
        exitDate: _exitDate == null ? null : normalizeDate(_exitDate!),
        clearExitDate: _exitDate == null,
        sameDayRoundTrip:
            _exitDate != null && dateKey(_entryDate) == dateKey(_exitDate!),
        locationName: locationName,
        clearLocationName: locationName == null,
        transportMode: transportMode,
        clearTransportMode: transportMode == null,
        note: note,
        clearNote: note == null,
        source: widget.confirmAfterSave
            ? RecordSource.userConfirmed
            : widget.record.source,
        confirmationStatus: widget.confirmAfterSave
            ? ConfirmationStatus.confirmed
            : widget.record.confirmationStatus,
        updatedAt: now,
      ),
    );
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

class _EditableDateField extends StatelessWidget {
  const _EditableDateField({
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
                  tooltip: '清空日期',
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
