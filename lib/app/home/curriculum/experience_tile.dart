import 'package:enreda_app/app/home/curriculum/experience_form.dart';
import 'package:enreda_app/app/home/curriculum/experience_form_update.dart';
import 'package:enreda_app/app/home/curriculum/formation_form.dart';
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
  const ExperienceTile({Key? key, required this.experience, this.onTap, required this.type})
      : super(key: key);
  final Experience experience;
  final VoidCallback? onTap;
  final String type;

  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    final textTheme = Theme.of(context).textTheme;
    final DateFormat formatter = DateFormat('yyyy');
    bool dismissible = true;
    String startDate = experience.startDate != null
        ? formatter.format(experience.startDate!.toDate())
        : 'Desconocida';
    String endDate = experience.subtype == 'Responsabilidades familiares'? 'Desconocida': experience.endDate != null
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
            if (experience.activity != null && experience.activityRole != null && experience.type != 'Formativa' && experience.type != 'Complementaria')
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


            if((experience.type == 'Formativa' || experience.type == 'Complementaria') && experience.institution != '' && experience.nameFormation != '')
              RichText(
                text: TextSpan(
                    text: '${experience.institution!.toUpperCase()} -',
                    style: textTheme.bodyText1?.copyWith(
                      fontSize: 14.0,
                    ),
                    children: [
                      TextSpan(
                        text: ' ${experience.nameFormation!.toUpperCase()}',
                        style: textTheme.bodyText1?.copyWith(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ]),
              ),
            if (experience.activity != null && experience.activityRole == null)
              Text( experience.position == null || experience.position == "" ? '${experience.activity}' : '${experience.position}',
                  style: textTheme.bodyText1
                      ?.copyWith(fontSize: 14.0, fontWeight: FontWeight.bold)),
            if (experience.position != null || experience.activity != null) SpaceH8(),
            if (experience.organization != null && experience.organization != "") Column(
              children: [
                Text(
                  experience.organization!,
                  style: textTheme.bodyText1?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                  ),
                ),
                SpaceH8()
              ],
            ),
            Text(
              '$startDate / $endDate',
              style: textTheme.bodyText1?.copyWith(
                fontSize: 14.0,
              ),
            ),
            SpaceH8(),

            if((experience.type == 'Formativa' || experience.type == 'Complementaria') && experience.extraData != '')
              Column(
                children: [
                  Text(
                    experience.extraData!,
                    style: textTheme.bodyText1?.copyWith(
                      fontSize: 14.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SpaceH8(),
                ],
              ),

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
              showDialog(
                  barrierDismissible: dismissible,
                  context: context,
                  builder: (context) => AlertDialog(
                    content: selectorEdit(type)
                    /*type == 'Formativa'? FormationForm(isMainEducation: true, experience: experience,) :
                    ExperienceForm(
                      experience: experience,
                      isEducation: experience.type == 'Formativa',
                    ),*/
                  )
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

  Widget selectorEdit(String type){
    switch(type){
      case 'Formativa':
        return FormationForm(isMainEducation: true, experience: experience);
      case 'Complementaria':
        return FormationForm(isMainEducation: false, experience: experience);
      case 'Profesional':
        return ExperienceFormUpdate(isProfesional: true, experience: experience);
      case 'Personal' :
        return ExperienceFormUpdate(isProfesional: false, experience: experience);
      default:
        return Container();
    }
  }

}
