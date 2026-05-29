// Mobile / desktop implementation of the `.ics` delivery surface. Resolved by
// the conditional export in `ics_download.dart` on every non-web platform.
//
// Writes the iCalendar payload to a temporary file and opens the native share
// sheet so the user can send it to Apple Calendar / Google Calendar / Files.

import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Writes [content] to a temp `[filename]` and opens the share sheet.
///
/// Uses the share_plus v12 instance API (`SharePlus.instance.share` +
/// `ShareParams`); the old static `Share.shareXFiles(...)` was removed in v11.
Future<void> downloadIcs(String content, String filename) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$filename');
  await file.writeAsString(content);
  await SharePlus.instance.share(
    ShareParams(files: [XFile(file.path, mimeType: 'text/calendar')]),
  );
}
