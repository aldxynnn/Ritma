import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

import 'csv_exporter.dart';

Future<CsvExportOutcome> saveAndShareCsv({
  required String fileName,
  required String csvContent,
}) async {
  final bytes = Uint8List.fromList(utf8.encode(csvContent));
  final blobParts = <JSAny>[bytes.toJS].toJS;
  final blob = web.Blob(
    blobParts,
    web.BlobPropertyBag(type: 'text/csv;charset=utf-8'),
  );
  final objectUrl = web.URL.createObjectURL(blob);
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
  anchor.href = objectUrl;
  anchor.download = fileName;
  anchor.style.display = 'none';
  web.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  web.URL.revokeObjectURL(objectUrl);

  return CsvExportOutcome(
    fileName: fileName,
    csvContent: csvContent,
    transport: 'browser_download',
    detail: 'Downloaded $fileName via browser.',
  );
}
