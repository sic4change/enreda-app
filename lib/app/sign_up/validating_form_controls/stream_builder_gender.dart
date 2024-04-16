import 'package:enreda_app/app/home/models/gender.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../services/database.dart';
import '../../../utils/adaptive.dart';
import '../../../values/values.dart';

Widget streamBuilder_Dropdown_Genders (BuildContext context, Gender? selectedGender,  functionToWriteBackThings, String? gender ) {
  final database = Provider.of<Database>(context, listen: false);
  TextTheme textTheme = Theme.of(context).textTheme;
  double fontSize = responsiveSize(context, 14, 16, md: 15);
  return StreamBuilder<List<Gender>>(
      stream: database.genderStream(),
      builder: (context, snapshotGenders){

        List<DropdownMenuItem<Gender>> genderItems = [];
        if(snapshotGenders.hasData) {
          if(gender != null) {
            selectedGender =
                snapshotGenders.data!.firstWhere((element) => element.name == gender);
          }
          genderItems = snapshotGenders.data!.map((Gender gender) =>
              DropdownMenuItem<Gender>(
                value: gender,
                child: Text(gender.name),
              ))
              .toList();
        }

        return Column(
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
                isDense: true,
                value: selectedGender,
                items: genderItems,
                onChanged: (value) => functionToWriteBackThings(value),
                validator: (value) => selectedGender != null ? null : StringConst.FORM_GENDER_ERROR,
                decoration: InputDecoration(
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
              ),
            ]
        );
      });
}