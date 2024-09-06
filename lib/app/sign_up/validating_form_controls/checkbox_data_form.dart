import 'package:enreda_app/values/strings.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../../../../utils/responsive.dart';
import '../../../../../../values/values.dart';
import '../../../utils/adaptive.dart';
import '../../../utils/functions.dart';

Widget checkboxDataForm(BuildContext context, _checkFieldKey, bool _isChecked, functionSetState) {
  TextTheme textTheme = Theme.of(context).textTheme;
  double fontSize = responsiveSize(context, 14, 16, md: 15);
  return Form(
    key: _checkFieldKey,
    child: FormField<bool>(
      initialValue: _isChecked,
      builder: (FormFieldState<bool> state) {
        return Column(
          children: <Widget>[
            Row(
              children: [
                Checkbox(
                    activeColor: AppColors.primaryColor,
                    value: state.value,
                    onChanged: (bool? val) => { functionSetState(val), state.didChange(val)}
                ),
                // IconButton(
                //     icon: Icon(_isChecked ? Icons.check_box : Icons.crop_square),
                //     color: AppColors.primary900,
                //     iconSize: 20.0,
                //     onPressed: (){
                //       //database.setUserEnreda(user!.copyWith(checkAgreeCV: !_isChecked));
                //     }
                // ),
                Flexible(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: StringConst.FORM_ACCORDING,
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.primary900,
                            height: 1.5,
                            fontSize: fontSize,
                          ),
                        ),
                        TextSpan(
                          text: StringConst.PERSONAL_DATA_LAW,
                          style: textTheme.titleMedium?.copyWith(
                            color: AppColors.primary900,
                            height: 1.5,
                            fontSize: fontSize,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              launchURL(StringConst.PERSONAL_DATA_LAW_PDF);
                            },
                        ),
                        TextSpan(
                          text: StringConst.PERSONAL_DATA_LAW_TEXT,
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.primary900,
                            height: 1.5,
                            fontSize: fontSize,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
            state.errorText == null
                ? Text("")
                : Text(state.errorText!, style: TextStyle(color: AppColors.red, fontSize: 13)),
          ],
        );
      },
      validator: (value) => _isChecked ? null : StringConst.FORM_PRIVACY_DATA_ERROR,
    ),
  );
}