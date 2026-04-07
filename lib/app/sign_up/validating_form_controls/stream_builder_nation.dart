import 'package:enreda_app/services/location_cache.dart';
import 'package:enreda_app/utils/adaptive.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';

Widget streamBuilderForNation(BuildContext context, String? selectedNation, functionToWriteBackThings, String title, String? nationalityName) {
  TextTheme textTheme = Theme.of(context).textTheme;
  double fontSize = responsiveSize(context, 14, 16, md: 15);
  return Builder(
      builder: (context){
        final nations = LocationCache.instance.nations;
        List<DropdownMenuItem<String>> nationItems = nations.map((String nation) {
            if (selectedNation == null && nation == nationalityName) {
              selectedNation = nation;
            }
            return DropdownMenuItem<String>(
              value: nation,
              child: Text(nation),
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
                title,
                style: textTheme.bodySmall?.copyWith(
                  height: 1.5,
                  color: AppColors.greyDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
            DropdownButtonFormField(
              value: selectedNation,
              isExpanded: true,
              items: nationItems,
              onChanged: (value) => functionToWriteBackThings(value),
              validator: (value) => selectedNation != null ? null : StringConst.FORM_FIELD_ERROR,
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