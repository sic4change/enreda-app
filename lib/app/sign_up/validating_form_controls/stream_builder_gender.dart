import 'package:enreda_app/app/home/models/gender.dart';
import 'package:enreda_app/services/location_cache.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:flutter/material.dart';
import '../../../utils/adaptive.dart';
import '../../../values/values.dart';

Widget streamBuilder_Dropdown_Genders(BuildContext context, Gender? selectedGender,  functionToWriteBackThings, String? genderName ) {
  TextTheme textTheme = Theme.of(context).textTheme;
  double fontSize = responsiveSize(context, 14, 16, md: 15);
  return Builder(
      builder: (context){
        final genders = LocationCache.instance.genders;
        List<DropdownMenuItem<Gender>> genderItems = genders.map((Gender gender) {
            if (selectedGender == null && gender.name == genderName) {
              selectedGender = gender;
            }
            return DropdownMenuItem<Gender>(
              value: gender,
              child: Text(gender.name),
            );
          })
              .toList();

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                StringConst.FORM_GENDER,
                style: textTheme.bodySmall?.copyWith(
                  height: 1.5,
                  color: AppColors.greyDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
            DropdownButtonFormField(
              value: selectedGender,
              isExpanded: true,
              items: genderItems,
              onChanged: (value) => functionToWriteBackThings(value),
              validator: (value) => selectedGender != null ? null : StringConst.FORM_FIELD_ERROR,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.all(5),
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
            ),
          ],
        );
      });
}