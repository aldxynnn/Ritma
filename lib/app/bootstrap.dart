import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_env.dart';
import '../core/config/app_env_provider.dart';
import '../core/logging/app_logger.dart';
import '../core/network/supabase_provider.dart';
import 'app.dart';

/// Initializes core runtime infrastructure (logging, global error hooks,
/// environment config, and optional Supabase client) before mounting [RitmaApp].
Future<void> bootstrap({AppEnv? envOverride}) async {
  final env = envOverride ?? AppEnv.fromDartDefines();
  AppLogger.initialize(enableDebugLogging: env.enableDebugLogging);
  final log = AppLogger.named('bootstrap');

  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    log.severe('Unhandled Flutter error', details.exception, details.stack);
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    log.severe('Unhandled platform error', error, stack);
    return true;
  };

  await initializeSupabaseIfConfigured(env);

  runZonedGuarded(
    () {
      log.info('Starting RITMA in ${env.environment.name} environment');
      runApp(
        ProviderScope(
          overrides: [appEnvProvider.overrideWithValue(env)],
          child: const RitmaApp(),
        ),
      );
    },
    (error, stack) {
      log.severe('Unhandled zone error', error, stack);
    },
  );
}
