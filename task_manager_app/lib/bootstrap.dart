import 'package:flutter/material.dart';
import 'src/core/di/injection_container.dart' as di;

Future<void> bootstrap(Future<void> Function() builder) async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Dependency Injection
  await di.init();
  
  await builder();
}
