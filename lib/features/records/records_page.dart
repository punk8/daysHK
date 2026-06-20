import 'package:flutter/cupertino.dart';

import '../../core/time/hk_date.dart';
import '../../domain/models/stay_record.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/theme/platform_icons.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_empty_state.dart';
import '../../shared/widgets/app_notice.dart';
import '../../shared/widgets/badges.dart';
import '../../shared/widgets/cupertino_controls.dart';
import '../../shared/theme/platform_style.dart';
import '../../shared/widgets/page_scaffold.dart';

class RecordsPage extends StatelessWidget {
  const RecordsPage({
    super.key,
    required this.records,
    required this.onSave,
    required this.onDelete,
    required this.onManualEntry,
  });

  final List<StayRecord> records;
  final Future<void> Function(StayRecord record) onSave;
  final Future<void> Function(String id) onDelete;
  final VoidCallback onManualEntry;

  @override
  Widget build(BuildContext context) {
    final timelineItems = _buildTimelineItems();
    return AppSliverPage(
      title: '入离港记录',
      slivers: [
        if (records.isEmpty)
          AppSliverSection(
            child: AppEmptyState(
              icon: AppPlatformIcon.records(context),
              title: '暂无入离港记录',
              message: '添加第一条入港或离港时间后，这里会按月份整理你的记录。',
              actionLabel: '手动补录',
              actionHint: '打开手动补录页面添加第一条记录',
              onAction: onManualEntry,
            ),
          )
        else
          AppSliverListSection(
            itemCount: timelineItems.length,
            itemBuilder: (context, index) {
              final item = timelineItems[index];
              return switch (item) {
                _TimelineMonthHeader(:final label) => Padding(
                  padding: const EdgeInsets.only(bottom: 10, top: 4),
                  child: Text(label, style: AppTextStyles.section),
                ),
                _TimelineRecord(:final record) => _RecordTile(
                  record: record,
                  onSave: onSave,
                  onDelete: onDelete,
                ),
                _TimelineGap() => const SizedBox(height: 8),
              };
            },
          ),
      ],
    );
  }

  List<_TimelineItem> _buildTimelineItems() {
    if (records.isEmpty) {
      return const [];
    }
    final items = <_TimelineItem>[];
    for (final group in _groupByMonth(records).entries) {
      items.add(_TimelineMonthHeader(group.key));
      for (final record in group.value) {
        items.add(_TimelineRecord(record));
      }
      items.add(const _TimelineGap());
    }
    return items;
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

sealed class _TimelineItem {
  const _TimelineItem();
}

class _TimelineMonthHeader extends _TimelineItem {
  const _TimelineMonthHeader(this.label);

  final String label;
}

class _TimelineRecord extends _TimelineItem {
  const _TimelineRecord(this.record);

  final StayRecord record;
}

class _TimelineGap extends _TimelineItem {
  const _TimelineGap();
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
    final stackedActions = context.appPrefersStackedLayout;
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
                    child: ExcludeSemantics(
                      child: Icon(
                        isExit
                            ? AppPlatformIcon.exit(context)
                            : AppPlatformIcon.entry(context),
                        color: const Color(0xFFFFFFFF),
                        size: 18,
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
                AppIconButton(
                  icon: AppPlatformIcon.more(context),
                  label: '记录操作',
                  hint: '打开编辑、确认或删除操作',
                  color: AppColors.muted,
                  onPressed: () => _showRecordActions(context),
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
              _ConfirmationActions(
                stacked: stackedActions,
                onIgnore: () => onSave(
                  record.copyWith(
                    confirmationStatus: ConfirmationStatus.rejected,
                    updatedAt: DateTime.now(),
                  ),
                ),
                onEdit: () => _showEditRecordDialog(
                  context: context,
                  record: record,
                  onSave: onSave,
                  confirmAfterSave: true,
                ),
                onConfirm: () => onSave(
                  record.copyWith(
                    confirmationStatus: ConfirmationStatus.confirmed,
                    source: RecordSource.userConfirmed,
                    updatedAt: DateTime.now(),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showRecordActions(BuildContext context) async {
    final value = await showAppActionSheet<String>(
      context: context,
      title: '记录操作',
      actions: [
        if (record.confirmationStatus == ConfirmationStatus.needsConfirmation)
          const AppActionSheetItem(value: 'confirm', label: '确认记录'),
        const AppActionSheetItem(value: 'edit', label: '编辑 / 修正'),
        const AppActionSheetItem(
          value: 'delete',
          label: '删除',
          destructive: true,
        ),
      ],
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

class _ConfirmationActions extends StatelessWidget {
  const _ConfirmationActions({
    required this.stacked,
    required this.onIgnore,
    required this.onEdit,
    required this.onConfirm,
  });

  final bool stacked;
  final VoidCallback onIgnore;
  final VoidCallback onEdit;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final buttons = [
      AppButton(
        label: '忽略',
        filled: false,
        semanticHint: '忽略这条待确认记录',
        onPressed: onIgnore,
      ),
      AppButton(label: '修正', semanticHint: '打开编辑表单修正这条记录', onPressed: onEdit),
      AppButton(label: '确认', semanticHint: '确认这条自动检测记录', onPressed: onConfirm),
    ];

    if (stacked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buttons[0],
          const SizedBox(height: 8),
          buttons[1],
          const SizedBox(height: 8),
          buttons[2],
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: buttons[0]),
        const SizedBox(width: 10),
        Expanded(child: buttons[1]),
        const SizedBox(width: 10),
        Expanded(child: buttons[2]),
      ],
    );
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
            ExcludeSemantics(
              child: Icon(
                AppPlatformIcon.place(context),
                size: 14,
                color: context.appColor(AppColors.teal),
              ),
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
  final updated = await showAppModalSheet<StayRecord>(
    context: context,
    builder: (context) =>
        _EditRecordSheet(record: record, confirmAfterSave: confirmAfterSave),
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
  late final TextEditingController _noteController = TextEditingController(
    text: widget.record.note ?? '',
  );
  String? _error;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sheetHeight = context.appPrefersStackedLayout
        ? MediaQuery.sizeOf(context).height * 0.88
        : MediaQuery.sizeOf(context).height * 0.68;
    final sheet = SafeArea(
      top: false,
      child: SizedBox(
        height: sheetHeight,
        child: Column(
          children: [
            SizedBox(
              height: 52,
              child: Row(
                children: [
                  AppTextButton(
                    label: '取消',
                    hint: '关闭编辑记录表单',
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      '编辑记录',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  AppTextButton(
                    label: '保存',
                    hint: '保存编辑后的记录',
                    bold: true,
                    onPressed: _save,
                  ),
                ],
              ),
            ),
            Container(height: 1, color: context.appColor(AppColors.border)),
            Expanded(
              child: SingleChildScrollView(
                physics: AppPlatformStyle.scrollPhysics(context),
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
                        final picked = await _pickDate(_exitDate ?? _entryDate);
                        if (picked != null) {
                          setState(() => _exitDate = picked);
                        }
                      },
                      onClear: () => setState(() => _exitDate = null),
                    ),
                    const SizedBox(height: 12),
                    AppCupertinoTextField(
                      label: '备注',
                      fieldKey: const Key('record-edit-note-field'),
                      controller: _noteController,
                      minLines: 2,
                      maxLines: 5,
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
    );

    return AppPlatformStyle.isMaterial(context)
        ? sheet
        : CupertinoPopupSurface(
            child: CupertinoTheme(
              data: CupertinoTheme.of(context),
              child: sheet,
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
    final note = _emptyToNull(_noteController.text);
    Navigator.pop(
      context,
      widget.record.copyWith(
        entryDate: normalizeDate(_entryDate),
        exitDate: _exitDate == null ? null : normalizeDate(_exitDate!),
        clearExitDate: _exitDate == null,
        sameDayRoundTrip:
            _exitDate != null && dateKey(_entryDate) == dateKey(_exitDate!),
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
