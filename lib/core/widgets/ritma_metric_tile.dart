import 'package:flutter/material.dart';

import '../theme/ritma_spacing.dart';

/// Editorial Kinetic KPI card with tabular figures and hairline border.
class RitmaMetricTile extends StatelessWidget {
  const RitmaMetricTile({
    required this.label,
    required this.value,
    super.key,
    this.caption,
    this.icon,
  });

  final String label;
  final String value;
  final String? caption;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
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
                  Icon(
                    icon,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ],
            ),
            const SizedBox(height: RitmaSpacing.xs),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            if (caption != null) ...[
              const SizedBox(height: RitmaSpacing.xxs),
              Text(caption!, style: theme.textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}
