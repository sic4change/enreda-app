import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/utils/functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Conditional import: on web, dart:html is available and the real
// implementation is used; on native, the stub returns an empty string.
import 'package:enreda_app/utils/user_agent_stub.dart'
    if (dart.library.html) 'package:enreda_app/utils/user_agent_web.dart';

/// Returns true when the page is loaded from a mobile device's web browser.
bool _isMobileWebBrowser() {
  if (!kIsWeb) return false;
  try {
    final String ua = getUserAgent().toLowerCase();
    return ua.contains('android') ||
        ua.contains('iphone') ||
        ua.contains('ipad') ||
        ua.contains('mobile') ||
        ua.contains('blackberry') ||
        ua.contains('windows phone');
  } catch (_) {
    return false;
  }
}

/// A dismissible banner shown at the very top of the page when a user opens
/// the web app from a mobile browser. It informs the user that the experience
/// is better in the native app and provides a link to the Google Play Store.
///
/// Usage:
/// ```dart
/// MobileWebBanner(child: Scaffold(...))
/// ```
class MobileWebBanner extends StatefulWidget {
  const MobileWebBanner({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  State<MobileWebBanner> createState() => _MobileWebBannerState();
}

class _MobileWebBannerState extends State<MobileWebBanner> {
  bool _dismissed = false;
  late final bool _showBanner;

  @override
  void initState() {
    super.initState();
    _showBanner = _isMobileWebBrowser();
  }

  @override
  Widget build(BuildContext context) {
    if (!_showBanner || _dismissed) return widget.child;

    return Column(
      children: [
        _BannerContent(onDismiss: () => setState(() => _dismissed = true)),
        Expanded(child: widget.child),
      ],
    );
  }
}

class _BannerContent extends StatelessWidget {
  const _BannerContent({required this.onDismiss});

  final VoidCallback onDismiss;

  static const String _playStoreUrl =
      'https://play.google.com/store/apps/details?id=org.sic4change.enreda_app&hl=en&pli=1';

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0,
      color: Constants.enredaDarkTeal,
      child: Container(
        width: double.infinity,
        color: Constants.enredaDarkTeal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              // App icon
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white.withOpacity(0.12),
                ),
                child: const Icon(
                  Icons.phone_android,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),

              // Texts
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Esta página funciona mejor en la app',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Descárgala gratis en Google Play',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Download CTA button
              GestureDetector(
                onTap: () => launchURL(_playStoreUrl),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: Constants.enredaTeal,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Descargar',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // Dismiss button
              GestureDetector(
                onTap: onDismiss,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.close, color: Colors.white54, size: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
