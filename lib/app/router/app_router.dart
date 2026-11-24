import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/logging/app_logger.dart';
import '../../features/auth/application/auth_providers.dart';
import '../../features/auth/domain/auth_session_state.dart';
import '../../features/auth/presentation/backend_setup_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/profile_screen.dart';
import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/auth/presentation/sign_up_screen.dart';
import '../../features/auth/presentation/workspace_picker_screen.dart';
import '../../features/shells/presentation/member_shell.dart';
import '../../features/shells/presentation/member_views.dart';
import '../../features/shells/presentation/ops_shell.dart';
import '../../features/shells/presentation/ops_views.dart';
import 'app_routes.dart';

final _routerLogger = AppLogger.named('router');

class _RouterRefreshListenable extends ChangeNotifier {
  void refresh() => notifyListeners();
}

/// Provides the reactive, role-aware application [GoRouter] enforcing strict
/// surface isolation between Member (`/member/*`) and Operations (`/ops/*`).
final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = _RouterRefreshListenable();

  ref.listen(appModeProvider, (_, _) => refreshListenable.refresh());
  ref.listen(authControllerProvider, (_, _) => refreshListenable.refresh());
  ref.listen(activeWorkspaceProvider, (_, _) => refreshListenable.refresh());

  final router = GoRouter(
    initialLocation: AppRoutes.signIn,
    refreshListenable: refreshListenable,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final path = state.uri.path;
      final mode = ref.read(appModeProvider);

      if (mode == AppMode.unconfigured) {
        return path == AppRoutes.setup ? null : AppRoutes.setup;
      }

      if (path == AppRoutes.setup) {
        return AppRoutes.signIn;
      }

      final authAsync = ref.read(authControllerProvider);
      if (authAsync.isLoading && !authAsync.hasValue) {
        return null;
      }

      final session = authAsync.asData?.value;
      final isAuthRoute = path.startsWith('/auth');

      if (session is! AuthenticatedSession) {
        return isAuthRoute ? null : AppRoutes.signIn;
      }

      final workspace = ref.read(activeWorkspaceProvider);
      if (workspace == null) {
        return path == AppRoutes.workspaces ? null : AppRoutes.workspaces;
      }

      if (isAuthRoute) {
        return AppRoutes.defaultRouteForWorkspace(workspace);
      }

      if (path == AppRoutes.workspaces) {
        return null;
      }

      if (workspace.isOperationsSurface) {
        if (path.startsWith('/member') || !path.startsWith('/ops')) {
          return AppRoutes.defaultRouteForWorkspace(workspace);
        }
        if (!AppRoutes.isRouteAllowedForOpsWorkspace(path, workspace)) {
          return AppRoutes.defaultRouteForWorkspace(workspace);
        }
      } else {
        if (path.startsWith('/ops') || !path.startsWith('/member')) {
          return AppRoutes.memberHome;
        }
      }

      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.setup,
        builder: (context, state) => const BackendSetupScreen(),
      ),
      GoRoute(
        path: AppRoutes.signIn,
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.workspaces,
        builder: (context, state) => const WorkspacePickerScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MemberShell(navigationShell: navigationShell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.memberHome,
                builder: (context, state) => const MemberHomeView(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.memberSchedule,
                builder: (context, state) => const MemberScheduleView(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.memberBookings,
                builder: (context, state) => const MemberBookingsView(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.memberProfile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            OpsShell(navigationShell: navigationShell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.opsDashboard,
                builder: (context, state) => const OpsDashboardView(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.opsCheckIn,
                builder: (context, state) => const OpsCheckInView(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.opsSchedule,
                builder: (context, state) => const OpsScheduleView(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.opsMembers,
                builder: (context, state) => const OpsMembersView(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.opsSettings,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
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

  ref.onDispose(() {
    router.dispose();
    refreshListenable.dispose();
  });

  return router;
});
