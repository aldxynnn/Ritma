import 'csv_exporter.dart';

Future<CsvExportOutcome> saveAndShareCsv({
  required String fileName,
  required String csvContent,
}) async {
  return CsvExportOutcome(
    fileName: fileName,
    csvContent: csvContent,
    transport: 'clipboard_fallback',
    detail: 'Generated CSV in memory; copy from the preview dialog.',
  );
}
