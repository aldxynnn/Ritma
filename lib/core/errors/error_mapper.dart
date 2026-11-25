import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

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
    if (error is AuthException) {
      return _mapAuthException(error);
    }
    if (error is PostgrestException) {
      return _mapPostgrestException(error);
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

  static AppFailure _mapAuthException(AuthException error) {
    final lower = error.message.toLowerCase();
    if (lower.contains('email not confirmed')) {
      return const AppFailure.validation(
        message: 'Your email address has not been confirmed yet. Check your inbox or verify your account before signing in.',
      );
    }
    if (lower.contains('invalid login credentials')) {
      return const AppFailure.validation(message: 'Invalid email or password.');
    }
    if (error.statusCode == '401' ||
        lower.contains('jwt') ||
        lower.contains('session')) {
      return AppFailure.unauthorized(message: error.message, cause: error);
    }
    if (lower.contains('network') || lower.contains('socket')) {
      return AppFailure.network(message: error.message, cause: error);
    }
    return AppFailure.validation(message: error.message);
  }

  static AppFailure _mapPostgrestException(PostgrestException error) {
    final msg = error.message;
    final cleanMsg = _stripPrefix(msg);
    final code = error.code;

    if (msg.startsWith('UNAUTHORIZED:')) {
      return AppFailure.unauthorized(message: cleanMsg, cause: error);
    }
    if (code == '42501' ||
        msg.startsWith('FORBIDDEN:') ||
        msg.toLowerCase().contains('permission denied')) {
      return AppFailure.forbidden(message: cleanMsg);
    }
    if (code == 'PGRST116' || code == 'P0002' || msg.startsWith('NOT_FOUND:')) {
      return AppFailure.notFound(message: cleanMsg);
    }
    if (code == '23505' ||
        _hasPrefix(msg, const [
          'INSUFFICIENT_CREDITS:',
          'INSUFFICIENT_PT_CREDITS:',
          'CAPACITY_EXCEEDED:',
          'CAPACITY_BELOW_BOOKED:',
          'ALREADY_BOOKED:',
          'ALREADY_CLAIMED:',
          'SESSION_CLOSED:',
          'MEMBER_INACTIVE:',
          'OUTSIDE_AVAILABILITY:',
          'TRAINER_CONFLICT:',
          'MEMBER_CONFLICT:',
          'LAST_ORG_OWNER:',
          'IDEMPOTENCY_KEY_REUSED:',
          'INVALID_STATE:',
          'ALREADY_REFUNDED:',
          'REFUND_EXCEEDS_REMAINING:',
          'PAYMENT_NOT_REFUNDABLE:',
        ])) {
      return AppFailure.conflict(
        message: cleanMsg,
        code: _extractCode(msg) ?? code,
      );
    }
    if (code == '22023' ||
        msg.startsWith('VALIDATION_ERROR:') ||
        msg.startsWith('INVALID_INVITATION:') ||
        msg.startsWith('INVALID_CLAIM:') ||
        msg.startsWith('INVALID_REFUND:')) {
      return AppFailure.validation(message: cleanMsg);
    }

    return AppFailure.unexpected(cause: error);
  }

  static bool _hasPrefix(String message, List<String> prefixes) {
    for (final prefix in prefixes) {
      if (message.startsWith(prefix)) {
        return true;
      }
    }
    return false;
  }

  static String? _extractCode(String message) {
    final idx = message.indexOf(':');
    if (idx <= 0) {
      return null;
    }
    final candidate = message.substring(0, idx).trim();
    final isCode = RegExp(r'^[A-Z0-9_]+$').hasMatch(candidate);
    return isCode ? candidate : null;
  }

  static String _stripPrefix(String message) {
    final idx = message.indexOf(':');
    if (idx <= 0 || idx + 1 >= message.length) {
      return message;
    }
    final prefix = message.substring(0, idx).trim();
    if (RegExp(r'^[A-Z0-9_]+$').hasMatch(prefix)) {
      return message.substring(idx + 1).trim();
    }
    return message;
  }
}
