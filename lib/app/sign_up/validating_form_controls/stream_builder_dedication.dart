import 'package:enreda_app/app/home/models/dedication.dart';
import 'package:enreda_app/common_widgets/custom_text.dart';
import 'package:enreda_app/services/location_cache.dart';
import 'package:flutter/material.dart';
import '../../../utils/adaptive.dart';
import '../../../values/strings.dart';
import '../../../values/values.dart';

Widget streamBuilderDropdownDedication (BuildContext context, Dedication? selectedDedication,  functionToWriteBackThings ) {
  TextTheme textTheme = Theme.of(context).textTheme;
  double fontSize = responsiveSize(context, 14, 16, md: 15);
  return Builder(
      builder: (context){
        final dedications = LocationCache.instance.dedications;
        List<DropdownMenuItem<Dedication>> dedicationItems = dedications.map((Dedication dedication) =>
              DropdownMenuItem<Dedication>(
                value: dedication,
                child: Text(dedication.label),
              ))
              .toList();

        return DropdownButtonFormField<Dedication>(
          isDense: true,
          isExpanded: true,
          value: selectedDedication,
          items: dedicationItems,
          validator: (value) => selectedDedication != null ? null : StringConst.FORM_MOTIVATION_ERROR,
          onChanged: (value) => functionToWriteBackThings(value),
          iconDisabledColor: AppColors.greyDark,
          iconEnabledColor: AppColors.primaryColor,
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            labelStyle: textTheme.bodySmall?.copyWith(
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
          style: textTheme.bodySmall?.copyWith(
            height: 1.5,
            color: AppColors.greyDark,
            fontWeight: FontWeight.w400,
            fontSize: fontSize,
          ),
        );
      });
}