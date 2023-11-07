import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';
import 'package:enreda_app/app/home/curriculum/experience_form_update.dart';
import 'package:enreda_app/app/home/curriculum/stream_builder_professionsActivities.dart';
import 'package:enreda_app/app/home/models/choice.dart';
import 'package:enreda_app/app/home/models/experience.dart';
import 'package:enreda_app/common_widgets/show_alert_dialog.dart';
import 'package:enreda_app/common_widgets/show_competencies.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/services/api_path.dart';
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
import '../models/activity.dart';

// TODO: ¿Esta clase no se está usando?
class ExperienceForm extends StatefulWidget {
  const ExperienceForm({Key? key, this.experience, required this.isEducation, this.isProfesional})
      : super(key: key);

  final Experience? experience;
  final bool isEducation;
  final bool? isProfesional;

  @override
  State<ExperienceForm> createState() => _ExperienceFormState();
}

class _ExperienceFormState extends State<ExperienceForm> {
  Stream<List<Choice>> _experienceActivitiesStream = Stream.empty();
  Choice? _type, _subtype, _activity, _role, _level;
  List<Choice> _experienceTypes = [],
      _experienceSubtypes = [],
      _experienceActivities = [],
      _experienceRoles = [],
      _experienceLevels = [];
  final _organizationController = TextEditingController();
  final _positionController = TextEditingController();
  final _locationController = TextEditingController();
  Timestamp? _startDate, _endDate;
  String? _workType, _context, _contextPlace;
  final _formKey = GlobalKey<FormState>();
  bool _experienceIsLoaded = false;
  Map<String, int> userCompetencies = {};

  TextEditingController _textEditingControllerProfessionsActivities = TextEditingController();
  Set<Activity> selectedProfessionActivities = {};
  List<String> professionActivities = [];
  String? _professionActivityId;
  List<String>? activitiesIds = [];
  String _otherText = "";

  @override
  void initState() {
    super.initState();
    final _experience = widget.experience;
    if (_experience != null) {
      _startDate = _experience.startDate;
      _endDate = _experience.endDate;
      _organizationController.text = _experience.organization ?? '';
      _positionController.text = _experience.position ?? '';
      _locationController.text = _experience.location;
      _textEditingControllerProfessionsActivities.text = _experience.professionActivitiesText ?? '';
      _workType = _experience.workType;
      _context = _experience.context;
      _contextPlace = _experience.contextPlace;
      _otherText = _experience.otherProfessionActivityString?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);

    return StatefulBuilder(builder: (context, setState) {
      return Card(
        elevation: 0,
        color: Colors.white,
        child: StreamBuilder<List<Choice>>(
            stream: database.choicesStream(APIPath.experienceTypes(), null, null),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                _experienceTypes = widget.isEducation
                    ? snapshot.data!
                        .where((choice) => choice.name == 'Formativa')
                        .toList()
                    : snapshot.data!
                        .where((choice) => choice.name != 'Formativa')
                        .toList();
              } else {
                _experienceTypes = [];
              }
              //_experienceTypes = snapshot.hasData ? snapshot.data! : [];

              return StreamBuilder<List<Choice>>(
                  stream: database.choicesStream(
                      APIPath.experienceSubtypes(), null, null),
                  builder: (context, snapshot) {
                    _experienceSubtypes =
                        snapshot.hasData && _type?.name == 'Personal'
                            ? snapshot.data!
                            : [];

                    return StreamBuilder<List<Choice>>(
                        stream: _experienceActivitiesStream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData &&
                              _type != null &&
                              ((_type?.name == 'Personal' && _subtype != null) ||
                                  _type?.name != 'Personal')) {
                            _experienceActivities = snapshot.data!;
                          } else {
                            _experienceActivities = [];
                          }
                          return StreamBuilder<List<Choice>>(
                              stream: database.choicesStream(
                                  APIPath.activityRoleChoices(),
                                  _type?.id,
                                  _subtype?.id),
                              builder: (context, snapshot) {
                                _experienceRoles = snapshot.hasData &&
                                        _type != null &&
                                        _subtype != null
                                    ? snapshot.data!
                                    : [];

                                return StreamBuilder<List<Choice>>(
                                    stream: database.choicesStream(
                                        APIPath.activityLevelChoices(),
                                        null,
                                        null),
                                    builder: (context, snapshot) {
                                      _experienceLevels = snapshot.hasData &&
                                              _type != null &&
                                              _subtype != null &&
                                              _subtype!.name == 'Deporte'
                                          ? snapshot.data!
                                          : [];

                                      if ((widget.experience?.activityLevel !=
                                                  null &&
                                              _level != null) ||
                                          (widget.experience?.activityRole !=
                                                  null &&
                                              _role != null) ||
                                          (widget.experience?.activity != null &&
                                              _activity != null)) {
                                        _experienceIsLoaded = true;
                                      }

                                      if (widget.experience != null &&
                                          !_experienceIsLoaded)
                                        _loadDropdowns(database);

                                      if (widget.isEducation &&
                                          _type == null &&
                                          _experienceTypes.isNotEmpty) {
                                        _type = _experienceTypes.firstWhere(
                                            (element) =>
                                                element.name == 'Formativa');
                                        _experienceActivitiesStream =
                                            database.choicesStream(
                                                APIPath.activityChoices(),
                                                _type?.id,
                                                _subtype?.id);
                                      }

                                      return _buildForm(context, setState);
                                    });
                              });
                        });
                  });
            }),
      );
    });
  }

  Form _buildForm(BuildContext context, StateSetter setState) {
    final database = Provider.of<Database>(context, listen: false);
    final textTheme = Theme.of(context).textTheme;
    double fontSize = responsiveSize(context, 15, 16, md: 15);
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            CustomFlexRowColumn(
              childLeft: _buildTypeDropdown(database, setState),
              childRight: _buildActivityDropdown(database, setState),
            ),
            _type?.name == 'Personal' ?
            CustomFlexRowColumn(
              childLeft:  _buildSubtypeDropdown(database, setState),
              childRight: _buildRoleDropdown(setState),
            ) : Container(),
            CustomFlexRowColumn(
              childLeft: _type?.name == 'Profesional' ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      controller: _textEditingControllerProfessionsActivities,
                      decoration: InputDecoration(
                        hintText: 'Indica las tareas que realizaste *',
                        hintMaxLines: 2,
                        label: Text(
                          'Tareas que realizaste',
                          style: textTheme.bodyText2,
                        ),
                        labelStyle: textTheme.bodyText1?.copyWith(
                          color: AppColors.greyDark,
                          height: 1.5,
                          fontWeight: FontWeight.w400,
                          fontSize: fontSize,
                        ),
                      ),
                      onTap: () => _showMultiSelectProfessionActivities(context),
                      validator: (value) {
                        if (value == null || value == "") return 'Selecciona un valor';
                        return null;
                      },
                      onSaved: (value) => value = _professionActivityId,
                      maxLines: 2,
                      readOnly: true,
                      style: textTheme.button?.copyWith(
                        height: 1.5,
                        color: AppColors.greyDark,
                        fontWeight: FontWeight.w400,
                        fontSize: fontSize,
                      ),
                    ),
                  ]) : Container(),
              childRight: _type?.name == 'Profesional' ? TextFormField(
                controller: _positionController,
                style: textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  label: Text(
                    'Indica tu cargo...',
                    style: textTheme.bodyText2,
                  ),
                ),
              ) : Container(),
            ),
            CustomFlexRowColumn(
              childRight: _type?.name == 'Personal' ? _buildLevelDropdown(setState) : Container(),
              childLeft: TextFormField(
                controller: _organizationController,
                style: textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  label: Text(
                    widget.isEducation? 'Empresa, organización, instituto, universidad...':'Empresa, organización...' ,
                    style: textTheme.bodyText2,
                  ),
                ),
              ),
            ),
            CustomFlexRowColumn(
              childLeft: DateTimeField(
                initialValue: _startDate?.toDate(),
                format: DateFormat('dd/MM/yyyy'),
                decoration: InputDecoration(
                  labelText: 'Fecha inicio *',
                  labelStyle: textTheme.bodyMedium,
                  suffixIcon: Icon(
                    Icons.event,
                  ),
                ),
                style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                onShowPicker: (context, currentValue) {
                  return showDatePicker(
                    context: context,
                    locale: Locale('es', 'ES'),
                    firstDate: new DateTime(DateTime.now().year - 100,),
                    initialDate: currentValue ?? _endDate?.toDate() ?? DateTime.now(),
                    lastDate: _endDate?.toDate() ?? DateTime.now(),
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
                  labelText: 'Fecha fin',
                  labelStyle: textTheme.bodyMedium,
                  suffixIcon: Icon(
                    Icons.event,
                  ),
                ),
                style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                onShowPicker: (context, currentValue) {
                  return showDatePicker(
                    context: context,
                    locale: Locale('es', 'ES'),
                    firstDate: _startDate?.toDate() ?? new DateTime(DateTime.now().year - 100,),
                    initialDate: currentValue ?? DateTime.now(),
                    lastDate: DateTime.now(),
                  );
                },
                onChanged: (dateTime) {
                  setState(() => _endDate = Timestamp.fromDate(dateTime!));
                },
                validator: (value) {
                  if (value == null || value.toString().isEmpty)
                    return 'La fecha de nacimiento no puede estar vacía';
                  return null;
                },
              ),
            ),
            CustomFlexRowColumn(
              childLeft: TextFormField(
                  controller: _locationController,
                  style: textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                      label: Text(
                        'Municipio, ciudad, región o país *',
                        style: textTheme.bodyText2,
                      )),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'El Municipio, ciudad, región o país es un campo obligatorio';
                    return null;
                  },
                ),
              childRight: DropdownButtonFormField<String>(
                hint: Text('La mayor parte del tiempo estabas... *',
                    style: textTheme.bodyText2,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                style:
                    textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                isExpanded: true,
                isDense: false,
                value: _workType,
                items: StringConst.EXPERIENCE_WORK_TYPES
                    .map((e) =>
                        DropdownMenuItem<String>(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  _workType = value ?? _workType;
                },
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Selecciona un valor';
                  return null;
                },
              ),
            ),
            CustomFlexRowColumn(
                childLeft: DropdownButtonFormField<String>(
                  hint: Text(
                    'Sensación del ambiente de la experiencia *',
                    style: textTheme.bodyText2,
                    maxLines: 2, overflow: TextOverflow.ellipsis
                  ),
                  style: textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                  isExpanded: true,
                  isDense: false,
                  value: _context,
                  items: StringConst.EXPERIENCE_CONTEXT
                      .map((e) => DropdownMenuItem<String>(
                      value: e,
                      child: Text(
                        e,
                        style: textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                      )))
                      .toList(),
                  onChanged: (value) {
                    _context = value ?? _context;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Selecciona un valor';
                    return null;
                  },
                ),
                childRight: DropdownButtonFormField<String>(
                  hint: Text(
                      'Lugar *', style: textTheme.bodyText2
                  ),
                  style: textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                  value: _contextPlace,
                  items: StringConst.EXPERIENCE_CONTEXT_PLACES
                      .map((e) => DropdownMenuItem<String>(value: e, child: Text(e, style: textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),)))
                      .toList(),
                  onChanged: (value) {
                    _contextPlace = value ?? _contextPlace;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Selecciona un valor';
                    return null;
                  },
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
                      style: textTheme.bodyText1,
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
                            style: textTheme.bodyText1?.copyWith(fontWeight: FontWeight.w600,
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

  void _loadDropdowns(Database database) {
    if (_type == null &&
        _experienceTypes.isNotEmpty &&
        widget.experience != null) {
      try {
        _type = _experienceTypes
            .firstWhere((element) => element.name == widget.experience!.type);
      } catch (e) {
        print(e);
      }
    }

    if (_subtype == null &&
        _experienceSubtypes.isNotEmpty &&
        widget.experience != null) {
      try {
        _subtype = _experienceSubtypes.firstWhere(
            (element) => element.name == widget.experience!.subtype);
      } catch (e) {
        print(e);
      }
    }

    if (_type?.name == 'Profesional') {
      _experienceActivitiesStream =
          database.choicesStream(APIPath.professions(), null, null);

    } else {
      _experienceActivitiesStream = database.choicesStream(
          APIPath.activityChoices(), _type?.id, _subtype?.id);
    }

    if (_activity == null &&
        _experienceActivities.isNotEmpty &&
        widget.experience != null) {
      try {
        _activity = _experienceActivities.firstWhere(
            (element) => element.name == widget.experience!.activity);
      } catch (e) {
        print(e);
      }
    }

    if (_role == null &&
        _experienceRoles.isNotEmpty &&
        widget.experience != null) {
      try {
        _role = _experienceRoles.firstWhere(
            (element) => element.name == widget.experience!.activityRole);
      } catch (e) {
        print(e);
      }
    }

    if (_level == null &&
        _experienceLevels.isNotEmpty &&
        widget.experience != null) {
      try {
        _level = _experienceLevels.firstWhere(
            (element) => element.name == widget.experience!.activityLevel);
      } catch (e) {
        print(e);
      }
    }
  }

  Widget _buildTypeDropdown(
      Database database, void Function(void Function()) setState) {
    final textTheme = Theme.of(context).textTheme;

    return DropdownButtonFormField<Choice>(
      hint: Text('Tipo *', style: textTheme.bodyText1,),
      style: textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
      items: _experienceTypes
          .map((e) => DropdownMenuItem<Choice>(value: e, child: Text(e.name, style: textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),)))
          .toList(),
      value: _type,
      onChanged: widget.isEducation
          ? null
          : (newType) {
              setState(() {
                _type = newType;
                _subtype = null;
                _activity = null;
                _role = null;
                _level = null;

                if (_type?.name == 'Profesional') {
                  _experienceActivitiesStream =
                      database.choicesStream(APIPath.professions(), null, null);
                } else {
                  _experienceActivitiesStream = database.choicesStream(
                      APIPath.activityChoices(), _type?.id, _subtype?.id);
                }
              });
            },
      validator: (value) {
        if (value == null || value.name.isEmpty) return 'Selecciona un valor';
        return null;
      },
    );
  }

  Widget _buildSubtypeDropdown(
      Database database, void Function(void Function()) setState) {
    final textTheme = Theme.of(context).textTheme;

    return DropdownButtonFormField<Choice>(
        hint: Text('Subtipo', style: textTheme.bodyText1,),
        style: textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
        items: _experienceSubtypes
            .map((e) => DropdownMenuItem<Choice>(value: e, child: Text(e.name, style: textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),)))
            .toList(),
        value: _subtype,
        onChanged: (newSubtype) {
          setState(() {
            _subtype = newSubtype;
            _activity = null;
            _role = null;
            _level = null;
            _experienceActivitiesStream = database.choicesStream(
                APIPath.activityChoices(), _type?.id, _subtype?.id);
          });
        });
  }

  Widget _buildActivityDropdown(
      Database database, void Function(void Function()) setState) {
    final textTheme = Theme.of(context).textTheme;

    return DropdownButtonFormField<Choice>(
        hint: Text('Actividad', style: textTheme.bodyText1, maxLines: 2, overflow: TextOverflow.ellipsis),
        style: textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
        isExpanded: true,
        isDense: false,
        items: _experienceActivities
            .map((e) => DropdownMenuItem<Choice>(value: e, child: Text(e.name, style: textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),)))
            .toList(),
        value: _activity,
        onChanged: (newActivity) {
          setState(() {
            _activity = newActivity;
            activitiesIds =_activity?.activities;
          });
        });
  }

  void _showMultiSelectProfessionActivities(BuildContext context) async {
    final textTheme = Theme.of(context).textTheme;
    var selectedValues = await showDialog<Set<Activity>>(
      context: context,
      builder: (BuildContext context) {
        if(_activity == null)
          return AlertDialog(
            content: Text(StringConst.FORM_ACTIVITIES_EMPTY,  style: textTheme.bodyText1,),
            actions: <Widget>[
              ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(StringConst.FORM_ACCEPT, style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold))
              ),
            ],
          );
        return streamBuilderDropdownProfessionActivities(
            context,
            _activity!,
            activitiesIds!,
            selectedProfessionActivities,
            (text) => _otherText = text,
            _otherText
        );
      },
    );
    getValuesFromKeyProfessionActivities(selectedValues);
  }

  void getValuesFromKeyProfessionActivities (selectedValues) {
    var concatenate = StringBuffer();
    List<String> activitiesIds = [];
    selectedValues.forEach((item){
      concatenate.write(item.name +' / ');
      activitiesIds.add(item.id);
    });
    setState(() {
      this._textEditingControllerProfessionsActivities.text = concatenate.toString();
      this.professionActivities = activitiesIds;
      this.selectedProfessionActivities = selectedValues;
    });
  }

  Widget _buildRoleDropdown(void Function(void Function()) setState) {
    final textTheme = Theme.of(context).textTheme;

    return DropdownButtonFormField<Choice>(
        hint: Text('Rol', style: textTheme.bodyText1,),
        style: textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
        items: _experienceRoles
            .map((e) => DropdownMenuItem<Choice>(value: e, child: Text(e.name, style: textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),)))
            .toList(),
        value: _role,
        onChanged: (newRole) {
          setState(() {
            _role = newRole;
          });
        });
  }

  Widget _buildLevelDropdown(void Function(void Function()) setState) {
    final textTheme = Theme.of(context).textTheme;

    return DropdownButtonFormField<Choice>(
        hint: Text('Nivel', style: textTheme.bodyText1,),
        style: textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
        items: _experienceLevels
            .map((e) => DropdownMenuItem<Choice>(value: e, child: Text(e.name, style: textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),)))
            .toList(),
        value: _level,
        onChanged: (newLevel) {
          setState(() {
            _level = newLevel;
          });
        });
  }

  Future<void> saveExperience() async {
    final database = Provider.of<Database>(context, listen: false);
    final auth = Provider.of<AuthBase>(context, listen: false);

    if (widget.experience == null) {
      final experience = Experience(
          userId: auth.currentUser!.uid,
          type: _type!.name,
          subtype: _subtype?.name,
          activity: _activity?.name,
          activityRole: _role?.name,
          activityLevel: _level?.name,
          startDate: _startDate!,
          endDate: _endDate,
          organization: _organizationController.text,
          location: _locationController.text,
          workType: _workType!,
          context: _context!,
          contextPlace: _contextPlace!,
          professionActivities: selectedProfessionActivities.map((e) => e.id!).toList(),
          position: _positionController.text,
          professionActivitiesText: _textEditingControllerProfessionsActivities.text,
          otherProfessionActivityString: _otherText,
      );

      await database.addExperience(experience);
      _updateCompetenciesPoints(_type);
      _updateCompetenciesPoints(_subtype);
      _updateCompetenciesPoints(_activity);
      _updateCompetenciesPoints(_role);
      _updateCompetenciesPoints(_level);
      _updateListCompetenciesPoints(selectedProfessionActivities);
      // TODO: Update competencies of other fields (in assistant_page too)
      await showCompetencies(context, userCompetencies: userCompetencies,
          onDismiss: (dialogContext) async {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        await showAlertDialog(context,
            title: 'Información guardada',
            content: 'La información ha sido guardada en tu CV correctamente',
            defaultActionText: 'Ok');
      });
    } else {
      final experience = Experience(
          id: widget.experience!.id,
          userId: auth.currentUser!.uid,
          type: _type!.name,
          subtype: _subtype?.name,
          activity: _activity?.name,
          activityRole: _role?.name,
          activityLevel: _level?.name,
          startDate: _startDate!,
          endDate: _endDate,
          organization: _organizationController.text,
          location: _locationController.text,
          workType: _workType!,
          context: _context!,
          contextPlace: _contextPlace!,
          position: _positionController.text,
          professionActivities: selectedProfessionActivities.map((e) => e.id!).toList(),
          professionActivitiesText: _textEditingControllerProfessionsActivities.text,
          otherProfessionActivityString: _otherText,
      );

      await database.updateExperience(experience);
      Navigator.of(context).pop();
      await showAlertDialog(context,
          title: 'Información guardada',
          content: 'La información ha sido guardada en tu CV correctamente',
          defaultActionText: 'Ok');
    }
  }

  void _updateCompetenciesPoints(Choice? choice) {
    if (choice != null && choice.competencies.isNotEmpty) {
      choice.competencies.keys.forEach((competencyId) {
        userCompetencies.update(
            competencyId, (value) => value + choice.competencies[competencyId]!,
            ifAbsent: () => choice.competencies[competencyId]!);
      });
    }
  }

  void _updateListCompetenciesPointsActivity(Activity? activity) {
    if (activity != null && activity.competencies.isNotEmpty) {
      activity.competencies.keys.forEach((competencyId) {
        userCompetencies.update(
            competencyId, (value) => value + activity.competencies[competencyId]!,
            ifAbsent: () => activity.competencies[competencyId]!);
      });
    }
  }

  void _updateListCompetenciesPoints(Set<Activity>? choices) {
    if (choices != null && choices.isNotEmpty)
      for (var itemChoice in choices) {
        _updateListCompetenciesPointsActivity(itemChoice);
      }
  }
}
