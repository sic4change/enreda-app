import 'package:enreda_app/app/home/models/dedication.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../services/database.dart';
import '../../../utils/adaptive.dart';
import '../../../values/strings.dart';
import '../../../values/values.dart';

Widget streamBuilderDropdownDedication (BuildContext context, Dedication? selectedDedication,  functionToWriteBackThings ) {
  final database = Provider.of<Database>(context, listen: false);
  TextTheme textTheme = Theme.of(context).textTheme;
  double fontSize = responsiveSize(context, 14, 16, md: 15);
  return StreamBuilder<List<Dedication>>(
      stream: database.dedicationStream(),
      builder: (context, snapshotDedications){

        List<DropdownMenuItem<Dedication>> dedicationItems = [];
        if (snapshotDedications.hasData) {
          dedicationItems = snapshotDedications.data!.map((Dedication dedication) =>
              DropdownMenuItem<Dedication>(
                value: dedication,
                child: Text(dedication.label),
              ))
              .toList();
        }

        return DropdownButtonFormField<Dedication>(
          hint: Text(StringConst.FORM_DEDICATION, maxLines: 2, overflow: TextOverflow.ellipsis),
          isDense: false,
          isExpanded: true,
          value: selectedDedication,
          items: dedicationItems,
          validator: (value) => selectedDedication != null ? null : StringConst.FORM_MOTIVATION_ERROR,
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