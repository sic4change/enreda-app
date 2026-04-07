import 'package:enreda_app/app/home/models/timeSearching.dart';
import 'package:enreda_app/services/location_cache.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:flutter/material.dart';
import '../../../utils/adaptive.dart';
import '../../../values/values.dart';

Widget streamBuilderDropdownTimeSearching (BuildContext context, TimeSearching? selectedTimeSearching,  functionToWriteBackThings ) {
  TextTheme textTheme = Theme.of(context).textTheme;
  double fontSize = responsiveSize(context, 14, 16, md: 15);
  return Builder(
      builder: (context){
        final timeSearchings = LocationCache.instance.timeSearchings;
        List<DropdownMenuItem<TimeSearching>> timeSearchingItems = timeSearchings.map((TimeSearching timeSearching) =>
              DropdownMenuItem<TimeSearching>(
                value: timeSearching,
                child: Text(timeSearching.label),
              ))
              .toList();

        return DropdownButtonFormField<TimeSearching>(
          hint: Text(StringConst.FORM_TIME_SEARCHING, maxLines: 2, overflow: TextOverflow.ellipsis),
          isExpanded: true,
          isDense: false,
          value: selectedTimeSearching,
          items: timeSearchingItems,
          validator: (value) => selectedTimeSearching != null ? null : StringConst.FORM_MOTIVATION_ERROR,
          onChanged: (value) => functionToWriteBackThings(value),
          iconDisabledColor: AppColors.greyDark,
          iconEnabledColor: AppColors.primaryColor,
          decoration: InputDecoration(
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