import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'csv_exporter.dart';

Future<CsvExportOutcome> saveAndShareCsv({
  required String fileName,
  required String csvContent,
}) async {
  try {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}${Platform.pathSeparator}$fileName');
    await file.writeAsString(csvContent, flush: true);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'text/csv', name: fileName)],
        subject: fileName,
        text: 'RITMA Report Export: $fileName',
      ),
    );

    return CsvExportOutcome(
      fileName: fileName,
      csvContent: csvContent,
      transport: 'native_share',
      detail: file.path,
    );
  } on MissingPluginException {
    return CsvExportOutcome(
      fileName: fileName,
      csvContent: csvContent,
      transport: 'clipboard_fallback',
      detail: 'Native share is unavailable here; copy CSV from preview.',
    );
  }
}
