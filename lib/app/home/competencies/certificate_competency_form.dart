import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enreda_app/common_widgets/custom_raised_button.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common_widgets/background_mobile.dart';
import '../../../common_widgets/custom_text.dart';
import '../../../common_widgets/flex_row_column.dart';
import '../../../common_widgets/show_alert_dialog.dart';
import '../../../common_widgets/show_exception_alert_dialog.dart';
import '../../../utils/adaptive.dart';
import '../../../utils/responsive.dart';
import '../../../values/values.dart';
import '../../anallytics/analytics.dart';
import '../models/certificationRequest.dart';

enum Option { option1, option2 }

class CertificateCompetencyForm extends StatefulWidget {
  const CertificateCompetencyForm({Key? key,
    required this.certificationRequestId,
  })
      : super(key: key);
  final String certificationRequestId;

  @override
  _CertificateCompetencyFormState createState() => _CertificateCompetencyFormState();
}

class _CertificateCompetencyFormState extends State<CertificateCompetencyForm> {
  late CertificationRequest certificationRequest;
  bool? certification = false;
  bool? _isSelected = false;
  bool? _isSelectedData = false;
  bool? _buttonDisabled = false;
  Color _selectedColor = AppColors.greyViolet;
  Color _textColorOpc1 = AppColors.greyDark;
  Color _textColorOpc2 = AppColors.greyDark;
  Color _textColorOne = AppColors.greyDark;
  Color _textColorTwo = AppColors.greyDark;
  bool isLoading = false;
  String? codeDialog;
  String? valueText;
  int? _selectedCertify;
  int? _selectedApprove;
  Color _buttonColor = AppColors.primaryColor;

  @override
  void initState() {
    super.initState();
  }

  void _selectApproval(int choice) {
    setState(() {
      _selectedApprove = choice;
    });
  }

  void _selectCertification(int choice) {
    setState(() {
      _selectedCertify = choice;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, 200),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(),
            ],
          ),
        ),
      ),
      body: Stack(
        alignment: AlignmentDirectional.topCenter,
        children: <Widget>[
          BackgroundMobile(backgroundHeight: BackgroundHeight.ExtraLarge),
          Positioned(
            top: 50,
            child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50.0),
            child: Image.asset(
              ImagePath.LOGO_WHITE,
              height: 40,
            ),
          ),),
          _buildContent()
        ],
      ),
    );
  }

  Widget _buildContent() {
    final database = Provider.of<Database>(context, listen: false);
    return StreamBuilder<CertificationRequest>(
        stream: database.certificationRequestStream(widget.certificationRequestId),
        builder: (context, snapshotCertificationRequest) {
          if (snapshotCertificationRequest.hasData &&
              snapshotCertificationRequest.connectionState == ConnectionState.active) {
            certificationRequest = snapshotCertificationRequest.data!;
            return _buildChild(context, certificationRequest);
          }else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        }
    );
  }

  Widget _buildChild(BuildContext context, CertificationRequest certificationRequest) {
    TextTheme textTheme = Theme.of(context).textTheme;
    double fontSize = responsiveSize(context, 14, 18, md: 15);
    double fontSizeTitle = responsiveSize(context, 16, 25, md: 20);
    return Container(
        width: Responsive.isMobile(context) || Responsive.isTablet(context) ? MediaQuery.of(context).size.width * 0.9 : MediaQuery.of(context).size.width * 0.6,
        margin: EdgeInsets.only(top: 120),
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
              SpaceH20(),
              Text(
                'Solicitud de certificación de competencias',
                textAlign: TextAlign.center,
                style: textTheme.bodyText1?.copyWith(
                  color: AppColors.greyDark,
                  height: 1.5,
                  fontWeight: FontWeight.w800,
                  fontSize: fontSizeTitle,
                ),
              ),
              SpaceH20(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Solicitante:',
                    style: textTheme.bodyText1?.copyWith(
                      color: AppColors.greyDark,
                      height: 1.5,
                      fontWeight: FontWeight.w800,
                      fontSize: fontSize,
                    ),
                  ),
                  SpaceW12(),
                  Text(
                    '${certificationRequest.unemployedRequesterName}',
                    style: textTheme.bodyText1?.copyWith(
                      color: AppColors.greyDark,
                      height: 1.5,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              SpaceH8(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Competencia:',
                    style: textTheme.bodyText1?.copyWith(
                      color: AppColors.greyDark,
                      height: 1.5,
                      fontWeight: FontWeight.w800,
                      fontSize: fontSize,
                    ),
                  ),
                  SpaceW12(),
                  CustomTextTitle(title: certificationRequest.competencyName.toUpperCase()),
                ],
              ),
              SizedBox(height: Constants.mainPadding),
              Text(
                'Selecciona una opción:',
                style: textTheme.bodyText1?.copyWith(
                  color: AppColors.greyDark,
                  height: 1.5,
                  fontWeight: FontWeight.w800,
                  fontSize: fontSize,
                ),
              ),
              _buildFormCertify(context),
              SpaceH12(),
              Divider(),
            ],
          ),
        )

    );
  }

  Widget _buildFormCertify(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    double fontSize = responsiveSize(context, 14, 18, md: 15);
    return Column(
        children: [
          SizedBox(height: Constants.mainPadding / 2),
          Container(
            width: Responsive.isMobile(context) ? 300 : 500,
            child: CustomFlexRowColumn(
              childLeft: Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: ChoiceChip(
                  label: Text('APTO',
                    style: textTheme.bodyText1?.copyWith(
                      color: _textColorOpc1,
                      height: 1.5,
                      fontWeight: FontWeight.w800,
                      fontSize: fontSize,
                    ),),
                  labelPadding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 10),
                  elevation: 1.0,
                  selected: _selectedCertify == 0,
                  selectedColor: _selectedColor,
                  onSelected: (value) {
                    setState(() {
                      _selectCertification(0);
                      _textColorOpc1 = AppColors.white;
                      _textColorOpc2 = AppColors.greyDark;
                      _isSelected = true;
                    });
                  },
                ),
              ),
              childRight: Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: ChoiceChip(
                  label: Text('NO APTO',
                    style: textTheme.bodyText1?.copyWith(
                      color: _textColorOpc2,
                      height: 1.5,
                      fontWeight: FontWeight.w800,
                      fontSize: fontSize,
                    ),),
                  labelPadding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 10),
                  selected: _selectedCertify == 1,
                  selectedColor: _selectedColor,
                  onSelected: (value) {
                    setState(() {
                      _selectCertification(1);
                      _textColorOpc2 = AppColors.white;
                      _textColorOpc1 = AppColors.greyDark;
                      _isSelected = true;
                    });
                  },
                ),
              ),
            ),
          ),
          SizedBox(height: Constants.mainPadding),
          Text(
            '¿Puedo incluir tus datos de contacto en mi CV?',
            style: textTheme.bodyText1?.copyWith(
              color: AppColors.greyDark,
              height: 1.5,
              fontWeight: FontWeight.w800,
              fontSize: fontSize,
            ),
          ),
          SizedBox(height: Constants.mainPadding / 2),
          Container(
            width: 400,
            child: CustomFlexRowColumn(
              childLeft: ChoiceChip(
                label: CustomTextChip(text: 'SI', color: _textColorOne),
                labelPadding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 10),
                selected: _selectedApprove == 0,
                selectedColor: AppColors.greyViolet,
                onSelected: (bool selected) {
                  _selectApproval(0);
                  _textColorOne = AppColors.white;
                  _textColorTwo = AppColors.greyDark;
                  _isSelectedData = true;
                },
              ),
              childRight: ChoiceChip(
                label: CustomTextChip(text: 'NO', color: _textColorTwo),
                labelPadding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 10),
                selected: _selectedApprove == 1,
                selectedColor: AppColors.greyViolet,
                onSelected: (bool selected) {
                  _selectApproval(1);
                  _textColorOne = AppColors.greyDark;
                  _textColorTwo = AppColors.white;
                  _isSelectedData = true;
                },
              ),
            ),
          ),
          SizedBox(height: Constants.mainPadding / 2),
          isLoading ? Padding(
            padding: const EdgeInsets.all(30.0),
            child: Center(child: CircularProgressIndicator()),
          ) :
          CustomButton(
              text: 'Certificar competencia',
              color: _buttonColor,
              onPressed: _buttonDisabled == false ? () async {
                if (_isSelected == true && _isSelectedData == true) {
                  try {
                    final database = Provider.of<Database>(context, listen: false);
                    bool certified = _selectedCertify == 0 ? true : false;
                    bool referenced = _selectedApprove == 0 ? true : false;
                    setState(() => isLoading = true);
                    await database.updateCertificationRequest(certificationRequest, certified, referenced);
                    sendBasicAnalyticsEvent(context, "enreda_app_confirm_certification_request");
                    setState(() {
                      isLoading = false;
                      _buttonColor = AppColors.grey350;
                      _buttonDisabled = true;
                    });
                    showAlertDialog(
                      context,
                      title: '¡Competencia ${certificationRequest.competencyName} ha sido certificada con éxito!',
                      content: 'Muchas gracias por tu información.',
                      defaultActionText: 'ACEPTAR',
                    );
                  } on FirebaseException catch (e) {
                    showExceptionAlertDialog(context,
                        title: 'Error al enviar solicitud, intenta de nuevo.', exception: e).then((value) => Navigator.pop(context));
                  }
                } else {
                  showAlertDialog(context,
                      title: 'Debe seleccionar al menos una opción:',
                      content: _isSelected == true ? '¿Apruebas compartir sus datos de contacto?' : 'Apto o No Apto.',
                      defaultActionText: 'ACEPTAR');
                }
              } : null
          ),
        ]);
  }

}
