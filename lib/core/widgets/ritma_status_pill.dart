import 'package:flutter/material.dart';

import '../theme/ritma_spacing.dart';
import '../theme/ritma_status_colors.dart';

enum RitmaPillTone { neutral, success, warning, danger, lime }

/// Color-blind-safe pill displaying an icon and concise label.
class RitmaStatusPill extends StatelessWidget {
  const RitmaStatusPill({
    required this.label,
    super.key,
    this.icon,
    this.tone = RitmaPillTone.neutral,
  });

  final String label;
  final IconData? icon;
  final RitmaPillTone tone;

  @override
  Widget build(BuildContext context) {
    final status = context.statusColors;
    final (bg, fg) = switch (tone) {
      RitmaPillTone.neutral => (status.infoBg, status.infoFg),
      RitmaPillTone.success => (status.successBg, status.successFg),
      RitmaPillTone.warning => (status.warningBg, status.warningFg),
      RitmaPillTone.danger => (status.dangerBg, status.dangerFg),
      RitmaPillTone.lime => (status.accentLimeBg, status.accentLimeFg),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RitmaSpacing.sm,
        vertical: RitmaSpacing.xxs + 2,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(RitmaRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: RitmaSpacing.xxs + 2),
          ],
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelSmall
                  ?.copyWith(color: fg, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
