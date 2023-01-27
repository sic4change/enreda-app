import 'package:flutter/material.dart';

import '../utils/adaptive.dart';
import '../values/values.dart';

class CustomExpandedRow extends StatelessWidget {

  CustomExpandedRow({ required this.title, required this.text, });
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    double fontSize = responsiveSize(context, 14, 18, md: 15);
    return Row(
      children: [
        Expanded(
            flex: 1,
            child: Text(title,
              maxLines: 3,
              style: textTheme.bodyText1?.copyWith(
                height: 1.5,
                color: AppColors.greyDark,
                fontWeight: FontWeight.w700,
                fontSize: fontSize,
              ),)),
        SizedBox(width: 50),
        Expanded(
            flex: 2,
            child: Text(text,
              textAlign: TextAlign.right,
              maxLines: 4,
              style: textTheme.bodyText1?.copyWith(
                height: 1.5,
                color: AppColors.greyDark,
                fontWeight: FontWeight.w700,
                fontSize: fontSize,
              ),
            )),
      ],
    );
  }
}