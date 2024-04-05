import 'package:enreda_app/common_widgets/custom_text.dart';
import 'package:enreda_app/common_widgets/rounded_container.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';

class ContactDetail extends StatelessWidget {
  const ContactDetail({
    Key? key,
    required this.widget,
    required this.title,
    required this.description,
    required this.icon
  }) : super(key: key);
  final Widget widget;
  final String title;
  final String description;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return RoundedContainer(
      contentPadding: const EdgeInsets.only(top: Sizes.kDefaultPaddingDouble),
      width: 260,
      height: 253,
      child: Column(
        children: [
          widget,
          CustomTextBoldCenter(title: title, padding: EdgeInsets.only(top: 8),),
          CustomTextSubTitle(title: description),
          Spacer(),
          Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.turquoiseBlue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(Sizes.kDefaultPaddingDouble), // Adjust the radius as needed
                  bottomRight: Radius.circular(Sizes.kDefaultPaddingDouble), // Adjust the radius as needed
                ),
              ),
              child: icon),
        ],
      ),
    );
  }
}
