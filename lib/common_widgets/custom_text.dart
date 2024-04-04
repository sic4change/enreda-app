import 'package:flutter/material.dart';
import '../../../values/values.dart';
import '../utils/adaptive.dart';

class CustomTextTitle extends StatelessWidget {

  CustomTextTitle({ required this.title, this.color = AppColors.turquoiseBlue });
  final String title;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        title,
        style: textTheme.bodyMedium?.copyWith(
          color: color,
          height: 1.5,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class CustomTextSubTitle extends StatelessWidget {

  CustomTextSubTitle({ required this.title });
  final String title;

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        title,
        style: textTheme.bodySmall?.copyWith(
          color: AppColors.turquoiseBlue,
          height: 1.5,
          fontWeight: FontWeight.w400,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class CustomTextBody extends StatelessWidget {

  CustomTextBody({ required this.text });
  final String text;

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Text(
      text,
      style: textTheme.bodySmall?.copyWith(
        color: AppColors.greyAlt,
        height: 1.5,
      ),
    );
  }
}

class CustomText extends StatelessWidget {

  CustomText({ required this.title });
  final String title;

  @override
  Widget build(BuildContext context) {
    double fontSize = responsiveSize(context, 14, 15, md: 14);
    TextTheme textTheme = Theme.of(context).textTheme;
    return Text(
      title,
      style: textTheme.bodySmall?.copyWith(
        color: AppColors.greyAlt,
        height: 1.5,
        fontSize: fontSize,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class CustomTextBold extends StatelessWidget {

  CustomTextBold({ required this.title, this.color = AppColors.greyTxtAlt });
  final String title;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    double fontSize = responsiveSize(context, 14, 15, md: 14);
    TextTheme textTheme = Theme.of(context).textTheme;
    return Text(
      title,
      style: textTheme.headlineLarge?.copyWith(
        height: 1.5,
        color: color,
        fontSize: fontSize
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class CustomTextSmall extends StatelessWidget {

  CustomTextSmall({ required this.text });
  final String text;

  @override
  Widget build(BuildContext context) {
    double fontSize = responsiveSize(context, 14, 15, md: 14);
    TextTheme textTheme = Theme.of(context).textTheme;
    return Text(
      text,
      style: textTheme.bodySmall?.copyWith(
        height: 1.5,
        fontSize: fontSize,
      ),
    );
  }
}

class CustomTextChip extends StatelessWidget {
  CustomTextChip({ required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    double fontSize = responsiveSize(context, 14, 18, md: 15);
    TextTheme textTheme = Theme.of(context).textTheme;
    return Text(text,
      style: textTheme.bodySmall?.copyWith(
        color: color,
        height: 1.5,
        fontWeight: FontWeight.w800,
        fontSize: fontSize,
      ),
    );
  }
}

class CustomTextBoldCenter extends StatelessWidget {

  const CustomTextBoldCenter({super.key,  required this.title, this.color = AppColors.greyTxtAlt, this.height = 1.5});
  final String title;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    double fontSize = responsiveSize(context, 16, 20, md: 18);
    TextTheme textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: textTheme.titleMedium?.copyWith(
            color: color,
            height: height,
            fontSize: fontSize,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class CustomTextBoldTitle extends StatelessWidget {

  const CustomTextBoldTitle({super.key,  required this.title });
  final String title;

  @override
  Widget build(BuildContext context) {
    double fontSize = responsiveSize(context, 15, 30, md: 25);
    TextTheme textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(
        title,
        style: textTheme.bodyLarge?.copyWith(
          color: AppColors.turquoiseBlue,
          height: 1.5,
          //fontWeight: FontWeight.w600,
          fontSize: fontSize,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class CustomTextMediumBold extends StatelessWidget {

  const CustomTextMediumBold({super.key,  required this.text });
  final String text;

  @override
  Widget build(BuildContext context) {
    double fontSize = responsiveSize(context, 13, 22, md: 15);
    TextTheme textTheme = Theme.of(context).textTheme;
    return Text(
      text,
      style: textTheme.titleMedium?.copyWith(
        color: AppColors.turquoiseBlue,
        height: 1.5,
        fontSize: fontSize,
      ),
    );
  }
}

class CustomTextLargeBold extends StatelessWidget {

  const CustomTextLargeBold({super.key,  required this.text });
  final String text;

  @override
  Widget build(BuildContext context) {
    double fontSize = responsiveSize(context, 15, 22, md: 20);
    TextTheme textTheme = Theme.of(context).textTheme;
    return Text(
      text,
      textAlign: TextAlign.center,
      style: textTheme.bodyLarge?.copyWith(
        color: AppColors.turquoiseBlue,
        height: 1.5,
        fontSize: fontSize
      ),
    );
  }
}