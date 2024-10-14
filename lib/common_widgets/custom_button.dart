import 'package:flutter/material.dart';

import '../values/values.dart';
import 'custom_text.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color color;
  final Color backgroundColor;
  const CustomButton({
    Key? key,
    required this.text,
    required this.onTap,
    required this.color,
    this.backgroundColor = AppColors.primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: color, backgroundColor: backgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
            side: BorderSide(color: backgroundColor),
          ),
        ),
        onPressed: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CustomTextSmall(text: text, color: color,),
        ),
      ),
    );
  }
}