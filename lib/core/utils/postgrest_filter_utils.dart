/// Helpers for safely escaping PostgreSQL `ILIKE` patterns and quoting
/// PostgREST `.or(...)` filter literals so special characters (commas,
/// parentheses, quotes, apostrophes, backslashes, wildcards) cannot break
/// query parsing (`PGRST100` / HTTP 400).
library;

/// Escapes `\` and SQL `LIKE` / `ILIKE` wildcard characters (`%`, `_`) so user
/// input matches literally.
String escapePostgresIlikeLiteral(String raw) {
  return raw
      .replaceAll(r'\', r'\\')
      .replaceAll('%', r'\%')
      .replaceAll('_', r'\_');
}

/// Wraps [value] in PostgREST double-quoted syntax, escaping backslashes and
/// double quotes according to PostgREST's filter parser rules.
String quotePostgrestValue(String value) {
  final escaped = value.replaceAll(r'\', r'\\').replaceAll('"', r'\"');
  return '"$escaped"';
}

/// Builds a comma-separated PostgREST `or` expression applying `.ilike.` with
/// `%query%` across each column in [columns], or returns `null` if [rawQuery]
/// is empty after trimming.
String? buildPostgrestIlikeOrFilter(List<String> columns, String rawQuery) {
  final trimmed = rawQuery.trim();
  if (trimmed.isEmpty || columns.isEmpty) {
    return null;
  }
  final literal = escapePostgresIlikeLiteral(trimmed);
  final pattern = quotePostgrestValue('%$literal%');
  return columns.map((col) => '$col.ilike.$pattern').join(',');
}
