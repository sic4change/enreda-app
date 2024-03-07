import 'package:flutter/material.dart';
import '../../../values/values.dart';
import '../utils/adaptive.dart';

class CustomTextTitle extends StatelessWidget {

  CustomTextTitle({ required this.title, this.color = AppColors.greyViolet });
  final String title;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(
        title,
        style: textTheme.bodySmall?.copyWith(
          color: color,
          height: 1.5,
          fontWeight: FontWeight.w600,
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
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(
        title,
        style: textTheme.bodySmall?.copyWith(
          color: AppColors.greyViolet,
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

  CustomTextBold({ required this.title });
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
        fontWeight: FontWeight.bold
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
        color: AppColors.greyAlt,
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