import 'package:flutter/material.dart';

/// Accessible, responsive typography scale for RITMA.
///
/// Uses platform-clean sans-serif fallback until final bundled display/body
/// font families are approved in the visual direction review.
abstract final class RitmaTypography {
  static TextTheme buildTextTheme(ColorScheme colorScheme) {
    final base = Typography.material2021().black.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );

    return base.copyWith(
      displaySmall: base.displaySmall?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.6,
        height: 1.15,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
        height: 1.2,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.25,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.35,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.35,
      ),
      bodyLarge: base.bodyLarge?.copyWith(height: 1.5),
      bodyMedium: base.bodyMedium?.copyWith(height: 1.45),
      bodySmall: base.bodySmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
        height: 1.4,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
    );
  }
}
