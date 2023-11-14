import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:enreda_app/app/home/models/userPoints.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

const kDuration = Duration(milliseconds: 600);

Future<void> launchURL(url) async {
  if (!url.contains('http://') && !url.contains('https://')) {
    url = 'http://' + url;
  }
  final Uri _url = Uri.parse(url);
  final bool nativeAppLaunchSucceeded = await launchUrl(
    _url,
    mode: LaunchMode.externalNonBrowserApplication,
  );
  if (!nativeAppLaunchSucceeded) {
    if (!await launchUrl(
      _url,
      mode: LaunchMode.inAppWebView,
    )) throw 'No se puede mostrar la dirección $_url';
  }
}


scrollToSection(BuildContext context) {
  Scrollable.ensureVisible(
    context,
    duration: kDuration,
  );
}

int daysBetween(DateTime from, DateTime to) {
  from = DateTime(from.year, from.month, from.day);
  to = DateTime(to.year, to.month, to.day);
  return (to.difference(from).inHours / 24).round();
}

String removeDiacritics(String str) {
  var withDia = 'ÀÁÂÃÄÅàáâãäåÒÓÔÕÕÖØòóôõöøÈÉÊËèéêëðÇçÐÌÍÎÏìíîïÙÚÛÜùúûüÑñŠšŸÿýŽž';
  var withoutDia = 'AAAAAAaaaaaaOOOOOOOooooooEEEEeeeeeCcDIIIIiiiiUUUUuuuuNnSsYyyZz';

  for (int i = 0; i < withDia.length; i++) {
    str = str.replaceAll(withDia[i], withoutDia[i]);
  }

  return str;
}

void showPointsSnackbar({
  required BuildContext context,
  required UserPoints userPoints
}) {
  final snackBar = SnackBar(
    /// need to set following properties for best effect of awesome_snackbar_content
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    content: Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: AwesomeSnackbarContent(
        title: "",
        message: userPoints.message,
        titleFontSize: 0.0,
        messageFontSize: 20.0,
        /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
        contentType: ContentType.success,
        color: Constants.turquoise,
      ),
    ),
  );

  ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(snackBar);
}
