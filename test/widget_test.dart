import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ritma/app/app.dart';
import 'package:ritma/core/config/app_env.dart';
import 'package:ritma/core/config/app_env_provider.dart';

void main() {
  testWidgets('RitmaApp renders foundation screen with configured env', (
    tester,
  ) async {
    const testEnv = AppEnv(
      environment: AppEnvironment.dev,
      appName: 'RITMA',
      supabaseUrl: '',
      supabaseAnonKey: '',
      enableDebugLogging: true,
      enableDemoMode: false,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appEnvProvider.overrideWithValue(testEnv)],
        child: const RitmaApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('RITMA'), findsOneWidget);
    expect(find.text('One platform. Every fitness business.'), findsOneWidget);
    expect(find.text('DEV'), findsOneWidget);
    expect(find.text('Foundation Ready'), findsOneWidget);
  });
}
