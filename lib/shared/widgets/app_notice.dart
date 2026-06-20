import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/platform_icons.dart';
import '../theme/platform_style.dart';
import 'app_haptics.dart';
import 'cupertino_controls.dart';

class AppNoticeAction {
  const AppNoticeAction({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;
}

class AppNotice {
  static void show(
    BuildContext context,
    String message, {
    AppNoticeAction? action,
  }) {
    if (AppPlatformStyle.isMaterial(context)) {
      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger == null) {
        return;
      }
      AppHaptics.lightImpact(context);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(message),
            action: action == null
                ? null
                : SnackBarAction(
                    label: action.label,
                    onPressed: action.onPressed,
                  ),
          ),
        );
      return;
    }

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) {
      return;
    }

    late final OverlayEntry entry;
    Timer? timer;
    void dismiss() {
      timer?.cancel();
      if (entry.mounted) {
        entry.remove();
      }
    }

    entry = OverlayEntry(
      builder: (context) => _AppNoticeOverlay(
        message: message,
        action: action,
        onDismiss: dismiss,
      ),
    );

    AppHaptics.lightImpact(context);
    overlay.insert(entry);
    timer = Timer(const Duration(seconds: 3), dismiss);
  }
}

class _AppNoticeOverlay extends StatelessWidget {
  const _AppNoticeOverlay({
    required this.message,
    required this.action,
    required this.onDismiss,
  });

  final String message;
  final AppNoticeAction? action;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top + 10;
    final reduceMotion = AppHaptics.shouldReduceFeedback(context);
    return Positioned(
      left: 12,
      right: 12,
      top: top,
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: reduceMotion ? 1 : 0, end: 1),
              duration: reduceMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, -10 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Semantics(
                liveRegion: true,
                label: message,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: context.appColor(AppColors.noticeBackground),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: CupertinoColors.white.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ExcludeSemantics(
                              child: Icon(
                                AppPlatformIcon.success(context),
                                color: CupertinoColors.white.withValues(
                                  alpha: 0.92,
                                ),
                                size: 19,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                message,
                                style: const TextStyle(
                                  color: CupertinoColors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  height: 1.25,
                                ),
                              ),
                            ),
                            if (action != null) ...[
                              const SizedBox(width: 8),
                              AppTextButton(
                                label: action!.label,
                                hint: '执行通知操作',
                                bold: true,
                                color: CupertinoColors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                onPressed: () {
                                  onDismiss();
                                  action!.onPressed();
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
