import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../utils/functions.dart';
import '../../../../utils/responsive.dart';
import '../../../../values/values.dart';
import '../../common_widgets/social_button.dart';
import '../../common_widgets/spaces.dart';
import '../../common_widgets/vertical_divider.dart';
import '../../utils/adaptive.dart';
import '../../values/strings.dart';

class FooterSection extends StatefulWidget {
  FooterSection({Key? key});
  @override
  _FooterSectionState createState() => _FooterSectionState();
}

class _FooterSectionState extends State<FooterSection> {
  late StackRouter router;

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    TextStyle? footerTextStyle = textTheme.caption?.copyWith(
      color: AppColors.primaryText2,
      fontWeight: FontWeight.bold,
    );

    return Container(
      child: Column(
        children: [
          SpaceH50(),
          InkWell(
            onTap: () {
              context.push(StringConst.PATH_ACCESS);
            },
            child: Image.asset(
              ImagePath.LOGO,
              height: Sizes.HEIGHT_74,
            ),
          ),
          SpaceH30(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  SpaceW20(),
                  ..._buildSocialIcons(Data.socialData),
                  SpaceW20(),
                ],
              ),
            ],
          ),
          Responsive.isTablet(context) || Responsive.isMobile(context) ? SpaceH30() : Container(),
          Flex(
            direction: Responsive.isTablet(context) || Responsive.isMobile(context) ? Axis.vertical : Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: InkWell(
                  onTap: () => openUrlLink(StringConst.PRIVACITY_URL),
                  child: RichText(
                    text: TextSpan(
                      text: StringConst.RIGHTS_RESERVED + " ",
                      style: footerTextStyle,
                      children: [
                        TextSpan(text: StringConst.DESIGNED_BY + " "),
                        TextSpan(
                          text: " ",
                          style: footerTextStyle?.copyWith(
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w900,
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Responsive.isTablet(context) || Responsive.isMobile(context) ? Container() :
              EnredaVerticalDivider(),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: InkWell(
                  onTap: () => openUrlLink(StringConst.USE_CONDITIONS_URL),
                  child: RichText(
                    text: TextSpan(
                      text: StringConst.BUILT_BY + " ",
                      style: footerTextStyle,
                      children: [

                      ],
                    ),
                  ),
                ),
              ),
              Responsive.isTablet(context) || Responsive.isMobile(context) ? Container() :
              EnredaVerticalDivider(),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(StringConst.MADE_BY, style: footerTextStyle),
                    SpaceW4(),
                    Icon(
                      FontAwesomeIcons.solidHeart,
                      color: AppColors.primaryColor,
                      size: Sizes.ICON_SIZE_12,
                    ),
                    SpaceW4(),
                    Text(StringConst.WITH_LOVE, style: footerTextStyle),
                    SpaceW4(),
                    InkWell(
                      onTap: () => openUrlLink(StringConst.WEB_SIC4Change),
                      child: RichText(
                        text: TextSpan(
                          text: " ",
                          style: footerTextStyle,
                          children: [
                            TextSpan(
                              text: StringConst.SIC4CHANGE + ". ",
                              style: footerTextStyle?.copyWith(
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w900,
                                color: AppColors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SpaceH100(),
            ],
          )
        ],
      ),
    );
  }


  List<Widget> _buildSocialIcons(List<SocialButtonData> socialItems) {
    List<Widget> items = [];
    for (int index = 0; index < socialItems.length; index++) {
      items.add(
        SocialButton(
          tag: socialItems[index].tag,
          iconData: socialItems[index].iconData,
          onPressed: () => openUrlLink(socialItems[index].url),
        ),
      );
      items.add(SpaceW16());
    }
    return items;
  }

}

class FooterItem extends StatelessWidget {
  FooterItem({
    required this.title,
    required this.subtitle,
    required this.image,
  });

  final String title;
  final String subtitle;
  final String image;

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    double fontSize = responsiveSize(context, 14, 18, md: 15);
    return Padding(
      padding: Responsive.isMobile(context) ? EdgeInsets.all(10.0) : Responsive.isDesktopS(context) ? EdgeInsets.all(20.0) : EdgeInsets.all(40.0),
      child: Column(
        children: [
          Image.asset(
            image,
            height: Responsive.isTablet(context) || Responsive.isMobile(context) ? Sizes.ICON_SIZE_40 : Sizes.ICON_SIZE_60,
          ),
          SpaceH12(),
          Text(
            title,
            style: textTheme.subtitle1?.copyWith(
              color: AppColors.greyTxtAlt, fontSize: fontSize,
            ),
          ),
          SpaceH8(),
          Text(
            subtitle,
            style: textTheme.bodyText1?.copyWith(
              color: AppColors.greyTxtAlt.withOpacity(0.7), fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}