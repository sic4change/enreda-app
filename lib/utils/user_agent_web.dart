// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Returns the browser's user-agent string.
/// This implementation is used on Flutter Web only.
String getUserAgent() {
  try {
    return html.window.navigator.userAgent;
  } catch (_) {
    return '';
  }
}
