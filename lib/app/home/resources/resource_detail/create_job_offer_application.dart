import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../common_widgets/custom_form_field.dart';
import '../../../../common_widgets/custom_text.dart';
import '../../../../common_widgets/custom_text_form_field_title.dart';
import '../../../../common_widgets/show_alert_dialog.dart';
import '../../../../common_widgets/show_exception_alert_dialog.dart';
import '../../../../services/auth.dart';
import '../../../../services/database.dart';
import '../../../../utils/adaptive.dart';
import '../../../../utils/functions.dart';
import '../../../../utils/responsive.dart';
import '../../../../values/strings.dart';
import '../../../../values/values.dart';
import '../../documentation/file_data.dart';
import '../../models/jobOfferApplication.dart';
import '../../models/resource.dart';
import '../../models/userEnreda.dart';

class CreateJobOfferApplication extends StatefulWidget {
  CreateJobOfferApplication({Key? key, required this.resource}) : super(key: key);

  final Resource resource;

  @override
  _CreateJobOfferApplicationState createState() => _CreateJobOfferApplicationState();
}

class _CreateJobOfferApplicationState extends State<CreateJobOfferApplication> {
  List<FileData> filesList = [];
  final _formKey = GlobalKey<FormState>();
  TextEditingController textEditingControllerDateInput = TextEditingController();
  late String _documentName = "";
  DateTime _creationDate = new DateTime.now();


  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    double fontSizeButton = responsiveSize(context, 12, 15, md: 13);
    return AlertDialog(
      content: Container(
        width: 500,
        height: Responsive.isMobile(context) ? MediaQuery.of(context).size.height * 0.9 : 550,
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CustomTextBoldCenter(
                title: StringConst.SET_JOB_OFFER_APPLICATION, color: AppColors.primary900,),
              CustomTextBoldCenter(
                title: widget.resource.title, color: AppColors.primary900,),
              SizedBox(height: 20,),
              CustomFormField(
                child: FormField(
                    builder: (FormFieldState<dynamic> field) {
                      return customTextFormMultiline(
                          context,
                          _documentName,
                          '',
                          StringConst.FORM_GENERIC_ERROR,
                          functionsSetState, 2000);
                    }
                ),
                label: StringConst.PRESENTATION_LETTER,
              ),
              SizedBox(height: 20,),
              _buildFinalCheck(context),
              SizedBox(height: 30,),
              Flex(
                direction: Responsive.isMobile(context) ? Axis.vertical : Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                      ),
                      onPressed: () => Navigator.of(context).pop((false)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(StringConst.CANCEL,
                            style: textTheme.bodySmall?.copyWith(
                                color: AppColors.white,
                                height: 1.5,
                                fontWeight: FontWeight.w400,
                                fontSize: fontSizeButton)),
                      )),
                  SizedBox(height: 20,),
                  SizedBox(width: 20,),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                      ),
                      onPressed: () => _submit(),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(StringConst.ADD_JOB_OFFER_APPLICATION,
                            style: textTheme.bodySmall?.copyWith(
                                color: AppColors.white,
                                height: 1.5,
                                fontWeight: FontWeight.w400,
                                fontSize: fontSizeButton)),
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void functionsSetState(String? val) {
    setState(() => _documentName = val!);
  }

  Widget _buildFinalCheck(BuildContext context,){
    final database = Provider.of<Database>(context, listen: false);
    final auth = Provider.of<AuthBase>(context, listen: false);
    TextTheme textTheme = Theme.of(context).textTheme;
    double fontSize = responsiveSize(context, 12, 14, md: 13);
    return StreamBuilder<List<UserEnreda>>(
        stream: database.userStream(auth.currentUser?.email ?? ''),
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.active) {
            UserEnreda? user = snapshot.data!.isNotEmpty ? snapshot.data!.first : null;
            final bool checkFinal = user?.checkAgreeCV ?? false;
            return Row(
              children: [
                user?.checkAgreeCV == true ? Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Icon(Icons.check_box, color: AppColors.primary900),
                ) :
                IconButton(
                    icon: Icon(checkFinal ? Icons.check_box : Icons.crop_square),
                    color: AppColors.primary900,
                    iconSize: 20.0,
                    onPressed: (){
                      showAlertDialog(
                        context,
                        title: 'Aviso',
                        content: 'Se ha guardado la autorización de uso de datos.',
                        defaultActionText: 'Aceptar',
                      );
                      database.setUserEnreda(user!.copyWith(checkAgreeCV: !checkFinal));
                    }
                ),
                Flexible(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: StringConst.FORM_ACCORDING,
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.primary900,
                            height: 1.5,
                            fontSize: fontSize,
                          ),
                        ),
                        TextSpan(
                          text: StringConst.PERSONAL_DATA_LAW,
                          style: textTheme.titleMedium?.copyWith(
                            color: AppColors.primary900,
                            height: 1.5,
                            fontSize: fontSize,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              launchURL(StringConst.PERSONAL_DATA_LAW_PDF);
                            },
                        ),
                        TextSpan(
                          text: StringConst.PERSONAL_DATA_LAW_TEXT,
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.primary900,
                            height: 1.5,
                            fontSize: fontSize,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }

  bool _validateAndSaveForm() {
    if (_formKey.currentState != null &&
        _formKey.currentState!.validate()) {
      _formKey.currentState?.save();
      return true;
    }
    return false;
  }

  Future<void> _submit() async {
    if (_validateAndSaveForm() == false) {
      await showAlertDialog(context,
          title: StringConst.FORM_ENTITY_ERROR,
          content: StringConst.FORM_ENTITY_CHECK,
          defaultActionText: StringConst.CLOSE);
    }
    if (_validateAndSaveForm()) {
      _formKey.currentState!.save();
      final auth = Provider.of<AuthBase>(context, listen: false);
      JobOfferApplication jobOfferApplication = JobOfferApplication(
        jobOfferApplicationId: '',
        jobOfferId: widget.resource.jobOfferId!,
        resourceId: widget.resource.resourceId,
        userId: auth.currentUser!.uid,
        match: 0,
        status: "registered",
        createdate: _creationDate,
        evaluations: {},
        points: {},
      );
      try {
        final database = Provider.of<Database>(context, listen: false);
        await database.addJobOfferApplication(jobOfferApplication);
        await showAlertDialog(
          context,
          title: StringConst.CREATE_JOB_OFFER,
          content: StringConst.CREATE_JOB_OFFER_SUCCESS,
          defaultActionText: StringConst.FORM_ACCEPT,
        );
        Navigator.of(context).pop();
      } on FirebaseException catch (e) {
        showExceptionAlertDialog(context,
            title: StringConst.FORM_ERROR, exception: e).then((value) => Navigator.pop(context));
      }
    }
  }

}

