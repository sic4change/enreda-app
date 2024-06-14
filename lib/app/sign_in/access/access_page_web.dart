import 'package:enreda_app/app/home/models/trainingPill.dart';
import 'package:enreda_app/app/home/trainingPills/videos_tooltip_widget/pill_tooltip.dart';
import 'package:enreda_app/app/sign_in/email_sign_in_form_change_notifier.dart';
import 'package:enreda_app/app/sign_in/access/sections/background_web.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/utils/functions.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../../common_widgets/spaces.dart';
import '../../../common_widgets/stores_buttons.dart';
import '../../../utils/adaptive.dart';

class AccessPageWeb extends StatefulWidget {
  @override
  State<AccessPageWeb> createState() => _AccessPageWebState();
}

class _AccessPageWebState extends State<AccessPageWeb> {
  @override
  Widget build(BuildContext context) {
    final double largeHeight = 900;
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return constraints.maxHeight > largeHeight
              ? _buildLargeBody(context)
              : _buildSmallBody(context);
        }
      )
    );
  }

  Widget _buildLargeBody(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final double widthSize = MediaQuery.of(context).size.width;
    final double heightSize = MediaQuery.of(context).size.height;
    double fontSize = responsiveSize(context, 20, 30, md: 22);
    return Stack(
      children: [
        AccessBackgroundWeb(),
        Center(
          child: Container(
            height: heightSize * 0.85,
            width: widthSize * 0.70,
            child: Card(
              color: AppColors.turquoiseBlue,
              elevation: 5,
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Image.asset(
                      height: heightSize * 0.85,
                      ImagePath.ACCESS_PHOTO,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Expanded(
                      flex: 5,
                      child: Container()),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: Responsive.isDesktopS(context) ? 70 : 35,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: EdgeInsets.only(left: 4, right: 25),
              height: heightSize * 0.70,
              width: widthSize * 0.70,
              child: Image.asset(ImagePath.ACCESS_VECTOR)),
          ),
        ),
        Center(
          child: Container(
            color: Colors.transparent,
            height: heightSize * 0.85,
            width: widthSize * 0.70,
            child: Card(
              color: Colors.transparent,
              elevation: 0,
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                  Expanded(
                      flex: 5,
                      child: Padding(
                        padding: EdgeInsets.only(left: Constants.mainPadding,
                            right: Constants.mainPadding, bottom: Constants.mainPadding,
                            top: Constants.mainPadding * 2),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              color: Colors.transparent,
                              height: 50,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Expanded(child: Container()),
                                  InkWell(
                                    onTap: () => launchURL(StringConst.NEW_WEB_ENREDA_URL),
                                    child: Image.asset(
                                      ImagePath.LOGO_ENREDA_LIGHT,
                                      height: Sizes.HEIGHT_100,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Spacer(),
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 34,
                                      ),
                                      Spacer(),
                                      Text(
                                        StringConst.LOOKING_FOR_JOB,
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        style: textTheme.bodyLarge?.copyWith(
                                          height: 1.5,
                                          color: AppColors.white,
                                          fontWeight: FontWeight.w400,
                                          fontSize: fontSize,
                                        ),
                                      ),
                                      Spacer(),
                                      Container(
                                        width: 34,
                                        child: PillTooltip(
                                          title: StringConst.TAG_ENREDA,
                                          pillId: TrainingPill.WHAT_IS_ENREDA_ID,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SpaceH12(),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                                  child: EmailSignInFormChangeNotifier.create(context),
                                ),
                                SpaceH4(),
                                kIsWeb ? buildStoresButtons(context) : Container(),
                                SpaceH4(),
                                kIsWeb ? Text(
                                  StringConst.BETTER_FROM_APPS,
                                  style: textTheme.bodySmall?.copyWith(
                                    height: 1.5,
                                    color: AppColors.white,
                                  ),
                                ) : Container(),
                              ],
                            ),
                            Spacer(),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSmallBody(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final double widthSize = MediaQuery.of(context).size.width;
    double fontSize = responsiveSize(context, 20, 30, md: 22);
    return Stack(
      children: [
        AccessBackgroundWeb(),
        Center(
          child: Container(
            height: 750,
            width: widthSize * 0.85,
            child: Card(
              color: AppColors.turquoiseBlue,
              elevation: 5,
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Image.asset(
                      height: 750,
                      ImagePath.ACCESS_PHOTO,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Expanded(
                      flex: 5,
                      child: Container()),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 70,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
                padding: EdgeInsets.only(left: 4, right: 30, top: 50),
                width: widthSize * 0.85,
                child: Image.asset(ImagePath.ACCESS_VECTOR)),
          ),
        ),
        Center(
          child: Container(
            height: 750,
            width: widthSize * 0.85,
            child: Card(
              color: Colors.transparent,
              elevation: 0,
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                  Expanded(
                      flex: 5,
                      child: Padding(
                        padding: EdgeInsets.all(Constants.mainPadding),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 10.0, top: 50),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  InkWell(
                                    onTap: () => launchURL(StringConst.NEW_WEB_ENREDA_URL),
                                    child: Image.asset(
                                      ImagePath.LOGO_ENREDA_LIGHT,
                                      height: Sizes.HEIGHT_74,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 34,
                                    ),
                                    Spacer(),
                                    Text(
                                      StringConst.LOOKING_FOR_JOB,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style: textTheme.bodyLarge?.copyWith(
                                        height: 1.5,
                                        color: AppColors.white,
                                        fontWeight: FontWeight.w400,
                                        fontSize: fontSize,
                                      ),
                                    ),
                                    Spacer(),
                                    Container(
                                      width: 34,
                                      child: PillTooltip(
                                        title: StringConst.TAG_ENREDA,
                                        pillId: TrainingPill.WHAT_IS_ENREDA_ID,
                                      ),
                                    ),
                                  ],
                                ),
                                SpaceH12(),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                                  child: EmailSignInFormChangeNotifier.create(context),
                                ),
                                SpaceH4(),
                                kIsWeb ? buildStoresButtons(context) : Container(),
                                SpaceH4(),
                                kIsWeb ? Text(
                                  StringConst.BETTER_FROM_APPS,
                                  style: textTheme.bodySmall?.copyWith(
                                    height: 1.5,
                                    color: AppColors.white,
                                  ),
                                ) : Container(),
                              ],
                            ),
                            Spacer(),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

