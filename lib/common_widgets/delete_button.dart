import 'package:enreda_app/utils/const.dart';
import 'package:flutter/material.dart';

class DeleteButton extends StatelessWidget {
  const DeleteButton({Key? key, required this.onTap}) : super(key: key);
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onTap,
        child: Icon(
          Icons.delete_outline,
          color: Constants.alertRed,
          size: 18.0,
        ));
  }
}
