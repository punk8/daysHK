import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../features/shell/app_shell.dart';
import '../shared/theme/app_theme.dart';
import '../shared/theme/platform_style.dart';
import 'bootstrap.dart';

class DaysInHkApp extends StatelessWidget {
  const DaysInHkApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    if (!AppPlatformStyle.defaultIsCupertino) {
      return MaterialApp(
        title: '在港日记',
        debugShowCheckedModeBanner: false,
        theme: buildMaterialAppTheme(Brightness.light),
        darkTheme: buildMaterialAppTheme(Brightness.dark),
        locale: const Locale('zh', 'Hans'),
        localizationsDelegates: const [
          ...GlobalMaterialLocalizations.delegates,
          ...GlobalCupertinoLocalizations.delegates,
        ],
        supportedLocales: const [
          Locale('zh', 'Hans'),
          Locale('zh', 'Hant'),
          Locale('en'),
        ],
        home: AppShell(dependencies: dependencies),
      );
    }

    return CupertinoApp(
      title: '在港日记',
      debugShowCheckedModeBanner: false,
      theme: buildCupertinoAppTheme(),
      locale: const Locale('zh', 'Hans'),
      localizationsDelegates: const [
        ...GlobalCupertinoLocalizations.delegates,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: const [
        Locale('zh', 'Hans'),
        Locale('zh', 'Hant'),
        Locale('en'),
      ],
      home: AppShell(dependencies: dependencies),
    );
  }
}
