import 'package:flutter/cupertino.dart';

import '../../core/time/hk_date.dart';

import '../theme/app_theme.dart';
import 'app_haptics.dart';

Future<void> showAppInfoDialog({
  required BuildContext context,
  required String title,
  required String message,
}) {
  return showCupertinoDialog<void>(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: Text(title),
      content: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(message),
      ),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () {
            AppHaptics.selection(context);
            Navigator.pop(context);
          },
          child: const Text('知道了'),
        ),
      ],
    ),
  );
}

Future<bool> showAppConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = '取消',
  bool destructive = false,
}) async {
  final confirmed = await showCupertinoDialog<bool>(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: Text(title),
      content: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(message),
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: () {
            AppHaptics.selection(context);
            Navigator.pop(context, false);
          },
          child: Text(cancelLabel),
        ),
        CupertinoDialogAction(
          isDefaultAction: !destructive,
          isDestructiveAction: destructive,
          onPressed: () {
            AppHaptics.selection(context);
            Navigator.pop(context, true);
          },
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

Future<DateTime?> showAppDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  String title = '选择日期',
}) {
  var selected = _clampDate(initialDate, firstDate, lastDate);
  return showCupertinoModalPopup<DateTime>(
    context: context,
    builder: (context) => CupertinoPopupSurface(
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 320,
          child: Column(
            children: [
              SizedBox(
                height: 48,
                child: Row(
                  children: [
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      onPressed: () {
                        AppHaptics.selection(context);
                        Navigator.pop(context);
                      },
                      child: const Text('取消'),
                    ),
                    Expanded(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: context.appColor(AppColors.ink),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      onPressed: () {
                        AppHaptics.selection(context);
                        Navigator.pop(context, selected);
                      },
                      child: const Text(
                        '完成',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
              Container(height: 1, color: context.appColor(AppColors.border)),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: selected,
                  minimumDate: firstDate,
                  maximumDate: lastDate,
                  onDateTimeChanged: (value) => selected = value,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

DateTime _clampDate(DateTime date, DateTime firstDate, DateTime lastDate) {
  if (date.isBefore(firstDate)) {
    return firstDate;
  }
  if (date.isAfter(lastDate)) {
    return lastDate;
  }
  return date;
}

class AppCupertinoButton extends StatelessWidget {
  const AppCupertinoButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.destructive = false,
    this.filled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool destructive;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.red : AppColors.teal;
    final resolved = context.appColor(color);
    final foreground = filled ? CupertinoColors.white : resolved;
    final background = filled ? resolved : resolved.withValues(alpha: 0.10);
    return CupertinoButton(
      minimumSize: const Size(44, 44),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      color: onPressed == null
          ? context.appColor(AppColors.border)
          : background,
      borderRadius: BorderRadius.circular(8),
      onPressed: onPressed == null
          ? null
          : () {
              AppHaptics.selection(context);
              onPressed!();
            },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: foreground),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: foreground, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class AppCupertinoTextField extends StatelessWidget {
  const AppCupertinoTextField({
    super.key,
    required this.label,
    required this.controller,
    this.fieldKey,
    this.minLines,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final Key? fieldKey;
  final int? minLines;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: context.appColor(AppColors.muted),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        CupertinoTextField(
          key: fieldKey,
          controller: controller,
          minLines: minLines,
          maxLines: maxLines,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: context.appColor(AppColors.surface),
            border: Border.all(color: context.appColor(AppColors.border)),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    );
  }
}

class AppCupertinoDateField extends StatelessWidget {
  const AppCupertinoDateField({
    super.key,
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
    return CupertinoButton(
      minimumSize: Size.zero,
      padding: EdgeInsets.zero,
      onPressed: () {
        AppHaptics.selection(context);
        onTap();
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.appColor(AppColors.surface),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: context.appColor(AppColors.border)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: context.appColor(AppColors.muted),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date == null ? '未选择' : dateKey(date!),
                      style: TextStyle(
                        color: context.appColor(AppColors.ink),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              if (onClear != null && date != null)
                CupertinoButton(
                  minimumSize: const Size(32, 32),
                  padding: EdgeInsets.zero,
                  onPressed: onClear,
                  child: Icon(
                    CupertinoIcons.clear_circled,
                    color: context.appColor(AppColors.muted),
                    size: 20,
                  ),
                ),
              const SizedBox(width: 4),
              Icon(
                CupertinoIcons.calendar,
                color: context.appColor(AppColors.teal),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
