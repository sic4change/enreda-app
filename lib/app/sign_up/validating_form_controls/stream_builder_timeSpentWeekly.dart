import 'package:enreda_app/app/home/models/timeSpentWeekly.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../services/database.dart';
import '../../../utils/adaptive.dart';
import '../../../values/values.dart';

Widget streamBuilderDropdownTimeSpentWeekly (BuildContext context, TimeSpentWeekly? selectedTimeSpentWeekly,  functionToWriteBackThings ) {
  final database = Provider.of<Database>(context, listen: false);
  TextTheme textTheme = Theme.of(context).textTheme;
  double fontSize = responsiveSize(context, 14, 16, md: 15);
  return StreamBuilder<List<TimeSpentWeekly>>(
      stream: database.timeSpentWeeklyStream(),
      builder: (context, snapshotTimeSpentWeeklyStream){

        List<DropdownMenuItem<TimeSpentWeekly>> timeSpentWeeklyItems = [];
        if (snapshotTimeSpentWeeklyStream.hasData) {
          timeSpentWeeklyItems = snapshotTimeSpentWeeklyStream.data!.map((TimeSpentWeekly timeSpentWeekly) =>
              DropdownMenuItem<TimeSpentWeekly>(
                value: timeSpentWeekly,
                child: Text(timeSpentWeekly.label),
              ))
              .toList();
        }

        return DropdownButtonFormField<TimeSpentWeekly>(
          hint: Text(StringConst.FORM_TIME_SPENT_WEEKLY, maxLines: 2, overflow: TextOverflow.ellipsis),
          isExpanded: true,
          isDense: false,
          value: selectedTimeSpentWeekly,
          items: timeSpentWeeklyItems,
          validator: (value) => selectedTimeSpentWeekly != null ? null : StringConst.FORM_MOTIVATION_ERROR,
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
            color: AppColors.greyDark,
            fontWeight: FontWeight.w400,
            fontSize: fontSize,
          ),
        );
      });
}