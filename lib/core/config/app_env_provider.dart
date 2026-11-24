import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_env.dart';

/// Provides the active compile-time [AppEnv] across the application.
final appEnvProvider = Provider<AppEnv>((ref) {
  return AppEnv.fromDartDefines();
});
