import 'package:enreda_app/utils/adaptive.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';

import '../utils/responsive.dart';

Future showAlertDialog(
  BuildContext context, {
  required String title,
  required String content,
  required String defaultActionText,
  String? cancelActionText,
}) {
  final textTheme = Theme.of(context).textTheme;

  try {
    double fontSize = responsiveSize(context, 13, 20, md: 16);
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.primary050,
        titlePadding:
          Responsive.isMobile(context) ? const EdgeInsets.only(top: 40.0, left: 20.0, right: 20.0, bottom: 10.0) :
          const EdgeInsets.only(top: 50.0, left: 50.0, right: 50.0, bottom: 10.0),
        contentPadding:
          Responsive.isMobile(context) ? const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0) :
          const EdgeInsets.only(left: 50.0, right: 50.0, bottom: 30.0),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title,
                style: textTheme.titleLarge?.copyWith(
                  color: AppColors.turquoiseBlue,
                  fontSize: fontSize,
                  height: 1.5,
                )),
          ],
        ),
        content: Text(content,
            style: textTheme.headlineLarge?.copyWith(
                color: AppColors.turquoiseBlue,
                height: 1.5,
                fontSize: fontSize - 1)),
        actions: <Widget>[
          if (cancelActionText != null)
            // ignore: deprecated_member_use
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Constants.turquoise,
                      ),
                      onPressed: () => Navigator.of(context).pop((false)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(cancelActionText,
                            style: textTheme.bodySmall?.copyWith(
                                color: AppColors.white,
                                height: 1.5,
                                fontWeight: FontWeight.w400,
                                fontSize: fontSize - 2)),
                      )),
                  Responsive.isMobile(context) ? SizedBox(width: 10,) : SizedBox(width: 30,),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Constants.turquoise,
                      ),
                      onPressed: () => Navigator.of(context).pop((true)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(defaultActionText,
                            style: textTheme.bodySmall?.copyWith(
                                color: AppColors.white,
                                height: 1.5,
                                fontWeight: FontWeight.w400,
                                fontSize: fontSize - 2)),
                      )),
                ],
              ),
            ),
        ],
      ),
    );
  } catch (e) {
    TextTheme textTheme = Theme.of(context).textTheme;
    double fontSize = responsiveSize(context, 14, 18, md: 15);
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title,
            style: textTheme.bodySmall?.copyWith(
              color: Constants.grey,
              height: 1.5,
              fontWeight: FontWeight.w800,
              fontSize: fontSize + 2,
            )),
        content: Text(content,
            style: textTheme.bodySmall?.copyWith(
              color: Constants.grey,
              height: 1.5,
              fontWeight: FontWeight.w400,
              fontSize: fontSize,
            )),
        actions: <Widget>[
          if (cancelActionText != null)
            // ignore: deprecated_member_use
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.turquoise,
                ),
                onPressed: () => Navigator.of(context).pop((false)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(cancelActionText,
                      style: textTheme.bodySmall?.copyWith(
                          color: AppColors.white,
                          height: 1.5,
                          fontWeight: FontWeight.w400,
                          fontSize: fontSize)),
                )),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Constants.turquoise,
              ),
              onPressed: () => Navigator.of(context).pop((true)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(defaultActionText,
                    style: textTheme.bodySmall?.copyWith(
                        color: Constants.grey,
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                        fontSize: fontSize)),
              )),
        ],
      ),
    );
  }
}
