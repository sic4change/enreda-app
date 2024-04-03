import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';

class CustomStepperButton extends StatelessWidget {
  const CustomStepperButton({super.key, required this.child, required this.color, required this.icon});
  final Widget child;
  final Color color;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: Sizes.kDefaultPaddingDouble / 3, horizontal: Sizes.kDefaultPaddingDouble),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(Sizes.kDefaultPaddingDouble * 2),
      ),
      child: Row(
        children: [
          icon,
          SpaceW8(),
          child,
        ],
      ),
    );
  }
}
