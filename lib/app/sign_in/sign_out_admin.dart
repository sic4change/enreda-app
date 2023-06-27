import 'package:enreda_app/common_widgets/enreda_button.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/utils/adaptive.dart';
import 'package:enreda_app/utils/functions.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> adminSignOut(BuildContext context) async {
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final auth = Provider.of<AuthBase>(context, listen: false);
    final textTheme = Theme.of(context).textTheme;
    double fontSize = responsiveSize(context, 14, 18, md: 15);
    await showDialog(
      context: context,
      builder: (BuildContext context) => Center(
        child: AlertDialog(
          insetPadding: const EdgeInsets.all(20),
          contentPadding: const EdgeInsets.only(left: 20, right: 20, top: 30),
          content: SizedBox(
            height: 100,
            width: MediaQuery.of(context).size.width * 0.5,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    ImagePath.LOGO,
                    height: 30,
                  ),
                  SpaceH20(),
                  Text(StringConst.ARE_YOU_ADMIN,
                      style: textTheme.bodyText1?.copyWith(
                        color: AppColors.greyDark,
                        height: 1.5,
                        fontWeight: FontWeight.w800,
                        fontSize: fontSize,
                      )
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: EnredaButton(
                  buttonTitle: StringConst.GO_ADMIN_WEB,
                  onPressed: () {
                    auth.signOut();
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    ).then((exit) {
      if (exit == null) {
        auth.signOut();
        //launchURL(StringConst.WEB_COMPANIES_URL_ACCESS);
        launchURL(StringConst.WEB_ADMIN_ACCESS);
      }
    });
  });
}