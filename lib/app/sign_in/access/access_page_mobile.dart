import 'package:enreda_app/app/sign_in/email_sign_in_form_change_notifier.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../common_widgets/spaces.dart';
import '../../../common_widgets/stores_buttons.dart';
import '../../../values/strings.dart';

class AccessPageMobile extends StatefulWidget {
  @override
  _AccessPageMobileState createState() => _AccessPageMobileState();
}

class _AccessPageMobileState extends State<AccessPageMobile> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size(double.infinity, 60),
          child: AppBar(
            title: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Image.asset(
                    ImagePath.LOGO,
                    height: 25.0,
                  ),
                ],
              ),
            ),
            backgroundColor: Constants.white,
            elevation: 1.0,
          ),
        ),
        backgroundColor: Constants.white,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                StringConst.LOOKING_FOR_JOB,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SpaceH30(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: EmailSignInFormChangeNotifier.create(context),
            ),
            SpaceH20(),
            kIsWeb ? buildStoresButtons(context) : Container(),
            SpaceH4(),
            kIsWeb ? Text(
              StringConst.BETTER_FROM_APPS,
              style: textTheme.bodyText2,
            ) : Container(),
          ],
        ),
    );
  }
}
