/// Lightweight, deterministic IANA timezone helpers for RITMA operations.
///
/// RITMA stores timestamps in UTC in PostgreSQL (`timestamptz`) and converts
/// display and scheduling wall-clock times into the organization's or branch's
/// configured timezone (for example `Asia/Jakarta` UTC+7).
class RitmaTimezone {
  const RitmaTimezone._();

  static const Map<String, Duration> _fixedOffsets = {
    'UTC': Duration.zero,
    'Etc/UTC': Duration.zero,
    'Asia/Jakarta': Duration(hours: 7),
    'Asia/Bangkok': Duration(hours: 7),
    'Asia/Ho_Chi_Minh': Duration(hours: 7),
    'Asia/Singapore': Duration(hours: 8),
    'Asia/Makassar': Duration(hours: 8),
    'Asia/Kuala_Lumpur': Duration(hours: 8),
    'Asia/Manila': Duration(hours: 8),
    'Asia/Hong_Kong': Duration(hours: 8),
    'Asia/Jayapura': Duration(hours: 9),
    'Asia/Tokyo': Duration(hours: 9),
    'Asia/Seoul': Duration(hours: 9),
    'Australia/Perth': Duration(hours: 8),
  };

  /// Returns the UTC offset for known fixed-offset studio IANA timezones,
  /// or falls back to the device timezone offset if unrecognized.
  static Duration offsetFor(String? timezone) {
    final trimmed = timezone?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      final known = _fixedOffsets[trimmed];
      if (known != null) return known;
    }
    return DateTime.now().timeZoneOffset;
  }

  /// Short human-readable zone tag (e.g. `WIB`, `WITA`, `WIT`, `UTC+7`).
  static String shortLabel(String? timezone) {
    return switch (timezone?.trim()) {
      'Asia/Jakarta' => 'WIB',
      'Asia/Makassar' => 'WITA',
      'Asia/Jayapura' => 'WIT',
      'UTC' || 'Etc/UTC' => 'UTC',
      final tz? when tz.isNotEmpty => _formatOffsetLabel(offsetFor(tz)),
      _ => _formatOffsetLabel(DateTime.now().timeZoneOffset),
    };
  }

  static String _formatOffsetLabel(Duration offset) {
    if (offset == Duration.zero) return 'UTC';
    final sign = offset.isNegative ? '-' : '+';
    final absMin = offset.inMinutes.abs();
    final hours = absMin ~/ 60;
    final mins = absMin % 60;
    if (mins == 0) return 'UTC$sign$hours';
    return 'UTC$sign$hours:${mins.toString().padLeft(2, '0')}';
  }

  /// Converts [instant] to an un-zoned [DateTime] whose year/month/day/hour/minute
  /// components represent wall-clock time in [timezone].
  static DateTime toOrgWallClock(DateTime instant, String? timezone) {
    final utc = instant.toUtc();
    final offset = offsetFor(timezone);
    final shifted = utc.add(offset);
    return DateTime.utc(
      shifted.year,
      shifted.month,
      shifted.day,
      shifted.hour,
      shifted.minute,
      shifted.second,
      shifted.millisecond,
    );
  }

  /// Returns today's date (at midnight) in [timezone] as an un-zoned UTC
  /// DateTime suitable for date comparisons and DatePicker initial dates.
  static DateTime orgToday(String? timezone, {DateTime? now}) {
    final wall = toOrgWallClock(now ?? DateTime.now(), timezone);
    return DateTime.utc(wall.year, wall.month, wall.day);
  }

  /// Converts a wall-clock date + hour/minute in [timezone] into a UTC [DateTime].
  static DateTime fromOrgWallClock({
    required int year,
    required int month,
    required int day,
    required int hour,
    int minute = 0,
    String? timezone,
  }) {
    final offset = offsetFor(timezone);
    return DateTime.utc(year, month, day, hour, minute).subtract(offset);
  }

  /// Weekday using PostgreSQL `EXTRACT(DOW ...)` convention:
  /// `0` = Sunday, `1` = Monday, ..., `6` = Saturday.
  static int pgWeekday(DateTime orgWallDate) => orgWallDate.weekday % 7;

  /// Parses `'HH:mm:ss'` or `'HH:mm'` into minutes since midnight.
  static int? parseTimeOfDayMinutes(String raw) {
    final parts = raw.trim().split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return h * 60 + m;
  }

  /// Formats `HH:mm` in [timezone] (e.g. `14:00 WIB`).
  static String formatTime(
    DateTime instant,
    String? timezone, {
    bool includeZone = false,
  }) {
    final w = toOrgWallClock(instant, timezone);
    final hh = w.hour.toString().padLeft(2, '0');
    final mm = w.minute.toString().padLeft(2, '0');
    if (!includeZone) return '$hh:$mm';
    return '$hh:$mm ${shortLabel(timezone)}';
  }

  /// Formats `YYYY-MM-DD HH:mm` in [timezone].
  static String formatDateTime(
    DateTime instant,
    String? timezone, {
    bool includeZone = true,
  }) {
    final w = toOrgWallClock(instant, timezone);
    final m = w.month.toString().padLeft(2, '0');
    final d = w.day.toString().padLeft(2, '0');
    final hh = w.hour.toString().padLeft(2, '0');
    final mm = w.minute.toString().padLeft(2, '0');
    final base = '${w.year}-$m-$d $hh:$mm';
    return includeZone ? '$base ${shortLabel(timezone)}' : base;
  }

  /// Formats `YYYY-MM-DD` in [timezone].
  static String formatDate(DateTime instant, String? timezone) {
    final w = toOrgWallClock(instant, timezone);
    final m = w.month.toString().padLeft(2, '0');
    final d = w.day.toString().padLeft(2, '0');
    return '${w.year}-$m-$d';
  }

  /// Formats currency minor units safely across org currencies (`USD`, `IDR`, `SGD`, `EUR`).
  static String formatMoney(int amountMinor, String? currencyCode) {
    final code = (currencyCode ?? 'USD').trim().toUpperCase();
    final isNeg = amountMinor < 0;
    final absMinor = amountMinor.abs();
    if (code == 'IDR' || code == 'JPY') {
      final whole = code == 'IDR' ? (absMinor / 100).round() : absMinor;
      final formatted = _withThousands(whole);
      return '${isNeg ? '-' : ''}$code $formatted';
    }
    final whole = absMinor ~/ 100;
    final cents = (absMinor % 100).toString().padLeft(2, '0');
    final prefix = switch (code) {
      'USD' => r'$',
      'EUR' => '€',
      'GBP' => '£',
      'SGD' => 'S\$',
      _ => '$code ',
    };
    return '${isNeg ? '-' : ''}$prefix${_withThousands(whole)}.$cents';
  }

  static String _withThousands(int value) {
    final s = value.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      final revIdx = s.length - i;
      if (i > 0 && revIdx % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
