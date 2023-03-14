import 'package:enreda_app/utils/const.dart';
import 'package:flutter/material.dart';

class SelectButton extends StatelessWidget {
  const SelectButton({Key? key, required this.isSelected}) : super(key: key);
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Icon(
      isSelected == false ? Icons.crop_square : Icons.check_box,
      color: Constants.darkGray,
      size: 20.0,
    );
  }
}
