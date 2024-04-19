import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomDatePickerTitle extends StatelessWidget {
  const CustomDatePickerTitle({
    super.key,
    required this.labelText,
    this.fontSize = 14.0,
    this.onChanged,
    this.hintText,
    this.validator,
    this.initialValue,
    this.enabled,

  });
  final String labelText;
  final double fontSize;
  final Function(DateTime?)? onChanged;
  final String? hintText;
  final String ?Function(DateTime?)? validator;
  final DateTime? initialValue;
  final bool? enabled;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 15,
                  color: Colors.black,
                ),
                SpaceW12(),
                Text(
                  labelText,
                  style: textTheme.bodySmall?.copyWith(
                    height: 1.5,
                    color: AppColors.greyDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          DateTimeField(
            initialValue: initialValue,
            enabled: enabled ?? true,
            onChanged: onChanged,
            validator: validator,
            format: DateFormat('dd/MM/yyyy'),
            decoration: InputDecoration(
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
            style: textTheme.bodySmall?.copyWith(
              height: 1.5,
              color: AppColors.greyDark,
              fontWeight: FontWeight.w400,
              fontSize: fontSize,
            ),
            onShowPicker: (context, currentValue) {
              return showDatePicker(
                context: context,
                locale: Locale('es', 'ES'),
                firstDate: DateTime(DateTime.now().year - 100, DateTime.now().month, DateTime.now().day),
                initialDate: currentValue ?? DateTime.now(),
                lastDate: DateTime(DateTime.now().year + 100, DateTime.now().month, DateTime.now().day),
              );
            },
          ),
        ]
    );
  }
}