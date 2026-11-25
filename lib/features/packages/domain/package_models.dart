import 'package:freezed_annotation/freezed_annotation.dart';

part 'package_models.freezed.dart';
part 'package_models.g.dart';

enum PackageType {
  @JsonValue('gym_membership')
  gymMembership('Gym Membership'),
  @JsonValue('class_pack')
  classPack('Studio Class Pack'),
  @JsonValue('pt_pack')
  ptPack('Personal Training Pack'),
  @JsonValue('hybrid')
  hybrid('Hybrid Package');

  const PackageType(this.label);
  final String label;
}

enum EntitlementKind {
  @JsonValue('facility_access')
  facilityAccess('Facility Access'),
  @JsonValue('class_credit')
  classCredit('Class Credits'),
  @JsonValue('pt_credit')
  ptCredit('PT Credits'),
  @JsonValue('unlimited_class')
  unlimitedClass('Unlimited Classes');

  const EntitlementKind(this.label);
  final String label;
}

enum BranchAccessScope {
  @JsonValue('single_branch')
  singleBranch('Single Branch'),
  @JsonValue('selected_branches')
  selectedBranches('Selected Branches'),
  @JsonValue('all_branches')
  allBranches('All Branches');

  const BranchAccessScope(this.label);
  final String label;

  String get dbValue => switch (this) {
    BranchAccessScope.singleBranch => 'single_branch',
    BranchAccessScope.selectedBranches => 'selected_branches',
    BranchAccessScope.allBranches => 'all_branches',
  };
}

enum ClassScope {
  @JsonValue('all_classes')
  allClasses('All Classes'),
  @JsonValue('selected_classes')
  selectedClasses('Selected Classes');

  const ClassScope(this.label);
  final String label;
}

enum SubscriptionStatus { pending, active, frozen, expired, cancelled }

enum EntitlementStatus { active, frozen, expired, revoked }

enum CreditType {
  @JsonValue('class_credit')
  classCredit('Class Credits'),
  @JsonValue('pt_credit')
  ptCredit('PT Credits');

  const CreditType(this.label);
  final String label;
}

enum CreditGrantStatus { active, frozen, depleted, expired, revoked }

enum LedgerEntryType { grant, consume, refund, expire, adjustment }

enum PaymentMethod {
  @JsonValue('cash')
  cash('Cash'),
  @JsonValue('bank_transfer')
  bankTransfer('Bank Transfer'),
  @JsonValue('card_terminal')
  cardTerminal('Card Terminal'),
  @JsonValue('gateway')
  gateway('Gateway');

  const PaymentMethod(this.label);
  final String label;
}

@freezed
abstract class ClassTypeModel with _$ClassTypeModel {
  const factory ClassTypeModel({
    required String id,
    @JsonKey(name: 'organization_id') required String organizationId,
    required String name,
    @JsonKey(name: 'color_token') @Default('sage') String colorToken,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
  }) = _ClassTypeModel;

  factory ClassTypeModel.fromJson(Map<String, dynamic> json) =>
      _$ClassTypeModelFromJson(json);
}

@freezed
abstract class PackageEntitlementRuleModel with _$PackageEntitlementRuleModel {
  const factory PackageEntitlementRuleModel({
    required String id,
    @JsonKey(name: 'organization_id') required String organizationId,
    @JsonKey(name: 'package_id') required String packageId,
    @JsonKey(name: 'entitlement_kind') required EntitlementKind entitlementKind,
    @JsonKey(name: 'duration_days') int? durationDays,
    @JsonKey(name: 'credit_quantity') int? creditQuantity,
    @JsonKey(name: 'branch_access_scope')
    @Default(BranchAccessScope.singleBranch)
    BranchAccessScope branchAccessScope,
    @JsonKey(name: 'class_scope')
    @Default(ClassScope.allClasses)
    ClassScope classScope,
    @Default(<String>[]) List<String> allowedBranchIds,
    @Default(<String>[]) List<String> allowedClassTypeIds,
  }) = _PackageEntitlementRuleModel;

  factory PackageEntitlementRuleModel.fromJson(Map<String, dynamic> json) =>
      _$PackageEntitlementRuleModelFromJson(json);
}

@freezed
abstract class PackageModel with _$PackageModel {
  const factory PackageModel({
    required String id,
    @JsonKey(name: 'organization_id') required String organizationId,
    required String name,
    @Default('') String description,
    @JsonKey(name: 'package_type') required PackageType packageType,
    @JsonKey(name: 'price_minor') @Default(0) int priceMinor,
    @JsonKey(name: 'currency_code') @Default('USD') String currencyCode,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'package_entitlement_rules')
    @Default(<PackageEntitlementRuleModel>[])
    List<PackageEntitlementRuleModel> rules,
  }) = _PackageModel;

  factory PackageModel.fromJson(Map<String, dynamic> json) =>
      _$PackageModelFromJson(json);
}

@freezed
abstract class MemberSubscriptionModel with _$MemberSubscriptionModel {
  const factory MemberSubscriptionModel({
    required String id,
    @JsonKey(name: 'organization_id') required String organizationId,
    @JsonKey(name: 'member_id') required String memberId,
    @JsonKey(name: 'package_id') required String packageId,
    @JsonKey(name: 'assigned_branch_id') required String assignedBranchId,
    required SubscriptionStatus status,
    @JsonKey(name: 'starts_at') required DateTime startsAt,
    @JsonKey(name: 'ends_at') DateTime? endsAt,
    @JsonKey(name: 'frozen_at') DateTime? frozenAt,
    @JsonKey(name: 'total_frozen_seconds') @Default(0) int totalFrozenSeconds,
  }) = _MemberSubscriptionModel;

  factory MemberSubscriptionModel.fromJson(Map<String, dynamic> json) =>
      _$MemberSubscriptionModelFromJson(json);
}

@freezed
abstract class MemberEntitlementModel with _$MemberEntitlementModel {
  const factory MemberEntitlementModel({
    required String id,
    @JsonKey(name: 'organization_id') required String organizationId,
    @JsonKey(name: 'member_id') required String memberId,
    @JsonKey(name: 'subscription_id') required String subscriptionId,
    @JsonKey(name: 'entitlement_kind') required EntitlementKind entitlementKind,
    @JsonKey(name: 'branch_access_scope')
    required BranchAccessScope branchAccessScope,
    @JsonKey(name: 'class_scope') required ClassScope classScope,
    @JsonKey(name: 'valid_from') required DateTime validFrom,
    @JsonKey(name: 'valid_until') required DateTime validUntil,
    required EntitlementStatus status,
    @Default(<String>[]) List<String> allowedBranchIds,
  }) = _MemberEntitlementModel;

  factory MemberEntitlementModel.fromJson(Map<String, dynamic> json) =>
      _$MemberEntitlementModelFromJson(json);
}

@freezed
abstract class CreditGrantModel with _$CreditGrantModel {
  const factory CreditGrantModel({
    required String id,
    @JsonKey(name: 'organization_id') required String organizationId,
    @JsonKey(name: 'member_id') required String memberId,
    @JsonKey(name: 'subscription_id') String? subscriptionId,
    @JsonKey(name: 'credit_type') required CreditType creditType,
    @JsonKey(name: 'branch_access_scope')
    required BranchAccessScope branchAccessScope,
    @JsonKey(name: 'class_scope') required ClassScope classScope,
    @JsonKey(name: 'initial_amount') required int initialAmount,
    @JsonKey(name: 'remaining_amount') required int remainingAmount,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
    required CreditGrantStatus status,
    @Default(<String>[]) List<String> allowedBranchIds,
    @Default(<String>[]) List<String> allowedClassTypeIds,
  }) = _CreditGrantModel;

  factory CreditGrantModel.fromJson(Map<String, dynamic> json) =>
      _$CreditGrantModelFromJson(json);
}

@freezed
abstract class CreditLedgerEntryModel with _$CreditLedgerEntryModel {
  const factory CreditLedgerEntryModel({
    required String id,
    @JsonKey(name: 'organization_id') required String organizationId,
    @JsonKey(name: 'member_id') required String memberId,
    @JsonKey(name: 'grant_id') required String grantId,
    @JsonKey(name: 'credit_type') required CreditType creditType,
    @JsonKey(name: 'entry_type') required LedgerEntryType entryType,
    required int delta,
    @JsonKey(name: 'reference_type') required String referenceType,
    @JsonKey(name: 'reference_id') required String referenceId,
    String? reason,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _CreditLedgerEntryModel;

  factory CreditLedgerEntryModel.fromJson(Map<String, dynamic> json) =>
      _$CreditLedgerEntryModelFromJson(json);
}

class CreatePackageRuleInput {
  const CreatePackageRuleInput({
    required this.entitlementKind,
    this.durationDays,
    this.creditQuantity,
    this.branchAccessScope = BranchAccessScope.singleBranch,
    this.classScope = ClassScope.allClasses,
    this.allowedBranchIds = const <String>[],
    this.allowedClassTypeIds = const <String>[],
  });

  final EntitlementKind entitlementKind;
  final int? durationDays;
  final int? creditQuantity;
  final BranchAccessScope branchAccessScope;
  final ClassScope classScope;
  final List<String> allowedBranchIds;
  final List<String> allowedClassTypeIds;
}

class MemberWalletSnapshot {
  const MemberWalletSnapshot({
    required this.subscriptions,
    required this.entitlements,
    required this.creditGrants,
    required this.ledgerEntries,
  });

  final List<MemberSubscriptionModel> subscriptions;
  final List<MemberEntitlementModel> entitlements;
  final List<CreditGrantModel> creditGrants;
  final List<CreditLedgerEntryModel> ledgerEntries;

  int get totalClassCredits {
    final now = DateTime.now().toUtc();
    return creditGrants
        .where(
          (g) =>
              g.creditType == CreditType.classCredit &&
              g.status == CreditGrantStatus.active &&
              (g.expiresAt == null || g.expiresAt!.isAfter(now)),
        )
        .fold<int>(0, (sum, g) => sum + g.remainingAmount);
  }

  int get totalPtCredits {
    final now = DateTime.now().toUtc();
    return creditGrants
        .where(
          (g) =>
              g.creditType == CreditType.ptCredit &&
              g.status == CreditGrantStatus.active &&
              (g.expiresAt == null || g.expiresAt!.isAfter(now)),
        )
        .fold<int>(0, (sum, g) => sum + g.remainingAmount);
  }

  bool get hasActiveFacilityAccess {
    final now = DateTime.now().toUtc();
    return entitlements.any(
      (e) =>
          e.entitlementKind == EntitlementKind.facilityAccess &&
          e.status == EntitlementStatus.active &&
          !e.validFrom.isAfter(now) &&
          e.validUntil.isAfter(now),
    );
  }
}
