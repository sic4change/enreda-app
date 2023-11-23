import 'package:flutter/material.dart';

class CustomPersonPillImage extends StatelessWidget {
  CustomPersonPillImage({ required this.personPillImagePath, required this.height});
  final String personPillImagePath;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
            alignment: Alignment.bottomCenter,
            height: height,
            child: Image.asset(personPillImagePath)),
      ],
    );
  }
}
