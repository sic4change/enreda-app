import 'package:enreda_app/app/home/models/trainingPill.dart';
import 'package:enreda_app/app/home/trainingPills/videos_tooltip_widget/pill_tooltip.dart';
import 'package:enreda_app/app/sign_in/email_sign_in_form_change_notifier.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/utils/functions.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../common_widgets/show_back_icon.dart';
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
      backgroundColor: Constants.white,
        body: Container(
          color: AppColors.turquoiseBlue,
          child: Stack(
            children: [
              Positioned(
                right: 30,
                top: 30,
                child: Container(
                  width: 34,
                  child: PillTooltip(
                    title: StringConst.TAG_ENREDA,
                    pillId: TrainingPill.WHAT_IS_ENREDA_ID,
                  ),
                ),
              ),
              SpaceW20(),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () => launchURL(StringConst.NEW_WEB_ENREDA_URL),
                    child: Image.asset(
                      ImagePath.LOGO_ENREDA_LIGHT,
                      height: Sizes.HEIGHT_50,
                    ),
                  ),
                  SpaceH30(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      StringConst.LOOKING_FOR_JOB,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 25.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
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
                    style: textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      color: AppColors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ) : Container(),
                ],
              ),
            ],
          ),
        ),
    );
  }
}
