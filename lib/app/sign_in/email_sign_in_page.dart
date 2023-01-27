import 'package:enreda_app/app/sign_in/email_sign_in_form_change_notifier.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/utils/adaptive.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EmailSignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final double largeHeight = 800;
    return Responsive.isMobile(context)
        ? _buildMobileLayout(context)
        : Scaffold(
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
        _buildBackButton(context),
        Row(
          children: [
            Expanded(
              flex: 15,
              child: Container(),
            ),
            Expanded(
              flex: 70,
              child: Column(
                children: [
                  Expanded(
                    flex: 15,
                    child: Container(),
                  ),
                  Expanded(
                    flex: 60,
                    child: Container(
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Constants.lightGray, width: 1),
                        borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        color: Colors.white,
                      ),
                      child: Stack(
                        children: [
                          Row(
                            children: [
                              Expanded(flex: 4, child: Container()),
                              Expanded(
                                  flex: 6,
                                  child: Image.asset(
                                    ImagePath.LEARNING_GIRL,
                                    height: heightOfScreen(context) * 0.4,
                                  )),
                            ],
                          ),
                          _buildMainContent(context),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 25,
                    child: Container(),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 15,
              child: Container(),
            ),
          ],
        ),
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
        _buildBackButton(context),
        Row(
          children: [
            Expanded(
              flex: 15,
              child: Container(),
            ),
            Expanded(
              flex: 70,
              child: Column(
                children: [
                  Container(
                    height: 120.0,
                  ),
                  Container(
                    height: 480.0,
                    decoration: BoxDecoration(
                      border: Border.all(color: Constants.lightGray, width: 1),
                      borderRadius: BorderRadius.all(Radius.circular(15.0)),
                      color: Colors.white,
                    ),
                    child: Stack(
                      children: [
                        Row(
                          children: [
                            Expanded(flex: 4, child: Container()),
                            Expanded(
                                flex: 6,
                                child: Image.asset(
                                  ImagePath.LEARNING_GIRL,
                                  height: 400.0,
                                )),
                          ],
                        ),
                        _buildMainContent(context),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 25,
                    child: Container(),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 15,
              child: Container(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 30.0, top: 30.0, bottom: 20.0),
          child: Image.asset(
            ImagePath.LOGO,
            height: 20,
          ),
        ),
        Divider(),
        Padding(
          padding: const EdgeInsets.all(30.0),
          child: Text(
            StringConst.LOOKING_FOR_JOB,
            style: TextStyle(
              fontSize: 32.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Row(
            children: [
              Expanded(
                child: EmailSignInFormChangeNotifier.create(context),
              ),
              Expanded(child: Container()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 20.0, left: 20.0),
      width: 44.0,
      height: 44.0,
      child: TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.all(0),
          backgroundColor: Colors.white.withOpacity(0.3),
          shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(10.0),
          ),
        ),
        child: Icon(Icons.keyboard_backspace, color: Colors.white),
        onPressed: () {
          context.canPop() ? context.pop() : context.go(StringConst.PATH_HOME);
        },
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, 60),
        child: AppBar(
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
                  style: TextButton.styleFrom(
                    shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Icon(Icons.keyboard_backspace, color: Constants.turquoise),
                  onPressed: () {
                    context.canPop() ? context.pop() : context.go(StringConst.PATH_HOME);
                  },
                ),
          ),
          title: Image.asset(
              ImagePath.LOGO,
              height: 25,
          ),
          backgroundColor: Constants.white,
          elevation: 1.0,
        ),
      ),
      backgroundColor: Constants.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                StringConst.LOOKING_FOR_JOB,
                style: TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SpaceH20(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: EmailSignInFormChangeNotifier.create(context),
            ),
          ],
        ),
      ),
    );
  }
}
