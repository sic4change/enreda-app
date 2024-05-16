import 'package:enreda_app/common_widgets/custom_text.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';

class CardButtonContact extends StatelessWidget {
  final String title;
  final Widget icon;
  final VoidCallback onTap;
  final double width;

  CardButtonContact({
    Key? key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.width = 100,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: width,
        padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 10),
        margin: EdgeInsets.only(bottom: 5, top: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.0),
          color: AppColors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                icon,
                SpaceW4(),
                CustomText(title: title, color: AppColors.turquoiseBlue)
              ],
            ),
          ],
        ),
      ),
    );
  }
}
