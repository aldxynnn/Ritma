import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../core/repository/base_repository.dart';
import '../../../core/result/result.dart';
import '../domain/package_entitlement_repository.dart';
import '../domain/package_models.dart';

class SupabasePackageEntitlementRepository extends BaseRepository
    implements PackageEntitlementRepository {
  SupabasePackageEntitlementRepository(this._client)
    : super(loggerName: 'supabase_package_repo');

  final sb.SupabaseClient _client;

  @override
  Future<Result<List<ClassTypeModel>>> fetchClassTypes(String orgId) {
    return guard(() async {
      final rows = await _client
          .from('class_types')
          .select('id, organization_id, name, color_token, is_active')
          .eq('organization_id', orgId)
          .eq('is_active', true)
          .order('name', ascending: true);
      return rows
          .map((row) => ClassTypeModel.fromJson(Map<String, dynamic>.from(row)))
          .toList();
    }, operation: 'fetchClassTypes');
  }

  @override
  Future<Result<ClassTypeModel>> createClassType({
    required String orgId,
    required String name,
    String colorToken = 'sage',
  }) {
    return guard(() async {
      final row = await _client
          .from('class_types')
          .insert(<String, dynamic>{
            'organization_id': orgId,
            'name': name.trim(),
            'color_token': colorToken,
          })
          .select('id, organization_id, name, color_token, is_active')
          .single();
      return ClassTypeModel.fromJson(Map<String, dynamic>.from(row));
    }, operation: 'createClassType');
  }

  @override
  Future<Result<List<PackageModel>>> fetchPackages(String orgId) {
    return guard(() async {
      final rows = await _client
          .from('packages')
          .select('*, package_entitlement_rules(*)')
          .eq('organization_id', orgId)
          .eq('is_active', true)
          .order('name', ascending: true);
      return rows
          .map((row) => PackageModel.fromJson(Map<String, dynamic>.from(row)))
          .toList();
    }, operation: 'fetchPackages');
  }

  @override
  Future<Result<PackageModel>> createPackage({
    required String orgId,
    required String name,
    required String description,
    required PackageType packageType,
    required int priceMinor,
    required String currencyCode,
    required List<CreatePackageRuleInput> rules,
  }) {
    return guard(() async {
      final pkgRow = await _client
          .from('packages')
          .insert(<String, dynamic>{
            'organization_id': orgId,
            'name': name.trim(),
            'description': description.trim(),
            'package_type': _packageTypeDb(packageType),
            'price_minor': priceMinor,
            'currency_code': currencyCode.trim().toUpperCase(),
          })
          .select('id')
          .single();

      final pkgId = pkgRow['id'] as String;

      for (final rule in rules) {
        final ruleRow = await _client
            .from('package_entitlement_rules')
            .insert(<String, dynamic>{
              'organization_id': orgId,
              'package_id': pkgId,
              'entitlement_kind': _entitlementKindDb(rule.entitlementKind),
              'duration_days': rule.durationDays,
              'credit_quantity': rule.creditQuantity,
              'branch_access_scope': _branchScopeDb(rule.branchAccessScope),
              'class_scope': _classScopeDb(rule.classScope),
            })
            .select('id')
            .single();

        final ruleId = ruleRow['id'] as String;
        if (rule.branchAccessScope == BranchAccessScope.selectedBranches &&
            rule.allowedBranchIds.isNotEmpty) {
          await _client
              .from('package_rule_branches')
              .insert(
                rule.allowedBranchIds
                    .map(
                      (branchId) => <String, dynamic>{
                        'organization_id': orgId,
                        'rule_id': ruleId,
                        'branch_id': branchId,
                      },
                    )
                    .toList(),
              );
        }

        if (rule.classScope == ClassScope.selectedClasses &&
            rule.allowedClassTypeIds.isNotEmpty) {
          await _client
              .from('package_rule_class_types')
              .insert(
                rule.allowedClassTypeIds
                    .map(
                      (classTypeId) => <String, dynamic>{
                        'organization_id': orgId,
                        'rule_id': ruleId,
                        'class_type_id': classTypeId,
                      },
                    )
                    .toList(),
              );
        }
      }

      final full = await _client
          .from('packages')
          .select('*, package_entitlement_rules(*)')
          .eq('id', pkgId)
          .single();
      return PackageModel.fromJson(Map<String, dynamic>.from(full));
    }, operation: 'createPackage');
  }

  @override
  Future<Result<MemberWalletSnapshot>> fetchMemberWallet({
    required String orgId,
    required String memberId,
  }) {
    return guard(() async {
      final subsFuture = _client
          .from('member_subscriptions')
          .select()
          .eq('organization_id', orgId)
          .eq('member_id', memberId)
          .order('starts_at', ascending: false);

      final entFuture = _client
          .from('member_entitlements')
          .select()
          .eq('organization_id', orgId)
          .eq('member_id', memberId)
          .order('valid_until', ascending: false);

      final grantsFuture = _client
          .from('credit_grants')
          .select()
          .eq('organization_id', orgId)
          .eq('member_id', memberId)
          .order('created_at', ascending: false);

      final ledgerFuture = _client
          .from('credit_ledger_entries')
          .select()
          .eq('organization_id', orgId)
          .eq('member_id', memberId)
          .order('created_at', ascending: false)
          .limit(50);

      final results = await Future.wait<List<Map<String, dynamic>>>([
        subsFuture,
        entFuture,
        grantsFuture,
        ledgerFuture,
      ]);

      return MemberWalletSnapshot(
        subscriptions: results[0]
            .map(
              (r) => MemberSubscriptionModel.fromJson(
                Map<String, dynamic>.from(r),
              ),
            )
            .toList(),
        entitlements: results[1]
            .map(
              (r) =>
                  MemberEntitlementModel.fromJson(Map<String, dynamic>.from(r)),
            )
            .toList(),
        creditGrants: results[2]
            .map((r) => CreditGrantModel.fromJson(Map<String, dynamic>.from(r)))
            .toList(),
        ledgerEntries: results[3]
            .map(
              (r) =>
                  CreditLedgerEntryModel.fromJson(Map<String, dynamic>.from(r)),
            )
            .toList(),
      );
    }, operation: 'fetchMemberWallet');
  }

  @override
  Future<Result<String>> assignPackageToMember({
    required String orgId,
    required String branchId,
    required String memberId,
    required String packageId,
    required PaymentMethod paymentMethod,
    required String idempotencyKey,
    DateTime? startsAt,
  }) {
    return guard(() async {
      final raw = await _client.rpc<dynamic>(
        'assign_package_to_member',
        params: <String, dynamic>{
          'p_org_id': orgId,
          'p_branch_id': branchId,
          'p_member_id': memberId,
          'p_package_id': packageId,
          'p_starts_at': (startsAt ?? DateTime.now().toUtc()).toIso8601String(),
          'p_payment_method': _paymentMethodDb(paymentMethod),
          'p_idempotency_key': idempotencyKey,
        },
      );
      final map = Map<String, dynamic>.from(raw as Map);
      return map['subscription_id'] as String;
    }, operation: 'assignPackageToMember');
  }

  @override
  Future<Result<void>> freezeSubscription({
    required String orgId,
    required String subscriptionId,
    String? reason,
  }) {
    return guard(() async {
      await _client.rpc<dynamic>(
        'freeze_member_subscription',
        params: <String, dynamic>{
          'p_org_id': orgId,
          'p_subscription_id': subscriptionId,
          'p_reason': reason,
        },
      );
    }, operation: 'freezeSubscription');
  }

  @override
  Future<Result<void>> unfreezeSubscription({
    required String orgId,
    required String subscriptionId,
  }) {
    return guard(() async {
      await _client.rpc<dynamic>(
        'unfreeze_member_subscription',
        params: <String, dynamic>{
          'p_org_id': orgId,
          'p_subscription_id': subscriptionId,
        },
      );
    }, operation: 'unfreezeSubscription');
  }

  @override
  Future<Result<void>> adjustMemberCredits({
    required String orgId,
    required String memberId,
    required CreditType creditType,
    required int delta,
    required String reason,
    required String idempotencyKey,
    DateTime? expiresAt,
  }) {
    return guard(() async {
      await _client.rpc<dynamic>(
        'adjust_member_credits',
        params: <String, dynamic>{
          'p_org_id': orgId,
          'p_member_id': memberId,
          'p_credit_type': creditType == CreditType.ptCredit
              ? 'pt_credit'
              : 'class_credit',
          'p_delta': delta,
          'p_reason': reason.trim(),
          'p_idempotency_key': idempotencyKey,
          'p_expires_at': expiresAt?.toIso8601String(),
        },
      );
    }, operation: 'adjustMemberCredits');
  }

  String _packageTypeDb(PackageType type) => switch (type) {
    PackageType.gymMembership => 'gym_membership',
    PackageType.classPack => 'class_pack',
    PackageType.ptPack => 'pt_pack',
    PackageType.hybrid => 'hybrid',
  };

  String _entitlementKindDb(EntitlementKind kind) => switch (kind) {
    EntitlementKind.facilityAccess => 'facility_access',
    EntitlementKind.classCredit => 'class_credit',
    EntitlementKind.ptCredit => 'pt_credit',
    EntitlementKind.unlimitedClass => 'unlimited_class',
  };

  String _branchScopeDb(BranchAccessScope scope) => switch (scope) {
    BranchAccessScope.singleBranch => 'single_branch',
    BranchAccessScope.selectedBranches => 'selected_branches',
    BranchAccessScope.allBranches => 'all_branches',
  };

  String _classScopeDb(ClassScope scope) => switch (scope) {
    ClassScope.allClasses => 'all_classes',
    ClassScope.selectedClasses => 'selected_classes',
  };

  String _paymentMethodDb(PaymentMethod method) => switch (method) {
    PaymentMethod.cash => 'cash',
    PaymentMethod.bankTransfer => 'bank_transfer',
    PaymentMethod.cardTerminal => 'card_terminal',
    PaymentMethod.gateway => 'gateway',
  };
}
