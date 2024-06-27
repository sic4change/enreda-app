import 'package:enreda_app/app/home/models/education.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../services/database.dart';
import '../../../utils/adaptive.dart';
import '../../../values/values.dart';

Widget streamBuilderDropdownEducation(BuildContext context, Education? selectedEducation,  functionToWriteBackThings, genericType, String title) {
  final database = Provider.of<Database>(context, listen: false);
  TextTheme textTheme = Theme.of(context).textTheme;
  double fontSize = responsiveSize(context, 14, 16, md: 15);
  return StreamBuilder<List<Education>>(
      stream: database.educationStream(),
      builder: (context, snapshotEducation){

        List<DropdownMenuItem<Education>> educationItems = [];
        if (snapshotEducation.hasData) {
          educationItems = snapshotEducation.data!.map((Education education) {
            if (selectedEducation == null && education.educationId == genericType?.educationId) {
              selectedEducation = education;
            }
            return DropdownMenuItem<Education>(
              value: education,
              child: Text(education.label),
            );
          })
              .toList();
        }
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  StringConst.FORM_EDUCATION,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
                isExpanded: true,
                value: selectedEducation,
                items: educationItems,
                onChanged: (value) => functionToWriteBackThings(value),
                validator: (value) => selectedEducation != null ? null : StringConst.FORM_MOTIVATION_ERROR,
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
                  height: 1.4,
                  color: AppColors.greyDark,
                  fontWeight: FontWeight.w400,
                  fontSize: fontSize,
                ),
              ),
            ]
        );
      });
}