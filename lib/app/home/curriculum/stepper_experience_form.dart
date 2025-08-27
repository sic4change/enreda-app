import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';
import 'package:enreda_app/app/home/curriculum/stepper_cv.dart';
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
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../common_widgets/flex_row_column.dart';
import '../../anallytics/analytics.dart';
import '../models/activity.dart';

class StepperExperienceForm extends StatefulWidget {
  const StepperExperienceForm({
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
  State<StepperExperienceForm> createState() => _StepperExperienceFormState();
}

class _StepperExperienceFormState extends State<StepperExperienceForm> {
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
            formFieldCustom(
              //_buildTypeDropdown(database, setState),
              Visibility(
                child: _isProfesional ? _buildActivityDropdown(database, setState) : _buildSubtypeDropdown(database, setState),
                  visible: !_general,
                ),
                '¿En qué sector de actividad fue tu experiencia?'
            ),

            
            !_isProfesional && !_general && _type?.name == 'Personal' && _subtype?.name == 'Deporte' ||
                !_isProfesional && !_general && _type?.name == 'Personal' && _subtype?.name == 'Ocio' ?
            Column(
              children: [
                formFieldCustom(
                  _buildActivityDropdown(database, setState),
                  '¿Qué tipo de actividad realizaste?'
                ),
                formFieldCustom(
                  _buildRoleDropdown(setState),
                  '¿Qué rol tienes en esa actividad?'
                ),
              ],
            ) : Container(),

            //FOR LEVEL

            !_general && _type?.name == 'Personal' && _subtype?.name == 'Deporte' ?
            formFieldCustom(
              _buildLevelDropdown(setState),
              '¿Qué nivel tienes?'
            ) : Container(),

            //FOR COMPANY NAME
            !_general ? formFieldCustom(TextFormField(
              controller: _organizationController,
              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              decoration: _appDecoration('Empresa, organización...'),
            ), '¿En qué tipo de organismo la realizaste?') : Container(),

            //FOR CITY
            !_general ? formFieldCustom(TextFormField(
                controller: _locationController,
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                decoration: _appDecoration('Municipio, ciudad, región o país'),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'El Municipio, ciudad, región o país es un campo obligatorio';
                  return null;
                },
              )
              , '¿Dónde realizaste la experiencia?') : Container(),

            //FOR DATE
            formFieldCustom(CustomFlexRowColumn(
              contentPadding: const EdgeInsets.all(0),
              separatorSize: 20,
              childLeft: Container(
                width: 300,
                child: YearPickerFormField(
                  hint: 'Año de inicio',
                  initialDate: _startDate?.toDate(),
                  firstDate: DateTime(DateTime.now().year - 100, 1, 1),
                  lastDate: _endDate?.toDate() ?? DateTime.now(),
                  textStyle: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  onChanged: (dt) {
                    setState(() => _startDate = dt != null ? Timestamp.fromDate(dt) : null);
                    // print('inicio: $_startDate fin: $_endDate');
                  },
                ),
              ),
              childRight: YearPickerFormField(
                hint: 'Año de fin',
                initialDate: _endDate?.toDate(),
                firstDate: _startDate?.toDate() ?? DateTime(DateTime.now().year - 100, 1, 1),
                lastDate: DateTime.now(),
                textStyle: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                onChanged: (dt) {
                  setState(() => _endDate = dt != null ? Timestamp.fromDate(dt) : null);
                },
              ),
            ), 'Completa las fechas',),

            //FOR PROFESSIONS ACTIVITIES
            (!_general && _isProfesional) ? formFieldCustom(TextFormField(
                      controller: _textEditingControllerProfessionsActivities,
                      decoration: _appDecoration(''),
                      
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
            ), '¿Qué tareas realizaste?') : Container(),

            //FOR POSITION
            !_general ? formFieldCustom(TextFormField(
              controller: _positionController,
              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              decoration: _appDecoration('Nombre del cargo'),
            ), '¿Qué cargo ocupaste?') : Container(),

            SpaceH36(),

            !_general ? Text(StringConst.ALL_COMPETENCIES, style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w800, color: AppColors.primary900, fontSize: 30),
            )
             : Container(),

            SpaceH20(),

            formFieldCustom(
              PillOptionsFormField<String>(
                options: StringConst.EXPERIENCE_WORK_TYPES,
                initialValue: _workType,
                labelBuilder: (s) => s,
                onChanged: (v) => _workType = v ?? _workType,
                validator: (v) => (v == null || v.isEmpty) ? 'Selecciona un valor' : null,
              ),    
              '¿Cómo desarrollaste tu actividad?'
            ),
              
            SpaceH20(),
            formFieldCustom(YesNoFormField(
              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              isDense: true,
              isExpanded: true,
              value: _contextPlace,
              items: StringConst.EXPERIENCE_CONTEXT_PLACES, // ['Sí','No']
              onChanged: (value) {
                _contextPlace = value ?? _contextPlace;
                setState(() {}); // si estás en StatefulWidget y quieres repintar
              },
              validator: (value) {
                if (value == null || value.isEmpty) return 'Selecciona un valor';
                return null;
              },
            ), '¿Esta experiencia te supuso un cambio de domicilio?'),
            SpaceH20(),
            formFieldCustom(YesNoFormField(
              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              isDense: true,
              isExpanded: true,
              value: _context,
              items: StringConst.EXPERIENCE_CONTEXT, // ['Sí','No']
              onChanged: (value) {
                _context = value ?? _context;
                setState(() {}); // si estás en StatefulWidget y quieres repintar
              },
              validator: (value) {
                if (value == null || value.isEmpty) return 'Selecciona un valor';
                return null;
              },
            ), '¿Esta experiencia te supuso hacer cosas que no solías hacer antes?')

            /*SpaceH24(),
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
            ) : Container(),*/
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
        //hint: Text('Subtipo', style: textTheme.bodyMedium,),
        decoration: _appDecoration(''),
        style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        isExpanded: true,
        isDense: true,
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
        //hint: Text('Actividad', style: textTheme.bodyMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
        style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        decoration: _appDecoration(''),
        isExpanded: true,
        isDense: true,
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
        //hint: Text('Rol', style: textTheme.bodyMedium,),
        decoration: _appDecoration(''),
        style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        isExpanded: true,
        isDense: true,
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
        //hint: Text('Nivel', style: textTheme.bodyMedium,),
        decoration: _appDecoration(''),
        style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        isExpanded: true,
        isDense: true,
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

  Widget formFieldCustom(Widget child, String title){
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: Borders.kDefaultPaddingDouble / 2),
          child: SizedBox(
            width: Responsive.isMobile(context) ? MediaQuery.of(context).size.width : MediaQuery.of(context).size.width/3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w500, fontSize: 26, color: AppColors.primary900),
                ),
                SpaceH20(),
                child,
              ],
            ),
          ),
    );
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


 InputDecoration _appDecoration(String hintText) {
    const radius = 30.0;
    final baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: const BorderSide(color: AppColors.primary100, width: 1),
    );

    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: AppColors.greyHint, fontSize: 12),
      filled: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      enabledBorder: baseBorder,
      disabledBorder: baseBorder,
      focusedBorder: baseBorder.copyWith(
        borderSide: const BorderSide(color: AppColors.primary100, width: 3),
      ),
      errorBorder: baseBorder.copyWith(
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
      focusedErrorBorder: baseBorder.copyWith(
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }

  class YearPickerFormField extends StatefulWidget {
  final String hint;
  final String? label;
  final DateTime? initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime?>? onChanged;
  final FormFieldValidator<String>? validator;
  final TextStyle? textStyle;

  const YearPickerFormField({
    super.key,
    required this.hint,
    this.label,
    this.initialDate,
    required this.firstDate,
    required this.lastDate,
    this.onChanged,
    this.validator,
    this.textStyle,
  });

  @override
  State<YearPickerFormField> createState() => _YearPickerFormFieldState();
}

class _YearPickerFormFieldState extends State<YearPickerFormField> {
  final _ctrl = TextEditingController();
  final _fmt = DateFormat('yyyy');

  @override
  void initState() {
    super.initState();
    if (widget.initialDate != null) {
      _ctrl.text = _fmt.format(widget.initialDate!);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _pickYear() async {
    final base = widget.initialDate ??
        ( _ctrl.text.isNotEmpty
            ? DateTime(int.tryParse(_ctrl.text) ?? DateTime.now().year)
            : DateTime.now());

    final picked = await showDatePicker(
      context: context,
      locale: const Locale('es', 'ES'),
      // El truco: abrir en selección de año y sólo calendario
      initialDatePickerMode: DatePickerMode.year,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDate: base.isBefore(widget.firstDate) || base.isAfter(widget.lastDate)
          ? widget.lastDate
          : base,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      confirmText: 'Confirmar',
    );

    if (picked != null) {
      // Normalizamos al 1 de enero; mostramos sólo el año
      final normalized = DateTime(picked.year, 1, 1);
      _ctrl.text = _fmt.format(normalized);
      widget.onChanged?.call(normalized);
      setState(() {});
    }
  }

Widget _calendarBadge(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      margin: const EdgeInsets.only(left: 8, right: 8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary100, width: 1.5),
      ),
      child: const Center(
        child: Icon(Icons.calendar_month_outlined, size: 22, color: AppColors.primary100),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _ctrl,
      readOnly: true,
      style: widget.textStyle,
      onTap: _pickYear,
      decoration: _appDecoration(widget.hint).copyWith(
        // Si quieres que “Año de inicio/fin” se vea como label flotante, usa labelText en vez de hint
        labelText: widget.label,
        // Prefix “badge” circular
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        prefixIcon: _calendarBadge(context),
      ),
      validator: (val) {
        if (widget.validator != null) return widget.validator!(val);
        if (val == null || val.trim().isEmpty) return 'Este campo es obligatorio';
        return null;
      },
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color base = AppColors.primary100; // mismo color de tu _appDecoration
    final borderColor = selected ? theme.colorScheme.primary : base;
    final borderWidth = selected ? 3.0 : 1.0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.greyAlt, fontSize: 12,)
        ),
      ),
    );
  }
}

/// FormField de opciones tipo “píldora” (selección única).
class PillOptionsFormField<T> extends FormField<T> {
  PillOptionsFormField({
    super.key,
    required List<T> options,
    required String Function(T) labelBuilder,
    T? initialValue,
    FormFieldValidator<T>? validator,
    ValueChanged<T?>? onChanged,
    double spacing = 16,
    bool equalWidth = true, // para alinear como en el mock
  }) : super(
          initialValue: initialValue,
          validator: validator,
          builder: (state) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final total = options.length;
                final itemWidth = equalWidth
                    ? (constraints.maxWidth - spacing * (total - 1)) / total
                    : null;

                final children = <Widget>[];
                for (var i = 0; i < options.length; i++) {
                  final opt = options[i];
                  final selected = state.value == opt;

                  final pill = SizedBox(
                    width: itemWidth,
                    child: _PillButton(
                      label: labelBuilder(opt),
                      selected: selected,
                      onTap: () {
                        state.didChange(opt);
                        onChanged?.call(opt);
                      },
                    ),
                  );

                  children.add(pill);
                  if (i != options.length - 1) {
                    children.add(SizedBox(width: spacing));
                  }
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: children),
                    if (state.hasError)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          state.errorText!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                        ),
                      ),
                  ],
                );
              },
            );
          },
        );
}

class YesNoFormField extends FormField<String> {
  YesNoFormField({
    super.key,
    // Firma compatible con tu Dropdown:
    required List<String> items,      // p.ej. ['Sí', 'No']
    String? value,                    // valor actual
    ValueChanged<String?>? onChanged, // callback
    FormFieldValidator<String>? validator,
    // Props “de fachada” para respetar la firma del Dropdown:
    TextStyle? style,
    bool isDense = true,
    bool isExpanded = true,
    double gap = 24,
  }) : assert(items.length >= 2,
              'items debe contener al menos dos opciones (Sí / No)'),
       super(
        initialValue: value,
        validator: validator ??
            (v) => (v == null || v.isEmpty) ? 'Selecciona un valor' : null,
        builder: (state) {
          final theme = Theme.of(state.context);
          final optYes = items[0];
          final optNo  = items[1];

          IconData _iconFor(String label, String first) {
            final n = label.toLowerCase().replaceAll('í', 'i').trim();
            if (n == 'si' || n == 'sí') return Icons.check_rounded;
            if (n == 'no') return Icons.close_rounded;
            // fallback: el primero “parece” el positivo
            return label == first ? Icons.check_rounded : Icons.close_rounded;
          }

          Widget _buildCard(String label) => Expanded(
                child: ChoiceCard(
                  selected: state.value == label,
                  icon: _iconFor(label, optYes),
                  label: label,
                  onTap: () {
                    state.didChange(label);
                    onChanged?.call(label);
                  },
                ),
              );

          // Permite aplicar estilo de texto si lo pasas (opcional)
          final content = Row(
            children: [
              _buildCard(optYes),
              SizedBox(width: gap),
              _buildCard(optNo),
            ],
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (style != null) DefaultTextStyle.merge(style: style, child: content) else content,
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    state.errorText!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
            ],
          );
        },
      );
}