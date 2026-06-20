import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../features/shell/app_shell.dart';
import '../shared/theme/app_theme.dart';
import 'bootstrap.dart';

class DaysInHkApp extends StatelessWidget {
  const DaysInHkApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: '在港日记',
      debugShowCheckedModeBanner: false,
      theme: buildCupertinoAppTheme(),
      locale: const Locale('zh', 'Hans'),
      localizationsDelegates: GlobalCupertinoLocalizations.delegates,
      supportedLocales: const [
        Locale('zh', 'Hans'),
        Locale('zh', 'Hant'),
        Locale('en'),
      ],
      home: AppShell(dependencies: dependencies),
    );
  }
}
