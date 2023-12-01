import 'package:enreda_app/app/sign_in/access/access_page_mobile.dart';
import 'package:enreda_app/app/sign_in/access/access_page_web.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../anallytics/analytics.dart';

class AccessPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    sendBasicAnalyticsEvent(context, "enreda_app_visit_log_in_page");
    return Responsive.isMobile(context) || Responsive.isTablet(context)
        ? AccessPageMobile()
        : AccessPageWeb();
  }
}

