import 'package:flutter/material.dart';

import 'ritma_colors.dart';
import 'ritma_spacing.dart';
import 'ritma_status_colors.dart';
import 'ritma_typography.dart';

/// Builds Material 3 [ThemeData] for RITMA light and dark modes with optional
/// [RitmaDensity] adjustments for Member vs Operations workspaces.
abstract final class RitmaTheme {
  static ThemeData light({RitmaDensity density = RitmaDensity.member}) {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: RitmaColors.graphite,
      onPrimary: RitmaColors.porcelain,
      primaryContainer: RitmaColors.electricLime,
      onPrimaryContainer: RitmaColors.graphite,
      secondary: RitmaColors.deepSage,
      onSecondary: RitmaColors.porcelain,
      secondaryContainer: RitmaColors.sand,
      onSecondaryContainer: RitmaColors.graphite,
      tertiary: RitmaColors.mutedCoral,
      onTertiary: RitmaColors.graphite,
      error: RitmaColors.dangerLight,
      onError: RitmaColors.porcelain,
      surface: RitmaColors.warmIvory,
      onSurface: RitmaColors.graphite,
      surfaceContainerHighest: RitmaColors.porcelain,
      onSurfaceVariant: RitmaColors.slateMuted,
      outline: RitmaColors.stoneBorder,
      outlineVariant: RitmaColors.sand,
      shadow: Color(0x14000000),
      scrim: Color(0x66000000),
      inverseSurface: RitmaColors.graphite,
      onInverseSurface: RitmaColors.warmIvory,
      inversePrimary: RitmaColors.electricLime,
    );

    return _buildTheme(
      colorScheme: colorScheme,
      statusColors: RitmaStatusColors.light,
      density: density,
    );
  }

  static ThemeData dark({RitmaDensity density = RitmaDensity.member}) {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: RitmaColors.electricLime,
      onPrimary: RitmaColors.graphite,
      primaryContainer: RitmaColors.charcoal,
      onPrimaryContainer: RitmaColors.electricLime,
      secondary: RitmaColors.sage,
      onSecondary: RitmaColors.obsidian,
      secondaryContainer: RitmaColors.charcoal,
      onSecondaryContainer: RitmaColors.warmIvory,
      tertiary: RitmaColors.mutedCoral,
      onTertiary: RitmaColors.obsidian,
      error: RitmaColors.dangerDark,
      onError: RitmaColors.obsidian,
      surface: RitmaColors.obsidian,
      onSurface: RitmaColors.warmIvory,
      surfaceContainerHighest: RitmaColors.graphite,
      onSurfaceVariant: RitmaColors.darkMuted,
      outline: RitmaColors.darkBorder,
      outlineVariant: RitmaColors.charcoal,
      shadow: Color(0x40000000),
      scrim: Color(0x88000000),
      inverseSurface: RitmaColors.warmIvory,
      onInverseSurface: RitmaColors.graphite,
      inversePrimary: RitmaColors.graphite,
    );

    return _buildTheme(
      colorScheme: colorScheme,
      statusColors: RitmaStatusColors.dark,
      density: density,
    );
  }

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required RitmaStatusColors statusColors,
    required RitmaDensity density,
  }) {
    final isOps = density == RitmaDensity.operations;
    final visualDensity = isOps
        ? VisualDensity.compact
        : VisualDensity.standard;
    final cardRadius = isOps ? RitmaRadius.md : RitmaRadius.lg;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      visualDensity: visualDensity,
      textTheme: RitmaTypography.buildTextTheme(colorScheme),
      extensions: <ThemeExtension<dynamic>>[statusColors],
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerHighest,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: BorderSide(color: colorScheme.outline),
        ),
      ),
      dividerTheme: DividerThemeData(color: colorScheme.outline, thickness: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RitmaRadius.md),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RitmaRadius.md),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RitmaRadius.md),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: RitmaSpacing.md,
          vertical: isOps ? RitmaSpacing.sm : RitmaSpacing.md,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: Size(64, isOps ? 44 : 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RitmaRadius.md),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: Size(64, isOps ? 44 : 48),
          side: BorderSide(color: colorScheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RitmaRadius.md),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        indicatorColor: colorScheme.primaryContainer,
        surfaceTintColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        indicatorColor: colorScheme.primaryContainer,
        selectedIconTheme: IconThemeData(color: colorScheme.onPrimaryContainer),
        unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: TextStyle(color: colorScheme.onInverseSurface),
      ),
    );
  }
}

/// Applies the appropriate [RitmaDensity] theme profile to a sub-tree (e.g.,
/// Member lifestyle shell vs Operations high-density workspace shell).
class RitmaDensityScope extends StatelessWidget {
  const RitmaDensityScope({
    required this.density,
    required this.child,
    super.key,
  });

  final RitmaDensity density;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final themed = brightness == Brightness.dark
        ? RitmaTheme.dark(density: density)
        : RitmaTheme.light(density: density);

    return Theme(data: themed, child: child);
  }
}
