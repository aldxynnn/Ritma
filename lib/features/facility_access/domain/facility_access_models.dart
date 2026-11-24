import 'package:freezed_annotation/freezed_annotation.dart';

part 'facility_access_models.freezed.dart';
part 'facility_access_models.g.dart';

@freezed
abstract class QrPassToken with _$QrPassToken {
  const factory QrPassToken({
    required String token,
    @JsonKey(name: 'issued_at') required DateTime issuedAt,
    @JsonKey(name: 'expires_at') required DateTime expiresAt,
    @JsonKey(name: 'ttl_seconds') @Default(60) int ttlSeconds,
  }) = _QrPassToken;

  factory QrPassToken.fromJson(Map<String, dynamic> json) =>
      _$QrPassTokenFromJson(json);
}

@freezed
abstract class CheckInOutcome with _$CheckInOutcome {
  const factory CheckInOutcome({
    required bool allowed,
    @JsonKey(name: 'reason_code') @Default('OK') String reasonCode,
    @JsonKey(name: 'visit_id') String? visitId,
    @JsonKey(name: 'member_id') String? memberId,
    @JsonKey(name: 'member_name') String? memberName,
    @JsonKey(name: 'entitlement_valid_until') DateTime? entitlementValidUntil,
    @JsonKey(name: 'idempotent_replay') @Default(false) bool idempotentReplay,
  }) = _CheckInOutcome;

  factory CheckInOutcome.fromJson(Map<String, dynamic> json) =>
      _$CheckInOutcomeFromJson(json);
}

@freezed
abstract class FacilityVisitModel with _$FacilityVisitModel {
  const factory FacilityVisitModel({
    required String id,
    @JsonKey(name: 'organization_id') required String organizationId,
    @JsonKey(name: 'branch_id') required String branchId,
    @JsonKey(name: 'member_id') required String memberId,
    @JsonKey(name: 'member_name') String? memberName,
    @JsonKey(name: 'entitlement_id') String? entitlementId,
    @JsonKey(name: 'check_in_method') required String checkInMethod,
    @JsonKey(name: 'override_reason') String? overrideReason,
    @JsonKey(name: 'checked_in_at') required DateTime checkedInAt,
    @JsonKey(name: 'checked_out_at') DateTime? checkedOutAt,
  }) = _FacilityVisitModel;

  factory FacilityVisitModel.fromJson(Map<String, dynamic> json) =>
      _$FacilityVisitModelFromJson(json);
}

@freezed
abstract class CheckInMemberLookup with _$CheckInMemberLookup {
  const factory CheckInMemberLookup({
    required String id,
    @JsonKey(name: 'member_code') required String memberCode,
    @JsonKey(name: 'full_name') required String fullName,
    @JsonKey(name: 'home_branch_id') required String homeBranchId,
    required String status,
  }) = _CheckInMemberLookup;

  factory CheckInMemberLookup.fromJson(Map<String, dynamic> json) =>
      _$CheckInMemberLookupFromJson(json);
}
