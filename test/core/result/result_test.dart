import 'package:flutter_test/flutter_test.dart';
import 'package:ritma/core/errors/app_failure.dart';
import 'package:ritma/core/repository/base_repository.dart';
import 'package:ritma/core/result/result.dart';

class _TestRepository extends BaseRepository {
  _TestRepository() : super(loggerName: 'test_repo');

  Future<Result<int>> runSuccess() => guard(() async => 42);

  Future<Result<int>> runFailure() =>
      guard(() async => throw const FormatException('Bad payload'));
}

void main() {
  group('Result & BaseRepository', () {
    test('returns Success on completed action', () async {
      final repo = _TestRepository();
      final result = await repo.runSuccess();

      expect(result.isSuccess, isTrue);
      final value = result.when(success: (data) => data, failure: (_) => -1);
      expect(value, 42);
    });

    test('maps thrown exceptions into Failure', () async {
      final repo = _TestRepository();
      final result = await repo.runFailure();

      expect(result.isFailure, isTrue);
      final failure = result.when(
        success: (_) => null,
        failure: (error) => error,
      );
      expect(failure, isA<ValidationFailure>());
      expect(failure?.message, 'Bad payload');
    });
  });
}
