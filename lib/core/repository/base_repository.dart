import 'package:logging/logging.dart';

import '../errors/error_mapper.dart';
import '../logging/app_logger.dart';
import '../result/result.dart';

/// Shared base class for feature repositories.
///
/// Provides [guard] to wrap infrastructure calls with uniform error mapping
/// and structured failure logging.
abstract class BaseRepository {
  BaseRepository({required String loggerName})
    : logger = AppLogger.named(loggerName);

  final Logger logger;

  Future<Result<T>> guard<T>(
    Future<T> Function() action, {
    String? operation,
  }) async {
    try {
      final value = await action();
      return Success<T>(value);
    } catch (error, stackTrace) {
      final failure = ErrorMapper.map(error, stackTrace);
      logger.warning(
        'Repository failure${operation != null ? ' during $operation' : ''}: '
        '$failure',
        error,
        stackTrace,
      );
      return Failure<T>(failure);
    }
  }
}
