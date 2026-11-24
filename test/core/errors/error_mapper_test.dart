import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:ritma/core/errors/app_failure.dart';
import 'package:ritma/core/errors/error_mapper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('ErrorMapper', () {
    test('passes through existing AppFailure instances', () {
      const original = AppFailure.forbidden(
        requiredPermission: 'checkin.perform',
      );
      expect(ErrorMapper.map(original), equals(original));
    });

    test('unwraps AppException to its underlying failure', () {
      const expected = AppFailure.conflict(
        message: 'Class session is at capacity.',
        code: 'CAPACITY_EXCEEDED',
      );
      expect(ErrorMapper.map(const AppException(expected)), equals(expected));
    });

    test('maps TimeoutException to NetworkFailure', () {
      final result = ErrorMapper.map(TimeoutException('timed out'));
      expect(result, isA<NetworkFailure>());
    });

    test('maps FormatException to ValidationFailure', () {
      final result = ErrorMapper.map(const FormatException('Invalid QR token'));
      expect(result, isA<ValidationFailure>());
      expect(result.message, 'Invalid QR token');
    });

    test('maps unknown errors to UnexpectedFailure', () {
      final result = ErrorMapper.map(StateError('boom'));
      expect(result, isA<UnexpectedFailure>());
    });

    test('maps AuthException cleanly', () {
      const authUnauthorized = AuthException(
        'Invalid JWT token',
        statusCode: '401',
      );
      expect(ErrorMapper.map(authUnauthorized), isA<UnauthorizedFailure>());

      const authValidation = AuthException('Invalid login credentials');
      expect(ErrorMapper.map(authValidation), isA<ValidationFailure>());
    });

    test('maps PostgrestException SQLSTATE and RITMA domain codes', () {
      const forbidden = PostgrestException(
        message: 'FORBIDDEN: Missing checkin.perform permission',
        code: '42501',
      );
      final mappedForbidden = ErrorMapper.map(forbidden);
      expect(mappedForbidden, isA<ForbiddenFailure>());
      expect(mappedForbidden.message, 'Missing checkin.perform permission');

      const duplicate = PostgrestException(
        message: 'ALREADY_BOOKED: Member already holds an active booking',
        code: '23505',
      );
      expect(ErrorMapper.map(duplicate), isA<ConflictFailure>());

      const notFound = PostgrestException(
        message: 'NOT_FOUND: Session not found',
        code: 'P0002',
      );
      expect(ErrorMapper.map(notFound), isA<NotFoundFailure>());

      const insufficient = PostgrestException(
        message: 'INSUFFICIENT_CREDITS: Available balance is 0',
        code: '22023',
      );
      final mappedInsufficient = ErrorMapper.map(insufficient);
      expect(mappedInsufficient, isA<ConflictFailure>());
      expect(
        (mappedInsufficient as ConflictFailure).code,
        'INSUFFICIENT_CREDITS',
      );

      const unauthorized = PostgrestException(
        message: 'UNAUTHORIZED: Authentication required',
        code: '42501',
      );
      expect(ErrorMapper.map(unauthorized), isA<UnauthorizedFailure>());
    });
  });
}
