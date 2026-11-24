import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/ritma_spacing.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../../core/widgets/ritma_section_header.dart';
import '../../../core/widgets/ritma_status_pill.dart';
import '../application/operations_extras_providers.dart';
import '../domain/operations_extras_models.dart';

class NotificationsBellButton extends ConsumerWidget {
  const NotificationsBellButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadNotificationCountProvider);

    return IconButton(
      tooltip: 'Notifications',
      onPressed: () async {
        await showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (_) => const _NotificationsSheet(),
        );
      },
      icon: Badge(
        isLabelVisible: unread > 0,
        label: Text('$unread'),
        child: const Icon(Icons.notifications_outlined),
      ),
    );
  }
}

class _NotificationsSheet extends ConsumerWidget {
  const _NotificationsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(userNotificationsProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (ctx, scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(RitmaSpacing.md),
            child: RitmaSectionHeader(
              title: 'Notifications',
              subtitle: 'Operational alerts and membership updates',
              trailing: IconButton(
                onPressed: () => Navigator.of(ctx).pop(),
                icon: const Icon(Icons.close),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: AsyncStateView<List<UserNotificationModel>>(
              value: notificationsAsync,
              isEmpty: (list) => list.isEmpty,
              emptyTitle: 'All caught up',
              emptyMessage: 'No notifications in this workspace yet.',
              onRetry: () => ref.invalidate(userNotificationsProvider),
              data: (items) {
                final fmt = DateFormat.MMMd().add_jm();
                return ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(RitmaSpacing.md),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isUnread = item.readAt == null;
                    return Card(
                      margin: const EdgeInsets.only(bottom: RitmaSpacing.xs),
                      child: ListTile(
                        title: Text(item.title),
                        subtitle: Text(
                          '${item.body}\n${fmt.format(item.createdAt.toLocal())}',
                        ),
                        isThreeLine: true,
                        trailing: isUnread
                            ? IconButton(
                                tooltip: 'Mark as read',
                                onPressed: () async {
                                  final repo = ref.read(
                                    operationsExtrasRepositoryProvider,
                                  );
                                  if (repo == null) return;
                                  final res = await repo.markNotificationRead(
                                    notificationId: item.id,
                                  );
                                  if (!context.mounted) return;
                                  res.when(
                                    success: (_) => ref.invalidate(
                                      userNotificationsProvider,
                                    ),
                                    failure: (f) =>
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(content: Text(f.message)),
                                        ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.mark_email_read_outlined,
                                ),
                              )
                            : const RitmaStatusPill(label: 'Read'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
