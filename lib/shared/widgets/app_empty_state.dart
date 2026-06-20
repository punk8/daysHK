import 'package:flutter/cupertino.dart';

import '../theme/app_theme.dart';
import 'app_card.dart';
import 'cupertino_controls.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    this.actionHint,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;
  final String? actionHint;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Semantics(
        label: '$title，$message',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: context.appColor(AppColors.info),
                  shape: BoxShape.circle,
                ),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: ExcludeSemantics(
                    child: Icon(
                      icon,
                      color: context.appColor(AppColors.teal),
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(title, style: AppTextStyles.section),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: context.appColor(AppColors.muted)),
            ),
            const SizedBox(height: 20),
            AppButton(
              label: actionLabel,
              fullWidth: true,
              semanticHint: actionHint,
              onPressed: onAction,
            ),
          ],
        ),
      ),
    );
  }
}
