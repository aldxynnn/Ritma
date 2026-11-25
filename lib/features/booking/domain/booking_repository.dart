import '../../../core/result/result.dart';
import 'booking_models.dart';

abstract interface class BookingRepository {
  Future<Result<List<ClassSessionModel>>> fetchSessions({
    required String orgId,
    String? branchId,
  });

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
  });

  Future<Result<List<AssignableInstructor>>> fetchAssignableInstructors({
    required String orgId,
    String? branchId,
  });

  Future<Result<ClassSessionModel>> updateClassSession({
    required String orgId,
    required String sessionId,
    required String roomId,
    required String classTypeId,
    required String title,
    required DateTime startsAt,
    required DateTime endsAt,
    required int capacity,
    required int creditCost,
    required DateTime cancellationCutoffAt,
    required bool waitlistEnabled,
    String? instructorUserId,
    required String instructorDisplayName,
  });

  Future<Result<void>> cancelClassSession({
    required String orgId,
    required String sessionId,
    String? reason,
  });

  Future<Result<List<ClassBookingModel>>> fetchMemberBookings({
    required String orgId,
    required String memberId,
  });

  Future<Result<BookingActionOutcome>> bookClassSession({
    required String orgId,
    required String sessionId,
    required String memberId,
    required String idempotencyKey,
  });

  Future<Result<CancelBookingOutcome>> cancelClassBooking({
    required String orgId,
    required String bookingId,
    String? reason,
  });

  Future<Result<List<SessionRosterEntry>>> fetchSessionRoster({
    required String orgId,
    required String sessionId,
  });

  Future<Result<void>> markAttendance({
    required String orgId,
    required String bookingId,
    required AttendanceStatus attendanceStatus,
  });
}
