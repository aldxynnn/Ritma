/// Supported deployment environments for RITMA.
enum AppEnvironment {
  dev,
  staging,
  prod;

  static AppEnvironment fromName(String value) {
    switch (value.trim().toLowerCase()) {
      case 'prod':
      case 'production':
        return AppEnvironment.prod;
      case 'staging':
      case 'stage':
        return AppEnvironment.staging;
      case 'dev':
      case 'development':
      default:
        return AppEnvironment.dev;
    }
  }
}

/// Compile-time environment configuration supplied via `--dart-define` or
/// `--dart-define-from-file`.
///
/// Secrets such as service-role keys must NEVER be included in client builds.
class AppEnv {
  const AppEnv({
    required this.environment,
    required this.appName,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.enableDebugLogging,
    required this.enableDemoMode,
  });

  factory AppEnv.fromDartDefines() {
    const rawEnv = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
    const appName = String.fromEnvironment('APP_NAME', defaultValue: 'RITMA');
    const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
    const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
    const debugLogging = String.fromEnvironment(
      'ENABLE_DEBUG_LOGGING',
      defaultValue: 'true',
    );
    const demoMode = String.fromEnvironment(
      'ENABLE_DEMO_MODE',
      defaultValue: 'false',
    );

    final environment = AppEnvironment.fromName(rawEnv);

    return AppEnv(
      environment: environment,
      appName: appName,
      supabaseUrl: supabaseUrl,
      supabaseAnonKey: supabaseAnonKey,
      enableDebugLogging:
          environment != AppEnvironment.prod &&
          debugLogging.toLowerCase() == 'true',
      enableDemoMode:
          environment != AppEnvironment.prod &&
          demoMode.toLowerCase() == 'true',
    );
  }

  final AppEnvironment environment;
  final String appName;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final bool enableDebugLogging;
  final bool enableDemoMode;

  bool get isProduction => environment == AppEnvironment.prod;
  bool get hasSupabaseConfig =>
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty &&
      !supabaseUrl.contains('your-project-ref') &&
      supabaseAnonKey != 'your-public-anon-key';
}
