import 'package:enreda_app/app/home/models/education.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/adaptive.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddEducationalLevel extends StatefulWidget {
  const AddEducationalLevel({super.key});

  @override
  State<AddEducationalLevel> createState() => _AddEducationalLevelState();
}

class _AddEducationalLevelState extends State<AddEducationalLevel> {
  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    TextTheme textTheme = Theme.of(context).textTheme;
    double fontSize = responsiveSize(context, 14, 16, md: 15);
    return StatefulBuilder(builder: (context, setState) {
      return Card(
          elevation: 0,
          color: Colors.white,
          child: StreamBuilder<List<Education>>(
            stream: database.educationStream(),
            builder: (context, snapshotEducation){

          List<DropdownMenuItem<Education>> educationItems = [];
          if (snapshotEducation.hasData) {
            educationItems = snapshotEducation.data!.map((Education education) =>
              DropdownMenuItem<Education>(
              value: education,
              child: Text(education.label),
              ))
                  .toList();
              }

          return Container();/*DropdownButton<Education>(
                hint: Text(StringConst.FORM_EDUCATION, maxLines: 2, overflow: TextOverflow.ellipsis),
                isExpanded: true,
                isDense: false,
                value: selectedEducation,
                items: educationItems,
                validator: (value) => selectedEducation != null ? null : StringConst.FORM_MOTIVATION_ERROR,
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
              );*/
              }));
            });
        }
      }

