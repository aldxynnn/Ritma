import 'package:flutter/material.dart';

/// RITMA — Contemporary Performance foundational color tokens.
///
/// These tokens represent the baseline palette candidate (Direction A: Editorial
/// Kinetic) and are organized semantically so visual direction adjustments
/// remain localized to theme definitions rather than widget code.
abstract final class RitmaColors {
  // Core Brand Primitives
  static const Color graphite = Color(0xFF202421);
  static const Color obsidian = Color(0xFF141715);
  static const Color charcoal = Color(0xFF2A2F2B);
  static const Color warmIvory = Color(0xFFF6F4ED);
  static const Color porcelain = Color(0xFFFFFFFF);
  static const Color sand = Color(0xFFE9E5D9);
  static const Color sage = Color(0xFFA7B7A0);
  static const Color deepSage = Color(0xFF4E624A);
  static const Color electricLime = Color(0xFFC7F36B);
  static const Color mutedCoral = Color(0xFFD98276);
  static const Color deepCoral = Color(0xFFB34C3E);

  // Neutral Text & Border Primitives
  static const Color slateMuted = Color(0xFF5A635C);
  static const Color stoneBorder = Color(0xFFD8D4C8);
  static const Color darkMuted = Color(0xFFA5AEA7);
  static const Color darkBorder = Color(0xFF343B36);

  // Semantic Status Tokens (WCAG-conscious foreground/surface pairs)
  static const Color successLight = Color(0xFF2F6F4E);
  static const Color successDark = Color(0xFF7AD6A3);
  static const Color warningLight = Color(0xFF9A6700);
  static const Color warningDark = Color(0xFFF0C36D);
  static const Color dangerLight = deepCoral;
  static const Color dangerDark = mutedCoral;
}
