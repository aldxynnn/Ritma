import '../../features/auth/domain/workspace_context.dart';

/// Centralized route paths and surface helpers for RITMA.
abstract final class AppRoutes {
  static const String setup = '/setup';

  static const String signIn = '/auth/sign-in';
  static const String signUp = '/auth/sign-up';
  static const String forgotPassword = '/auth/forgot-password';

  static const String workspaces = '/workspaces';

  static const String memberHome = '/member/home';
  static const String memberSchedule = '/member/schedule';
  static const String memberBookings = '/member/bookings';
  static const String memberProfile = '/member/profile';

  static const String opsDashboard = '/ops/dashboard';
  static const String opsCheckIn = '/ops/checkin';
  static const String opsSchedule = '/ops/schedule';
  static const String opsMembers = '/ops/members';
  static const String opsSettings = '/ops/settings';
  static const String opsOrgSetup = '/ops/settings/org-setup';

  /// Returns the highest-priority valid landing route for a selected
  /// [WorkspaceContext] so restricted roles (e.g., Instructor or Receptionist)
  /// land directly on a surface they are authorized to use.
  static String defaultRouteForWorkspace(WorkspaceContext workspace) {
    if (!workspace.isOperationsSurface) {
      return memberHome;
    }
    if (workspace.hasPermission('dashboard.org.read') ||
        workspace.hasPermission('dashboard.branch.read')) {
      return opsDashboard;
    }
    if (workspace.hasPermission('checkin.perform') ||
        workspace.hasPermission('checkin.read')) {
      return opsCheckIn;
    }
    if (workspace.hasPermission('schedule.manage') ||
        workspace.hasPermission('booking.read') ||
        workspace.hasPermission('attendance.mark') ||
        workspace.hasPermission('pt.manage')) {
      return opsSchedule;
    }
    if (workspace.hasPermission('member.read') ||
        workspace.hasPermission('entitlement.read') ||
        workspace.hasPermission('package.manage')) {
      return opsMembers;
    }
    return opsSettings;
  }

  static bool isRouteAllowedForOpsWorkspace(
    String path,
    WorkspaceContext workspace,
  ) {
    if (path.startsWith(opsDashboard)) {
      return workspace.hasPermission('dashboard.org.read') ||
          workspace.hasPermission('dashboard.branch.read');
    }
    if (path.startsWith(opsCheckIn)) {
      return workspace.hasPermission('checkin.perform') ||
          workspace.hasPermission('checkin.read');
    }
    if (path.startsWith(opsSchedule)) {
      return workspace.hasPermission('schedule.manage') ||
          workspace.hasPermission('booking.read') ||
          workspace.hasPermission('attendance.mark') ||
          workspace.hasPermission('pt.manage');
    }
    if (path.startsWith(opsMembers)) {
      return workspace.hasPermission('member.read') ||
          workspace.hasPermission('entitlement.read') ||
          workspace.hasPermission('package.manage');
    }
    if (path.startsWith(opsOrgSetup)) {
      return workspace.hasPermission('branch.manage') ||
          workspace.hasPermission('role.assign');
    }
    return path.startsWith(opsSettings);
  }
}
