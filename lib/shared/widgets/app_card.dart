import 'package:flutter/cupertino.dart';

import '../theme/app_theme.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.appColor(color ?? AppColors.surface),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appColor(AppColors.border)),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
