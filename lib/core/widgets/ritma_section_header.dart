import 'package:flutter/material.dart';

import '../theme/ritma_spacing.dart';

class RitmaSectionHeader extends StatelessWidget {
  const RitmaSectionHeader({
    required this.title,
    super.key,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleMedium),
              if (subtitle != null) ...[
                const SizedBox(height: RitmaSpacing.xxs),
                Text(subtitle!, style: theme.textTheme.bodySmall),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: RitmaSpacing.sm),
          trailing!,
        ],
      ],
    );
  }
}
