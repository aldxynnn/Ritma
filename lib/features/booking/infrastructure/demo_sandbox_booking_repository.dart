import '../../../core/demo/demo_sandbox_engine.dart';
import '../../../core/repository/base_repository.dart';
import '../../../core/result/result.dart';
import '../domain/booking_models.dart';
import '../domain/booking_repository.dart';

class DemoSandboxBookingRepository extends BaseRepository
    implements BookingRepository {
  DemoSandboxBookingRepository(this._engine)
    : super(loggerName: 'demo_booking_repo');

  final DemoSandboxEngine _engine;

  @override
  Future<Result<List<ClassSessionModel>>> fetchSessions({
    required String orgId,
    String? branchId,
  }) {
    return guard(() async {
      final list =
          _engine.classSessions.values
              .where(
                (s) =>
                    s.organizationId == orgId &&
                    s.status != SessionStatus.cancelled &&
                    (branchId == null || s.branchId == branchId),
              )
              .toList()
            ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
      return list;
    }, operation: 'demo.fetchSessions');
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
    return guard(
      () async => _engine.createClassSession(
        orgId: orgId,
        branchId: branchId,
        roomId: roomId,
        classTypeId: classTypeId,
        title: title,
        startsAt: startsAt,
        endsAt: endsAt,
        capacity: capacity,
        creditCost: creditCost,
        cancellationCutoffAt: cancellationCutoffAt,
        waitlistEnabled: waitlistEnabled,
        instructorUserId: instructorUserId,
        instructorDisplayName: instructorDisplayName,
      ),
      operation: 'demo.createClassSession',
    );
  }

  @override
  Future<Result<void>> cancelClassSession({
    required String orgId,
    required String sessionId,
    String? reason,
  }) {
    return guard(
      () async => _engine.cancelClassSession(
        orgId: orgId,
        sessionId: sessionId,
        reason: reason,
      ),
      operation: 'demo.cancelClassSession',
    );
  }

  @override
  Future<Result<List<ClassBookingModel>>> fetchMemberBookings({
    required String orgId,
    required String memberId,
  }) {
    return guard(() async {
      final list =
          _engine.classBookings
              .where((b) => b.organizationId == orgId && b.memberId == memberId)
              .toList()
            ..sort((a, b) => b.bookedAt.compareTo(a.bookedAt));
      return list;
    }, operation: 'demo.fetchMemberBookings');
  }

  @override
  Future<Result<BookingActionOutcome>> bookClassSession({
    required String orgId,
    required String sessionId,
    required String memberId,
    required String idempotencyKey,
  }) {
    return guard(
      () async => _engine.bookClassSession(
        orgId: orgId,
        sessionId: sessionId,
        memberId: memberId,
        idempotencyKey: idempotencyKey,
      ),
      operation: 'demo.bookClassSession',
    );
  }

  @override
  Future<Result<CancelBookingOutcome>> cancelClassBooking({
    required String orgId,
    required String bookingId,
    String? reason,
  }) {
    return guard(
      () async => _engine.cancelClassBooking(
        orgId: orgId,
        bookingId: bookingId,
        reason: reason,
      ),
      operation: 'demo.cancelClassBooking',
    );
  }

  @override
  Future<Result<List<SessionRosterEntry>>> fetchSessionRoster({
    required String orgId,
    required String sessionId,
  }) {
    return guard(
      () async => _engine.getSessionRoster(orgId: orgId, sessionId: sessionId),
      operation: 'demo.fetchSessionRoster',
    );
  }

  @override
  Future<Result<void>> markAttendance({
    required String orgId,
    required String bookingId,
    required AttendanceStatus attendanceStatus,
  }) {
    return guard(
      () async => _engine.markClassAttendance(
        orgId: orgId,
        bookingId: bookingId,
        attendanceStatus: attendanceStatus,
      ),
      operation: 'demo.markAttendance',
    );
  }
}
