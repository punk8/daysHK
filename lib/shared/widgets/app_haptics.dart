import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class AppHaptics {
  const AppHaptics._();

  static Future<void> selection(BuildContext context) {
    if (shouldReduceFeedback(context)) {
      return Future<void>.value();
    }
    return HapticFeedback.selectionClick();
  }

  static Future<void> lightImpact(BuildContext context) {
    if (shouldReduceFeedback(context)) {
      return Future<void>.value();
    }
    return HapticFeedback.lightImpact();
  }

  static bool shouldReduceFeedback(BuildContext context) {
    final mediaQuery = MediaQuery.maybeOf(context);
    return mediaQuery?.disableAnimations == true ||
        mediaQuery?.accessibleNavigation == true;
  }
}
