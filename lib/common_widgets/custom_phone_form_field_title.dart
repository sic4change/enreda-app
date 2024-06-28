import 'package:country_code_picker/country_code_picker.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomPhoneFormFieldTitle extends StatelessWidget {
  const CustomPhoneFormFieldTitle({
    super.key,
    required this.phoneCode,
    required this.labelText,
    this.fontSize = 14.0,
    this.initialValue,
    this.validator,
    this.onSaved,
    this.onCountryChange,

  });

  final String labelText;
  final String phoneCode;
  final double fontSize;
  final String? initialValue;
  final String ?Function(String?)? validator;
  final Function(String?)? onSaved;
  final Function(CountryCode)? onCountryChange;

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
        Container(
          height: 50,
          child: TextFormField(
            decoration: InputDecoration(
              //labelText: 'Teléfono fijo',
              filled: true,
              fillColor: Colors.white,
              prefixIcon: CountryCodePicker(
                dialogSize: Size(350.0, MediaQuery.of(context).size.height * 0.6),
                onChanged: onCountryChange,
                initialSelection: 'ES',
                showFlagDialog: true,
              ),
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
            ),
            initialValue: initialValue,
            validator: validator,
            onSaved: onSaved,
            textCapitalization: TextCapitalization.sentences,
            keyboardType: TextInputType.phone,
            style: textTheme.bodySmall?.copyWith(
              height: 1.5,
              color: AppColors.greyDark,
              fontWeight: FontWeight.w400,
              fontSize: fontSize,
            ),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
            ],
          ),
        ),
      ],
    );
  }

}
