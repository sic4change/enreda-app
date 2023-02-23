import 'package:enreda_app/app/sign_in/email_sign_in_form_change_notifier.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/utils/adaptive.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../common_widgets/show_back_icon.dart';
import '../../common_widgets/stores_buttons.dart';

class ErrorPage extends StatelessWidget {
  ErrorPage(Exception? error);

  @override
  Widget build(BuildContext context) {
    return Responsive.isMobile(context) || Responsive.isTablet(context)
        ? Text('Error de navegación')
        : Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.turquoise,
        elevation: 0.0,
        leading: showBackIconButton(context, Colors.white),
      ),
      body: Text('Error de navegación'),
    );
  }

}
