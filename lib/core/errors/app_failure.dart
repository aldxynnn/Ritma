import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_failure.freezed.dart';

/// Centralized domain and infrastructure failure union.
///
/// Repositories catch low-level exceptions and translate them into an
/// [AppFailure] so presentation and application layers never depend on
/// transport-specific exception classes.
@freezed
sealed class AppFailure with _$AppFailure {
  const factory AppFailure.network({
    @Default('Unable to reach RITMA services. Check your connection.')
    String message,
    Object? cause,
  }) = NetworkFailure;

  const factory AppFailure.unauthorized({
    @Default('Your session has expired. Please sign in again.') String message,
    Object? cause,
  }) = UnauthorizedFailure;

  const factory AppFailure.forbidden({
    @Default('You do not have permission to perform this action.')
    String message,
    String? requiredPermission,
  }) = ForbiddenFailure;

  const factory AppFailure.notFound({
    @Default('The requested resource could not be found.') String message,
    String? resourceType,
  }) = NotFoundFailure;

  const factory AppFailure.conflict({required String message, String? code}) =
      ConflictFailure;

  const factory AppFailure.validation({
    required String message,
    @Default(<String, String>{}) Map<String, String> fieldErrors,
  }) = ValidationFailure;

  const factory AppFailure.unexpected({
    @Default('An unexpected error occurred. Please try again.') String message,
    Object? cause,
    StackTrace? stackTrace,
  }) = UnexpectedFailure;
}
