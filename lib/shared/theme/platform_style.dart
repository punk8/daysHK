import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum AppPlatformFamily { cupertino, material }

class AppPlatformStyle {
  const AppPlatformStyle._();

  static AppPlatformFamily family(BuildContext context) {
    final hasCupertinoHost =
        context.findAncestorWidgetOfExactType<CupertinoApp>() != null;
    final hasMaterialHost =
        context.findAncestorWidgetOfExactType<MaterialApp>() != null;
    if (hasCupertinoHost && !hasMaterialHost) {
      return AppPlatformFamily.cupertino;
    }
    if (hasMaterialHost && !hasCupertinoHost) {
      return AppPlatformFamily.material;
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS || TargetPlatform.macOS => AppPlatformFamily.cupertino,
      TargetPlatform.android ||
      TargetPlatform.fuchsia ||
      TargetPlatform.linux ||
      TargetPlatform.windows => AppPlatformFamily.material,
    };
  }

  static bool isCupertino(BuildContext context) {
    return family(context) == AppPlatformFamily.cupertino;
  }

  static bool isMaterial(BuildContext context) {
    return family(context) == AppPlatformFamily.material;
  }

  static bool get defaultIsCupertino {
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  static ScrollPhysics scrollPhysics(BuildContext context) {
    if (isCupertino(context)) {
      return const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      );
    }
    return const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }
}
