// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'package_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClassTypeModel _$ClassTypeModelFromJson(Map<String, dynamic> json) =>
    _ClassTypeModel(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      name: json['name'] as String,
      colorToken: json['color_token'] as String? ?? 'sage',
      isActive: json['is_active'] as bool? ?? true,
    );

Map<String, dynamic> _$ClassTypeModelToJson(_ClassTypeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'organization_id': instance.organizationId,
      'name': instance.name,
      'color_token': instance.colorToken,
      'is_active': instance.isActive,
    };

_PackageEntitlementRuleModel _$PackageEntitlementRuleModelFromJson(
  Map<String, dynamic> json,
) => _PackageEntitlementRuleModel(
  id: json['id'] as String,
  organizationId: json['organization_id'] as String,
  packageId: json['package_id'] as String,
  entitlementKind: $enumDecode(
    _$EntitlementKindEnumMap,
    json['entitlement_kind'],
  ),
  durationDays: (json['duration_days'] as num?)?.toInt(),
  creditQuantity: (json['credit_quantity'] as num?)?.toInt(),
  branchAccessScope:
      $enumDecodeNullable(
        _$BranchAccessScopeEnumMap,
        json['branch_access_scope'],
      ) ??
      BranchAccessScope.singleBranch,
  classScope:
      $enumDecodeNullable(_$ClassScopeEnumMap, json['class_scope']) ??
      ClassScope.allClasses,
  allowedBranchIds:
      (json['allowedBranchIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  allowedClassTypeIds:
      (json['allowedClassTypeIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
);

Map<String, dynamic> _$PackageEntitlementRuleModelToJson(
  _PackageEntitlementRuleModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'organization_id': instance.organizationId,
  'package_id': instance.packageId,
  'entitlement_kind': _$EntitlementKindEnumMap[instance.entitlementKind]!,
  'duration_days': instance.durationDays,
  'credit_quantity': instance.creditQuantity,
  'branch_access_scope':
      _$BranchAccessScopeEnumMap[instance.branchAccessScope]!,
  'class_scope': _$ClassScopeEnumMap[instance.classScope]!,
  'allowedBranchIds': instance.allowedBranchIds,
  'allowedClassTypeIds': instance.allowedClassTypeIds,
};

const _$EntitlementKindEnumMap = {
  EntitlementKind.facilityAccess: 'facility_access',
  EntitlementKind.classCredit: 'class_credit',
  EntitlementKind.ptCredit: 'pt_credit',
  EntitlementKind.unlimitedClass: 'unlimited_class',
};

const _$BranchAccessScopeEnumMap = {
  BranchAccessScope.singleBranch: 'single_branch',
  BranchAccessScope.selectedBranches: 'selected_branches',
  BranchAccessScope.allBranches: 'all_branches',
};

const _$ClassScopeEnumMap = {
  ClassScope.allClasses: 'all_classes',
  ClassScope.selectedClasses: 'selected_classes',
};

_PackageModel _$PackageModelFromJson(Map<String, dynamic> json) =>
    _PackageModel(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      packageType: $enumDecode(_$PackageTypeEnumMap, json['package_type']),
      priceMinor: (json['price_minor'] as num?)?.toInt() ?? 0,
      currencyCode: json['currency_code'] as String? ?? 'USD',
      isActive: json['is_active'] as bool? ?? true,
      rules:
          (json['package_entitlement_rules'] as List<dynamic>?)
              ?.map(
                (e) => PackageEntitlementRuleModel.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          const <PackageEntitlementRuleModel>[],
    );

Map<String, dynamic> _$PackageModelToJson(_PackageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'organization_id': instance.organizationId,
      'name': instance.name,
      'description': instance.description,
      'package_type': _$PackageTypeEnumMap[instance.packageType]!,
      'price_minor': instance.priceMinor,
      'currency_code': instance.currencyCode,
      'is_active': instance.isActive,
      'package_entitlement_rules': instance.rules,
    };

const _$PackageTypeEnumMap = {
  PackageType.gymMembership: 'gym_membership',
  PackageType.classPack: 'class_pack',
  PackageType.ptPack: 'pt_pack',
  PackageType.hybrid: 'hybrid',
};

_MemberSubscriptionModel _$MemberSubscriptionModelFromJson(
  Map<String, dynamic> json,
) => _MemberSubscriptionModel(
  id: json['id'] as String,
  organizationId: json['organization_id'] as String,
  memberId: json['member_id'] as String,
  packageId: json['package_id'] as String,
  assignedBranchId: json['assigned_branch_id'] as String,
  status: $enumDecode(_$SubscriptionStatusEnumMap, json['status']),
  startsAt: DateTime.parse(json['starts_at'] as String),
  endsAt: json['ends_at'] == null
      ? null
      : DateTime.parse(json['ends_at'] as String),
  frozenAt: json['frozen_at'] == null
      ? null
      : DateTime.parse(json['frozen_at'] as String),
  totalFrozenSeconds: (json['total_frozen_seconds'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$MemberSubscriptionModelToJson(
  _MemberSubscriptionModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'organization_id': instance.organizationId,
  'member_id': instance.memberId,
  'package_id': instance.packageId,
  'assigned_branch_id': instance.assignedBranchId,
  'status': _$SubscriptionStatusEnumMap[instance.status]!,
  'starts_at': instance.startsAt.toIso8601String(),
  'ends_at': instance.endsAt?.toIso8601String(),
  'frozen_at': instance.frozenAt?.toIso8601String(),
  'total_frozen_seconds': instance.totalFrozenSeconds,
};

const _$SubscriptionStatusEnumMap = {
  SubscriptionStatus.pending: 'pending',
  SubscriptionStatus.active: 'active',
  SubscriptionStatus.frozen: 'frozen',
  SubscriptionStatus.expired: 'expired',
  SubscriptionStatus.cancelled: 'cancelled',
};

_MemberEntitlementModel _$MemberEntitlementModelFromJson(
  Map<String, dynamic> json,
) => _MemberEntitlementModel(
  id: json['id'] as String,
  organizationId: json['organization_id'] as String,
  memberId: json['member_id'] as String,
  subscriptionId: json['subscription_id'] as String,
  entitlementKind: $enumDecode(
    _$EntitlementKindEnumMap,
    json['entitlement_kind'],
  ),
  branchAccessScope: $enumDecode(
    _$BranchAccessScopeEnumMap,
    json['branch_access_scope'],
  ),
  classScope: $enumDecode(_$ClassScopeEnumMap, json['class_scope']),
  validFrom: DateTime.parse(json['valid_from'] as String),
  validUntil: DateTime.parse(json['valid_until'] as String),
  status: $enumDecode(_$EntitlementStatusEnumMap, json['status']),
  allowedBranchIds:
      (json['allowedBranchIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
);

Map<String, dynamic> _$MemberEntitlementModelToJson(
  _MemberEntitlementModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'organization_id': instance.organizationId,
  'member_id': instance.memberId,
  'subscription_id': instance.subscriptionId,
  'entitlement_kind': _$EntitlementKindEnumMap[instance.entitlementKind]!,
  'branch_access_scope':
      _$BranchAccessScopeEnumMap[instance.branchAccessScope]!,
  'class_scope': _$ClassScopeEnumMap[instance.classScope]!,
  'valid_from': instance.validFrom.toIso8601String(),
  'valid_until': instance.validUntil.toIso8601String(),
  'status': _$EntitlementStatusEnumMap[instance.status]!,
  'allowedBranchIds': instance.allowedBranchIds,
};

const _$EntitlementStatusEnumMap = {
  EntitlementStatus.active: 'active',
  EntitlementStatus.frozen: 'frozen',
  EntitlementStatus.expired: 'expired',
  EntitlementStatus.revoked: 'revoked',
};

_CreditGrantModel _$CreditGrantModelFromJson(Map<String, dynamic> json) =>
    _CreditGrantModel(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      memberId: json['member_id'] as String,
      subscriptionId: json['subscription_id'] as String?,
      creditType: $enumDecode(_$CreditTypeEnumMap, json['credit_type']),
      branchAccessScope: $enumDecode(
        _$BranchAccessScopeEnumMap,
        json['branch_access_scope'],
      ),
      classScope: $enumDecode(_$ClassScopeEnumMap, json['class_scope']),
      initialAmount: (json['initial_amount'] as num).toInt(),
      remainingAmount: (json['remaining_amount'] as num).toInt(),
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.parse(json['expires_at'] as String),
      status: $enumDecode(_$CreditGrantStatusEnumMap, json['status']),
      allowedBranchIds:
          (json['allowedBranchIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      allowedClassTypeIds:
          (json['allowedClassTypeIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
    );

Map<String, dynamic> _$CreditGrantModelToJson(_CreditGrantModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'organization_id': instance.organizationId,
      'member_id': instance.memberId,
      'subscription_id': instance.subscriptionId,
      'credit_type': _$CreditTypeEnumMap[instance.creditType]!,
      'branch_access_scope':
          _$BranchAccessScopeEnumMap[instance.branchAccessScope]!,
      'class_scope': _$ClassScopeEnumMap[instance.classScope]!,
      'initial_amount': instance.initialAmount,
      'remaining_amount': instance.remainingAmount,
      'expires_at': instance.expiresAt?.toIso8601String(),
      'status': _$CreditGrantStatusEnumMap[instance.status]!,
      'allowedBranchIds': instance.allowedBranchIds,
      'allowedClassTypeIds': instance.allowedClassTypeIds,
    };

const _$CreditTypeEnumMap = {
  CreditType.classCredit: 'class_credit',
  CreditType.ptCredit: 'pt_credit',
};

const _$CreditGrantStatusEnumMap = {
  CreditGrantStatus.active: 'active',
  CreditGrantStatus.frozen: 'frozen',
  CreditGrantStatus.depleted: 'depleted',
  CreditGrantStatus.expired: 'expired',
  CreditGrantStatus.revoked: 'revoked',
};

_CreditLedgerEntryModel _$CreditLedgerEntryModelFromJson(
  Map<String, dynamic> json,
) => _CreditLedgerEntryModel(
  id: json['id'] as String,
  organizationId: json['organization_id'] as String,
  memberId: json['member_id'] as String,
  grantId: json['grant_id'] as String,
  creditType: $enumDecode(_$CreditTypeEnumMap, json['credit_type']),
  entryType: $enumDecode(_$LedgerEntryTypeEnumMap, json['entry_type']),
  delta: (json['delta'] as num).toInt(),
  referenceType: json['reference_type'] as String,
  referenceId: json['reference_id'] as String,
  reason: json['reason'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$CreditLedgerEntryModelToJson(
  _CreditLedgerEntryModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'organization_id': instance.organizationId,
  'member_id': instance.memberId,
  'grant_id': instance.grantId,
  'credit_type': _$CreditTypeEnumMap[instance.creditType]!,
  'entry_type': _$LedgerEntryTypeEnumMap[instance.entryType]!,
  'delta': instance.delta,
  'reference_type': instance.referenceType,
  'reference_id': instance.referenceId,
  'reason': instance.reason,
  'created_at': instance.createdAt.toIso8601String(),
};

const _$LedgerEntryTypeEnumMap = {
  LedgerEntryType.grant: 'grant',
  LedgerEntryType.consume: 'consume',
  LedgerEntryType.refund: 'refund',
  LedgerEntryType.expire: 'expire',
  LedgerEntryType.adjustment: 'adjustment',
};
