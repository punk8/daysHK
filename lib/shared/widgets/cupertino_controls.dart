import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/time/hk_date.dart';

import '../theme/app_theme.dart';
import '../theme/platform_icons.dart';
import '../theme/platform_style.dart';
import 'app_haptics.dart';

class AppActionSheetItem<T> {
  const AppActionSheetItem({
    required this.value,
    required this.label,
    this.destructive = false,
    this.isDefault = false,
  });

  final T value;
  final String label;
  final bool destructive;
  final bool isDefault;
}

Future<void> showAppInfoDialog({
  required BuildContext context,
  required String title,
  required String message,
}) {
  if (AppPlatformStyle.isMaterial(context)) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
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
  if (AppPlatformStyle.isMaterial(context)) {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              AppHaptics.selection(context);
              Navigator.pop(context, false);
            },
            child: Text(cancelLabel),
          ),
          TextButton(
            onPressed: () {
              AppHaptics.selection(context);
              Navigator.pop(context, true);
            },
            style: destructive
                ? TextButton.styleFrom(
                    foregroundColor: context.appColor(AppColors.red),
                  )
                : null,
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

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
  if (AppPlatformStyle.isMaterial(context)) {
    return showDatePicker(
      context: context,
      initialDate: selected,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: title,
      cancelText: '取消',
      confirmText: '完成',
    );
  }

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

Future<T?> showAppActionSheet<T>({
  required BuildContext context,
  required String title,
  required List<AppActionSheetItem<T>> actions,
  String cancelLabel = '取消',
}) {
  if (AppPlatformStyle.isMaterial(context)) {
    return showModalBottomSheet<T>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            for (final action in actions)
              ListTile(
                title: Text(
                  action.label,
                  style: TextStyle(
                    color: action.destructive
                        ? context.appColor(AppColors.red)
                        : null,
                    fontWeight: action.isDefault ? FontWeight.w700 : null,
                  ),
                ),
                onTap: () {
                  AppHaptics.selection(context);
                  Navigator.pop(context, action.value);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  return showCupertinoModalPopup<T>(
    context: context,
    builder: (context) => CupertinoActionSheet(
      title: Text(title),
      actions: [
        for (final action in actions)
          CupertinoActionSheetAction(
            isDefaultAction: action.isDefault,
            isDestructiveAction: action.destructive,
            onPressed: () {
              AppHaptics.selection(context);
              Navigator.pop(context, action.value);
            },
            child: Text(action.label),
          ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.pop(context),
        child: Text(cancelLabel),
      ),
    ),
  );
}

Future<T?> showAppModalSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  if (AppPlatformStyle.isMaterial(context)) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: builder,
    );
  }

  return showCupertinoModalPopup<T>(context: context, builder: builder);
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

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.destructive = false,
    this.filled = true,
    this.fullWidth = false,
    this.semanticHint,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool destructive;
  final bool filled;
  final bool fullWidth;
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

    if (AppPlatformStyle.isMaterial(context)) {
      final materialForeground = onPressed == null
          ? Theme.of(context).disabledColor
          : foreground;
      final style = ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(52, 52)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return context.appColor(AppColors.border);
          }
          return background;
        }),
        foregroundColor: WidgetStatePropertyAll(materialForeground),
      );
      final content = Text(
        label,
        maxLines: 2,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      );
      final button = FilledButton(
        onPressed: handlePressed,
        style: style,
        child: Row(
          mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 6),
            ],
            Flexible(child: content),
          ],
        ),
      );
      return Semantics(
        button: true,
        enabled: onPressed != null,
        label: label,
        hint: semanticHint,
        onTap: handlePressed,
        child: ExcludeSemantics(
          child: fullWidth
              ? SizedBox(width: double.infinity, child: button)
              : button,
        ),
      );
    }

    final button = CupertinoButton(
      minimumSize: const Size(52, 52),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      color: onPressed == null
          ? context.appColor(AppColors.border)
          : background,
      borderRadius: BorderRadius.circular(14),
      onPressed: handlePressed,
      child: Row(
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
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
              style: TextStyle(color: foreground, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: label,
      hint: semanticHint,
      onTap: handlePressed,
      child: ExcludeSemantics(
        child: fullWidth
            ? SizedBox(width: double.infinity, child: button)
            : button,
      ),
    );
  }
}

@Deprecated('Use AppButton for platform-adaptive actions.')
class AppCupertinoButton extends StatelessWidget {
  const AppCupertinoButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.destructive = false,
    this.filled = true,
    this.fullWidth = false,
    this.semanticHint,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool destructive;
  final bool filled;
  final bool fullWidth;
  final String? semanticHint;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: label,
      onPressed: onPressed,
      icon: icon,
      destructive: destructive,
      filled: filled,
      fullWidth: fullWidth,
      semanticHint: semanticHint,
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
    if (AppPlatformStyle.isMaterial(context)) {
      return Semantics(
        button: true,
        enabled: onPressed != null,
        label: label,
        hint: hint,
        onTap: handlePressed,
        child: ExcludeSemantics(
          child: IconButton(
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            tooltip: label,
            onPressed: handlePressed,
            icon: Icon(
              icon,
              color: context.appColor(color ?? AppColors.ink),
              size: size,
            ),
          ),
        ),
      );
    }

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
    if (AppPlatformStyle.isMaterial(context)) {
      return Semantics(
        button: true,
        enabled: onPressed != null,
        label: label,
        hint: hint,
        onTap: handlePressed,
        child: ExcludeSemantics(
          child: TextButton(
            onPressed: handlePressed,
            style: TextButton.styleFrom(
              minimumSize: const Size(44, 44),
              padding: padding,
              foregroundColor: color == null ? null : context.appColor(color!),
            ),
            child: Text(
              label,
              style: TextStyle(fontWeight: bold ? FontWeight.w700 : null),
            ),
          ),
        ),
      );
    }

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
    final inputDecoration = BoxDecoration(
      color: context.appColor(AppColors.surface),
      border: Border.all(color: context.appColor(AppColors.border)),
      borderRadius: BorderRadius.circular(14),
    );
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
          child: AppPlatformStyle.isMaterial(context)
              ? TextField(
                  key: fieldKey,
                  controller: controller,
                  minLines: minLines,
                  maxLines: maxLines,
                  decoration: InputDecoration(
                    hintText: label,
                    filled: true,
                    fillColor: context.appColor(AppColors.surface),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: context.appColor(AppColors.border),
                      ),
                    ),
                  ),
                  cursorColor: context.appColor(AppColors.teal),
                  style: context.appTextStyle(AppTextStyles.body),
                  textInputAction: maxLines == 1
                      ? TextInputAction.done
                      : TextInputAction.newline,
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                )
              : CupertinoTextField(
                  key: fieldKey,
                  controller: controller,
                  minLines: minLines,
                  maxLines: maxLines,
                  placeholder: label,
                  cursorColor: context.appColor(AppColors.teal),
                  style: context.appTextStyle(AppTextStyles.body),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  textInputAction: maxLines == 1
                      ? TextInputAction.done
                      : TextInputAction.newline,
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  decoration: inputDecoration,
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
    final content = Column(
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
    );

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
                  child: AppPlatformStyle.isMaterial(context)
                      ? InkWell(
                          borderRadius: borderRadius,
                          onTap: () {
                            AppHaptics.selection(context);
                            onTap();
                          },
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 44),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: content,
                            ),
                          ),
                        )
                      : CupertinoButton(
                          minimumSize: const Size(44, 44),
                          padding: EdgeInsets.zero,
                          alignment: Alignment.centerLeft,
                          onPressed: () {
                            AppHaptics.selection(context);
                            onTap();
                          },
                          child: content,
                        ),
                ),
              ),
            ),
            if (onClear != null && date != null)
              AppIconButton(
                icon: AppPlatformIcon.clear(context),
                label: '清除$label',
                hint: '清除当前选择的日期',
                color: AppColors.muted,
                size: 20,
                onPressed: onClear,
              ),
            const SizedBox(width: 4),
            ExcludeSemantics(
              child: Icon(
                AppPlatformIcon.calendar(context),
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

class AppAdaptiveSwitch extends StatelessWidget {
  const AppAdaptiveSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    void handleChanged(bool value) {
      AppHaptics.selection(context);
      onChanged?.call(value);
    }

    if (AppPlatformStyle.isMaterial(context)) {
      return Switch(
        value: value,
        activeThumbColor: context.appColor(AppColors.teal),
        onChanged: onChanged == null ? null : handleChanged,
      );
    }

    return CupertinoSwitch(
      value: value,
      activeTrackColor: AppColors.teal,
      onChanged: onChanged == null ? null : handleChanged,
    );
  }
}

class AppSegmentedControl<T extends Object> extends StatelessWidget {
  const AppSegmentedControl({
    super.key,
    required this.value,
    required this.values,
    required this.labelBuilder,
    required this.onChanged,
  });

  final T value;
  final List<T> values;
  final String Function(T value) labelBuilder;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    if (AppPlatformStyle.isMaterial(context)) {
      return SegmentedButton<T>(
        selected: {value},
        showSelectedIcon: false,
        segments: [
          for (final item in values)
            ButtonSegment<T>(value: item, label: Text(labelBuilder(item))),
        ],
        onSelectionChanged: (selected) {
          if (selected.isNotEmpty) {
            AppHaptics.selection(context);
            onChanged(selected.first);
          }
        },
      );
    }

    return CupertinoSlidingSegmentedControl<T>(
      groupValue: value,
      backgroundColor: context.appColor(AppColors.monthZero),
      thumbColor: context.appColor(AppColors.surface),
      children: {
        for (final item in values)
          item: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(labelBuilder(item)),
          ),
      },
      onValueChanged: (next) {
        if (next != null) {
          AppHaptics.selection(context);
          onChanged(next);
        }
      },
    );
  }
}
