
import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

Widget customDatePicker(BuildContext context, DateTime? time, String labelText, String errorText, functionSetState) {
  TextTheme textTheme = Theme.of(context).textTheme;
  double fontSize = Responsive.isMobile(context) ? 13 : Responsive.isTablet(context) ? 14 : 16;
  return DateTimeField(
    initialValue: time ?? null,
    format: DateFormat('dd/MM/yyyy'),
    decoration: InputDecoration(
      prefixIcon: const Icon(Icons.calendar_today),
      labelText: labelText,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      labelStyle: textTheme.bodyLarge?.copyWith(
        height: 1.5,
        color: AppColors.greyDark,
        fontWeight: FontWeight.w400,
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
    style: textTheme.bodyMedium?.copyWith(
      height: 1.5,
      color: AppColors.greyDark,
      fontWeight: FontWeight.w600,
      fontSize: fontSize,
    ),
    onShowPicker: (context, currentValue) {
      return showDatePicker(
        context: context,
        locale: Locale('es', 'ES'),
        firstDate: DateTime(DateTime.now().year - 100, DateTime.now().month, DateTime.now().day),
        initialDate: currentValue ?? DateTime.now(),
        lastDate: DateTime(DateTime.now().year + 100, DateTime.now().month, DateTime.now().day),
        initialEntryMode: DatePickerEntryMode.calendarOnly,
      );
    },
    onSaved: (dateTime) => functionSetState(dateTime),
    validator: (value) => value != null ? null : errorText,
  );
}

Widget customTextFormFieldNum(BuildContext context, String formValue, String labelText, String errorText, functionSetState) {
  TextTheme textTheme = Theme.of(context).textTheme;
  double fontSize = Responsive.isMobile(context) ? 13 : Responsive.isTablet(context) ? 14 : 16;
  return TextFormField(
    decoration: InputDecoration(
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
    initialValue: formValue.toString(),
    validator: (value) =>
    value!.isNotEmpty ? null : errorText,
    inputFormatters: <TextInputFormatter>[
      FilteringTextInputFormatter.digitsOnly
    ],
    onSaved: (String? val) => functionSetState(val),
    textCapitalization: TextCapitalization.sentences,
    keyboardType: TextInputType.number,
    style: textTheme.bodyMedium?.copyWith(
      color: AppColors.greyDark,
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
    ),
  );
}