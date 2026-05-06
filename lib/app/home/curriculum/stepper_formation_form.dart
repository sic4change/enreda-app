import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enreda_app/app/home/models/education.dart';
import 'package:enreda_app/app/home/models/experience.dart';
import 'package:enreda_app/common_widgets/show_alert_dialog.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../common_widgets/flex_row_column.dart';
import '../../anallytics/analytics.dart';

class StepperFormationForm extends StatefulWidget {
  const StepperFormationForm({
    Key? key,
    this.formKey,
    this.experience,
    required this.isMainEducation,
    this.onComingBack,
  })
      : super(key: key);

  final Experience? experience;
  final bool isMainEducation;
  final VoidCallback? onComingBack;
  final GlobalKey<FormState>? formKey;

  @override
  State<StepperFormationForm> createState() => StepperFormationFormState();
}

class StepperFormationFormState extends State<StepperFormationForm> {
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
        color: Colors.transparent,
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
      key: widget.formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            formFieldCustom(
              DropdownButtonFormField<String>(
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                decoration: _appDecoration('Selecciona una opción'),
                isExpanded: true,
                isDense: true,
                iconEnabledColor: AppColors.primary400,
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
              '¿En qué tipo de institución fue realizada?',
            ),

            formFieldCustom(
              TextFormField(
                controller: _nameFormationController,
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                decoration: _appDecoration('Nombre de la formación'),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'El nombre de la formación es un campo obligatorio';
                  return null;
                },
              ),
              '¿Cómo se llama la formación?',
            ),

        // !widget.isMainEducation ? Container() :
        // formFieldCustom(
        //   DropdownButtonFormField<Education>(
        //     hint: Text(StringConst.EDUCATIONAL_LEVEL, maxLines: 2, overflow: TextOverflow.ellipsis),
        //     isExpanded: true,
        //     isDense: false,
        //     value: _selectedEducation,
        //     items: educationItems,
        //     validator: (value) => _selectedEducation != null ? null : StringConst.FORM_MOTIVATION_ERROR,
        //     onChanged: (value) => setState(() {
        //       _selectedEducation = value;
        //     }),
        //     style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        //   ),
        // ),



            formFieldCustom(
              TextFormField(
                controller: _organizationController,
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                decoration: _appDecoration('Nombre institución educativa'),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'El nombre de la institución educativa es obligatorio';
                  return null;
                },
              ),
              '¿Cómo se llama la institución educativa?',
            ),

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
                isEndDate: true,
                onChanged: (dt) {
                  setState(() => _endDate = dt != null ? Timestamp.fromDate(dt) : null);
                },
              ),
            ), 'Completa las fechas',),

            formFieldCustom(
              TextFormField(
                controller: _locationController,
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                decoration: _appDecoration('Municipio, ciudad, región o país'),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'El Municipio, ciudad, región o país es un campo obligatorio';
                  return null;
                },
              ),
              '¿Dónde cursaste la formación?',
            ),

            formFieldCustom(
              TextFormField(
                controller: _extraDataController,
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                decoration: _appDecoration('Datos de interés sobre la formación'),
              ),
            '¿Quieres agregar alguna información de interés acerca de esta formación?',),


            SpaceH24(),
            /*Row(
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
            )*/
          ],
        ),
      ),
    );
  }

  Widget formFieldCustom(Widget child, String title){
    final textTheme = Theme.of(context).textTheme;
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
    final database = context.read<Database>();
    final auth = Provider.of<AuthBase>(context, listen: false);
    print('dentro de saveExperience');

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
          //education: widget.isMainEducation ? _selectedEducation!.label : '',
          education: '',
          institution: _institution,
          extraData: _extraDataController.text,

      );

      sendBasicAnalyticsEvent(context, "enreda_app_updated_cv");
      await database.addExperience(experience);
      //Navigator.of(context).pop();
      /*await showAlertDialog(context,
            title: 'Información guardada',
            content: 'La información ha sido guardada en tu CV correctamente',
            defaultActionText: 'Ok');*/
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
          //education: widget.isMainEducation ? _selectedEducation!.label : '',
          education: '',
          institution: _institution,
          extraData: _extraDataController.text,
      );

      sendBasicAnalyticsEvent(context, "enreda_app_updated_cv");
      await database.updateExperience(experience);
      //Navigator.of(context).pop();
      /*await showAlertDialog(context,
          title: 'Información guardada',
          content: 'La información ha sido guardada en tu CV correctamente',
          defaultActionText: 'Ok');*/
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
  final bool isEndDate;

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
    this.isEndDate = false,
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
    // Si es campo de fecha fin, mostrar diálogo previo con opción "Continúa actualmente"
    if (widget.isEndDate) {
      final action = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Fecha de fin'),
          content: const Text('¿Cuándo finalizó o sigue activa?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop('cancel'),
              child: const Text('Cancelar'),
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.timelapse_rounded),
              label: const Text('Continúa actualmente'),
              onPressed: () => Navigator.of(ctx).pop('current'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop('pick'),
              child: const Text('Elegir año'),
            ),
          ],
        ),
      );

      if (action == null || action == 'cancel') return;

      if (action == 'current') {
        // Limpiar el campo → fin = null → se considera activa
        _ctrl.clear();
        widget.onChanged?.call(null);
        setState(() {});
        return;
      }
      // action == 'pick' → continúa al picker normal
    }

    final base = widget.initialDate ??
        (_ctrl.text.isNotEmpty
            ? DateTime(int.tryParse(_ctrl.text) ?? DateTime.now().year)
            : DateTime.now());

    final picked = await showDatePicker(
      context: context,
      locale: const Locale('es', 'ES'),
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
        // El año de fin no es obligatorio (puede dejarse vacío = "continúa actualmente")
        if (widget.isEndDate) return null;
        if (val == null || val.trim().isEmpty) return 'Este campo es obligatorio';
        return null;
      },
    );
  }
}