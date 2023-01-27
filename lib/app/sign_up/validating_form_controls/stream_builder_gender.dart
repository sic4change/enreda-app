import 'package:enreda_app/app/home/models/gender.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../services/database.dart';
import '../../../utils/adaptive.dart';
import '../../../values/values.dart';

Widget streamBuilder_Dropdown_Genders (BuildContext context, Gender? selectedGender,  functionToWriteBackThings ) {
  final database = Provider.of<Database>(context, listen: false);
  TextTheme textTheme = Theme.of(context).textTheme;
  double fontSize = responsiveSize(context, 14, 16, md: 15);
  return StreamBuilder<List<Gender>>(
      stream: database.genderStream(),
      builder: (context, snapshotGenders){

        List<DropdownMenuItem<Gender>> genderItems = [];
        if(snapshotGenders.hasData) {
          genderItems = snapshotGenders.data!.map((Gender gender) =>
              DropdownMenuItem<Gender>(
                value: gender,
                child: Text(gender.name),
              ))
              .toList();
        }

        return DropdownButtonFormField<Gender>(
          hint: Text(StringConst.FORM_GENDER),
          isExpanded: true,
          value: selectedGender,
          items: genderItems,
          validator: (value) => selectedGender != null ? null : StringConst.FORM_GENDER_ERROR,
          onChanged: (value) => functionToWriteBackThings(value),
          iconDisabledColor: AppColors.greyDark,
          iconEnabledColor: AppColors.primaryColor,
          decoration: InputDecoration(
            labelStyle: textTheme.button?.copyWith(
              height: 1.5,
              color: AppColors.greyDark,
              fontWeight: FontWeight.w400,
              fontSize: fontSize,
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
          style: textTheme.button?.copyWith(
            height: 1.5,
            fontWeight: FontWeight.w400,
            color: AppColors.greyDark,
            fontSize: fontSize,
          ),
        );
      });
}