// ignore_for_file: avoid_web_libraries_in_flutter
//
// Intentionally targets dart:html. Only imported on Flutter Web via the
// conditional `if (dart.library.html)` clause in `ics_download.dart`; on every
// other platform the IO implementation in `ics_download_io.dart` is used.

import 'dart:convert';
import 'dart:html' as html;

/// Triggers a browser download of [content] as [filename], served as
/// `text/calendar;charset=utf-8` so the browser hands it off to the user's
/// default calendar app (or saves to Downloads).
Future<void> downloadIcs(String content, String filename) async {
  final bytes = utf8.encode(content);
  final blob = html.Blob([bytes], 'text/calendar;charset=utf-8');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..style.display = 'none';
  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);
}
