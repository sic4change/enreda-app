import 'package:enreda_app/app/home/models/timeSearching.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../services/database.dart';
import '../../../utils/adaptive.dart';
import '../../../values/values.dart';

Widget streamBuilderDropdownTimeSearching (BuildContext context, TimeSearching? selectedTimeSearching,  functionToWriteBackThings ) {
  final database = Provider.of<Database>(context, listen: false);
  TextTheme textTheme = Theme.of(context).textTheme;
  double fontSize = responsiveSize(context, 14, 16, md: 15);
  return StreamBuilder<List<TimeSearching>>(
      stream: database.timeSearchingStream(),
      builder: (context, snapshotTimeSearching){

        List<DropdownMenuItem<TimeSearching>> timeSearchingItems = [];
        if (snapshotTimeSearching.hasData) {
          timeSearchingItems = snapshotTimeSearching.data!.map((TimeSearching timeSearching) =>
              DropdownMenuItem<TimeSearching>(
                value: timeSearching,
                child: Text(timeSearching.label),
              ))
              .toList();
        }

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