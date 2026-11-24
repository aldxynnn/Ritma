import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_env.dart';
import '../logging/app_logger.dart';

final _log = AppLogger.named('supabase');

/// Initializes [Supabase] exactly once when valid client config is provided.
Future<bool> initializeSupabaseIfConfigured(AppEnv env) async {
  if (!env.hasSupabaseConfig) {
    _log.info('Supabase client not initialized: no configuration supplied.');
    return false;
  }

  try {
    await Supabase.initialize(
      url: env.supabaseUrl,
      publishableKey: env.supabaseAnonKey,
    );
    _log.info('Supabase client initialized for ${env.environment.name}.');
    return true;
  } catch (error, stackTrace) {
    _log.severe('Failed to initialize Supabase client', error, stackTrace);
    rethrow;
  }
}

/// Exposes the initialized [SupabaseClient] when configured, or `null` when
/// running unconfigured or in non-production Demo Sandbox mode.
final supabaseClientProvider = Provider<SupabaseClient?>((ref) {
  try {
    return Supabase.instance.client;
  } catch (_) {
    return null;
  }
});
