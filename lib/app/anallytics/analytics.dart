

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

Future<void> sendBasicAnalyticsEvent(BuildContext context, String analytic) async {
  FirebaseAnalytics analytics = Provider.of<FirebaseAnalytics>(context);
  await analytics.logEvent(
      name: analytic,
      parameters: {
        analytic: 'ok'
      }
  ).whenComplete(() => print('logEvent $analytic'));
}