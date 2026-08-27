import 'package:enreda_app/app/home/models/companion_data.dart';
import 'package:enreda_app/app/home/models/userEnreda.dart';
import 'package:enreda_app/app/home/web_home.dart';
import 'package:enreda_app/common_widgets/custom_text.dart';
import 'package:enreda_app/common_widgets/enreda_button.dart';
import 'package:enreda_app/common_widgets/flex_row_column.dart';
import 'package:enreda_app/common_widgets/rounded_container.dart';
import 'package:enreda_app/common_widgets/show_alert_dialog.dart';
import 'package:enreda_app/common_widgets/show_exception_alert_dialog.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/adaptive.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CompanionDataForm extends StatefulWidget {
  const CompanionDataForm({Key? key, required this.user, this.companionData})
    : super(key: key);

  final UserEnreda user;
  final CompanionData? companionData;

  @override
  State<CompanionDataForm> createState() => _CompanionDataFormState();
}

class _CompanionDataFormState extends State<CompanionDataForm> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  String? _companionFamilySituation;
  String? _companionDateArriveSpain;
  String? _companionAdministrativeStatus;
  bool? _companionWorkPermit;
  String? _companionWorkPermitRenewalDate;
  String? _companionDocumentType;
  String? _companionDocumentNumber;
  List<String> _companionHelpNeeds = [];
  bool _companionHelpNeedsOther = false;
  String? _companionHelpNeedsOtherText;
  List<String> _companionContactSchedule = [];
  bool? _companionProfessionalHelp;
  String? _companionOtherRelevantData;

  @override
  void initState() {
    super.initState();
    _initValues(widget.companionData);
  }

  @override
  void didUpdateWidget(covariant CompanionDataForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.companionData != widget.companionData) {
      _initValues(widget.companionData);
    }
  }

  void _initValues(CompanionData? data) {
    if (data == null) return;
    _companionFamilySituation = data.companionFamilySituation;
    _companionDateArriveSpain = data.companionDateArriveSpain;
    _companionAdministrativeStatus = data.companionAdministrativeStatus;
    _companionWorkPermit = data.companionWorkPermit;
    _companionWorkPermitRenewalDate = data.companionWorkPermitRenewalDate;
    _companionDocumentType = data.companionDocumentType;
    _companionDocumentNumber = data.companionDocumentNumber;

    final helpNeedsList = List<String>.from(data.companionHelpNeeds);
    _companionHelpNeeds = [];
    _companionHelpNeedsOtherText = data.companionHelpNeedsOther;

    for (final item in helpNeedsList) {
      if (item.startsWith('Otro: ')) {
        _companionHelpNeedsOther = true;
        _companionHelpNeedsOtherText = item.replaceFirst('Otro: ', '');
      } else {
        _companionHelpNeeds.add(item);
      }
    }
    if (_companionHelpNeedsOtherText != null &&
        _companionHelpNeedsOtherText!.isNotEmpty) {
      _companionHelpNeedsOther = true;
    }

    _companionContactSchedule = List<String>.from(
      data.companionContactSchedule,
    );
    _companionProfessionalHelp = data.companionProfessionalHelp;
    _companionOtherRelevantData = data.companionOtherRelevantData;
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = Responsive.isMobile(context);
    return RoundedContainer(
      margin: isSmallScreen
          ? const EdgeInsets.all(0)
          : const EdgeInsets.all(Sizes.kDefaultPaddingDouble),
      contentPadding: isSmallScreen
          ? const EdgeInsets.symmetric(horizontal: 0.0)
          : const EdgeInsets.all(Sizes.kDefaultPaddingDouble * 2),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isSmallScreen
                ? InkWell(
                    onTap: () {
                      setStateIfMounted(() {
                        WebHome.controller.selectIndex(0);
                      });
                    },
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 25.0),
                          child: Image.asset(ImagePath.ARROW_B, height: 30),
                        ),
                        const Spacer(),
                        const CustomTextMediumBold(
                          text: 'ACOMPAÑAMIENTO PERSONALIZADO',
                        ),
                        const Spacer(),
                        const SizedBox(width: 55),
                      ],
                    ),
                  )
                : const CustomTextMediumBold(
                    text: 'ACOMPAÑAMIENTO PERSONALIZADO',
                  ),
            _buildCompanionBanner(context),
            Container(
              margin: isSmallScreen
                  ? const EdgeInsets.only(top: Sizes.kDefaultPaddingDouble / 4)
                  : const EdgeInsets.all(Sizes.kDefaultPaddingDouble),
              padding: isSmallScreen
                  ? const EdgeInsets.all(0)
                  : const EdgeInsets.symmetric(
                      vertical: Sizes.kDefaultPaddingDouble,
                    ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSmallScreen ? Colors.white : Constants.lightGray,
                  width: 1,
                ),
                borderRadius: isSmallScreen
                    ? const BorderRadius.all(Radius.circular(0.0))
                    : const BorderRadius.all(Radius.circular(15.0)),
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: isSmallScreen
                        ? Colors.transparent
                        : Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: isSmallScreen
                          ? const EdgeInsets.all(0)
                          : const EdgeInsets.symmetric(horizontal: 30.0),
                      child: _buildForm(context),
                    ),
                    const SizedBox(height: 40),
                    _buildSaveButton(context),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            isSmallScreen ? SpaceH50() : Container(),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanionBanner(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    double titleFontSize = responsiveSize(context, 20, 26, md: 24);
    double bodyFontSize = responsiveSize(context, 13, 15, md: 14);

    return Container(
      margin: Responsive.isMobile(context)
          ? const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0)
          : const EdgeInsets.all(Sizes.kDefaultPaddingDouble),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: AppColors.gre600.withOpacity(0.5), width: 1.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Stack(
          children: [
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Image.asset(
                'images/companion_banner_illustration.png',
                fit: BoxFit.contain,
                alignment: Alignment.topRight,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 24.0,
                top: 24.0,
                bottom: 24.0,
                right: Responsive.isMobile(context) ? 70.0 : 220.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Te acompañamos en tu camino',
                    style: textTheme.titleLarge?.copyWith(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w800,
                      fontSize: titleFontSize,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Cada persona tiene un camino diferente hacia el empleo. No importa si ya sabes cuál es tu objetivo o si aún estás descubriendo por dónde empezar: en Enreda te acompañamos en ese proceso.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.greyDark,
                      height: 1.45,
                      fontSize: bodyFontSize,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Te ayudaremos a identificar tus competencias y desarrollar otras nuevas, mejorar tu empleabilidad y acercarte a nuevas oportunidades laborales.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.greyDark,
                      height: 1.45,
                      fontSize: bodyFontSize,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Al completar este formulario, además de inscribirte en nuestra plataforma y acceder a sus herramientas, podrás recibir información sobre nuestros programas de acompañamiento personalizado para la búsqueda de empleo.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.greyDark,
                      height: 1.45,
                      fontSize: bodyFontSize,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          )
        : EnredaButton(
            buttonTitle: StringConst.UPDATE_DATA,
            onPressed: _submit,
          );
  }

  Widget _buildForm(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    double fontSize = responsiveSize(context, 14, 16, md: 15);

    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: AppColors.white,
      errorStyle: const TextStyle(height: 0.01),
      hintStyle: textTheme.bodySmall?.copyWith(
        color: AppColors.darkGray,
        fontSize: fontSize,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.0),
        borderSide: const BorderSide(color: AppColors.greyUltraLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.0),
        borderSide: const BorderSide(
          color: AppColors.greyUltraLight,
          width: 1.0,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.0),
        borderSide: const BorderSide(color: Colors.red, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.0),
        borderSide: const BorderSide(color: Colors.red, width: 1.0),
      ),
    );

    Widget sectionTitle(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
      child: Text(
        text,
        style: textTheme.bodySmall?.copyWith(
          height: 1.5,
          color: AppColors.primaryColor,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    );

    Widget fieldLabel(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 6.0, top: 8.0),
      child: Text(
        text,
        style: textTheme.bodySmall?.copyWith(
          height: 1.5,
          color: AppColors.greyDark,
          fontWeight: FontWeight.w600,
          fontSize: fontSize,
        ),
      ),
    );

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              'Información sobre tu situación y necesidades de acompañamiento hacia el empleo. Rellena o actualiza los campos que apliquen a tu situación.',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.greyDark,
                height: 1.4,
                fontSize: fontSize,
              ),
            ),
          ),
          const Divider(color: AppColors.greyUltraLight),

          // ── Situación familiar ──────────────────────────────────────────────
          sectionTitle('Situación familiar'),
          fieldLabel(
            '¿Tienes alguna responsabilidad familiar? ¿Tienes familiares en España?',
          ),
          TextFormField(
            initialValue: _companionFamilySituation,
            minLines: 2,
            maxLines: 4,
            decoration: inputDecoration.copyWith(
              hintText:
                  'Describe brevemente tu situación familiar en España...',
              hintStyle: textTheme.bodySmall?.copyWith(
                color: AppColors.darkGray,
                fontSize: fontSize,
              ),
            ),
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.greyDark,
              fontSize: fontSize,
            ),
            onSaved: (v) => _companionFamilySituation = v,
            onChanged: (v) => _companionFamilySituation = v,
          ),
          SpaceH20(),

          // ── Fecha de llegada ─────────────────────────────────────────────────
          sectionTitle('Fecha de llegada a España'),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: AppColors.greyDark,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Añade la fecha en la que llegaste a España',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.greyDark,
                    fontWeight: FontWeight.w600,
                    fontSize: fontSize,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: _companionDateArriveSpain,
            decoration: inputDecoration.copyWith(
              hintText: '¿Recuerdas la fecha exacta? Indica el año, mes o día en que llegaste al país.',
              hintStyle: textTheme.bodySmall?.copyWith(
                color: AppColors.darkGray,
                fontSize: fontSize,
              ),
            ),
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.greyDark,
              fontSize: fontSize,
            ),
            onSaved: (v) => _companionDateArriveSpain = v,
            onChanged: (v) => _companionDateArriveSpain = v,
          ),
          SpaceH20(),

          // ── Situación administrativa ────────────────────────────────────────
          fieldLabel('Situación administrativa'),
          DropdownButtonFormField<String>(
            value: _companionAdministrativeStatus,
            isExpanded: true,
            isDense: true,
            decoration: inputDecoration.copyWith(hintText: 'Selecciona...'),
            items: [
              'Regular',
              'Irregular',
              'Protección Internacional',
              'En trámite',
              'No lo tengo claro',
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) {
              setState(() {
                _companionAdministrativeStatus = v;
                if (v == 'Irregular') {
                  _companionWorkPermit = false;
                }
              });
            },
            onSaved: (v) => _companionAdministrativeStatus = v,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.greyDark,
              fontSize: fontSize,
            ),
          ),
          SpaceH20(),

          // ── Permiso de trabajo ───────────────────────────────────────────────
          fieldLabel('Permiso de trabajo'),
          Row(
            children: [
              Radio<bool>(
                value: true,
                groupValue: _companionWorkPermit,
                activeColor: AppColors.primaryColor,
                onChanged: (v) => setState(() => _companionWorkPermit = v),
              ),
              Text(
                'Sí',
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 15,
                  color: AppColors.greyDark,
                ),
              ),
              const SizedBox(width: 16),
              Radio<bool>(
                value: false,
                groupValue: _companionWorkPermit,
                activeColor: AppColors.primaryColor,
                onChanged: (v) => setState(() => _companionWorkPermit = v),
              ),
              Text(
                'No',
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 15,
                  color: AppColors.greyDark,
                ),
              ),
            ],
          ),
          if (_companionWorkPermit == true) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: AppColors.greyDark,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Añade la fecha de renovación de tu permiso de trabajo.',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.greyDark,
                      fontWeight: FontWeight.w600,
                      fontSize: fontSize,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: _companionWorkPermitRenewalDate,
              decoration: inputDecoration,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.greyDark,
                fontSize: fontSize,
              ),
              onSaved: (v) => _companionWorkPermitRenewalDate = v,
              onChanged: (v) => _companionWorkPermitRenewalDate = v,
            ),
          ],
          SpaceH20(),

          // ── Tipo de documento + Número ────────────────────────────────────
          Flex(
            direction: Responsive.isMobile(context)
                ? Axis.vertical
                : Axis.horizontal,
            children: [
              Expanded(
                flex: Responsive.isMobile(context) ? 0 : 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    fieldLabel('¿Qué tipo de documento tienes actualmente?'),
                    DropdownButtonFormField<String>(
                      value: _companionDocumentType,
                      isExpanded: true,
                      isDense: true,
                      decoration: inputDecoration.copyWith(
                        hintText: 'Selecciona...',
                      ),
                      items: ['DNI', 'NIE', 'Pasaporte o Cédula de Pasaporte']
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _companionDocumentType = v),
                      onSaved: (v) => _companionDocumentType = v,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.greyDark,
                        fontSize: fontSize,
                      ),
                    ),
                  ],
                ),
              ),
              if (Responsive.isMobile(context))
                SpaceH20()
              else
                const SizedBox(width: 16),
              Expanded(
                flex: Responsive.isMobile(context) ? 0 : 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    fieldLabel('Número de documento'),
                    TextFormField(
                      initialValue: _companionDocumentNumber,
                      decoration: inputDecoration.copyWith(
                        hintText: 'Escribe el número de documento',
                        hintStyle: textTheme.bodySmall?.copyWith(
                          color: AppColors.darkGray,
                          fontSize: fontSize,
                        ),
                      ),
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.greyDark,
                        fontSize: fontSize,
                      ),
                      onSaved: (v) => _companionDocumentNumber = v,
                      onChanged: (v) => _companionDocumentNumber = v,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SpaceH20(),

          // ── ¿Cómo te podemos ayudar? ────────────────────────────────────────
          sectionTitle('¿Cómo te podemos ayudar?'),
          fieldLabel('Selecciona una o varias...'),
          ...[
            'Ocio y tiempo libre',
            'Clases de español',
            'Formación',
            'Competencias digitales - Aula abierta',
            'Acompañamiento jurídico',
            'Acompañamiento hacia el empleo',
          ].map((option) {
            return CheckboxListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: AppColors.primaryColor,
              title: Text(
                option,
                style: textTheme.bodySmall?.copyWith(
                  fontSize: fontSize,
                  color: AppColors.greyDark,
                ),
              ),
              value: _companionHelpNeeds.contains(option),
              onChanged: (checked) {
                setState(() {
                  if (checked == true) {
                    _companionHelpNeeds.add(option);
                  } else {
                    _companionHelpNeeds.remove(option);
                  }
                });
              },
            );
          }),
          CheckboxListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: AppColors.primaryColor,
            title: Text(
              'Otro...(desarrolla)',
              style: textTheme.bodySmall?.copyWith(
                fontSize: fontSize,
                color: AppColors.greyDark,
              ),
            ),
            value: _companionHelpNeedsOther,
            onChanged: (checked) {
              setState(() {
                _companionHelpNeedsOther = checked ?? false;
                if (!_companionHelpNeedsOther)
                  _companionHelpNeedsOtherText = null;
              });
            },
          ),
          if (_companionHelpNeedsOther) ...[
            const SizedBox(height: 8),
            TextFormField(
              initialValue: _companionHelpNeedsOtherText,
              decoration: inputDecoration.copyWith(
                hintText: 'Describe brevemente...',
                hintStyle: textTheme.bodySmall?.copyWith(
                  color: AppColors.darkGray,
                  fontSize: fontSize,
                ),
              ),
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.greyDark,
                fontSize: fontSize,
              ),
              onSaved: (v) => _companionHelpNeedsOtherText = v,
              onChanged: (v) => _companionHelpNeedsOtherText = v,
            ),
          ],
          SpaceH20(),

          // ── Horario de contacto ───────────────────────────────────────────
          fieldLabel(
            '¿En qué horario prefieres que nos pongamos en contacto contigo?',
          ),
          fieldLabel('Selecciona una o varias...'),
          ...['Mañana', 'Tarde'].map((option) {
            return CheckboxListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: AppColors.primaryColor,
              title: Text(
                option,
                style: textTheme.bodySmall?.copyWith(
                  fontSize: fontSize,
                  color: AppColors.greyDark,
                ),
              ),
              value: _companionContactSchedule.contains(option),
              onChanged: (checked) {
                setState(() {
                  if (checked == true) {
                    _companionContactSchedule.add(option);
                  } else {
                    _companionContactSchedule.remove(option);
                  }
                });
              },
            );
          }),
          SpaceH20(),

          // ── ¿Ayuda de profesional? ───────────────────────────────────────
          fieldLabel(
            '¿Te ha ayudado algún/alguna profesional a rellenar este formulario?',
          ),
          Row(
            children: [
              Radio<bool>(
                value: true,
                groupValue: _companionProfessionalHelp,
                activeColor: AppColors.primaryColor,
                onChanged: (v) =>
                    setState(() => _companionProfessionalHelp = v),
              ),
              Text(
                'Sí',
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 15,
                  color: AppColors.greyDark,
                ),
              ),
              const SizedBox(width: 16),
              Radio<bool>(
                value: false,
                groupValue: _companionProfessionalHelp,
                activeColor: AppColors.primaryColor,
                onChanged: (v) =>
                    setState(() => _companionProfessionalHelp = v),
              ),
              Text(
                'No',
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 15,
                  color: AppColors.greyDark,
                ),
              ),
            ],
          ),
          SpaceH20(),

          // ── Otros datos relevantes ───────────────────────────────────────
          sectionTitle('Otros datos relevantes'),
          fieldLabel(
            'Cualquier dato que consideres importante en tu camino hacia al empleo',
          ),
          TextFormField(
            initialValue: _companionOtherRelevantData,
            minLines: 2,
            maxLines: 5,
            decoration: inputDecoration.copyWith(
              hintText: 'Cuéntanos brevemente cualquier otro dato que consideres importante en tu camino hacia al empleo.',
              hintStyle: textTheme.bodySmall?.copyWith(
                color: AppColors.darkGray,
                fontSize: fontSize,
              ),
            ),
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.greyDark,
              fontSize: fontSize,
            ),
            onSaved: (v) => _companionOtherRelevantData = v,
            onChanged: (v) => _companionOtherRelevantData = v,
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form != null && form.validate()) {
      form.save();

      final helpNeedsList = List<String>.from(_companionHelpNeeds);
      if (_companionHelpNeedsOther &&
          (_companionHelpNeedsOtherText?.isNotEmpty ?? false)) {
        helpNeedsList.add('Otro: ${_companionHelpNeedsOtherText!}');
      }

      final updatedCompanionData = CompanionData(
        companionDataId: widget.companionData?.companionDataId,
        userId: widget.user.email.isNotEmpty
            ? widget.user.email
            : (widget.user.userId ?? ''),
        companionFamilySituation: _companionFamilySituation,
        companionDateArriveSpain: _companionDateArriveSpain,
        companionAdministrativeStatus: _companionAdministrativeStatus,
        companionWorkPermit: _companionWorkPermit,
        companionWorkPermitRenewalDate: _companionWorkPermit == true
            ? _companionWorkPermitRenewalDate
            : null,
        companionDocumentType: _companionDocumentType,
        companionDocumentNumber: _companionDocumentNumber,
        companionHelpNeeds: helpNeedsList,
        companionHelpNeedsOther: _companionHelpNeedsOtherText,
        companionContactSchedule: _companionContactSchedule,
        companionProfessionalHelp: _companionProfessionalHelp,
        companionOtherRelevantData: _companionOtherRelevantData,
      );

      try {
        final database = Provider.of<Database>(context, listen: false);
        setState(() => isLoading = true);
        await database.setCompanionData(updatedCompanionData);
        setState(() => isLoading = false);

        if (mounted) {
          showAlertDialog(
            context,
            title: StringConst.UPDATED_DATA_TITLE,
            content:
                'Tus datos de acompañamiento se han actualizado correctamente.',
            defaultActionText: StringConst.FORM_ACCEPT,
          );
        }
      } on FirebaseException catch (e) {
        if (mounted) {
          setState(() => isLoading = false);
          showExceptionAlertDialog(
            context,
            title: StringConst.UPDATE_DATA_ERROR,
            exception: e,
          );
        }
      }
    }
  }
}
