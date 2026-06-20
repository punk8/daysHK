import 'dart:async';

import 'package:flutter/cupertino.dart';

import '../theme/app_theme.dart';
import 'app_haptics.dart';

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
    final bottom = MediaQuery.paddingOf(context).bottom + 18;
    return Positioned(
      left: 16,
      right: 16,
      bottom: bottom,
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: CupertinoPopupSurface(
              isSurfacePainted: true,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: context.appColor(AppColors.noticeBackground),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Text(
                          message,
                          style: const TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (action != null) ...[
                        const SizedBox(width: 8),
                        CupertinoButton(
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          onPressed: () {
                            onDismiss();
                            action!.onPressed();
                          },
                          child: Text(
                            action!.label,
                            style: const TextStyle(
                              color: CupertinoColors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
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
    );
  }
}
