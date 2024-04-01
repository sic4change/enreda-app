import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';
import 'package:enreda_app/app/home/models/education.dart';
import 'package:enreda_app/app/home/models/experience.dart';
import 'package:enreda_app/common_widgets/custom_text.dart';
import 'package:enreda_app/common_widgets/show_alert_dialog.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/adaptive.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../common_widgets/flex_row_column.dart';
import '../../anallytics/analytics.dart';
import '../../sign_up/validating_form_controls/stream_builder_education.dart';
import '../models/activity.dart';

class FormationForm extends StatefulWidget {
  const FormationForm({
    Key? key,
    this.experience,
    required this.isMainEducation,
    this.onComingBack,
  })
      : super(key: key);

  final Experience? experience;
  final bool isMainEducation;
  final VoidCallback? onComingBack;

  @override
  State<FormationForm> createState() => _FormationFormState();
}

class _FormationFormState extends State<FormationForm> {
  late String _type;
  final _nameFormationController = TextEditingController();
  final _organizationController = TextEditingController();
  //EducationLevel
  Education? _selectedEducation;
  String? _institution;
  Timestamp? _startDate, _endDate;
  List<DropdownMenuItem<Education>> educationItems = [];
  final _locationController = TextEditingController();
  final  _extraDataController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final _experience = widget.experience;
    if(widget.isMainEducation){
      _type = 'Formativa';
    }else{
      _type = 'Complementaria';
    }
    if (_experience != null) {
      _nameFormationController.text = _experience.nameFormation ?? '';
      _organizationController.text = _experience.organization ?? '';
      _institution = _experience.institution ?? '';
      _startDate = _experience.startDate;
      _endDate = _experience.endDate;
      _locationController.text = _experience.location;
      _extraDataController.text = _experience.extraData ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);

    return StatefulBuilder(builder: (context, setState) {
      return Card(
        elevation: 0,
        color: Colors.white,
        child: StreamBuilder<List<Education>>(
          stream: database.educationStream(),
            builder: (context, snapshotEducation){

            if (snapshotEducation.hasData) {
            educationItems = snapshotEducation.data!.map((Education education) =>
              DropdownMenuItem<Education>(
              value: education,
              child: Text(education.label),
              ))
                  .toList();

            if(widget.experience != null && widget.experience!.education != '' && _selectedEducation == null){
              educationItems.forEach((element) {
                if(element.value!.label == widget.experience!.education){
                  _selectedEducation = element.value;
                } else{
                  _selectedEducation = null;
                }
              });
            }
            }

            return _buildForm(context, setState);
            })
      );
    });
  }

  Form _buildForm(BuildContext context, StateSetter setState) {
    final textTheme = Theme.of(context).textTheme;
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            formFieldCustom(CustomTextTitle(title: widget.isMainEducation ?
            StringConst.EDUCATION.toUpperCase() :
            StringConst.SECONDARY_EDUCATION.toUpperCase())),

            formFieldCustom(
              TextFormField(
                controller: _nameFormationController,
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                    label: Text(
                      'Nombre de la formación',
                      style: textTheme.bodyMedium,
                    )),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'El nombre de la formación es un campo obligatorio';
                  return null;
                },
              ),
            ),

        !widget.isMainEducation ? Container() :
        formFieldCustom(
          DropdownButtonFormField<Education>(
            hint: Text(StringConst.EDUCATIONAL_LEVEL, maxLines: 2, overflow: TextOverflow.ellipsis),
            isExpanded: true,
            isDense: false,
            value: _selectedEducation,
            items: educationItems,
            validator: (value) => _selectedEducation != null ? null : StringConst.FORM_MOTIVATION_ERROR,
            onChanged: (value) => setState(() {
              _selectedEducation = value;
            }),
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),

            formFieldCustom(
              DropdownButtonFormField<String>(
                hint: Text('Institución educativa',
                    style: textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                style:
                textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                isExpanded: true,
                isDense: false,
                value: _institution == '' ? null : _institution,
                items: StringConst.FORMATION_INSTITUTIONS
                    .map((e) =>
                    DropdownMenuItem<String>(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  _institution = value ?? _institution;
                },
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Selecciona un valor';
                  return null;
                },
              ),
            ),

            formFieldCustom(
              TextFormField(
                controller: _organizationController,
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                    label: Text(
                      'Nombre institución educativa',
                      style: textTheme.bodyMedium,
                    )),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'El nombre de la institución educativa es obligatorio';
                  return null;
                },
              ),
            ),

            CustomFlexRowColumn(
              childLeft: DateTimeField(
                initialValue: _startDate?.toDate(),
                format: DateFormat('dd/MM/yyyy'),
                decoration: InputDecoration(
                  labelText: 'Año de inicio',
                  labelStyle: textTheme.bodyMedium,
                  suffixIcon: Icon(
                    Icons.event,
                  ),
                ),
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                onShowPicker: (context, currentValue) {
                  return showDatePicker(
                    context: context,
                    locale: Locale('es', 'ES'),
                    firstDate: new DateTime(DateTime.now().year - 100,),
                    initialDate: currentValue ?? _endDate?.toDate() ?? DateTime.now(),
                    lastDate: _endDate?.toDate() ?? DateTime.now(),
                    initialEntryMode: DatePickerEntryMode.calendarOnly,
                  );
                },
                onChanged: (dateTime) {
                  setState(() => _startDate = Timestamp.fromDate(dateTime!));
                },
                validator: (value) {
                  if (value == null || value.toString().isEmpty)
                    return 'La fecha de inicio es un campo obligatorio';
                  return null;
                },
              ),
              childRight: DateTimeField(
                initialValue: _endDate?.toDate(),
                format: DateFormat('dd/MM/yyyy'),
                decoration: InputDecoration(
                  labelText: 'Año de fin',
                  labelStyle: textTheme.bodyMedium,
                  suffixIcon: Icon(
                    Icons.event,
                  ),
                ),
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                onShowPicker: (context, currentValue) {
                  return showDatePicker(
                    context: context,
                    locale: Locale('es', 'ES'),
                    firstDate: _startDate?.toDate() ?? new DateTime(DateTime.now().year - 100,),
                    initialDate: currentValue ?? DateTime.now(),
                    lastDate: DateTime.now(),
                    initialEntryMode: DatePickerEntryMode.calendarOnly,
                  );
                },
                onChanged: (dateTime) {
                  setState(() => _endDate = Timestamp.fromDate(dateTime!));
                },
                validator: (value) {
                  if (value == null || value.toString().isEmpty)
                    return 'La fecha de inicio no puede estar vacía';
                  return null;
                },
              ),
            ),

            formFieldCustom(
              TextFormField(
                controller: _locationController,
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                    label: Text(
                      'Municipio, ciudad, región o país',
                      style: textTheme.bodyMedium,
                    )),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'El Municipio, ciudad, región o país es un campo obligatorio';
                  return null;
                },
              ),
            ),

            formFieldCustom(
              TextFormField(
                controller: _extraDataController,
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                    label: Text(
                      'Datos de interés sobre la formación',
                      style: textTheme.bodyMedium,
                    )),
              ),
            ),


            SpaceH24(),
            Row(
              children: [
                Expanded(
                    child: TextButton(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: (Text(
                      StringConst.CANCEL,
                      style: textTheme.bodyMedium,
                    )),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                )),
                SpaceW24(),
                Expanded(
                    child: TextButton(
                        style: ButtonStyle(
                          backgroundColor:
                          MaterialStateProperty.all<Color>(Constants.turquoise),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: (Text(
                            StringConst.SAVE,
                            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600,
                              color: Constants.white,),
                          )),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            saveExperience();
                          }
                        })),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget formFieldCustom(Widget child){
    return Padding(
        padding: const EdgeInsets.all(Borders.kDefaultPaddingDouble / 2),
          child: SizedBox(
            width: MediaQuery.of(context).size.width/3,
            child: child,
          ),
    );
  }

  Future<void> saveExperience() async {
    final database = Provider.of<Database>(context, listen: false);
    final auth = Provider.of<AuthBase>(context, listen: false);

    if (widget.experience == null) {
      final experience = Experience(
          userId: auth.currentUser!.uid,
          type: _type,
          subtype: '',
          activity: '',
          activityRole: '',
          activityLevel: '',
          startDate: _startDate!,
          endDate: _endDate,
          organization: _organizationController.text,
          location: _locationController.text,
          workType: '',
          context: '',
          contextPlace: '',
          professionActivities: [],
          position: '',
          professionActivitiesText: '',
          nameFormation: _nameFormationController.text,
          education: widget.isMainEducation ? _selectedEducation!.label : '',
          institution: _institution,
          extraData: _extraDataController.text,

      );

      sendBasicAnalyticsEvent(context, "enreda_app_updated_cv");
      await database.addExperience(experience);
      Navigator.of(context).pop();
      await showAlertDialog(context,
            title: 'Información guardada',
            content: 'La información ha sido guardada en tu CV correctamente',
            defaultActionText: 'Ok');
      if (widget.onComingBack != null) {
        widget.onComingBack!();
      }
    } else {
      final experience = Experience(
          id: widget.experience!.id,
          userId: auth.currentUser!.uid,
          type: _type,
          subtype: '',
          activity: '',
          activityRole: '',
          activityLevel: '',
          startDate: _startDate!,
          endDate: _endDate,
          organization: _organizationController.text,
          location: _locationController.text,
          workType: '',
          context: '',
          contextPlace: '',
          position: '',
          professionActivitiesText: '',
          nameFormation: _nameFormationController.text,
          education: widget.isMainEducation ? _selectedEducation!.label : '',
          institution: _institution,
          extraData: _extraDataController.text,
      );

      sendBasicAnalyticsEvent(context, "enreda_app_updated_cv");
      await database.updateExperience(experience);
      Navigator.of(context).pop();
      await showAlertDialog(context,
          title: 'Información guardada',
          content: 'La información ha sido guardada en tu CV correctamente',
          defaultActionText: 'Ok');
    }
  }
}
