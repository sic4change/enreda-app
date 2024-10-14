import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';

class CustomTextFormFieldTitle extends StatelessWidget {
  const CustomTextFormFieldTitle({
    super.key,
    required this.labelText,
    this.initialValue,
    this.hintText,
    this.fontSize = 14.0,
    this.onSaved,
    this.onChanged,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
    this.height,
    this.textColor = AppColors.greyTxtAlt,
  });

  final String labelText;
  final String? initialValue, hintText;
  final double fontSize;
  final Function(String)? onChanged;
  final Function(String?)? onSaved;
  final String ?Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool enabled;
  final double? height;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            labelText,
            style: textTheme.bodySmall?.copyWith(
              height: 1.5,
              color: AppColors.greyDark,
              fontWeight: FontWeight.w700,
              fontSize: fontSize,
            ),
          ),
        ),
        height != null ? 
        textField(context) :
        textField(context),
      ],
    );
  }
  
  Widget textField(BuildContext context){
    final textTheme = Theme.of(context).textTheme;
    return TextFormField(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.all(5),
        hintText: hintText,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide: BorderSide(
            color: AppColors.greyUltraLight,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide: BorderSide(
            color: AppColors.greyUltraLight,
            width: 1.0,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide: BorderSide(
            color: AppColors.greyUltraLight,
            width: 1.0,
          ),
        ),
      ),
      initialValue: initialValue,
      validator: (value) =>
      value!.isNotEmpty ? null : StringConst.FORM_FIELD_ERROR,
      onSaved: onSaved,
      keyboardType: keyboardType,
      onChanged: onChanged,
      enabled: enabled,
      style: textTheme.bodySmall?.copyWith(
        height: 1.5,
        color: textColor,
        fontWeight: FontWeight.w400,
        fontSize: fontSize,
      ),
    );
  }
}

Widget customTextFormField(BuildContext context, String formValue, String labelText, String errorText, functionSetState) {
  TextTheme textTheme = Theme.of(context).textTheme;
  double fontSize = Responsive.isMobile(context) ? 13 : Responsive.isTablet(context) ? 14 : 16;
  return TextFormField(
    decoration: InputDecoration(
      labelText: labelText,
      errorStyle: TextStyle(height: 0.01),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.0),
        borderSide: BorderSide(
          color: AppColors.greyUltraLight,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.0),
        borderSide: BorderSide(
          color: AppColors.greyUltraLight,
          width: 1.0,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.0),
        borderSide: BorderSide(
          color: AppColors.greyUltraLight,
          width: 1.0,
        ),
      ),
    ),
    style: textTheme.bodySmall?.copyWith(
      color: AppColors.greyDark,
      fontWeight: FontWeight.w400,
      fontSize: fontSize,
    ),
    initialValue: formValue,
    validator: (value) =>
    value!.isNotEmpty ? null : errorText,
    onSaved: (String? val) => functionSetState(val),
    textCapitalization: TextCapitalization.sentences,
    keyboardType: TextInputType.name,
  );
}

Widget customTextFormMultiline(BuildContext context, String formValue, String labelText, String errorText, functionSetState, int? maxLength) {
  TextTheme textTheme = Theme.of(context).textTheme;
  return TextFormField(
    maxLength: maxLength,
    keyboardType: TextInputType.multiline,
    decoration: InputDecoration(
      filled: true,
      fillColor: Colors.white,
      labelText: labelText,
      focusColor: AppColors.primaryColor,
      labelStyle: textTheme.bodyLarge?.copyWith(
        color: AppColors.greyDark,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.0),
        borderSide: const BorderSide(
          color: AppColors.greyUltraLight,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.0),
        borderSide: const BorderSide(
          color: AppColors.greyUltraLight,
          width: 1.0,
        ),
      ),
    ),
    initialValue: formValue,
    validator: (value) {
      if (value!.isEmpty) {
        return errorText;
      } else if (value.length < 100) {
        return 'El texto debe tener al menos 100 caracteres';
      }
      return null;
    },
    onSaved: (String? val) => functionSetState(val),
    textCapitalization: TextCapitalization.sentences,
    minLines: 3,
    maxLines: 3,
    style: textTheme.bodyMedium?.copyWith(
      color: AppColors.greyDark,
    ),
  );
}