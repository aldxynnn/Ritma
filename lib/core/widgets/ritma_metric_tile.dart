import 'package:flutter/material.dart';

import '../theme/ritma_spacing.dart';

/// Editorial Kinetic KPI card with tabular figures, accent badge, and hairline border.
class RitmaMetricTile extends StatelessWidget {
  const RitmaMetricTile({
    required this.label,
    required this.value,
    super.key,
    this.caption,
    this.icon,
    this.highlighted = false,
  });

  final String label;
  final String value;
  final String? caption;
  final IconData? icon;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(RitmaRadius.md),
      side: BorderSide(
        color: highlighted
            ? accent.withValues(alpha: 0.6)
            : theme.colorScheme.outline,
        width: highlighted ? 1.25 : 1,
      ),
    );

    return Card(
      shape: cardShape,
      child: Padding(
        padding: const EdgeInsets.all(RitmaSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (icon != null) ...[
                  const SizedBox(width: RitmaSpacing.xs),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: highlighted
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(RitmaRadius.sm),
                      border: Border.all(
                        color: highlighted
                            ? accent.withValues(alpha: 0.4)
                            : theme.colorScheme.outlineVariant,
                      ),
                    ),
                    child: Icon(
                      icon,
                      size: 16,
                      color: highlighted
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: RitmaSpacing.sm),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: highlighted ? accent : theme.colorScheme.onSurface,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            if (caption != null) ...[
              const SizedBox(height: RitmaSpacing.xxs),
              Text(
                caption!,
                style: theme.textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
