import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';
import 'package:enreda_app/app/home/curriculum/stream_builder_professionsActivities.dart';
import 'package:enreda_app/app/home/models/choice.dart';
import 'package:enreda_app/app/home/models/experience.dart';
import 'package:enreda_app/common_widgets/custom_text.dart';
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
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../common_widgets/flex_row_column.dart';
import '../../anallytics/analytics.dart';
import '../models/activity.dart';

class ExperienceFormUpdate extends StatefulWidget {
  const ExperienceFormUpdate({
    Key? key,
    this.experience,
    required this.isProfesional,
    this.general,
    this.onComingBack,
  })
      : super(key: key);

  final Experience? experience;
  final bool isProfesional; //if false -> personal exprience
  final bool? general;
  final void Function(bool isProfesional)? onComingBack;

  @override
  State<ExperienceFormUpdate> createState() => _ExperienceFormUpdateState();
}

class _ExperienceFormUpdateState extends State<ExperienceFormUpdate> {
  bool _isProfesional = true;
  bool _general = false;
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
  List<Activity> _allProffesionActivities = [];

  @override
  void initState() {
    super.initState();
    final _experience = widget.experience;
    _isProfesional = widget.isProfesional;
    if(widget.general != null){
      _general = widget.general!;
    }
    if (_experience != null) {
      _startDate = _experience.startDate;
      _endDate = _experience.endDate;
      _organizationController.text = _experience.organization ?? '';
      _positionController.text = _experience.position ?? '';
      _locationController.text = _experience.location;
      _textEditingControllerProfessionsActivities.text = _experience.professionActivitiesText ?? '';
      _otherText = _experience.otherProfessionActivityString?? "";

      if(StringConst.EXPERIENCE_WORK_TYPES.contains(_experience.workType)){
        _workType = _experience.workType;
      }else{
        _workType = null;
      }

      if(StringConst.EXPERIENCE_CONTEXT.contains(_experience.context)){
        _context = _experience.context;
      }else{
        _context = null;
      }

      if(StringConst.EXPERIENCE_CONTEXT_PLACES.contains(_experience.contextPlace)){
        _contextPlace = _experience.contextPlace;
      }else{
        _contextPlace = null;
      }

      _loadProfessionActivities();
    }
  }

  Future<void> _loadProfessionActivities() async {
    final database = Provider.of<Database>(context, listen: false);
    _allProffesionActivities = await database.professionsActivitiesStream().first;
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
                _experienceTypes = snapshot.data!.where((choice) => choice.name == 'Profesional' || choice.name == 'Personal').toList();
                /*
                _experienceTypes = _isProfesional
                    ? snapshot.data!
                        .where((choice) => choice.name == 'Profesional')
                        .toList()
                    : snapshot.data!
                        .where((choice) => choice.name == 'Personal')
                        .toList();*/
              } else {
                _experienceTypes = [];
              }

              return StreamBuilder<List<Choice>>(
                  stream: database.choicesStream(
                      APIPath.experienceSubtypes(), null, null),
                  builder: (context, snapshot) {
                    _experienceSubtypes =
                        snapshot.hasData && !_isProfesional
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

                                      if(_isProfesional && _type == null && !_general && _experienceTypes.isNotEmpty){
                                        _type = _experienceTypes.firstWhere(
                                                (element) =>
                                            element.name == 'Profesional');
                                        _experienceActivitiesStream =
                                            database.choicesStream(APIPath.professions(), null, null);
                                      }
                                      if(!_isProfesional && _type == null && !_general && _experienceTypes.isNotEmpty){
                                        _type = _experienceTypes.firstWhere(
                                                (element) =>
                                            element.name == 'Personal');
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextTitle(title: StringConst.MY_EXPERIENCES.toUpperCase()),
            SpaceW12(),
            CustomFlexRowColumn(
              childLeft: _buildTypeDropdown(database, setState),
              childRight: Visibility(
                child: _isProfesional ? _buildActivityDropdown(database, setState) : _buildSubtypeDropdown(database, setState),
                visible: !_general,
              ),

            ),
            !_isProfesional && !_general && _type?.name == 'Personal' && _subtype?.name == 'Deporte' ||
                !_isProfesional && !_general && _type?.name == 'Personal' && _subtype?.name == 'Ocio' ?
            CustomFlexRowColumn(
              childLeft:  _buildActivityDropdown(database, setState),
              childRight: _buildRoleDropdown(setState),
            ) : Container(),

            //FOR LEVEL

            !_general && _type?.name == 'Personal' && _subtype?.name == 'Deporte' ?
            Padding(
              padding: const EdgeInsets.all(Borders.kDefaultPaddingDouble / 2),
                child: _buildLevelDropdown(setState),
            ) : Container(),

            //FOR COMPANY NAME
            !_general ? Padding(
                padding: const EdgeInsets.all(Borders.kDefaultPaddingDouble / 2),
                child: TextFormField(
                  controller: _organizationController,
                  style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    label: Text(
                      'Empresa, organización...' ,
                      style: textTheme.bodyMedium,
                    ),
                  ),
                ),
            ) : Container(),

            //FOR CITY
            !_general ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: Borders.kDefaultPaddingDouble/2),
              child: TextFormField(
                controller: _locationController,
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                    label: Text(
                      'Municipio, ciudad, región o país *',
                      style: textTheme.bodyMedium,
                    )),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'El Municipio, ciudad, región o país es un campo obligatorio';
                  return null;
                },
              ),
            ) : Container(),

            //FOR DATE
            !_general ? CustomFlexRowColumn(
              childLeft: DateTimeField(
                initialValue: _startDate?.toDate(),
                format: DateFormat('yyyy'),
                decoration: InputDecoration(
                  labelText: 'Año inicio *',
                  labelStyle: textTheme.bodyMedium,
                  suffixIcon: Icon(
                    Icons.event,
                  ),
                ),
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                onShowPicker: (context, currentValue) {
                  return showDatePicker(
                    context: context,
                    confirmText: StringConst.FORM_CONFIRM,
                    initialDatePickerMode: DatePickerMode.year,
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
                    return 'El año de inicio es un campo obligatorio';
                  return null;
                },
              ),
              childRight: DateTimeField(
                initialValue: _endDate?.toDate(),
                format: DateFormat('yyyy'),
                decoration: InputDecoration(
                  labelText: 'Año fin',
                  labelStyle: textTheme.bodyMedium,
                  suffixIcon: Icon(
                    Icons.event,
                  ),
                ),
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                onShowPicker: (context, currentValue) {
                  return showDatePicker(
                    context: context,
                    confirmText: StringConst.FORM_CONFIRM,
                    initialDatePickerMode: DatePickerMode.year,
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
              ),
            ) : Container(),

            //FOR PROFESSIONS ACTIVITIES
            (!_general && _type?.name == 'Profesional') ? Padding(
              padding: const EdgeInsets.all(Borders.kDefaultPaddingDouble / 2),
              child: TextFormField(
                        controller: _textEditingControllerProfessionsActivities,
                        decoration: InputDecoration(
                          label: Text(
                            'Tareas que realizaste *',
                            style: textTheme.bodyMedium,
                          ),
                          labelStyle: textTheme.bodyMedium?.copyWith(
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
                        //maxLines: 2,
                        readOnly: true,
                        style: textTheme.bodySmall?.copyWith(
                          height: 1.5,
                          color: AppColors.greyDark,
                          fontWeight: FontWeight.w400,
                          fontSize: fontSize,
                          overflow: TextOverflow.ellipsis
                        )
              ),
            ) : Container(),

            //FOR POSITION
            !_general ? Padding(
              padding: const EdgeInsets.all(Borders.kDefaultPaddingDouble / 2),
              child: TextFormField(
                controller: _positionController,
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  label: Text(
                    'Indica tu cargo...',
                    style: textTheme.bodyMedium,
                  ),
                ),
              ),
            ) : Container(),

            SpaceH36(),

            !_general ? CustomTextTitle(title: StringConst.ALL_COMPETENCIES.toUpperCase()) : Container(),

            !_general ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: Borders.kDefaultPaddingDouble/2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¿Cómo desarrollaste tu actividad?',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      height: 1.5,
                      color: AppColors.greyDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                    isExpanded: true,
                    isDense: true,
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
                ],
              ),
            ) : Container(),
            SpaceH20(),
            !_general ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: Borders.kDefaultPaddingDouble/2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¿Esta experiencia te supuso un cambio de domicilio?',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      height: 1.5,
                      color: AppColors.greyDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold,),
                    isDense: true,
                    isExpanded: true,
                    value: _contextPlace,
                    items: StringConst.EXPERIENCE_CONTEXT_PLACES
                        .map((e) => DropdownMenuItem<String>(value: e, child: Text(e, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),)))
                        .toList(),
                    onChanged: (value) {
                      _contextPlace = value ?? _contextPlace;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Selecciona un valor';
                      return null;
                    },
                  ),
                ],
              ),
            ) : Container(),
            SpaceH20(),
            !_general ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: Borders.kDefaultPaddingDouble/2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¿Esta experiencia te supuso hacer cosas que no solías hacer antes?',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      height: 1.5,
                      color: AppColors.greyDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                    isExpanded: true,
                    isDense: true,
                    value: _context,
                    items: StringConst.EXPERIENCE_CONTEXT
                        .map((e) => DropdownMenuItem<String>(
                        value: e,
                        child: Text(
                          e,
                          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
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
                ],
              ),
            ) : Container(),

            SpaceH24(),
            !_general ? Row(
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
            ) : Container(),
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
        activitiesIds =_activity?.activities;
        if (activitiesIds != null && activitiesIds!.isNotEmpty) {
          activitiesIds!.add("30twSwwnuVmpIp3MoE6e");
        }
        selectedProfessionActivities.addAll(_allProffesionActivities.where((a) => widget.experience!.professionActivities.contains(a.id)));
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
      hint: Text('Tipo *', style: textTheme.bodyMedium,),
      style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
      isExpanded: true,
      isDense: false,
      items: _experienceTypes
          .map((e) => DropdownMenuItem<Choice>(value: e, child: Text(e.name, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),)))
          .toList(),
      value: _type,
      onChanged: (_type != null && _type!.name.isNotEmpty)? null :  (newType) {
        setState(() {
            _type = newType;
            _subtype = null;
            _activity = null;
            _role = null;
            _level = null;
            _general = false;

            if (_type?.name == 'Profesional') {
              _experienceActivitiesStream =
                  database.choicesStream(APIPath.professions(), null, null);
              _isProfesional = true;
            } else {
              _experienceActivitiesStream = database.choicesStream(
                  APIPath.activityChoices(), _type?.id, _subtype?.id);
              _isProfesional = false;
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
        hint: Text('Subtipo', style: textTheme.bodyMedium,),
        style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        isExpanded: true,
        isDense: false,
        items: _experienceSubtypes
            .map((e) => DropdownMenuItem<Choice>(value: e, child: Text(e.name, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),)))
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
        hint: Text('Actividad', style: textTheme.bodyMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
        style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        isExpanded: true,
        isDense: false,
        items: _experienceActivities
            .map((e) => DropdownMenuItem<Choice>(value: e, child: Text(e.name, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),)))
            .toList(),
        value: _activity,
        onChanged: (newActivity) {
          setState(() {
            if (_activity?.id != newActivity?.id) {
              selectedProfessionActivities.clear();
              _textEditingControllerProfessionsActivities.clear();
            }
            _activity = newActivity;
            activitiesIds =_activity?.activities;
            if (activitiesIds != null && activitiesIds!.isNotEmpty) {
              activitiesIds!.add("30twSwwnuVmpIp3MoE6e");
            }
          });
        });
  }

  void _showMultiSelectProfessionActivities(BuildContext context) async {
    final textTheme = Theme.of(context).textTheme;
    var selectedValues = await showDialog<Set<Activity>>(
      context: context,
      builder: (BuildContext context) {
        if(_activity == null) {
          return AlertDialog(
            content: Text(
              StringConst.FORM_ACTIVITIES_EMPTY,
              style: textTheme.bodyMedium,
            ),
            actions: <Widget>[
              ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Constants.turquoise),
                  onPressed: () => Navigator.pop(context),
                  child: Text(StringConst.FORM_ACCEPT,
                      style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold))),
            ],
          );
        } else {
          return streamBuilderDropdownProfessionActivities(
            context,
            _activity!,
            activitiesIds!,
            selectedProfessionActivities, // TODO:
            (text) => _otherText = text,
            _otherText
          );
        }
      },
    );
    getValuesFromKeyProfessionActivities(selectedValues);
  }

  void getValuesFromKeyProfessionActivities (selectedValues) {
    var concatenate = StringBuffer();
    List<String> activitiesIds = [];
    selectedValues.forEach((item){
      String text = item.name;
      if (item.id == '30twSwwnuVmpIp3MoE6e') {
        text = '${item.name}: $_otherText';
      }
      concatenate.write(text +' / ');
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
        hint: Text('Rol', style: textTheme.bodyMedium,),
        style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        isExpanded: true,
        isDense: false,
        items: _experienceRoles
            .map((e) => DropdownMenuItem<Choice>(value: e, child: Text(e.name, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),)))
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
        hint: Text('Nivel', style: textTheme.bodyMedium,),
        style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        items: _experienceLevels
            .map((e) => DropdownMenuItem<Choice>(value: e, child: Text(e.name, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),)))
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

      sendBasicAnalyticsEvent(context, "enreda_app_updated_cv");

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
        if (widget.onComingBack != null) {
          widget.onComingBack!(_isProfesional);
        }
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

      sendBasicAnalyticsEvent(context, "enreda_app_updated_cv");
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
