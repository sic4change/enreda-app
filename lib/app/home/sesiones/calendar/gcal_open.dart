import 'package:url_launcher/url_launcher.dart';

/// Opens [url] (a Google Calendar TEMPLATE URL) in the external browser / app.
///
/// Cross-platform via `url_launcher`: on web this opens a new tab, on mobile it
/// hands off to the browser or the Google Calendar app. Throws [UnsupportedError]
/// when no handler is available so callers can surface a localised message —
/// mirroring the `enredaEntidadSocial` contract.
Future<void> openExternalUrl(String url) async {
  final uri = Uri.parse(url);
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok) {
    throw UnsupportedError('No se pudo abrir el calendario externo.');
  }
}
