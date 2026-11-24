/// Spacing, border radius, and layout tokens for RITMA.
abstract final class RitmaSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

abstract final class RitmaRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double pill = 999;
}

/// Visual density profiles supporting Member vs Operations surfaces.
enum RitmaDensity {
  /// Generous breathing room for lifestyle-oriented Member flows.
  member,

  /// Higher information density for Operations and front-desk workflows.
  operations,
}
