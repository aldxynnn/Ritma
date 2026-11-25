import 'csv_exporter_stub.dart'
    if (dart.library.js_interop) 'csv_exporter_web.dart'
    if (dart.library.io) 'csv_exporter_io.dart'
    as impl;

/// Outcome returned when exporting a CSV file on Web or mobile/desktop.
class CsvExportOutcome {
  const CsvExportOutcome({
    required this.fileName,
    required this.csvContent,
    required this.transport,
    this.detail,
  });

  final String fileName;
  final String csvContent;
  final String transport;
  final String? detail;
}

/// Safe RFC 4180 + formula-injection-escaped CSV generator and exporter.
class CsvExporter {
  const CsvExporter._();

  /// Neutralizes spreadsheet formula injection characters (`=`, `+`, `-`, `@`, `\t`, `\r`)
  /// and quotes cells containing commas, quotes, or newlines.
  static String escapeCell(dynamic raw) {
    var value = raw?.toString() ?? '';
    if (value.isNotEmpty) {
      final first = value[0];
      if (first == '=' ||
          first == '+' ||
          first == '-' ||
          first == '@' ||
          first == '\t' ||
          first == '\r') {
        value = "'$value";
      }
    }
    final needsQuotes =
        value.contains(',') ||
        value.contains('"') ||
        value.contains('\n') ||
        value.contains('\r');
    if (!needsQuotes) return value;
    final doubled = value.replaceAll('"', '""');
    return '"$doubled"';
  }

  /// Renders [columns] and [rows] into a safe CSV document string.
  static String buildCsvString({
    required List<String> columns,
    required List<List<dynamic>> rows,
  }) {
    final buffer = StringBuffer();
    buffer.writeln(columns.map(escapeCell).join(','));
    for (final row in rows) {
      final cells = List<String>.generate(columns.length, (i) {
        final raw = i < row.length ? row[i] : '';
        return escapeCell(raw);
      });
      buffer.writeln(cells.join(','));
    }
    return buffer.toString();
  }

  /// Generates and exports/downloads/shares a `.csv` file cleanly per platform.
  static Future<CsvExportOutcome> export({
    required String fileName,
    required List<String> columns,
    required List<List<dynamic>> rows,
  }) {
    final safeName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final csv = buildCsvString(columns: columns, rows: rows);
    return impl.saveAndShareCsv(fileName: safeName, csvContent: csv);
  }
}
