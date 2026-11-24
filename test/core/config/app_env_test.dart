import 'package:flutter_test/flutter_test.dart';
import 'package:ritma/core/config/app_env.dart';
import 'package:ritma/core/config/tenant_context.dart';

void main() {
  group('AppEnvironment', () {
    test('parses known environment names case-insensitively', () {
      expect(AppEnvironment.fromName('prod'), AppEnvironment.prod);
      expect(AppEnvironment.fromName('PRODUCTION'), AppEnvironment.prod);
      expect(AppEnvironment.fromName('staging'), AppEnvironment.staging);
      expect(AppEnvironment.fromName('stage'), AppEnvironment.staging);
      expect(AppEnvironment.fromName('dev'), AppEnvironment.dev);
      expect(AppEnvironment.fromName('unknown'), AppEnvironment.dev);
    });
  });

  group('AppEnv', () {
    test('detects Supabase configuration completeness', () {
      const unconfigured = AppEnv(
        environment: AppEnvironment.dev,
        appName: 'RITMA',
        supabaseUrl: '',
        supabaseAnonKey: '',
        enableDebugLogging: true,
        enableDemoMode: false,
      );
      expect(unconfigured.hasSupabaseConfig, isFalse);
      expect(unconfigured.isProduction, isFalse);

      const configured = AppEnv(
        environment: AppEnvironment.prod,
        appName: 'RITMA',
        supabaseUrl: 'https://example.supabase.co',
        supabaseAnonKey: 'anon-key',
        enableDebugLogging: false,
        enableDemoMode: false,
      );
      expect(configured.hasSupabaseConfig, isTrue);
      expect(configured.isProduction, isTrue);

      const secretRejected = AppEnv(
        environment: AppEnvironment.dev,
        appName: 'RITMA',
        supabaseUrl: 'https://example.supabase.co',
        supabaseAnonKey: 'sb_secret_forbidden',
        enableDebugLogging: true,
        enableDemoMode: false,
      );
      expect(secretRejected.hasSupabaseConfig, isFalse);
    });
  });

  group('TenantContext', () {
    test('round-trips through JSON serialization', () {
      const original = TenantContext(
        organizationId: 'org-123',
        branchId: 'branch-456',
      );
      final json = original.toJson();
      final decoded = TenantContext.fromJson(json);

      expect(decoded, equals(original));
      expect(decoded.organizationId, 'org-123');
      expect(decoded.branchId, 'branch-456');
    });
  });
}
