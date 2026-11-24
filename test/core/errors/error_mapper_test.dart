import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:ritma/core/errors/app_failure.dart';
import 'package:ritma/core/errors/error_mapper.dart';

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
  });
}
