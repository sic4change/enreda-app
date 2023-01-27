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
import '../models/certificationRequest.dart';

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
  bool? certification;
  bool? _isSelectedTrue;
  bool? _isSelectedFalse;
  bool? _isSelected;
  bool? _buttonDisabled;
  Color? _selectedColor;
  Color? _textColorSelectedTrue;
  Color? _textColorSelectedFalse;


  @override
  void initState() {
    super.initState();
    certification = false;
    _isSelectedTrue = false;
    _isSelectedFalse = false;
    _textColorSelectedTrue = AppColors.greyDark;
    _textColorSelectedFalse = AppColors.greyDark;
    _selectedColor = AppColors.greyViolet;
    _isSelected = false;
    _buttonDisabled = false;
  }

  String? codeDialog;
  String? valueText;

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
                  CustomTextTitle(title: certificationRequest.competencyName),
                ],
              ),
              SpaceH20(),
              Text(
                'Seleccione una opción:',
                style: textTheme.bodyText1?.copyWith(
                  color: AppColors.greyDark,
                  height: 1.5,
                  fontWeight: FontWeight.w800,
                  fontSize: fontSize,
                ),
              ),
              _buildForm(context),
              SpaceH12(),
              Divider(),

            ],
          ),
        )

    );
  }

  Widget _buildForm(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    double fontSize = responsiveSize(context, 14, 18, md: 15);
    return Column(
        children: [
          SizedBox(height: Constants.mainPadding),
          Container(
            width: Responsive.isMobile(context) ? 300 : 600,
            child: CustomFlexRowColumn(
              childLeft: Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: ChoiceChip(
                  label: Text('APTO',
                    style: textTheme.bodyText1?.copyWith(
                      color: _textColorSelectedTrue,
                      height: 1.5,
                      fontWeight: FontWeight.w800,
                      fontSize: fontSize,
                    ),),
                  labelPadding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 10),
                  elevation: 1.0,
                  selected: _isSelectedTrue!,
                  selectedColor: _selectedColor,
                  onSelected: (value) {
                    setState(() {
                      _isSelectedTrue = value;
                      _isSelectedFalse = false;
                      _textColorSelectedTrue = AppColors.white;
                      _textColorSelectedFalse = AppColors.greyDark;
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
                      color: _textColorSelectedFalse,
                      height: 1.5,
                      fontWeight: FontWeight.w800,
                      fontSize: fontSize,
                    ),),
                  labelPadding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 10),
                  selected: _isSelectedFalse!,
                  selectedColor: _selectedColor,
                  onSelected: (value) {
                    setState(() {
                      _isSelectedFalse = value;
                      _isSelectedTrue = false;
                      _textColorSelectedFalse = AppColors.white;
                      _textColorSelectedTrue = AppColors.greyDark;
                      _isSelected = true;
                    });
                  },
                ),
              ),
            ),
          ),
          SizedBox(height: Constants.mainPadding / 2),
          CustomButton(
              text: 'Certificar competencia',
              color: AppColors.primaryColor,
              onPressed: _buttonDisabled == false ? () async {
                if (_isSelected == true) {
                  try {
                    final database = Provider.of<Database>(context, listen: false);
                    bool selected = _isSelectedTrue == true ? true : false;
                    await database.updateCertificationRequest(certificationRequest, selected);
                    setState(() {
                      _buttonDisabled = true;
                    });
                    showAlertDialog(
                      context,
                      title: 'Competencia ${certificationRequest.competencyName} ha sido certificada con éxito!',
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
                      content: 'Apto o No Apto',
                      defaultActionText: 'ACEPTAR');
                }
              } : null
          ),
        ]);
  }

}
