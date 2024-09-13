import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:flutter/material.dart';

import '../utils/responsive.dart';
import '../values/values.dart';

class EmptyList extends StatelessWidget {
  const EmptyList(
      {Key? key, required this.title, this.subtitle, required this.imagePath, this.onPressed, this.buttonTitle = "Empieza ahora"})
      : super(key: key);
  final String title;
  final String? subtitle;
  final String imagePath;
  final String? buttonTitle;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: Responsive.isMobile(context) ? MediaQuery.of(context).size.width : 500,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                    fontSize: Responsive.isMobile(context) ? 12.0 : 18.0,
                    color: AppColors.primary900),
              ),
            ),
            subtitle == null ? Container() : SpaceH8(),
            subtitle == null ? Container() : Container(
              width: Responsive.isMobile(context) ? MediaQuery.of(context).size.width : 500,
              child: Text(
                subtitle ?? '',
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(
                    fontSize: Responsive.isMobile(context) ? 15.0 : 22.0,
                    color: AppColors.primary900),
              ),
            ),
            SpaceH8(),
            Image.asset(
              imagePath,
              width: Responsive.isMobile(context) ? 100 : 200.0,
            ),
            SpaceH20(),
            onPressed != null ? TextButton(
              onPressed: () {
                if (onPressed != null) {
                  onPressed!();
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
                child: Text(
                  buttonTitle!,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(AppColors.primaryColor),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ))),
            ) : Container(),
          ],
        ),
      ),
    );
  }
}
