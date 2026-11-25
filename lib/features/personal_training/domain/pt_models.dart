import 'package:freezed_annotation/freezed_annotation.dart';

part 'pt_models.freezed.dart';
part 'pt_models.g.dart';

enum PtSessionStatus {
  scheduled,
  completed,
  @JsonValue('cancelled_early')
  cancelledEarly,
  @JsonValue('cancelled_late')
  cancelledLate,
  @JsonValue('no_show')
  noShow;

  String get displayLabel => switch (this) {
    PtSessionStatus.scheduled => 'Scheduled',
    PtSessionStatus.completed => 'Completed',
    PtSessionStatus.cancelledEarly => 'Cancelled Early',
    PtSessionStatus.cancelledLate => 'Cancelled Late',
    PtSessionStatus.noShow => 'No Show',
  };
}

@freezed
abstract class TrainerProfileModel with _$TrainerProfileModel {
  const factory TrainerProfileModel({
    required String id,
    @JsonKey(name: 'organization_id') required String organizationId,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'home_branch_id') required String homeBranchId,
    @Default('') String bio,
    @Default(<String>[]) List<String> specialties,
    @JsonKey(name: 'default_credit_cost') @Default(1) int defaultCreditCost,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'display_name') @Default('') String displayName,
  }) = _TrainerProfileModel;

  factory TrainerProfileModel.fromJson(Map<String, dynamic> json) =>
      _$TrainerProfileModelFromJson(json);
}

@freezed
abstract class TrainerAvailabilityModel with _$TrainerAvailabilityModel {
  const factory TrainerAvailabilityModel({
    required String id,
    @JsonKey(name: 'organization_id') required String organizationId,
    @JsonKey(name: 'branch_id') required String branchId,
    @JsonKey(name: 'trainer_id') required String trainerId,
    required int weekday,
    @JsonKey(name: 'start_time') required String startTime,
    @JsonKey(name: 'end_time') required String endTime,
  }) = _TrainerAvailabilityModel;

  factory TrainerAvailabilityModel.fromJson(Map<String, dynamic> json) =>
      _$TrainerAvailabilityModelFromJson(json);
}

@freezed
abstract class PtSessionModel with _$PtSessionModel {
  const factory PtSessionModel({
    required String id,
    @JsonKey(name: 'organization_id') required String organizationId,
    @JsonKey(name: 'branch_id') required String branchId,
    @JsonKey(name: 'trainer_id') required String trainerId,
    @JsonKey(name: 'trainer_user_id') String? trainerUserId,
    @JsonKey(name: 'member_id') required String memberId,
    @JsonKey(name: 'starts_at') required DateTime startsAt,
    @JsonKey(name: 'ends_at') required DateTime endsAt,
    @JsonKey(name: 'credit_cost') @Default(1) int creditCost,
    @Default(PtSessionStatus.scheduled) PtSessionStatus status,
    String? notes,
    @JsonKey(name: 'trainer_display_name')
    @Default('')
    String trainerDisplayName,
    @JsonKey(name: 'member_display_name') @Default('') String memberDisplayName,
    @JsonKey(name: 'member_code') @Default('') String memberCode,
  }) = _PtSessionModel;

  factory PtSessionModel.fromJson(Map<String, dynamic> json) =>
      _$PtSessionModelFromJson(json);
}

@freezed
abstract class PtClientLookup with _$PtClientLookup {
  const factory PtClientLookup({
    required String id,
    @JsonKey(name: 'member_code') required String memberCode,
    @JsonKey(name: 'full_name') required String fullName,
    @JsonKey(name: 'home_branch_id') required String homeBranchId,
    @Default('active') String status,
    @JsonKey(name: 'available_pt_credits') @Default(0) int availablePtCredits,
  }) = _PtClientLookup;

  factory PtClientLookup.fromJson(Map<String, dynamic> json) =>
      _$PtClientLookupFromJson(json);
}

@freezed
abstract class PtBookingOutcome with _$PtBookingOutcome {
  const factory PtBookingOutcome({
    @JsonKey(name: 'pt_session_id') required String ptSessionId,
    @Default(PtSessionStatus.scheduled) PtSessionStatus status,
    @JsonKey(name: 'credit_cost') @Default(1) int creditCost,
    @JsonKey(name: 'idempotent_replay') @Default(false) bool idempotentReplay,
  }) = _PtBookingOutcome;

  factory PtBookingOutcome.fromJson(Map<String, dynamic> json) =>
      _$PtBookingOutcomeFromJson(json);
}

@freezed
abstract class PtCancelOutcome with _$PtCancelOutcome {
  const factory PtCancelOutcome({
    @Default(PtSessionStatus.cancelledEarly) PtSessionStatus status,
    @JsonKey(name: 'refunded_credits') @Default(0) int refundedCredits,
    @JsonKey(name: 'idempotent_replay') @Default(false) bool idempotentReplay,
  }) = _PtCancelOutcome;

  factory PtCancelOutcome.fromJson(Map<String, dynamic> json) =>
      _$PtCancelOutcomeFromJson(json);
}
