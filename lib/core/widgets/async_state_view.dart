import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../errors/app_failure.dart';
import '../errors/error_mapper.dart';
import '../theme/ritma_spacing.dart';

/// Standard UI handler for loading, error, empty, and success states.
class AsyncStateView<T> extends StatelessWidget {
  const AsyncStateView({
    required this.value,
    required this.data,
    super.key,
    this.isEmpty,
    this.emptyTitle = 'Nothing here yet',
    this.emptyMessage = 'Data will appear here once available.',
    this.onRetry,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final bool Function(T data)? isEmpty;
  final String emptyTitle;
  final String emptyMessage;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(RitmaSpacing.lg),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) {
        final failure = ErrorMapper.map(error, stackTrace);
        return _ErrorStateCard(failure: failure, onRetry: onRetry);
      },
      data: (resolved) {
        if (isEmpty?.call(resolved) ?? false) {
          return _EmptyStateCard(title: emptyTitle, message: emptyMessage);
        }
        return data(resolved);
      },
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(RitmaSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 40,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: RitmaSpacing.sm),
            Text(
              title,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: RitmaSpacing.xxs),
            Text(
              message,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorStateCard extends StatelessWidget {
  const _ErrorStateCard({required this.failure, this.onRetry});

  final AppFailure failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(RitmaSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 40, color: theme.colorScheme.error),
            const SizedBox(height: RitmaSpacing.sm),
            Text(
              failure.message,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: RitmaSpacing.md),
              FilledButton(onPressed: onRetry, child: const Text('Try again')),
            ],
          ],
        ),
      ),
    );
  }
}
