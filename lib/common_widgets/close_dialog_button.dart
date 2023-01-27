import 'package:enreda_app/utils/const.dart';
import 'package:flutter/material.dart';

class CloseDialogButton extends StatelessWidget {
  const CloseDialogButton({Key? key, required this.onPressed}) : super(key: key);
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 20,
      child: IconButton(
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        icon: Icon(Icons.clear, size: 20.0,),
        color: Constants.darkGray,
        onPressed: onPressed,
      ),
      backgroundColor: Constants.lightGray,
    );;
  }
}
