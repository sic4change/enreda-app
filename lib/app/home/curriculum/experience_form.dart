import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:enreda_app/app/home/models/choice.dart';
import 'package:enreda_app/app/home/models/experience.dart';
import 'package:enreda_app/common_widgets/show_alert_dialog.dart';
import 'package:enreda_app/common_widgets/show_competencies.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/services/api_path.dart';
import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common_widgets/flex_row_column.dart';

class ExperienceForm extends StatefulWidget {
  const ExperienceForm({Key? key, this.experience, required this.isEducation})
      : super(key: key);

  final Experience? experience;
  final bool isEducation;

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
  final _locationController = TextEditingController();
  Timestamp? _startDate, _endDate;
  String? _workType, _context, _contextPlace;
  final _formKey = GlobalKey<FormState>();
  bool _experienceIsLoaded = false;
  Map<String, int> userCompetencies = {};

  @override
  void initState() {
    super.initState();
    final _experience = widget.experience;
    if (_experience != null) {
      _startDate = _experience.startDate;
      _endDate = _experience.endDate;
      _organizationController.text = _experience.organization ?? '';
      _locationController.text = _experience.location;
      _workType = _experience.workType;
      _context = _experience.context;
      _contextPlace = _experience.contextPlace;
    }
  }

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);

    return StatefulBuilder(builder: (context, setState) {
      return StreamBuilder<List<Choice>>(
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
          });
    });
  }

  Form _buildForm(BuildContext context, StateSetter setState) {
    final database = Provider.of<Database>(context, listen: false);
    final textTheme = Theme.of(context).textTheme;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomFlexRowColumn(
              childLeft: _buildTypeDropdown(database, setState),
              childRight: _buildSubtypeDropdown(database, setState),
            ),
            CustomFlexRowColumn(
              childLeft: _buildActivityDropdown(setState),
              childRight: _buildRoleDropdown(setState),
            ),
            CustomFlexRowColumn(
              childLeft: _buildLevelDropdown(setState),
              childRight: TextFormField(
                controller: _organizationController,
                style: textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  label: Text(
                    'Nombre de la empresa, organización...',
                    style: textTheme.bodyText1,
                  ),
                ),
              ),
            ),
            CustomFlexRowColumn(
              childLeft: DateTimePicker(
                locale: Locale('es', 'ES'),
                dateMask: 'dd/MM/yyyy',
                initialDate: _endDate?.toDate() ?? DateTime.now(),
                initialValue: _startDate?.toString(),
                firstDate: new DateTime(
                  DateTime.now().year - 100,
                ),
                lastDate: _endDate?.toDate() ?? DateTime.now(),
                style: textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                onChanged: (dateTime) {
                  setState(() =>
                  _startDate = Timestamp.fromDate(DateTime.parse(dateTime)));
                },
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'La fecha de inicio es un campo obligatorio';
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Fecha inicio *',
                  labelStyle: textTheme.bodyText1,
                  suffixIcon: Icon(
                    Icons.event,
                  ),
                ),
              ),
              childRight: DateTimePicker(
                locale: Locale('es', 'ES'),
                dateMask: 'dd/MM/yyyy',
                initialValue: _endDate?.toString(),
                firstDate: _startDate?.toDate() ??
                    new DateTime(
                      DateTime.now().year - 100,
                    ),
                lastDate: DateTime.now(),
                style: textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                onChanged: (dateTime) {
                  setState(() =>
                  _endDate = Timestamp.fromDate(DateTime.parse(dateTime)));
                },
                decoration: InputDecoration(
                  labelText: 'Fecha fin',
                  labelStyle: textTheme.bodyText1,
                  suffixIcon: Icon(
                    Icons.event,
                  ),
                ),
              ),
            ),
            CustomFlexRowColumn(
              childLeft: TextFormField(
                  controller: _locationController,
                  style: textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                      label: Text(
                        'Municipio, ciudad, región o país *',
                        style: textTheme.bodyText1,
                      )),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'El Municipio, ciudad, región o país es un campo obligatorio';
                    return null;
                  },
                ),
              childRight: DropdownButtonFormField<String>(
                hint: Text('La mayor parte del tiempo estabas... *',
                    style: textTheme.bodyText1,
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
                    style: textTheme.bodyText1,
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
                      'Lugar *', style: textTheme.bodyText1
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

  Widget _buildActivityDropdown(void Function(void Function()) setState) {
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
          });
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
          contextPlace: _contextPlace!);

      await database.addExperience(experience);
      _updateCompetenciesPoints(_type);
      _updateCompetenciesPoints(_subtype);
      _updateCompetenciesPoints(_activity);
      _updateCompetenciesPoints(_role);
      _updateCompetenciesPoints(_level);
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
          contextPlace: _contextPlace!);

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
}
