import 'package:flutter/material.dart';

import 'ritma_colors.dart';

/// Semantic status color pairs designed for WCAG 2.1 AA legibility in both
/// Light and Dark themes under Direction A (Editorial Kinetic).
@immutable
class RitmaStatusColors extends ThemeExtension<RitmaStatusColors> {
  const RitmaStatusColors({
    required this.successBg,
    required this.successFg,
    required this.warningBg,
    required this.warningFg,
    required this.dangerBg,
    required this.dangerFg,
    required this.infoBg,
    required this.infoFg,
    required this.accentLimeBg,
    required this.accentLimeFg,
  });

  final Color successBg;
  final Color successFg;
  final Color warningBg;
  final Color warningFg;
  final Color dangerBg;
  final Color dangerFg;
  final Color infoBg;
  final Color infoFg;
  final Color accentLimeBg;
  final Color accentLimeFg;

  static const RitmaStatusColors light = RitmaStatusColors(
    successBg: Color(0xFFE4EFE6),
    successFg: RitmaColors.successLight,
    warningBg: Color(0xFFF7EEDB),
    warningFg: RitmaColors.warningLight,
    dangerBg: Color(0xFFF9E5E2),
    dangerFg: RitmaColors.dangerLight,
    infoBg: Color(0xFFE9ECE8),
    infoFg: RitmaColors.graphite,
    accentLimeBg: RitmaColors.electricLime,
    accentLimeFg: RitmaColors.graphite,
  );

  static const RitmaStatusColors dark = RitmaStatusColors(
    successBg: Color(0xFF1B3325),
    successFg: RitmaColors.successDark,
    warningBg: Color(0xFF362B16),
    warningFg: RitmaColors.warningDark,
    dangerBg: Color(0xFF3C211E),
    dangerFg: RitmaColors.dangerDark,
    infoBg: RitmaColors.charcoal,
    infoFg: RitmaColors.warmIvory,
    accentLimeBg: RitmaColors.electricLime,
    accentLimeFg: RitmaColors.graphite,
  );

  @override
  RitmaStatusColors copyWith({
    Color? successBg,
    Color? successFg,
    Color? warningBg,
    Color? warningFg,
    Color? dangerBg,
    Color? dangerFg,
    Color? infoBg,
    Color? infoFg,
    Color? accentLimeBg,
    Color? accentLimeFg,
  }) {
    return RitmaStatusColors(
      successBg: successBg ?? this.successBg,
      successFg: successFg ?? this.successFg,
      warningBg: warningBg ?? this.warningBg,
      warningFg: warningFg ?? this.warningFg,
      dangerBg: dangerBg ?? this.dangerBg,
      dangerFg: dangerFg ?? this.dangerFg,
      infoBg: infoBg ?? this.infoBg,
      infoFg: infoFg ?? this.infoFg,
      accentLimeBg: accentLimeBg ?? this.accentLimeBg,
      accentLimeFg: accentLimeFg ?? this.accentLimeFg,
    );
  }

  @override
  RitmaStatusColors lerp(
    covariant ThemeExtension<RitmaStatusColors>? other,
    double t,
  ) {
    if (other is! RitmaStatusColors) {
      return this;
    }
    return RitmaStatusColors(
      successBg: Color.lerp(successBg, other.successBg, t)!,
      successFg: Color.lerp(successFg, other.successFg, t)!,
      warningBg: Color.lerp(warningBg, other.warningBg, t)!,
      warningFg: Color.lerp(warningFg, other.warningFg, t)!,
      dangerBg: Color.lerp(dangerBg, other.dangerBg, t)!,
      dangerFg: Color.lerp(dangerFg, other.dangerFg, t)!,
      infoBg: Color.lerp(infoBg, other.infoBg, t)!,
      infoFg: Color.lerp(infoFg, other.infoFg, t)!,
      accentLimeBg: Color.lerp(accentLimeBg, other.accentLimeBg, t)!,
      accentLimeFg: Color.lerp(accentLimeFg, other.accentLimeFg, t)!,
    );
  }
}

extension RitmaThemeContextX on BuildContext {
  RitmaStatusColors get statusColors =>
      Theme.of(this).extension<RitmaStatusColors>() ??
      (Theme.of(this).brightness == Brightness.dark
          ? RitmaStatusColors.dark
          : RitmaStatusColors.light);
}
