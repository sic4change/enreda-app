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

class EmailSignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final double largeHeight = 800;
    return Responsive.isMobile(context) || Responsive.isTablet(context)
        ? _buildMobileLayout(context)
        : Scaffold(
            appBar: AppBar(
              backgroundColor: Constants.turquoise,
              elevation: 0.0,
              leading: showBackIconButton(context, Colors.white),
            ),
            body: LayoutBuilder(builder: (context, constraints) {
              return constraints.maxHeight > largeHeight
                  ? _buildLargeBody(context)
                  : _buildSmallBody(context);
            }),
          );
  }

  Widget _buildLargeBody(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: <Widget>[
            Expanded(
              flex: 45,
              child: Container(
                color: Constants.turquoise,
              ),
            ),
            Expanded(
              flex: 55,
              child: Container(
                color: Constants.white,
              ),
            )
          ],
        ),
        _buildMainContent(context),
      ],
    );
  }

  Widget _buildSmallBody(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: <Widget>[
            Container(
              height: 360,
              color: Constants.turquoise,
            ),
            Expanded(
              child: Container(
                color: Constants.white,
              ),
            )
          ],
        ),
        _buildMainContent(context),
      ],
    );
  }

  Widget _buildMainContent(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    double fontSize = responsiveSize(context, 20, 30, md: 22);
    final double widthSize = MediaQuery.of(context).size.width;
    final double heightSize = MediaQuery.of(context).size.height;
    return Center(
      child: Container(
        height: heightSize * 0.80,
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
                        mainAxisAlignment: MainAxisAlignment.center,
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
                    ],
                  ),
                ),
              ),
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
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    double fontSize = responsiveSize(context, 20, 30, md: 22);
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: showBackIconButton(context, Constants.penBlue),
        title: Image.asset(
            ImagePath.LOGO,
            height: 30,
        ),
        backgroundColor: Constants.white,
        elevation: 1.0,
      ),
      backgroundColor: Constants.white,
      body: Container(
        color: AppColors.turquoiseBlue,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                StringConst.LOOKING_FOR_JOB,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            SpaceH20(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: EmailSignInFormChangeNotifier.create(context),
            ),
            kIsWeb ? buildStoresButtons(context) : Container(),
            SpaceH4(),
            kIsWeb ? Text(
              StringConst.BETTER_FROM_APPS,
              style: textTheme.bodyText2,
            ) : Container(),
          ],
        ),
      ),
    );
  }

}
