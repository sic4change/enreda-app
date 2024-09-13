import 'package:enreda_app/common_widgets/expanded_row.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:flutter/material.dart';
import '../../../../../../values/values.dart';
import '../../../utils/adaptive.dart';

Widget unemployedRevisionForm(
    BuildContext context,
    String _firstName,
    String _lastName,
    String _email,
    String phone,
    String nationality,
    String genderName,
    String countryName,
    String provinceName,
    String cityName,
    String _postalCode,
    String educationName,
    String entityName,
    String specificInterestsNames,
    String interestsNames,
    String keepLearningOptionsNames,
    ){
  TextTheme textTheme = Theme.of(context).textTheme;
  double fontSize = responsiveSize(context, 14, 16, md: 15);
  return Column(
    children: [
      CustomExpandedRow(title: StringConst.FORM_NAME, text: _firstName),
      SizedBox(height: Sizes.kDefaultPaddingDouble),
      CustomExpandedRow(title: StringConst.FORM_LASTNAME, text: _lastName),
      SizedBox(height: Sizes.kDefaultPaddingDouble),
      CustomExpandedRow(title: StringConst.FORM_PHONE, text: phone),
      SizedBox(height: Sizes.kDefaultPaddingDouble),
      CustomExpandedRow(title: StringConst.FORM_CURRENT_NATIONALITY, text: nationality),
      SizedBox(height: Sizes.kDefaultPaddingDouble),
      CustomExpandedRow(title: StringConst.FORM_EMAIL, text: _email),
      SizedBox(height: Sizes.kDefaultPaddingDouble),
      CustomExpandedRow(title: StringConst.FORM_GENDER, text: genderName),
      SizedBox(height: Sizes.kDefaultPaddingDouble),
      CustomExpandedRow(title: StringConst.FORM_COUNTRY, text: countryName),
      SizedBox(height: Sizes.kDefaultPaddingDouble),
      CustomExpandedRow(title: StringConst.FORM_PROVINCE, text: provinceName),
      SizedBox(height: Sizes.kDefaultPaddingDouble),
      CustomExpandedRow(title: StringConst.FORM_CITY, text: cityName),
      SizedBox(height: Sizes.kDefaultPaddingDouble),
      CustomExpandedRow(title: StringConst.FORM_POSTAL_CODE, text: _postalCode),
      SizedBox(height: Sizes.kDefaultPaddingDouble),
      CustomExpandedRow(title: StringConst.FORM_EDUCATION_REV_CREATE, text: educationName),
      SizedBox(height: Sizes.kDefaultPaddingDouble),
      CustomExpandedRow(title: StringConst.FORM_SOCIAL_ENTITY, text: entityName),
      (interestsNames != '') ? SizedBox(height: Sizes.kDefaultPaddingDouble) : Container(),
      (interestsNames != '') ? CustomExpandedRow(title: StringConst.FORM_INTERESTS, text: interestsNames) : Container(),
      (specificInterestsNames != '') ? SizedBox(height: Sizes.kDefaultPaddingDouble) : Container(),
      (specificInterestsNames != '') ? CustomExpandedRow(title: StringConst.FORM_SPECIFIC_INTERESTS, text: specificInterestsNames) : Container(),
      (keepLearningOptionsNames != '') ? SizedBox(height: Sizes.kDefaultPaddingDouble) : Container(),
      (keepLearningOptionsNames != '') ? CustomExpandedRow(title: StringConst.FORM_GOALS, text: keepLearningOptionsNames) : Container(),
      SizedBox(height: Sizes.kDefaultPaddingDouble),
      Text(StringConst.FORM_ACCEPTANCE,
        style: textTheme.bodySmall?.copyWith(
          height: 1.5,
          color: AppColors.greyDark,
          fontWeight: FontWeight.w400,
          fontSize: fontSize,
        ),),
      SizedBox(height: Sizes.kDefaultPaddingDouble),
    ],
  );
}