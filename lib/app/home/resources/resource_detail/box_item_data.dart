import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';

class BoxItemData {
  final IconData icon;
  final String title;
  final String contact;

  BoxItemData({
    required this.icon,
    required this.title,
    required this.contact,
  });
}

class BoxItem extends StatelessWidget {
  BoxItem({
    this.icon,
    this.title = "",
    this.contact = "",
  });

  final IconData? icon;
  final String title;
  final String contact;

  @override
  Widget build(BuildContext context) {
    return defaultChild(context);
  }

  Widget defaultChild(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        border: Border.all(
            color: AppColors.greyLight2.withOpacity(0.2),
            width: 1),
        borderRadius: BorderRadius.circular(5),
      ),
      key: Key("default"),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.turquoiseBlue, size: 20),
                SizedBox(width: 5),
                Text(
                  title,
                  textAlign: TextAlign.start,
                  style: textTheme.bodySmall?.copyWith(height: 1.4, fontWeight: FontWeight.w600, color: AppColors.turquoiseBlue),
                ),
              ],
            ),
            SpaceH12(),
            Text(
              contact,
              textAlign: TextAlign.start,
              style: textTheme.bodySmall?.copyWith(height: 0.5, fontWeight: FontWeight.w500, color: AppColors.turquoiseButton2),
            ),
          ],
        ),
      ),
    );
  }
}
