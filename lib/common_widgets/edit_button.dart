import 'package:enreda_app/utils/const.dart';
import 'package:flutter/material.dart';

class EditButton extends StatelessWidget {
  const EditButton({Key? key, required this.onTap}) : super(key: key);
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onTap,
        child: Icon(
          Icons.edit_outlined,
          color: Constants.darkGray,
          size: 18.0,
        ));
  }
}
