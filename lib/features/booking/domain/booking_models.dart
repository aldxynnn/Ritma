import 'package:freezed_annotation/freezed_annotation.dart';

part 'booking_models.freezed.dart';
part 'booking_models.g.dart';

enum SessionStatus {
  scheduled,
  @JsonValue('in_progress')
  inProgress,
  completed,
  cancelled,
}

enum BookingStatus {
  confirmed,
  waitlisted,
  @JsonValue('cancelled_early')
  cancelledEarly,
  @JsonValue('cancelled_late')
  cancelledLate,
  @JsonValue('expired_unpromoted')
  expiredUnpromoted;

  String get displayLabel => switch (this) {
    BookingStatus.confirmed => 'Confirmed',
    BookingStatus.waitlisted => 'Waitlisted',
    BookingStatus.cancelledEarly => 'Cancelled (Refunded)',
    BookingStatus.cancelledLate => 'Cancelled Late',
    BookingStatus.expiredUnpromoted => 'Waitlist Expired',
  };
}

enum AttendanceStatus {
  pending,
  @JsonValue('checked_in')
  checkedIn,
  @JsonValue('no_show')
  noShow;

  String get displayLabel => switch (this) {
    AttendanceStatus.pending => 'Pending',
    AttendanceStatus.checkedIn => 'Checked In',
    AttendanceStatus.noShow => 'No Show',
  };
}

@freezed
abstract class ClassSessionModel with _$ClassSessionModel {
  const ClassSessionModel._();

  const factory ClassSessionModel({
    required String id,
    @JsonKey(name: 'organization_id') required String organizationId,
    @JsonKey(name: 'branch_id') required String branchId,
    @JsonKey(name: 'room_id') required String roomId,
    @JsonKey(name: 'class_type_id') required String classTypeId,
    @JsonKey(name: 'instructor_user_id') String? instructorUserId,
    @JsonKey(name: 'instructor_display_name')
    @Default('')
    String instructorDisplayName,
    required String title,
    @JsonKey(name: 'starts_at') required DateTime startsAt,
    @JsonKey(name: 'ends_at') required DateTime endsAt,
    required int capacity,
    @JsonKey(name: 'confirmed_count') @Default(0) int confirmedCount,
    @JsonKey(name: 'credit_cost') @Default(1) int creditCost,
    @JsonKey(name: 'cancellation_cutoff_at')
    required DateTime cancellationCutoffAt,
    @JsonKey(name: 'waitlist_enabled') @Default(true) bool waitlistEnabled,
    @Default(SessionStatus.scheduled) SessionStatus status,
  }) = _ClassSessionModel;

  factory ClassSessionModel.fromJson(Map<String, dynamic> json) =>
      _$ClassSessionModelFromJson(json);

  int get remainingSpots => (capacity - confirmedCount).clamp(0, capacity);
  bool get isFull => confirmedCount >= capacity;
}

@freezed
abstract class ClassBookingModel with _$ClassBookingModel {
  const factory ClassBookingModel({
    required String id,
    @JsonKey(name: 'organization_id') required String organizationId,
    @JsonKey(name: 'branch_id') required String branchId,
    @JsonKey(name: 'session_id') required String sessionId,
    @JsonKey(name: 'member_id') required String memberId,
    required BookingStatus status,
    @JsonKey(name: 'attendance_status')
    @Default(AttendanceStatus.pending)
    AttendanceStatus attendanceStatus,
    @JsonKey(name: 'waitlist_position') int? waitlistPosition,
    @JsonKey(name: 'credit_cost') @Default(0) int creditCost,
    @JsonKey(name: 'booked_at') required DateTime bookedAt,
    @JsonKey(name: 'cancelled_at') DateTime? cancelledAt,
  }) = _ClassBookingModel;

  factory ClassBookingModel.fromJson(Map<String, dynamic> json) =>
      _$ClassBookingModelFromJson(json);
}

@freezed
abstract class SessionRosterEntry with _$SessionRosterEntry {
  const factory SessionRosterEntry({
    @JsonKey(name: 'booking_id') required String bookingId,
    @JsonKey(name: 'member_id') required String memberId,
    @JsonKey(name: 'member_display_name') required String memberDisplayName,
    @JsonKey(name: 'member_code') required String memberCode,
    required BookingStatus status,
    @JsonKey(name: 'attendance_status')
    @Default(AttendanceStatus.pending)
    AttendanceStatus attendanceStatus,
    @JsonKey(name: 'waitlist_position') int? waitlistPosition,
    @JsonKey(name: 'booked_at') required DateTime bookedAt,
  }) = _SessionRosterEntry;

  factory SessionRosterEntry.fromJson(Map<String, dynamic> json) =>
      _$SessionRosterEntryFromJson(json);
}

@freezed
abstract class BookingActionOutcome with _$BookingActionOutcome {
  const factory BookingActionOutcome({
    @JsonKey(name: 'booking_id') required String bookingId,
    required BookingStatus status,
    @JsonKey(name: 'waitlist_position') int? waitlistPosition,
    @JsonKey(name: 'idempotent_replay') @Default(false) bool idempotentReplay,
  }) = _BookingActionOutcome;

  factory BookingActionOutcome.fromJson(Map<String, dynamic> json) =>
      _$BookingActionOutcomeFromJson(json);
}

@freezed
abstract class CancelBookingOutcome with _$CancelBookingOutcome {
  const factory CancelBookingOutcome({
    required BookingStatus status,
    @JsonKey(name: 'refunded_credits') @Default(0) int refundedCredits,
    @JsonKey(name: 'promoted_booking_id') String? promotedBookingId,
    @JsonKey(name: 'idempotent_replay') @Default(false) bool idempotentReplay,
  }) = _CancelBookingOutcome;

  factory CancelBookingOutcome.fromJson(Map<String, dynamic> json) =>
      _$CancelBookingOutcomeFromJson(json);
}

@freezed
abstract class AssignableInstructor with _$AssignableInstructor {
  const factory AssignableInstructor({
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'display_name') required String displayName,
    @JsonKey(name: 'role_code') @Default('') String roleCode,
    @JsonKey(name: 'role_display_name') @Default('') String roleDisplayName,
  }) = _AssignableInstructor;

  factory AssignableInstructor.fromJson(Map<String, dynamic> json) =>
      _$AssignableInstructorFromJson(json);
}
