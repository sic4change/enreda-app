import 'package:enreda_app/app/home/home_page.dart';
import 'package:enreda_app/app/sign_in/email_sign_in_form_change_notifier.dart';
import 'package:enreda_app/app/sign_in/access/sections/background_web.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/utils/functions.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../common_widgets/spaces.dart';
import '../../../utils/adaptive.dart';

class AccessPageWeb extends StatefulWidget {
  @override
  State<AccessPageWeb> createState() => _AccessPageWebState();
}

class _AccessPageWebState extends State<AccessPageWeb> {
  @override
  Widget build(BuildContext context) {
    final double largeHeight = 800;
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
            height: heightSize * 0.70,
            width: widthSize * 0.80,
            child: Card(
              elevation: 5,
              child: Row(
                children: [
                  Expanded(
                      flex: 5,
                      child: Padding(
                        padding: EdgeInsets.all(Constants.mainPadding),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                children: [
                                  Image.asset(
                                    ImagePath.LOGO,
                                    height: Sizes.HEIGHT_32,
                                  ),
                                ],
                              ),
                            ),
                            Divider(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Text(
                                    StringConst.LOOKING_FOR_JOB,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: fontSize,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SpaceH12(),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                                  child: EmailSignInFormChangeNotifier.create(context),
                                ),
                                SpaceH4(),
                                _buildStoresButtons(180, 75),
                                SpaceH4(),
                                Text(
                                  StringConst.BETTER_FROM_APPS,
                                  style: textTheme.bodyText2,
                                ),
                              ],
                            ),
                          ],
                        ),
                      )),
                  Expanded(
                    flex: 5,
                    child: Stack(
                      children: [
                        Container(color: Constants.turquoise,),
                        Padding(
                          padding: const EdgeInsets.all(48.0),
                          child: Center(
                            child: Image.asset(
                              ImagePath.LEARNING_GIRL,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
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

    return Stack(
      children: [
        AccessBackgroundWeb(),
        Center(
          child: Container(
            height: 680,
            width: widthSize * 0.85,
            child: Card(
              elevation: 5,
              child: Row(
                children: [
                  Expanded(
                      flex: 5,
                      child: Padding(
                        padding: EdgeInsets.all(Constants.mainPadding),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () => {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => HomePage()),
                                      )
                                    },
                                    child: Image.asset(
                                      ImagePath.LOGO,
                                      height: Sizes.HEIGHT_32,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Text(
                                    StringConst.LOOKING_FOR_JOB,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 25.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SpaceH12(),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                                  child: EmailSignInFormChangeNotifier.create(context),
                                ),
                                SpaceH4(),
                                kIsWeb ? _buildStoresButtons(180, 75) : Container(),
                                SpaceH4(),
                                Text(
                                  StringConst.BETTER_FROM_APPS,
                                  style: textTheme.bodyText2,
                                ),
                              ],
                            ),
                          ],
                        ),
                      )),
                  Expanded(
                    flex: 5,
                    child: Stack(
                      children: [
                        Container(color: Constants.turquoise,
                        ),
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Center(
                                child: Image.asset(
                                  ImagePath.LEARNING_GIRL,
                                  height: 600.0,
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStoresButtons(double buttonWidth, double buttonHeight) {
    return Wrap(
      children: [
        InkWell(
          onTap: () => openUrlLink(StringConst.URL_APPSTORE),
          child: Image.asset(
            ImagePath.APP_STORE_BUTTON,
            width: buttonWidth,
            height: buttonHeight,
            fit: BoxFit.fill,
          ),
        ),
        InkWell(
          onTap: () => openUrlLink(StringConst.URL_GOOGLE_PLAY),
          child: Image.asset(
            ImagePath.PLAY_STORE_BUTTON,
            width: buttonWidth,
            height: buttonHeight,
            fit: BoxFit.fill,
          ),
        ),
      ],
    );
  }
}

