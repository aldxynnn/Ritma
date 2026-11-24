import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../core/repository/base_repository.dart';
import '../../../core/result/result.dart';
import '../domain/booking_models.dart';
import '../domain/booking_repository.dart';

class SupabaseBookingRepository extends BaseRepository
    implements BookingRepository {
  SupabaseBookingRepository(this._client)
    : super(loggerName: 'supabase_booking_repo');

  final sb.SupabaseClient _client;

  static const String _sessionColumns =
      'id, organization_id, branch_id, room_id, class_type_id, '
      'instructor_user_id, instructor_display_name, title, starts_at, '
      'ends_at, capacity, confirmed_count, credit_cost, '
      'cancellation_cutoff_at, waitlist_enabled, status';

  @override
  Future<Result<List<ClassSessionModel>>> fetchSessions({
    required String orgId,
    String? branchId,
  }) {
    return guard(() async {
      var builder = _client
          .from('class_sessions')
          .select(_sessionColumns)
          .eq('organization_id', orgId)
          .neq('status', 'cancelled');

      if (branchId != null) {
        builder = builder.eq('branch_id', branchId);
      }

      final rows = await builder.order('starts_at', ascending: true);
      return rows
          .map(
            (row) => ClassSessionModel.fromJson(Map<String, dynamic>.from(row)),
          )
          .toList();
    }, operation: 'fetchSessions');
  }

  @override
  Future<Result<ClassSessionModel>> createClassSession({
    required String orgId,
    required String branchId,
    required String roomId,
    required String classTypeId,
    required String title,
    required DateTime startsAt,
    required DateTime endsAt,
    required int capacity,
    required int creditCost,
    required DateTime cancellationCutoffAt,
    bool waitlistEnabled = true,
    String? instructorUserId,
    String instructorDisplayName = '',
  }) {
    return guard(() async {
      final row = await _client
          .from('class_sessions')
          .insert(<String, dynamic>{
            'organization_id': orgId,
            'branch_id': branchId,
            'room_id': roomId,
            'class_type_id': classTypeId,
            'instructor_user_id': instructorUserId,
            'instructor_display_name': instructorDisplayName.trim(),
            'title': title.trim(),
            'starts_at': startsAt.toUtc().toIso8601String(),
            'ends_at': endsAt.toUtc().toIso8601String(),
            'capacity': capacity,
            'credit_cost': creditCost,
            'cancellation_cutoff_at': cancellationCutoffAt
                .toUtc()
                .toIso8601String(),
            'waitlist_enabled': waitlistEnabled,
          })
          .select(_sessionColumns)
          .single();
      return ClassSessionModel.fromJson(Map<String, dynamic>.from(row));
    }, operation: 'createClassSession');
  }

  @override
  Future<Result<void>> cancelClassSession({
    required String orgId,
    required String sessionId,
    String? reason,
  }) {
    return guard(() async {
      await _client.rpc<dynamic>(
        'cancel_class_session',
        params: <String, dynamic>{
          'p_org_id': orgId,
          'p_session_id': sessionId,
          'p_reason': reason,
        },
      );
    }, operation: 'cancelClassSession');
  }

  @override
  Future<Result<List<ClassBookingModel>>> fetchMemberBookings({
    required String orgId,
    required String memberId,
  }) {
    return guard(() async {
      final rows = await _client
          .from('class_bookings')
          .select(
            'id, organization_id, branch_id, session_id, member_id, status, '
            'attendance_status, waitlist_position, credit_cost, booked_at, cancelled_at',
          )
          .eq('organization_id', orgId)
          .eq('member_id', memberId)
          .order('booked_at', ascending: false);
      return rows
          .map(
            (row) => ClassBookingModel.fromJson(Map<String, dynamic>.from(row)),
          )
          .toList();
    }, operation: 'fetchMemberBookings');
  }

  @override
  Future<Result<BookingActionOutcome>> bookClassSession({
    required String orgId,
    required String sessionId,
    required String memberId,
    required String idempotencyKey,
  }) {
    return guard(() async {
      final raw = await _client.rpc<dynamic>(
        'book_class_session',
        params: <String, dynamic>{
          'p_org_id': orgId,
          'p_session_id': sessionId,
          'p_member_id': memberId,
          'p_idempotency_key': idempotencyKey,
        },
      );
      return BookingActionOutcome.fromJson(
        Map<String, dynamic>.from(raw as Map),
      );
    }, operation: 'bookClassSession');
  }

  @override
  Future<Result<CancelBookingOutcome>> cancelClassBooking({
    required String orgId,
    required String bookingId,
    String? reason,
  }) {
    return guard(() async {
      final raw = await _client.rpc<dynamic>(
        'cancel_class_booking',
        params: <String, dynamic>{
          'p_org_id': orgId,
          'p_booking_id': bookingId,
          'p_reason': reason,
        },
      );
      return CancelBookingOutcome.fromJson(
        Map<String, dynamic>.from(raw as Map),
      );
    }, operation: 'cancelClassBooking');
  }

  @override
  Future<Result<List<SessionRosterEntry>>> fetchSessionRoster({
    required String orgId,
    required String sessionId,
  }) {
    return guard(() async {
      final raw = await _client.rpc<dynamic>(
        'get_session_roster',
        params: <String, dynamic>{'p_org_id': orgId, 'p_session_id': sessionId},
      );
      if (raw is! List<dynamic>) {
        return const <SessionRosterEntry>[];
      }
      return raw
          .whereType<Map<dynamic, dynamic>>()
          .map((r) => SessionRosterEntry.fromJson(Map<String, dynamic>.from(r)))
          .toList();
    }, operation: 'fetchSessionRoster');
  }

  @override
  Future<Result<void>> markAttendance({
    required String orgId,
    required String bookingId,
    required AttendanceStatus attendanceStatus,
  }) {
    return guard(() async {
      await _client.rpc<dynamic>(
        'mark_class_attendance',
        params: <String, dynamic>{
          'p_org_id': orgId,
          'p_booking_id': bookingId,
          'p_attendance_status': switch (attendanceStatus) {
            AttendanceStatus.pending => 'pending',
            AttendanceStatus.checkedIn => 'checked_in',
            AttendanceStatus.noShow => 'no_show',
          },
        },
      );
    }, operation: 'markAttendance');
  }
}
