import 'package:flutter/cupertino.dart';

import 'app/app.dart';
import 'app/bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dependencies = await bootstrapDependencies();
  runApp(DaysInHkApp(dependencies: dependencies));
}
