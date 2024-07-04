import 'package:enreda_app/app/home/curriculum/experience_form_update.dart';
import 'package:enreda_app/app/home/curriculum/formation_form.dart';
import 'package:enreda_app/app/home/models/experience.dart';
import 'package:enreda_app/common_widgets/custom_text.dart';
import 'package:enreda_app/common_widgets/delete_button.dart';
import 'package:enreda_app/common_widgets/edit_button.dart';
import 'package:enreda_app/common_widgets/show_custom_dialog.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../anallytics/analytics.dart';

class ExperienceTile extends StatelessWidget {
  const ExperienceTile({Key? key, required this.experience, required this.type})
      : super(key: key);
  final Experience experience;
  final String type;

  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final DateFormat formatter = DateFormat('yyyy');
    bool dismissible = true;
    String startDate = experience.startDate != null ? formatter.format(experience.startDate!.toDate()) : '-';
    String endDate = experience.endDate != null ? formatter.format(experience.endDate!.toDate()) : 'Actualmente';

    return Row(
      children: [
        Expanded(
          child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
          if (experience.activity != null && experience.activityRole != null && experience.type != 'Formativa' && experience.type != 'Complementaria')
            RichText(
              text: TextSpan(
                  text: '${experience.activityRole?.toUpperCase()} -',
                  style: textTheme.bodySmall?.copyWith(
                  ),
                  children: [
                    TextSpan(
                      text: ' ${experience.activity?.toUpperCase()}',
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ]),
            ),

          if((experience.type == 'Formativa' || experience.type == 'Complementaria') && experience.institution != '' && experience.nameFormation != '')
            RichText(
              text: TextSpan(
                  text: '${experience.institution?.toUpperCase()} -',
                  style: textTheme.bodySmall?.copyWith(
                  ),
                  children: [
                    TextSpan(
                      text: ' ${experience.nameFormation?.toUpperCase()}',
                      style: textTheme.bodySmall?.copyWith(
                      ),
                    )
                  ]),
            ),
          if(experience.subtype == 'Responsabilidades familiares' || experience.subtype == 'Compromiso social')
            Text(
              '${experience.subtype?.toUpperCase()}',
              style: textTheme.bodySmall?.copyWith(
              ),
            ),
          if(experience.subtype == 'Otro' && experience.position != null)
            Text(
              '${experience.position}',
              style: textTheme.bodySmall?.copyWith(
                fontSize: 14.0,
              ),
            ),
          if(experience.subtype == 'Otro' && experience.position == null)
            Container(),
          if (experience.activity != null && experience.activityRole == null)
            Text( experience.position == null || experience.position == "" ? '${experience.activity?.toUpperCase()}' : '${experience.position?.toUpperCase()} - ${experience.activity?.toUpperCase()}',
                style: textTheme.bodySmall
                    ?.copyWith()),
          if (experience.position != null || experience.activity != null) SpaceH8(),
          if (experience.organization != null && experience.organization != "") Column(
            children: [
              Text(
                experience.organization!,
                style: textTheme.bodySmall?.copyWith(
                ),
              ),
              SpaceH8()
            ],
          ),
          Text(
            '$startDate / $endDate',
            style: textTheme.bodySmall?.copyWith(),
          ),
          SpaceH8(),

          if((experience.type == 'Formativa' || experience.type == 'Complementaria') && experience.extraData != '')
            Column(
              children: [
                Text(
                  experience.extraData!,
                  style: textTheme.bodySmall?.copyWith(
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SpaceH8(),
              ],
            ),

          Text(
            experience.location,
            style: textTheme.bodySmall?.copyWith(
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
          onTap: () => {
            showCustomDialog(context,
                content: Container(
                  width: Responsive.isMobile(context) ? MediaQuery.of(context).size.width : MediaQuery.of(context).size.width * 0.3,
                  child: CustomTextMediumBold(
                      text: '¿Quieres eliminar esta ${experience.type == 'Formativa' ? 'formación' : 'experiencia'}?'),
                ),
                defaultActionText: 'Eliminar',
                cancelActionText: 'Cancelar',
                onDefaultActionPressed: (context) {
                  _deleteExperience(context,experience);
                  Navigator.of(context).pop();
                }
            )},
        ),
        SpaceW12()
      ],
    );
  }

  Future<void> _deleteExperience(BuildContext context, Experience experience) async {
    try {
      final database = Provider.of<Database>(context, listen: false);
      sendBasicAnalyticsEvent(context, "enreda_app_updated_cv");
      await database.deleteExperience(experience);
    } catch (e) {
      print(e.toString());
    }
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
