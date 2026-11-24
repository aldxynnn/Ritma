import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_env_provider.dart';
import '../core/theme/ritma_theme.dart';
import 'router/app_router.dart';

/// Root widget for RITMA.
class RitmaApp extends ConsumerWidget {
  const RitmaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final env = ref.watch(appEnvProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: env.appName,
      debugShowCheckedModeBanner: false,
      theme: RitmaTheme.light(),
      darkTheme: RitmaTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
