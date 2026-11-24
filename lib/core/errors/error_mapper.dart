import 'dart:async';

import 'app_failure.dart';

/// Application-level exception that carries a pre-classified [AppFailure].
class AppException implements Exception {
  const AppException(this.failure);

  final AppFailure failure;

  @override
  String toString() => 'AppException($failure)';
}

/// Maps arbitrary runtime errors and exceptions into typed [AppFailure] values.
abstract final class ErrorMapper {
  static AppFailure map(Object error, [StackTrace? stackTrace]) {
    if (error is AppFailure) {
      return error;
    }
    if (error is AppException) {
      return error.failure;
    }
    if (error is TimeoutException) {
      return AppFailure.network(
        message: 'The request timed out. Please try again.',
        cause: error,
      );
    }
    if (error is FormatException) {
      return AppFailure.validation(message: error.message);
    }
    if (error is ArgumentError) {
      return AppFailure.validation(
        message: error.message?.toString() ?? 'Invalid input provided.',
      );
    }

    return AppFailure.unexpected(cause: error, stackTrace: stackTrace);
  }
}
