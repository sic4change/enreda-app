import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/values/strings.dart';
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


Future<void> sendWhatsAppWebMessage(String phoneNumber, String message) async {
  var whatsappWebUrl = "https://web.whatsapp.com/send?phone=$phoneNumber&text=${Uri.encodeFull(message)}";
  if (await canLaunch(whatsappWebUrl)) {
    await launch(whatsappWebUrl);
  } else {
    throw 'Could not launch $whatsappWebUrl';
  }
}

void openWhatsAppMobile(BuildContext context, phoneNumber, message) async {
  var phoneNumberOnlyNumbers = removeNonNumeric(phoneNumber);
  var whatsappUrl = "https://wa.me/$phoneNumberOnlyNumbers/?text=${Uri.encodeFull(message)}";
  if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
    await launchUrl(Uri.parse(whatsappUrl));
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("WhatsApp no está instalado. Por favor, instalelo para poder enviar mensajes."),
      ),
    );
  }
}

String removeNonNumeric(String inputString) {
  return inputString.replaceAll(RegExp(r'[^0-9]'), '');
}

Future<void> makePhoneCall(String phoneNumber) async {
  final Uri launchUri = Uri(
    scheme: 'tel',
    path: phoneNumber,
  );
  if (await canLaunchUrl(launchUri)) {
    await launchUrl(launchUri);
  } else {
    throw 'Could not launch $launchUri';
  }
}

Future<void> sendEmail({
  required String toEmail,
  String subject = '',
  String body = '',
}) async {
  final Uri emailLaunchUri = Uri(
    scheme: 'mailto',
    path: toEmail,
    query: encodeQueryParameters(<String, String>{
      'subject': subject,
      'body': body,
    }),
  );

  if (await canLaunchUrl(emailLaunchUri)) {
    await launchUrl(emailLaunchUri);
  } else {
    throw 'Could not launch $emailLaunchUri';
  }
}

String? encodeQueryParameters(Map<String, String> params) {
  return params.entries
      .map((e) =>
  '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
      .join('&');
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

Future<void> setGamificationFlag({
  required BuildContext context,
  required String flagId,
}) async {
  final database = Provider.of<Database>(context, listen: false);
  final auth = Provider.of<AuthBase>(context, listen: false);

  if (auth.currentUser != null) {
    final user = await database.userEnredaStreamByUserId(auth.currentUser!.uid).first;
    if (!user.gamificationFlags.containsKey(flagId) ||
        !user.gamificationFlags[flagId]!) {
      user.gamificationFlags[flagId] = true;
      await database.setUserEnreda(user);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(StringConst.GAMIFICATION_PHASE_COMPLETED),
      ));
  }
  }
}
