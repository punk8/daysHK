import 'package:flutter/cupertino.dart';

import '../../core/time/hk_date.dart';
import '../../domain/models/stay_record.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_notice.dart';
import '../../shared/widgets/badges.dart';
import '../../shared/widgets/cupertino_controls.dart';
import '../../shared/widgets/app_haptics.dart';
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
                style: AppTextStyles.section,
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
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: context.appColor(
                      isExit ? AppColors.red : AppColors.teal,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: Icon(
                      isExit
                          ? CupertinoIcons.arrow_up_right
                          : CupertinoIcons.arrow_down_left,
                      color: CupertinoColors.white,
                      size: 18,
                    ),
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
                          color: context.appColor(
                            isExit ? AppColors.red : AppColors.ink,
                          ),
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
                CupertinoButton(
                  minimumSize: const Size(36, 36),
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    AppHaptics.selection(context);
                    _showRecordActions(context);
                  },
                  child: Icon(
                    CupertinoIcons.ellipsis_circle,
                    color: context.appColor(AppColors.muted),
                  ),
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
                  _LocationBadge(label: record.locationName!),
              ],
            ),
            if (record.confirmationStatus ==
                ConfirmationStatus.needsConfirmation) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppCupertinoButton(
                      label: '忽略',
                      filled: false,
                      onPressed: () => onSave(
                        record.copyWith(
                          confirmationStatus: ConfirmationStatus.rejected,
                          updatedAt: DateTime.now(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppCupertinoButton(
                      label: '修正',
                      onPressed: () => _showEditRecordDialog(
                        context: context,
                        record: record,
                        onSave: onSave,
                        confirmAfterSave: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppCupertinoButton(
                      label: '确认',
                      onPressed: () => onSave(
                        record.copyWith(
                          confirmationStatus: ConfirmationStatus.confirmed,
                          source: RecordSource.userConfirmed,
                          updatedAt: DateTime.now(),
                        ),
                      ),
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

  Future<void> _showRecordActions(BuildContext context) async {
    final value = await showCupertinoModalPopup<String>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('记录操作'),
        actions: [
          if (record.confirmationStatus == ConfirmationStatus.needsConfirmation)
            CupertinoActionSheetAction(
              onPressed: () {
                AppHaptics.selection(context);
                Navigator.pop(context, 'confirm');
              },
              child: const Text('确认记录'),
            ),
          CupertinoActionSheetAction(
            onPressed: () {
              AppHaptics.selection(context);
              Navigator.pop(context, 'edit');
            },
            child: const Text('编辑 / 修正'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              AppHaptics.selection(context);
              Navigator.pop(context, 'delete');
            },
            child: const Text('删除'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
      ),
    );

    if (!context.mounted || value == null) {
      return;
    }
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
      final confirmed = await showAppConfirmationDialog(
        context: context,
        title: '删除记录',
        message: '删除后将同步更新统计结果。',
        confirmLabel: '删除',
        destructive: true,
      );
      if (confirmed) {
        await onDelete(record.id);
      }
    }
  }
}

class _LocationBadge extends StatelessWidget {
  const _LocationBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.appColor(AppColors.info),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.placemark,
              size: 14,
              color: context.appColor(AppColors.teal),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: context.appColor(AppColors.ink),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
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
  final updated = await showCupertinoModalPopup<StayRecord>(
    context: context,
    builder: (context) => _EditRecordSheet(
      record: record,
      confirmAfterSave: confirmAfterSave,
    ),
  );
  if (updated != null) {
    await onSave(updated);
    if (context.mounted) {
      AppNotice.show(context, '记录已更新');
    }
  }
}

class _EditRecordSheet extends StatefulWidget {
  const _EditRecordSheet({
    required this.record,
    required this.confirmAfterSave,
  });

  final StayRecord record;
  final bool confirmAfterSave;

  @override
  State<_EditRecordSheet> createState() => _EditRecordSheetState();
}

class _EditRecordSheetState extends State<_EditRecordSheet> {
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
    return CupertinoPopupSurface(
      child: SafeArea(
        top: false,
        child: CupertinoTheme(
          data: CupertinoTheme.of(context),
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.82,
            child: Column(
              children: [
                SizedBox(
                  height: 52,
                  child: Row(
                    children: [
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('取消'),
                      ),
                      const Expanded(
                        child: Text(
                          '编辑记录',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        onPressed: _save,
                        child: const Text(
                          '保存',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(height: 1, color: context.appColor(AppColors.border)),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        AppCupertinoDateField(
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
                        AppCupertinoDateField(
                          label: '离港日期（可选）',
                          date: _exitDate,
                          onTap: () async {
                            final picked = await _pickDate(
                              _exitDate ?? _entryDate,
                            );
                            if (picked != null) {
                              setState(() => _exitDate = picked);
                            }
                          },
                          onClear: () => setState(() => _exitDate = null),
                        ),
                        const SizedBox(height: 12),
                        AppCupertinoTextField(
                          label: '口岸 / 地点',
                          fieldKey: const Key('record-edit-location-field'),
                          controller: _locationController,
                        ),
                        const SizedBox(height: 12),
                        AppCupertinoTextField(
                          label: '交通方式',
                          controller: _transportController,
                        ),
                        const SizedBox(height: 12),
                        AppCupertinoTextField(
                          label: '备注',
                          controller: _noteController,
                          minLines: 2,
                          maxLines: 3,
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            _error!,
                            style: TextStyle(
                              color: context.appColor(AppColors.red),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<DateTime?> _pickDate(DateTime initial) {
    return showAppDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      title: '选择日期',
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
