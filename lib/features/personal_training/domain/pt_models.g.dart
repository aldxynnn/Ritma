// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pt_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TrainerProfileModel _$TrainerProfileModelFromJson(Map<String, dynamic> json) =>
    _TrainerProfileModel(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      userId: json['user_id'] as String,
      homeBranchId: json['home_branch_id'] as String,
      bio: json['bio'] as String? ?? '',
      specialties:
          (json['specialties'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      defaultCreditCost: (json['default_credit_cost'] as num?)?.toInt() ?? 1,
      isActive: json['is_active'] as bool? ?? true,
      displayName: json['display_name'] as String? ?? '',
    );

Map<String, dynamic> _$TrainerProfileModelToJson(
  _TrainerProfileModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'organization_id': instance.organizationId,
  'user_id': instance.userId,
  'home_branch_id': instance.homeBranchId,
  'bio': instance.bio,
  'specialties': instance.specialties,
  'default_credit_cost': instance.defaultCreditCost,
  'is_active': instance.isActive,
  'display_name': instance.displayName,
};

_TrainerAvailabilityModel _$TrainerAvailabilityModelFromJson(
  Map<String, dynamic> json,
) => _TrainerAvailabilityModel(
  id: json['id'] as String,
  organizationId: json['organization_id'] as String,
  branchId: json['branch_id'] as String,
  trainerId: json['trainer_id'] as String,
  weekday: (json['weekday'] as num).toInt(),
  startTime: json['start_time'] as String,
  endTime: json['end_time'] as String,
);

Map<String, dynamic> _$TrainerAvailabilityModelToJson(
  _TrainerAvailabilityModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'organization_id': instance.organizationId,
  'branch_id': instance.branchId,
  'trainer_id': instance.trainerId,
  'weekday': instance.weekday,
  'start_time': instance.startTime,
  'end_time': instance.endTime,
};

_PtSessionModel _$PtSessionModelFromJson(Map<String, dynamic> json) =>
    _PtSessionModel(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      branchId: json['branch_id'] as String,
      trainerId: json['trainer_id'] as String,
      trainerUserId: json['trainer_user_id'] as String?,
      memberId: json['member_id'] as String,
      startsAt: DateTime.parse(json['starts_at'] as String),
      endsAt: DateTime.parse(json['ends_at'] as String),
      creditCost: (json['credit_cost'] as num?)?.toInt() ?? 1,
      status:
          $enumDecodeNullable(_$PtSessionStatusEnumMap, json['status']) ??
          PtSessionStatus.scheduled,
      notes: json['notes'] as String?,
      trainerDisplayName: json['trainer_display_name'] as String? ?? '',
      memberDisplayName: json['member_display_name'] as String? ?? '',
      memberCode: json['member_code'] as String? ?? '',
    );

Map<String, dynamic> _$PtSessionModelToJson(_PtSessionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'organization_id': instance.organizationId,
      'branch_id': instance.branchId,
      'trainer_id': instance.trainerId,
      'trainer_user_id': instance.trainerUserId,
      'member_id': instance.memberId,
      'starts_at': instance.startsAt.toIso8601String(),
      'ends_at': instance.endsAt.toIso8601String(),
      'credit_cost': instance.creditCost,
      'status': _$PtSessionStatusEnumMap[instance.status]!,
      'notes': instance.notes,
      'trainer_display_name': instance.trainerDisplayName,
      'member_display_name': instance.memberDisplayName,
      'member_code': instance.memberCode,
    };

const _$PtSessionStatusEnumMap = {
  PtSessionStatus.scheduled: 'scheduled',
  PtSessionStatus.completed: 'completed',
  PtSessionStatus.cancelledEarly: 'cancelled_early',
  PtSessionStatus.cancelledLate: 'cancelled_late',
  PtSessionStatus.noShow: 'no_show',
};

_PtClientLookup _$PtClientLookupFromJson(Map<String, dynamic> json) =>
    _PtClientLookup(
      id: json['id'] as String,
      memberCode: json['member_code'] as String,
      fullName: json['full_name'] as String,
      homeBranchId: json['home_branch_id'] as String,
      status: json['status'] as String? ?? 'active',
      availablePtCredits: (json['available_pt_credits'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$PtClientLookupToJson(_PtClientLookup instance) =>
    <String, dynamic>{
      'id': instance.id,
      'member_code': instance.memberCode,
      'full_name': instance.fullName,
      'home_branch_id': instance.homeBranchId,
      'status': instance.status,
      'available_pt_credits': instance.availablePtCredits,
    };

_PtBookingOutcome _$PtBookingOutcomeFromJson(Map<String, dynamic> json) =>
    _PtBookingOutcome(
      ptSessionId: json['pt_session_id'] as String,
      status:
          $enumDecodeNullable(_$PtSessionStatusEnumMap, json['status']) ??
          PtSessionStatus.scheduled,
      creditCost: (json['credit_cost'] as num?)?.toInt() ?? 1,
      idempotentReplay: json['idempotent_replay'] as bool? ?? false,
    );

Map<String, dynamic> _$PtBookingOutcomeToJson(_PtBookingOutcome instance) =>
    <String, dynamic>{
      'pt_session_id': instance.ptSessionId,
      'status': _$PtSessionStatusEnumMap[instance.status]!,
      'credit_cost': instance.creditCost,
      'idempotent_replay': instance.idempotentReplay,
    };

_PtCancelOutcome _$PtCancelOutcomeFromJson(Map<String, dynamic> json) =>
    _PtCancelOutcome(
      status:
          $enumDecodeNullable(_$PtSessionStatusEnumMap, json['status']) ??
          PtSessionStatus.cancelledEarly,
      refundedCredits: (json['refunded_credits'] as num?)?.toInt() ?? 0,
      idempotentReplay: json['idempotent_replay'] as bool? ?? false,
    );

Map<String, dynamic> _$PtCancelOutcomeToJson(_PtCancelOutcome instance) =>
    <String, dynamic>{
      'status': _$PtSessionStatusEnumMap[instance.status]!,
      'refunded_credits': instance.refundedCredits,
      'idempotent_replay': instance.idempotentReplay,
    };
