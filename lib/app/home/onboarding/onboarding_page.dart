import 'package:enreda_app/app/sign_in/access/access_page.dart';
import 'package:enreda_app/app/sign_up/unemployedUser/unemployed_registering.dart';
import 'package:enreda_app/utils/adaptive.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../utils/responsive.dart';
import '../../../../../values/values.dart';
import '../../../common_widgets/enreda_button.dart';
import '../../../common_widgets/spaces.dart';
import '../../../values/strings.dart';

const double bodyTextSizeLg = 16.0;
const double bodyTextSizeSm = 14.0;
const double socialTextSizeLg = 18.0;
const double socialTextSizeSm = 14.0;
const double sidePadding = Sizes.PADDING_20;

class OnboardingPageData {
  final String? logoImagePath, logoWithTextImagePath, mainImagePath, titleText, descriptionText, buttonText, circleImagePath;

  OnboardingPageData({
    this.logoImagePath,
    this.logoWithTextImagePath,
    this.mainImagePath,
    this.titleText,
    this.descriptionText,
    this.buttonText,
    this.circleImagePath,
  });
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage(
      { Key? key,
        this.logoImagePath,
        this.logoWithTextImagePath,
        this.mainImagePath,
        this.titleText,
        this.descriptionText,
        this.buttonText,
        this.circleImagePath,

      }) : super(key: key);

  final String? logoImagePath, logoWithTextImagePath, mainImagePath, titleText, descriptionText, buttonText, circleImagePath;

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  @override
  Widget build(BuildContext context) {
    double fontSizeTitle = responsiveSize(context, 20, 32, md: 30);
    double fontSizeDescription = responsiveSize(context, 17, 21, md: 20);
    double maxWidth = responsiveSize(context, 320, 700, md: 600);
    return Stack(
      children: [
        widget.logoImagePath == null || widget.logoImagePath == "" ? Container() :
        Positioned(
          top: Responsive.isMobile(context) ? 0 : Responsive.isTablet(context) ? -300 : -1000,
          child: Image.asset(
            widget.circleImagePath!,
            width: MediaQuery.of(context).size.width,
          ),
        ),
        widget.logoWithTextImagePath == null || widget.logoWithTextImagePath == "" ? Container():
        Positioned(
          top: Responsive.isMobile(context) ? 0 : Responsive.isTablet(context) ? -300 : -1000,
          child: Image.asset(
            widget.circleImagePath!,
            width: MediaQuery.of(context).size.width,
          ),
        ),
        Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SpaceH30(),
              widget.logoImagePath == null || widget.logoImagePath == "" ? Container() :
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Image.asset(
                        widget.logoImagePath!,
                        width: Responsive.isMobile(context) ? 180 : 250,
                      ),
                    ),
                    SpaceH20(),
                  ],
                ),
              ),
              widget.logoWithTextImagePath == null || widget.logoWithTextImagePath == "" ? Container():
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Image.asset(
                    widget.logoWithTextImagePath!,
                    width: Responsive.isMobile(context) ? 180 : 300,
                  ),
                ),
              ),
              widget.mainImagePath == null || widget.mainImagePath == "" ? Container() :
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Image.asset(
                    widget.mainImagePath!,
                  ),
                ),
              ),
              widget.titleText == null || widget.titleText == "" ? Container() :
              Expanded(
                  flex: 1,
                  child:
                  Column(
                      children: [
                        Container(
                          constraints: BoxConstraints(maxWidth: maxWidth),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0, right: 10, top: 20, bottom: 10),
                            child: Text(widget.titleText!,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: fontSizeTitle,
                                  color: Colors.white,
                                )),
                          ),
                        ),
                        Container(
                          constraints: BoxConstraints(maxWidth: maxWidth),
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(widget.descriptionText!,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                color: Colors.white,
                                fontSize: fontSizeDescription,
                              )),
                        )
                      ]
                  )
              ),
              widget.buttonText == null || widget.buttonText == "" ? Container() :
              Column(
                crossAxisAlignment: Responsive.isMobile(context) ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
                children: [
                  SpaceH20(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10),
                    child: EnredaButton(
                        buttonTitle: widget.buttonText!,
                        buttonColor: AppColors.primaryColor,
                        titleColor: AppColors.white,
                        onPressed: () => {
                          Navigator.of(this.context).push(
                            MaterialPageRoute<void>(
                              fullscreenDialog: true,
                              builder: ((context) =>
                                  UnemployedRegistering()),
                            ),
                          )
                        }),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(StringConst.HAVE_ACCOUNT,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                            color: Colors.white,
                            fontSize: fontSizeDescription,
                          )),
                      SpaceW4(),
                      TextButton(
                          onPressed: () {
                            context.push(StringConst.PATH_LOGIN);
                          },
                          child: Text(StringConst.LOG_IN,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: fontSizeDescription,
                              )),
                      )
                    ],
                  ),
                  SpaceH20(),
                ],
              ),
            ]
        ),
      ],
    );
  }
}


