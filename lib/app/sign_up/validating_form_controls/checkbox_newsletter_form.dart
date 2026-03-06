import 'package:enreda_app/values/strings.dart';
import 'package:flutter/material.dart';
import '../../../../../../utils/responsive.dart';
import '../../../../../../values/values.dart';
import '../../../utils/adaptive.dart';

Widget checkboxNewsletterForm(BuildContext context, GlobalKey<FormState> _checkFieldKey, bool _isChecked, Function(bool?) functionSetState) {
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
                    onChanged: (bool? val) {
                      functionSetState(val);
                      state.didChange(val);
                    }
                ),
                Flexible(
                  child: Text(
                    StringConst.FORM_NEWSLETTER,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.primary900,
                      height: 1.5,
                      fontSize: fontSize,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    ),
  );
}
