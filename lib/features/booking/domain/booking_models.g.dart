// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClassSessionModel _$ClassSessionModelFromJson(Map<String, dynamic> json) =>
    _ClassSessionModel(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      branchId: json['branch_id'] as String,
      roomId: json['room_id'] as String,
      classTypeId: json['class_type_id'] as String,
      instructorUserId: json['instructor_user_id'] as String?,
      instructorDisplayName: json['instructor_display_name'] as String? ?? '',
      title: json['title'] as String,
      startsAt: DateTime.parse(json['starts_at'] as String),
      endsAt: DateTime.parse(json['ends_at'] as String),
      capacity: (json['capacity'] as num).toInt(),
      confirmedCount: (json['confirmed_count'] as num?)?.toInt() ?? 0,
      creditCost: (json['credit_cost'] as num?)?.toInt() ?? 1,
      cancellationCutoffAt: DateTime.parse(
        json['cancellation_cutoff_at'] as String,
      ),
      waitlistEnabled: json['waitlist_enabled'] as bool? ?? true,
      status:
          $enumDecodeNullable(_$SessionStatusEnumMap, json['status']) ??
          SessionStatus.scheduled,
    );

Map<String, dynamic> _$ClassSessionModelToJson(_ClassSessionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'organization_id': instance.organizationId,
      'branch_id': instance.branchId,
      'room_id': instance.roomId,
      'class_type_id': instance.classTypeId,
      'instructor_user_id': instance.instructorUserId,
      'instructor_display_name': instance.instructorDisplayName,
      'title': instance.title,
      'starts_at': instance.startsAt.toIso8601String(),
      'ends_at': instance.endsAt.toIso8601String(),
      'capacity': instance.capacity,
      'confirmed_count': instance.confirmedCount,
      'credit_cost': instance.creditCost,
      'cancellation_cutoff_at': instance.cancellationCutoffAt.toIso8601String(),
      'waitlist_enabled': instance.waitlistEnabled,
      'status': _$SessionStatusEnumMap[instance.status]!,
    };

const _$SessionStatusEnumMap = {
  SessionStatus.scheduled: 'scheduled',
  SessionStatus.inProgress: 'in_progress',
  SessionStatus.completed: 'completed',
  SessionStatus.cancelled: 'cancelled',
};

_ClassBookingModel _$ClassBookingModelFromJson(Map<String, dynamic> json) =>
    _ClassBookingModel(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      branchId: json['branch_id'] as String,
      sessionId: json['session_id'] as String,
      memberId: json['member_id'] as String,
      status: $enumDecode(_$BookingStatusEnumMap, json['status']),
      attendanceStatus:
          $enumDecodeNullable(
            _$AttendanceStatusEnumMap,
            json['attendance_status'],
          ) ??
          AttendanceStatus.pending,
      waitlistPosition: (json['waitlist_position'] as num?)?.toInt(),
      creditCost: (json['credit_cost'] as num?)?.toInt() ?? 0,
      bookedAt: DateTime.parse(json['booked_at'] as String),
      cancelledAt: json['cancelled_at'] == null
          ? null
          : DateTime.parse(json['cancelled_at'] as String),
    );

Map<String, dynamic> _$ClassBookingModelToJson(
  _ClassBookingModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'organization_id': instance.organizationId,
  'branch_id': instance.branchId,
  'session_id': instance.sessionId,
  'member_id': instance.memberId,
  'status': _$BookingStatusEnumMap[instance.status]!,
  'attendance_status': _$AttendanceStatusEnumMap[instance.attendanceStatus]!,
  'waitlist_position': instance.waitlistPosition,
  'credit_cost': instance.creditCost,
  'booked_at': instance.bookedAt.toIso8601String(),
  'cancelled_at': instance.cancelledAt?.toIso8601String(),
};

const _$BookingStatusEnumMap = {
  BookingStatus.confirmed: 'confirmed',
  BookingStatus.waitlisted: 'waitlisted',
  BookingStatus.cancelledEarly: 'cancelled_early',
  BookingStatus.cancelledLate: 'cancelled_late',
  BookingStatus.expiredUnpromoted: 'expired_unpromoted',
};

const _$AttendanceStatusEnumMap = {
  AttendanceStatus.pending: 'pending',
  AttendanceStatus.checkedIn: 'checked_in',
  AttendanceStatus.noShow: 'no_show',
};

_SessionRosterEntry _$SessionRosterEntryFromJson(Map<String, dynamic> json) =>
    _SessionRosterEntry(
      bookingId: json['booking_id'] as String,
      memberId: json['member_id'] as String,
      memberDisplayName: json['member_display_name'] as String,
      memberCode: json['member_code'] as String,
      status: $enumDecode(_$BookingStatusEnumMap, json['status']),
      attendanceStatus:
          $enumDecodeNullable(
            _$AttendanceStatusEnumMap,
            json['attendance_status'],
          ) ??
          AttendanceStatus.pending,
      waitlistPosition: (json['waitlist_position'] as num?)?.toInt(),
      bookedAt: DateTime.parse(json['booked_at'] as String),
    );

Map<String, dynamic> _$SessionRosterEntryToJson(
  _SessionRosterEntry instance,
) => <String, dynamic>{
  'booking_id': instance.bookingId,
  'member_id': instance.memberId,
  'member_display_name': instance.memberDisplayName,
  'member_code': instance.memberCode,
  'status': _$BookingStatusEnumMap[instance.status]!,
  'attendance_status': _$AttendanceStatusEnumMap[instance.attendanceStatus]!,
  'waitlist_position': instance.waitlistPosition,
  'booked_at': instance.bookedAt.toIso8601String(),
};

_BookingActionOutcome _$BookingActionOutcomeFromJson(
  Map<String, dynamic> json,
) => _BookingActionOutcome(
  bookingId: json['booking_id'] as String,
  status: $enumDecode(_$BookingStatusEnumMap, json['status']),
  waitlistPosition: (json['waitlist_position'] as num?)?.toInt(),
  idempotentReplay: json['idempotent_replay'] as bool? ?? false,
);

Map<String, dynamic> _$BookingActionOutcomeToJson(
  _BookingActionOutcome instance,
) => <String, dynamic>{
  'booking_id': instance.bookingId,
  'status': _$BookingStatusEnumMap[instance.status]!,
  'waitlist_position': instance.waitlistPosition,
  'idempotent_replay': instance.idempotentReplay,
};

_CancelBookingOutcome _$CancelBookingOutcomeFromJson(
  Map<String, dynamic> json,
) => _CancelBookingOutcome(
  status: $enumDecode(_$BookingStatusEnumMap, json['status']),
  refundedCredits: (json['refunded_credits'] as num?)?.toInt() ?? 0,
  promotedBookingId: json['promoted_booking_id'] as String?,
  idempotentReplay: json['idempotent_replay'] as bool? ?? false,
);

Map<String, dynamic> _$CancelBookingOutcomeToJson(
  _CancelBookingOutcome instance,
) => <String, dynamic>{
  'status': _$BookingStatusEnumMap[instance.status]!,
  'refunded_credits': instance.refundedCredits,
  'promoted_booking_id': instance.promotedBookingId,
  'idempotent_replay': instance.idempotentReplay,
};

_AssignableInstructor _$AssignableInstructorFromJson(
  Map<String, dynamic> json,
) => _AssignableInstructor(
  userId: json['user_id'] as String,
  displayName: json['display_name'] as String,
  roleCode: json['role_code'] as String? ?? '',
  roleDisplayName: json['role_display_name'] as String? ?? '',
);

Map<String, dynamic> _$AssignableInstructorToJson(
  _AssignableInstructor instance,
) => <String, dynamic>{
  'user_id': instance.userId,
  'display_name': instance.displayName,
  'role_code': instance.roleCode,
  'role_display_name': instance.roleDisplayName,
};
