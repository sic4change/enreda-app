/// Public surface for delivering an `.ics` file to the user.
///
/// Conditional import: on Flutter Web (where `dart:html` is available) this
/// resolves to [ics_download_web.dart] which triggers a browser download via a
/// Blob + anchor click. On mobile / desktop it resolves to [ics_download_io.dart]
/// which writes the payload to a temp file and opens the native share sheet.
///
/// Both expose `Future<void> downloadIcs(String content, String filename)`.
export 'ics_download_io.dart'
    if (dart.library.html) 'ics_download_web.dart';
