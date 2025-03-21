import 'package:enreda_app/app/home/curriculum/experience_form.dart';
import 'package:enreda_app/app/home/models/experience.dart';
import 'package:enreda_app/common_widgets/delete_button.dart';
import 'package:enreda_app/common_widgets/edit_button.dart';
import 'package:enreda_app/common_widgets/show_custom_dialog.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/services/database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ExperienceTile extends StatelessWidget {
  const ExperienceTile({Key? key, required this.experience, this.onTap})
      : super(key: key);
  final Experience experience;
  final VoidCallback? onTap;

  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    final textTheme = Theme.of(context).textTheme;
    final DateFormat formatter = DateFormat('yyyy-MM-dd');

    String endDate = experience.endDate != null
        ? formatter.format(experience.endDate!.toDate())
        : 'Actualmente';

    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
            if (experience.activity != null && experience.activityRole != null)
              RichText(
                text: TextSpan(
                    text: '${experience.activityRole!.toUpperCase()} -',
                    style: textTheme.bodyText1?.copyWith(
                      fontSize: 14.0,
                    ),
                    children: [
                      TextSpan(
                        text: ' ${experience.activity!.toUpperCase()}',
                        style: textTheme.bodyText1?.copyWith(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ]),
              ),
            if (experience.activity != null && experience.activityRole == null)
              Text('${experience.activity!}',
                  style: textTheme.bodyText1
                      ?.copyWith(fontSize: 14.0, fontWeight: FontWeight.bold)),
            if (experience.activity != null) SpaceH8(),
            Text(
              '${formatter.format(experience.startDate.toDate())} / $endDate',
              style: textTheme.bodyText1?.copyWith(
                fontSize: 14.0,
              ),
            ),
            SpaceH8(),
            Text(
              experience.location,
              style: textTheme.bodyText1?.copyWith(
                fontSize: 14.0,
              ),
            ),
            /*
                    Text('${experience.type}'),
                    SpaceH12(),
                    if (experience.subtype != null) Text(experience.subtype!),
                    if (experience.subtype != null) SpaceH12(),
                    */
            // TODO: Profession activities
            /*
                    if (experience.peopleAffected != null)
                      Text(experience.peopleAffected!),
                    if (experience.peopleAffected != null) SpaceH12(),
                    if (experience.organization != null) Text(experience.organization!),
                    if (experience.organization != null) SpaceH12(),

                    Text(experience.workType),
                    SpaceH12(),
                    Text(experience.context),
                    SpaceH12(),
                    Text(experience.contextPlace),
                    SpaceH12(),
                    */
        ],
      ),
          ),

          EditButton(
            onTap: () {
              showCustomDialog(
                context,
                content: ExperienceForm(
                  experience: experience,
                  isEducation: experience.type == 'Formativa',
                ),
              );
            },
          ),
          SpaceW12(),
          DeleteButton(
            onTap: () {
              showCustomDialog(context,
                  content: Text(
                      '¿Quieres eliminar esta ${experience.type == 'Formativa' ? 'formación' : 'experiencia'}?', style: textTheme.bodyText1,),
                  defaultActionText: 'Eliminar',
                  cancelActionText: 'Cancelar',
                  onDefaultActionPressed: (dialogContext) {
                database.deleteExperience(experience);
                showCustomDialog(dialogContext,
                    content: Text(
                        'La ${experience.type == 'Formativa' ? 'formación' : 'experiencia'} ha sido eliminada de tu CV', style: textTheme.bodyText1,),
                    defaultActionText: 'Ok',
                    onDefaultActionPressed: (dialog2Context) {
                  Navigator.of(dialog2Context).pop();
                  Navigator.of(dialog2Context).pop();
                });
              });
            },
          ),
          SpaceW8()
        ],
      ),
    );
  }
}
