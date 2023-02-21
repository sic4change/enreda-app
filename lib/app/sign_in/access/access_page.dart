import 'package:enreda_app/app/sign_in/access/access_page_mobile.dart';
import 'package:enreda_app/app/sign_in/access/access_page_web.dart';
import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AccessPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Responsive.isMobile(context) || Responsive.isTablet(context)
        ? AccessPageMobile()
        : AccessPageWeb();
  }
}
