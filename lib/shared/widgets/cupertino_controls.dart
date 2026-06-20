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
                    AppTextButton(
                      label: '取消',
                      hint: '关闭日期选择器',
                      onPressed: () {
                        Navigator.pop(context);
                      },
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
                    AppTextButton(
                      label: '完成',
                      hint: '确认选择的日期',
                      bold: true,
                      onPressed: () {
                        Navigator.pop(context, selected);
                      },
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
    this.semanticHint,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool destructive;
  final bool filled;
  final String? semanticHint;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.red : AppColors.teal;
    final resolved = context.appColor(color);
    final foreground = filled ? CupertinoColors.white : resolved;
    final background = filled ? resolved : resolved.withValues(alpha: 0.10);
    final VoidCallback? handlePressed = onPressed == null
        ? null
        : () {
            AppHaptics.selection(context);
            onPressed!();
          };
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: label,
      hint: semanticHint,
      onTap: handlePressed,
      child: ExcludeSemantics(
        child: CupertinoButton(
          minimumSize: const Size(52, 52),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          color: onPressed == null
              ? context.appColor(AppColors.border)
              : background,
          borderRadius: BorderRadius.circular(14),
          onPressed: handlePressed,
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
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: foreground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.hint,
    this.color,
    this.size = 22,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final String? hint;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final VoidCallback? handlePressed = onPressed == null
        ? null
        : () {
            AppHaptics.selection(context);
            onPressed!();
          };
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: label,
      hint: hint,
      onTap: handlePressed,
      child: ExcludeSemantics(
        child: CupertinoButton(
          minimumSize: const Size(44, 44),
          padding: EdgeInsets.zero,
          onPressed: handlePressed,
          child: Icon(
            icon,
            color: context.appColor(color ?? AppColors.ink),
            size: size,
          ),
        ),
      ),
    );
  }
}

class AppTextButton extends StatelessWidget {
  const AppTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.hint,
    this.bold = false,
    this.color,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  final String label;
  final VoidCallback? onPressed;
  final String? hint;
  final bool bold;
  final Color? color;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final VoidCallback? handlePressed = onPressed == null
        ? null
        : () {
            AppHaptics.selection(context);
            onPressed!();
          };
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: label,
      hint: hint,
      onTap: handlePressed,
      child: ExcludeSemantics(
        child: CupertinoButton(
          minimumSize: const Size(44, 44),
          padding: padding,
          onPressed: handlePressed,
          child: Text(
            label,
            style: TextStyle(
              color: color == null ? null : context.appColor(color!),
              fontWeight: bold ? FontWeight.w700 : null,
            ),
          ),
        ),
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
        Semantics(
          textField: true,
          label: label,
          child: CupertinoTextField(
            key: fieldKey,
            controller: controller,
            minLines: minLines,
            maxLines: maxLines,
            placeholder: label,
            cursorColor: context.appColor(AppColors.teal),
            style: context.appTextStyle(AppTextStyles.body),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            textInputAction: maxLines == 1
                ? TextInputAction.done
                : TextInputAction.newline,
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            decoration: BoxDecoration(
              color: context.appColor(AppColors.surface),
              border: Border.all(color: context.appColor(AppColors.border)),
              borderRadius: BorderRadius.circular(14),
            ),
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
    final valueText = date == null ? '未选择' : dateKey(date!);
    final borderRadius = BorderRadius.circular(14);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.appColor(AppColors.surface),
        borderRadius: borderRadius,
        border: Border.all(color: context.appColor(AppColors.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 12, right: 8, top: 10, bottom: 10),
        child: Row(
          children: [
            Expanded(
              child: Semantics(
                button: true,
                label: '$label，$valueText',
                hint: '点按选择日期',
                onTap: () {
                  AppHaptics.selection(context);
                  onTap();
                },
                child: ExcludeSemantics(
                  child: CupertinoButton(
                    minimumSize: const Size(44, 44),
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                    onPressed: () {
                      AppHaptics.selection(context);
                      onTap();
                    },
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
                          valueText,
                          style: TextStyle(
                            color: context.appColor(AppColors.ink),
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (onClear != null && date != null)
              AppIconButton(
                icon: CupertinoIcons.clear_circled,
                label: '清除$label',
                hint: '清除当前选择的日期',
                color: AppColors.muted,
                size: 20,
                onPressed: onClear,
              ),
            const SizedBox(width: 4),
            ExcludeSemantics(
              child: Icon(
                CupertinoIcons.calendar,
                color: context.appColor(AppColors.teal),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
