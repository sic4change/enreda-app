import 'package:enreda_app/values/strings.dart';
import 'package:flutter/material.dart';
import '../../../../../../utils/functions.dart';
import '../../../../../../utils/responsive.dart';
import '../../../../../../values/values.dart';
import '../../../utils/adaptive.dart';

Widget checkboxForm(BuildContext context, _checkFieldKey, bool _isChecked, functionSetState) {
  TextTheme textTheme = Theme.of(context).textTheme;
  double fontSize = responsiveSize(context, 14, 16, md: 15);
  return Form(
    key: _checkFieldKey,
    child: FormField<bool>(
      initialValue: _isChecked,
      builder: (FormFieldState<bool> state) {
        return Column(
          children: <Widget>[
            Flex(
              direction: Responsive.isMobile(context) ? Axis.vertical : Axis.horizontal,
              children:<Widget> [
                Row(
                  children: [
                    Checkbox(
                        activeColor: AppColors.primaryColor,
                        value: state.value,
                        onChanged: (bool? val) => { functionSetState(val), state.didChange(val)}
                    ),
                    Text(StringConst.FORM_ACCEPT_SENTENCE,
                      style: textTheme.button?.copyWith(
                        height: 1.5,
                        color: AppColors.greyDark,
                        fontWeight: FontWeight.w700,
                        fontSize: fontSize,
                      ),),
                    TextButton(
                        onPressed: () => openUrlLink(StringConst.PRIVACITY_URL),
                        child: Flex(
                          direction: Responsive.isMobile(context) ? Axis.vertical : Axis.horizontal,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(StringConst.RIGHTS_RESERVED,
                              style: textTheme.button?.copyWith(
                                height: 1.5,
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w700,
                                fontSize: fontSize,
                              ),
                            ),
                          ],
                        )
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(StringConst.FORM_ACCEPT_SENTENCE_Y,
                      style: textTheme.button?.copyWith(
                        height: 1.5,
                        color: AppColors.greyDark,
                        fontWeight: FontWeight.w700,
                        fontSize: fontSize,
                      ),),
                    TextButton(
                        onPressed: () => openUrlLink(StringConst.USE_CONDITIONS_URL),
                        child: Flex(
                          direction: Responsive.isMobile(context) ? Axis.vertical : Axis.horizontal,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(StringConst.BUILT_BY,
                              style: textTheme.button?.copyWith(
                                height: 1.5,
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w700,
                                fontSize: fontSize,
                              ),
                            ),
                          ],
                        )
                    ),
                  ],
                ),
              ],
            ),
            state.errorText == null
                ? Text("")
                : Text(state.errorText!, style: TextStyle(color: AppColors.red, fontSize: 13)),
          ],
        );
      },
      validator: (value) => _isChecked ? null : StringConst.FORM_ACCEPTANCE_ERROR,
    ),
  );
}