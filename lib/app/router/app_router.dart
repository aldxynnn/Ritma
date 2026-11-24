import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/logging/app_logger.dart';
import '../../features/foundation/presentation/foundation_home_screen.dart';
import 'app_routes.dart';

final _routerLogger = AppLogger.named('router');

/// Provides the application-wide [GoRouter] instance.
///
/// Role-based redirects (Member vs Operations shells and authentication
/// guards) will attach here once the auth feature slice is introduced.
final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.root,
    debugLogDiagnostics: false,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.root,
        name: 'foundation',
        builder: (context, state) => const FoundationHomeScreen(),
      ),
    ],
    errorBuilder: (context, state) {
      _routerLogger.warning('Route not found: ${state.uri}');
      return Scaffold(
        body: Center(
          child: Text(
            'Page not found: ${state.uri.path}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    },
  );

  ref.onDispose(router.dispose);
  return router;
});
