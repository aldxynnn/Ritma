// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'facility_access_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_QrPassToken _$QrPassTokenFromJson(Map<String, dynamic> json) => _QrPassToken(
  token: json['token'] as String,
  issuedAt: DateTime.parse(json['issued_at'] as String),
  expiresAt: DateTime.parse(json['expires_at'] as String),
  ttlSeconds: (json['ttl_seconds'] as num?)?.toInt() ?? 60,
);

Map<String, dynamic> _$QrPassTokenToJson(_QrPassToken instance) =>
    <String, dynamic>{
      'token': instance.token,
      'issued_at': instance.issuedAt.toIso8601String(),
      'expires_at': instance.expiresAt.toIso8601String(),
      'ttl_seconds': instance.ttlSeconds,
    };

_CheckInOutcome _$CheckInOutcomeFromJson(Map<String, dynamic> json) =>
    _CheckInOutcome(
      allowed: json['allowed'] as bool,
      reasonCode: json['reason_code'] as String? ?? 'OK',
      visitId: json['visit_id'] as String?,
      memberId: json['member_id'] as String?,
      memberName: json['member_name'] as String?,
      entitlementValidUntil: json['entitlement_valid_until'] == null
          ? null
          : DateTime.parse(json['entitlement_valid_until'] as String),
      idempotentReplay: json['idempotent_replay'] as bool? ?? false,
    );

Map<String, dynamic> _$CheckInOutcomeToJson(
  _CheckInOutcome instance,
) => <String, dynamic>{
  'allowed': instance.allowed,
  'reason_code': instance.reasonCode,
  'visit_id': instance.visitId,
  'member_id': instance.memberId,
  'member_name': instance.memberName,
  'entitlement_valid_until': instance.entitlementValidUntil?.toIso8601String(),
  'idempotent_replay': instance.idempotentReplay,
};

_FacilityVisitModel _$FacilityVisitModelFromJson(Map<String, dynamic> json) =>
    _FacilityVisitModel(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      branchId: json['branch_id'] as String,
      memberId: json['member_id'] as String,
      memberName: json['member_name'] as String?,
      entitlementId: json['entitlement_id'] as String?,
      checkInMethod: json['check_in_method'] as String,
      overrideReason: json['override_reason'] as String?,
      checkedInAt: DateTime.parse(json['checked_in_at'] as String),
      checkedOutAt: json['checked_out_at'] == null
          ? null
          : DateTime.parse(json['checked_out_at'] as String),
    );

Map<String, dynamic> _$FacilityVisitModelToJson(_FacilityVisitModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'organization_id': instance.organizationId,
      'branch_id': instance.branchId,
      'member_id': instance.memberId,
      'member_name': instance.memberName,
      'entitlement_id': instance.entitlementId,
      'check_in_method': instance.checkInMethod,
      'override_reason': instance.overrideReason,
      'checked_in_at': instance.checkedInAt.toIso8601String(),
      'checked_out_at': instance.checkedOutAt?.toIso8601String(),
    };

_CheckInMemberLookup _$CheckInMemberLookupFromJson(Map<String, dynamic> json) =>
    _CheckInMemberLookup(
      id: json['id'] as String,
      memberCode: json['member_code'] as String,
      fullName: json['full_name'] as String,
      homeBranchId: json['home_branch_id'] as String,
      status: json['status'] as String,
    );

Map<String, dynamic> _$CheckInMemberLookupToJson(
  _CheckInMemberLookup instance,
) => <String, dynamic>{
  'id': instance.id,
  'member_code': instance.memberCode,
  'full_name': instance.fullName,
  'home_branch_id': instance.homeBranchId,
  'status': instance.status,
};
