import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:email_validator/email_validator.dart';
import 'package:enreda_app/app/home/models/certificationRequest.dart';
import 'package:enreda_app/app/home/models/competency.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/adaptive.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../common_widgets/custom_raised_button.dart';
import '../../../common_widgets/custom_text.dart';
import '../../../common_widgets/flex_row_column.dart';
import '../../../common_widgets/show_alert_dialog.dart';
import '../../../common_widgets/show_exception_alert_dialog.dart';
import '../../../common_widgets/text_form_field.dart';
import '../../anallytics/analytics.dart';
import '../models/userEnreda.dart';

class CompetencyDetailPage extends StatefulWidget {
  const CompetencyDetailPage({Key? key, required this.user, required this.competency})
      : super(key: key);
  final UserEnreda user;
  final Competency competency;

  @override
  _CompetencyDetailPageState createState() => _CompetencyDetailPageState();
}

class _CompetencyDetailPageState extends State<CompetencyDetailPage> {
  final _formKey = GlobalKey<FormState>();

  String? _email;
  String? _certifierName;
  String? _certifierCompany;
  String? _certifierPosition;
  String? _phone;
  String phoneCode = '+34';
  bool isLoading = false;
  String? codeDialog;
  String? valueText;

  @override
  void initState() {
    super.initState();
    _email = "";
    _certifierName = "";
    _certifierCompany = "";
    _certifierPosition= "";
    _phone = "";
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    double fontSize = responsiveSize(context, 20, 22, md: 22);
    return Scaffold(
      backgroundColor: AppColors.primary010,
      appBar: AppBar(
        title: Text(
          StringConst.COMPETENCY_CERTIFICATION_TITLE,
          textAlign: TextAlign.left,
          style: textTheme.bodySmall?.copyWith(
            color: AppColors.primary900,
            height: 1.5,
            letterSpacing: 0.3,
            fontWeight: FontWeight.w800,
            fontSize: fontSize,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0.0,
        iconTheme: IconThemeData(
          color: AppColors.primary900,
        ),
      ),
      body: _buildContent(context, widget.competency)
    );
  }

  Widget _buildContent(BuildContext context, Competency competency) {
    TextTheme textTheme = Theme.of(context).textTheme;
    double fontSize = responsiveSize(context, 15, 18, md: 16);
    return SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: Responsive.isMobile(context) || Responsive.isTablet(context) ?
            MediaQuery.of(context).size.width * 0.9 : MediaQuery.of(context).size.width * 0.6,
            margin: EdgeInsets.only(top: Responsive.isMobile(context) ? 10 : 80),
            decoration: BoxDecoration(
                color: Constants.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4.0,
                    offset: Offset(0.0, 1.0),
                  ),
                ]),
            padding: EdgeInsets.all(Constants.mainPadding),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SpaceH12(),
                  CustomTextChip(text: competency.name.toUpperCase(), color: AppColors.primary900,),
                  SpaceH12(),
                  CustomTextMedium(text: StringConst.COMPETENCY_INFORMATION),
                  _buildForm(context),
                  SpaceH12(),
                ],
              ),
            )

          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: _buildFormChildren(context),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFormChildren(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    double fontSize = responsiveSize(context, 14, 16, md: 15);
    return [
      SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: Constants.mainPadding / 2),
              CustomFlexRowColumn(
                childLeft: customTextFormFieldName(context, _certifierName!,
                    StringConst.FORM_NAME_CERTIFIER,
                    StringConst.NAME_ERROR,
                    _certifierNameSetState),
                childRight: customTextFormFieldName(context, _certifierCompany!,
                    StringConst.FORM_COMPANY_CERTIFIER,
                    StringConst.FORM_FIELD_ERROR,
                    _certifierCompanySetState),
              ),
              CustomFlexRowColumn(
                childLeft: customTextFormFieldName(context, _certifierPosition!,
                    StringConst.FORM_POSITION_CERTIFIER,
                    StringConst.FORM_FIELD_ERROR,
                    _certifierPositionSetState),
                childRight: TextFormField(
                  decoration: InputDecoration(
                    labelText: StringConst.FORM_EMAIL_CERTIFIER,
                    focusColor: AppColors.primaryColor,
                    labelStyle: textTheme.labelLarge?.copyWith(
                      height: 1.5,
                      color: AppColors.greyDark,
                      fontWeight: FontWeight.w400,
                      fontSize: fontSize,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: BorderSide(
                        color: AppColors.greyUltraLight,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: BorderSide(
                        color: AppColors.greyUltraLight,
                        width: 1.0,
                      ),
                    ),
                  ),
                  initialValue: _email,
                  validator: (value) => EmailValidator.validate(value!) ? null
                      : StringConst.EMAIL_ERROR,
                  onSaved: (value) => _email = value,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) => setState(() => this._email = value),
                  style: textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                    color: AppColors.greyDark,
                    fontWeight: FontWeight.w400,
                    fontSize: fontSize,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(Constants.mainPadding / 2),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: StringConst.FORM_PHONE_CERTIFIER,
                    prefixIcon:CountryCodePicker(
                      dialogSize: Size(350.0, MediaQuery.of(context).size.height * 0.6),
                      onChanged: _onCountryChange,
                      initialSelection: 'ES',
                      showFlagDialog: true,
                    ),
                    focusColor: AppColors.primaryColor,
                    labelStyle: textTheme.labelLarge?.copyWith(
                      height: 1.5,
                      color: AppColors.greyDark,
                      fontWeight: FontWeight.w400,
                      fontSize: fontSize,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: BorderSide(
                        color: AppColors.greyUltraLight,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: BorderSide(
                        color: AppColors.greyUltraLight,
                        width: 1.0,
                      ),
                    ),
                  ),
                  initialValue: _phone,
                  // validator: (value) =>
                  // value!.isNotEmpty ? null : StringConst.PHONE_ERROR,
                  onSaved: (value) => this._phone = phoneCode + value!,
                  textCapitalization: TextCapitalization.sentences,
                  keyboardType: TextInputType.phone,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                  style: textTheme.bodySmall?.copyWith(
                    height: 1.5,
                    color: AppColors.greyDark,
                    fontWeight: FontWeight.w400,
                    fontSize: fontSize,
                  ),
                ),
              ),
              isLoading ? Padding(
                padding: const EdgeInsets.all(30.0),
                child: Center(child: CircularProgressIndicator()),
              ) : CustomButton(
                text: StringConst.COMPETENCY_SEND_REQUEST,
                color: AppColors.primaryColor,
                onPressed: _submit,
              ),
              SizedBox(
                height: 32.0,
              ),
            ]),
      )
    ];
  }

  void _certifierNameSetState(String? val) {
    setState(() => this._certifierName = val!);
  }

  void _certifierCompanySetState(String? val) {
    setState(() => this._certifierCompany = val!);
  }

  void _certifierPositionSetState(String? val) {
    setState(() => this._certifierPosition = val!);
  }

  void _onCountryChange(CountryCode countryCode) {
    this.phoneCode =  countryCode.toString();
  }

  bool _validateAndSaveForm() {
    final form = _formKey.currentState;
    if (form != null)
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<void> _submit() async {
    if (_validateAndSaveForm()) {
      final certificateCompetency = CertificationRequest(
        competencyId: widget.competency.id!,
        competencyName: widget.competency.name,
        email: _email!,
        certifierName: _certifierName!,
        certifierCompany: _certifierCompany!,
        certifierPosition: _certifierPosition!,
        phone: _phone,
        unemployedRequesterId: widget.user.userId!,
        unemployedRequesterName: '${widget.user.firstName!} ${widget.user.lastName!}',
        certified: false,
        referenced: false,
      );
      try {
        final database = Provider.of<Database>(context, listen: false);
        setState(() => isLoading = true);
        await database.addCertificationRequest(certificateCompetency);
        sendBasicAnalyticsEvent(context, "enreda_app_send_certification_request");
        widget.user.competencies[widget.competency.id!] = StringConst.BADGE_PROCESSING;
        database.setUserEnreda(widget.user);
        setState(() => isLoading = false);
        showAlertDialog(
          context,
          title: StringConst.COMPETENCY_REQUEST_TITLE + '${widget.competency.name}',
          content: StringConst.COMPETENCY_REQUEST_DESCRIPTION,
          defaultActionText: StringConst.FORM_ACCEPT,
        ).then((value) => {
          Navigator.pop(context)
        },
        );
      } on FirebaseException catch (e) {
        showExceptionAlertDialog(context,
            title: StringConst.COMPETENCY_REQUEST_ERROR, exception: e).then((value) => Navigator.pop(context));
      }
    }
  }


}
