import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/booking/application/booking_providers.dart';
import '../../features/dashboard/application/dashboard_providers.dart';
import '../../features/facility_access/application/facility_access_providers.dart';
import '../../features/members/application/member_providers.dart';
import '../../features/operations_extras/application/operations_extras_providers.dart';
import '../../features/organizations/application/organization_providers.dart';
import '../../features/packages/application/package_providers.dart';
import '../../features/payments/application/payment_providers.dart';
import '../../features/personal_training/application/pt_providers.dart';

/// Centralized cross-module Riverpod invalidation helpers so dashboard metrics,
/// ledgers, wallets, rosters, and queues never display stale state after mutations.
abstract final class RitmaSync {
  static void afterCheckIn(WidgetRef ref) {
    ref.invalidate(branchVisitsProvider);
    ref.invalidate(memberVisitsProvider);
    ref.invalidate(memberQrPassProvider);
    ref.invalidate(operationalMetricsProvider);
  }

  static void afterBookingMutation(WidgetRef ref, {String? sessionId}) {
    ref.invalidate(classSessionsProvider);
    ref.invalidate(memberBookingsProvider);
    if (sessionId != null) {
      ref.invalidate(sessionRosterProvider(sessionId));
    } else {
      ref.invalidate(sessionRosterProvider);
    }
    ref.invalidate(memberWalletProvider);
    ref.invalidate(operationalMetricsProvider);
    ref.invalidate(userNotificationsProvider);
    ref.invalidate(unreadNotificationCountProvider);
  }

  static void afterPtMutation(WidgetRef ref) {
    ref.invalidate(ptSessionsProvider);
    ref.invalidate(ptClientLookupProvider);
    ref.invalidate(memberWalletProvider);
    ref.invalidate(operationalMetricsProvider);
    ref.invalidate(userNotificationsProvider);
    ref.invalidate(unreadNotificationCountProvider);
  }

  static void afterMemberMutation(WidgetRef ref, {String? memberId}) {
    ref.invalidate(membersListProvider);
    ref.invalidate(ptClientLookupProvider);
    if (memberId != null) {
      ref.invalidate(memberWalletProvider(memberId));
      ref.invalidate(memberPaymentsProvider);
    }
    ref.invalidate(operationalMetricsProvider);
  }

  static void afterPackageOrPaymentMutation(
    WidgetRef ref, {
    String? memberId,
    String? paymentId,
  }) {
    ref.invalidate(orgPackagesProvider);
    ref.invalidate(orgClassTypesProvider);
    ref.invalidate(orgPaymentsProvider);
    ref.invalidate(memberPaymentsProvider);
    if (paymentId != null) {
      ref.invalidate(paymentRefundsProvider(paymentId));
    } else {
      ref.invalidate(paymentRefundsProvider);
    }
    if (memberId != null) {
      ref.invalidate(memberWalletProvider(memberId));
    } else {
      ref.invalidate(memberWalletProvider);
    }
    ref.invalidate(ptClientLookupProvider);
    ref.invalidate(operationalMetricsProvider);
    ref.invalidate(auditLogsProvider);
  }

  static void afterOrgOrStaffMutation(WidgetRef ref) {
    ref.invalidate(activeOrganizationProvider);
    ref.invalidate(orgBranchesProvider);
    ref.invalidate(orgRoomsProvider);
    ref.invalidate(orgStaffProvider);
    ref.invalidate(orgInvitationsProvider);
    ref.invalidate(assignableInstructorsProvider);
    ref.invalidate(auditLogsProvider);
  }

  static void afterEquipmentMutation(WidgetRef ref) {
    ref.invalidate(equipmentAssetsProvider);
    ref.invalidate(maintenanceTicketsProvider);
    ref.invalidate(userNotificationsProvider);
    ref.invalidate(unreadNotificationCountProvider);
  }

  static void afterProfileMutation(WidgetRef ref) {
    ref.invalidate(membersListProvider);
    ref.invalidate(activeOrganizationProvider);
  }
}
