import 'package:enreda_app/common_widgets/custom_raised_button.dart';
import 'package:flutter/material.dart';

class FormSubmitButton extends CustomRaisedButton {
  FormSubmitButton({
    required String text,
    required Color color,
    VoidCallback? onPressed,
  }) : super(
          child: Text(
            text,
            style: TextStyle(color: Colors.white, fontSize: 16.0),
          ),
          height: 40.0,
          color: color,
          borderRadius: 4.0,
          onPressed: onPressed,
        );
}
