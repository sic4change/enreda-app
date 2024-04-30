import 'package:enreda_app/app/home/models/education.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/adaptive.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddEducationalLevel extends StatefulWidget {
  const AddEducationalLevel({
    super.key,
    this.selectedEducation,
    required this.onSaved,
  });

  final Education? selectedEducation;
  final Function(Education? selectedEducation) onSaved;

  @override
  State<AddEducationalLevel> createState() => _AddEducationalLevelState();
}

class _AddEducationalLevelState extends State<AddEducationalLevel> {

  Education? selectedEducation;

  @override
  void initState() {
    if(widget.selectedEducation != null && widget.selectedEducation?.educationId != null){
      selectedEducation = widget.selectedEducation;
    } else{
      selectedEducation = null;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    TextTheme textTheme = Theme.of(context).textTheme;
    double fontSize = responsiveSize(context, 14, 16, md: 15);

    return StreamBuilder<List<Education>>(
        stream: database.educationStream(),
        builder: (context, snapshotEducation) {

          List<DropdownMenuItem<Education>> educationItems = [];
          if (snapshotEducation.hasData) {
            educationItems = snapshotEducation.data!.map((Education education) =>
                DropdownMenuItem<Education>(
                  value: education,
                  child: Text(education.label),
                ))
                .toList();
          }

              return AlertDialog(
                  content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (selectedEducation != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: Borders.kDefaultPaddingDouble/2),
                            child: Text(
                                StringConst.FORM_EDUCATION,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.titleMedium,
                            ),
                          ),
                        DropdownButton<Education>(
                          hint: Text(StringConst.FORM_EDUCATION, maxLines: 2, overflow: TextOverflow.ellipsis),
                          value: selectedEducation,
                          items: educationItems,
                          isExpanded: true,
                          onChanged: (value) => setState(() {
                            selectedEducation = value;
                          }),
                          iconDisabledColor: AppColors.greyDark,
                          iconEnabledColor: AppColors.primaryColor,
                          style: textTheme.button?.copyWith(
                            height: 1.5,
                            color: AppColors.greyDark,
                            fontWeight: FontWeight.w400,
                            fontSize: fontSize,
                          ),
                        ),
                      ],
                    ),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          StringConst.CANCEL,
                          style: textTheme.button?.copyWith(
                            height: 1.5,
                            color: AppColors.silver,
                            fontWeight: FontWeight.w700,
                            fontSize: fontSize,
                          ),),
                    ),
                    TextButton(
                        onPressed: () {
                          widget.onSaved(selectedEducation);
                          Navigator.pop(context);
                        },
                        child: Text(StringConst.SAVE)
                    ),
                  ],
              );
            }
          );
        }
      }

