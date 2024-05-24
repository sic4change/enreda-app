import 'package:enreda_app/utils/adaptive.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';

import '../../../values/values.dart';

class EnredaButton extends StatelessWidget {
  EnredaButton({
    required this.buttonTitle,
    this.width = Sizes.WIDTH_150,
    this.height = Sizes.HEIGHT_60,
    this.titleStyle,
    this.titleColor = AppColors.white,
    this.buttonColor = AppColors.primaryColor,
    this.onPressed,
    this.padding = const EdgeInsets.all(Sizes.PADDING_8),
    this.borderRadius = const BorderRadius.all(
      Radius.circular(Sizes.RADIUS_30),
    ),
    this.opensUrl = false,
    this.url = "",
    this.linkTarget = LinkTarget.blank,
  });

  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final String buttonTitle;
  final TextStyle? titleStyle;
  final Color titleColor;
  final Color buttonColor;
  final BorderRadiusGeometry borderRadius;
  final EdgeInsetsGeometry padding;
  final String url;
  final LinkTarget linkTarget;
  final bool opensUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: MaterialButton(
        minWidth: width,
        height: height,
        onPressed: opensUrl ? () {} : onPressed,
        color: buttonColor,
        child: Padding(
          padding: padding,
          child: buildChild(context),
        ),
      ),
    );
  }

  Widget buildChild(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    double? textSize = responsiveSize(
      context,
      Sizes.TEXT_SIZE_18,
      Sizes.TEXT_SIZE_18,
      md: Sizes.TEXT_SIZE_18,
    );
      return Text(
        buttonTitle,
        style: titleStyle ??
            textTheme.bodySmall?.copyWith(
              color: titleColor,
              fontSize: textSize,
              letterSpacing: 1.1,
              fontWeight: FontWeight.bold,
            ),
      );
    // }
  }
}

class EnredaButtonIcon extends StatelessWidget {
  const EnredaButtonIcon({
    super.key,
    this.buttonTitle = "",
    this.width = Sizes.WIDTH_150,
    this.height = Sizes.HEIGHT_60,
    this.titleStyle,
    this.titleColor = AppColors.white,
    this.buttonColor = AppColors.primaryColor,
    this.onPressed,
    this.padding = const EdgeInsets.only(top: Sizes.PADDING_8, bottom: Sizes.PADDING_8, left: Sizes.PADDING_16, right: 0),
    this.borderRadius = const BorderRadius.all(
      Radius.circular(Sizes.RADIUS_45),
    ),
    this.opensUrl = false,
    this.url = "",
    this.linkTarget = LinkTarget.blank,
    this.widget,
  });

  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final String buttonTitle;
  final TextStyle? titleStyle;
  final Color titleColor;
  final Color buttonColor;
  final BorderRadiusGeometry borderRadius;
  final EdgeInsetsGeometry padding;
  final String url;
  final LinkTarget linkTarget;
  final bool opensUrl;
  final Widget? widget;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: MaterialButton(
        minWidth: width,
        height: height,
        onPressed: opensUrl ? () {} : onPressed,
        color: buttonColor,
        child: Padding(
          padding: padding,
          child: buildChild(context),
        ),
      ),
    );
  }

  Widget buildChild(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    double? textSize = responsiveSize(
      context,
      Sizes.TEXT_SIZE_14,
      Sizes.TEXT_SIZE_16,
      md: Sizes.TEXT_SIZE_15,
    );
    return Row(
      children: [
        Text(
          buttonTitle,
          style: titleStyle ??
              textTheme.bodySmall?.copyWith(
                color: titleColor,
                fontSize: textSize,
                letterSpacing: 1.1,
                fontWeight: FontWeight.bold,
              ),
        ),
        if(buttonTitle != "") SizedBox(width: 10,),
        Container(
            height: 30,
            child: widget ?? Container()),
      ],
    );
    // }
  }
}