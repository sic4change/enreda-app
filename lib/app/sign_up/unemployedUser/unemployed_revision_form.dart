import 'package:enreda_app/common_widgets/expanded_row.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:flutter/material.dart';
import '../../../../../../values/values.dart';
import '../../../utils/adaptive.dart';

Widget UnemployedRevisionForm(
    BuildContext context,
    String _firstName,
    String _lastName,
    String _email,
    String genderName,
    String countryName,
    String provinceName,
    String cityName,
    String _postalCode,
    String abilitesNames,
    String dedicationName,
    String timeSearchingName,
    String timeSpentWeeklyName,
    String educationName,
    String specificInterestsNames,
    String interestsNames,
    ){
  TextTheme textTheme = Theme.of(context).textTheme;
  double fontSize = responsiveSize(context, 14, 16, md: 15);
  return Column(
    children: [
      CustomExpandedRow(title: StringConst.FORM_NAME, text: _firstName),
      SizedBox(height: Borders.kDefaultPaddingDouble),
      CustomExpandedRow(title: StringConst.FORM_LASTNAME, text: _lastName),
      SizedBox(height: Borders.kDefaultPaddingDouble),
      CustomExpandedRow(title: StringConst.FORM_EMAIL, text: _email),
      SizedBox(height: Borders.kDefaultPaddingDouble),
      CustomExpandedRow(title: StringConst.FORM_GENDER, text: genderName),
      SizedBox(height: Borders.kDefaultPaddingDouble),
      CustomExpandedRow(title: StringConst.FORM_COUNTRY, text: countryName),
      SizedBox(height: Borders.kDefaultPaddingDouble),
      CustomExpandedRow(title: StringConst.FORM_PROVINCE, text: provinceName),
      SizedBox(height: Borders.kDefaultPaddingDouble),
      CustomExpandedRow(title: StringConst.FORM_CITY, text: cityName),
      SizedBox(height: Borders.kDefaultPaddingDouble),
      CustomExpandedRow(title: StringConst.FORM_POSTAL_CODE, text: _postalCode),
      SizedBox(height: Borders.kDefaultPaddingDouble),
      CustomExpandedRow(title: StringConst.FORM_ABILITIES_REV, text: abilitesNames),
      SizedBox(height: Borders.kDefaultPaddingDouble),
      CustomExpandedRow(title: StringConst.FORM_DEDICATION_REV, text: dedicationName),
      SizedBox(height: Borders.kDefaultPaddingDouble),
      CustomExpandedRow(title: StringConst.FORM_TIME_SEARCHING_REV, text: timeSearchingName),
      SizedBox(height: Borders.kDefaultPaddingDouble),
      CustomExpandedRow(title: StringConst.FORM_TIME_SPENT_WEEKLY_REV, text: timeSpentWeeklyName),
      SizedBox(height: Borders.kDefaultPaddingDouble),
      CustomExpandedRow(title: StringConst.FORM_EDUCATION_REV, text: educationName),
      (interestsNames != '') ? SizedBox(height: Borders.kDefaultPaddingDouble) : Container(),
      (interestsNames != '') ? CustomExpandedRow(title: StringConst.FORM_INTERESTS, text: interestsNames) : Container(),
      (specificInterestsNames != '') ? SizedBox(height: Borders.kDefaultPaddingDouble) : Container(),
      (specificInterestsNames != '') ? CustomExpandedRow(title: StringConst.FORM_SPECIFIC_INTERESTS, text: specificInterestsNames) : Container(),
      SizedBox(height: Borders.kDefaultPaddingDouble),
      Text(StringConst.FORM_ACCEPTANCE,
        style: textTheme.button?.copyWith(
          height: 1.5,
          color: AppColors.greyDark,
          fontWeight: FontWeight.w400,
          fontSize: fontSize,
        ),),
      SizedBox(height: Borders.kDefaultPaddingDouble),
    ],
  );
}