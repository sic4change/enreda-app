import 'package:cached_network_image/cached_network_image.dart';
import 'package:enreda_app/app/home/curriculum/pdf_generator/my_cv_multiple_pages.dart';
import 'package:enreda_app/app/home/curriculum/pdf_generator/my_cv_one_page.dart';
import 'package:enreda_app/app/home/models/certificationRequest.dart';
import 'package:enreda_app/app/home/models/language.dart';
import 'package:enreda_app/common_widgets/precached_avatar.dart';
import 'package:enreda_app/common_widgets/show_alert_dialog.dart';
import 'package:enreda_app/common_widgets/show_alert_dialog_img.dart';
import 'package:enreda_app/utils/adaptive.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../common_widgets/custom_text.dart';
import '../../../common_widgets/enreda_button.dart';
import '../../../common_widgets/spaces.dart';
import '../../../utils/responsive.dart';
import '../../../values/strings.dart';
import '../models/experience.dart';
import '../models/userEnreda.dart';

class MyCvModelsPage extends StatefulWidget {
  MyCvModelsPage({
    Key? key,
    required this.user,
    required this.city,
    required this.province,
    required this.country,
    required this.myCustomAboutMe,
    required this.myCustomEmail,
    required this.myCustomPhone,
    required this.myExperiences,
    required this.myCustomExperiences,
    required this.mySelectedExperiences,
    required this.myPersonalExperiences,
    required this.myPersonalCustomExperiences,
    required this.myPersonalSelectedExperiences,
    required this.myEducation,
    required this.myCustomEducation,
    required this.mySelectedEducation,
    required this.mySecondaryEducation,
    required this.mySecondaryCustomEducation,
    required this.mySecondarySelectedEducation,
    required this.competenciesNames,
    required this.myCustomCompetencies,
    required this.mySelectedCompetencies,
    required this.myCustomDataOfInterest,
    required this.mySelectedDataOfInterest,
    required this.myCustomLanguages,
    required this.mySelectedLanguages,
    required this.myCustomCity,
    required this.myCustomProvince,
    required this.myCustomCountry,
    required this.myReferences,
    required this.myCustomReferences,
    required this.mySelectedReferences,
    required this.myMaxEducation,
  }) : super(key: key);

  final UserEnreda? user;
  final String? city;
  final String? province;
  final String? country;
  String myCustomCity;
  String myCustomProvince;
  String myCustomCountry;
  String myCustomAboutMe;
  String myCustomEmail;
  String myCustomPhone;
  String myMaxEducation;
  final List<Experience>? myExperiences;
  List<Experience> myCustomExperiences;
  List<int> mySelectedExperiences;
  final List<Experience>? myPersonalExperiences;
  List<Experience> myPersonalCustomExperiences;
  List<int> myPersonalSelectedExperiences;
  final List<Experience>? myEducation;
  List<Experience> myCustomEducation;
  List<int> mySelectedEducation;
  List<Experience>? mySecondaryEducation;
  List<Experience> mySecondaryCustomEducation;
  List<int> mySecondarySelectedEducation;
  final List<String> competenciesNames;
  List<String> myCustomCompetencies;
  List<int> mySelectedCompetencies;
  List<String> myCustomDataOfInterest;
  List<int> mySelectedDataOfInterest;
  List<Language> myCustomLanguages;
  List<int> mySelectedLanguages;
  final List<CertificationRequest>? myReferences;
  List<CertificationRequest> myCustomReferences;
  List<int> mySelectedReferences;

  @override
  _MyCvModelsPageState createState() => _MyCvModelsPageState();
}

class _MyCvModelsPageState extends State<MyCvModelsPage> {
  int? _selectedEducationIndex;
  int? _selectedSecondaryEducationIndex;
  int? _selectedExperienceIndex;
  int? _selectedPersonalExperienceIndex;
  int? _selectedReferenceIndex;
  int? _selectedCompetenciesIndex;
  int? _selectedLanguagesIndex;
  int? _selectedDataOfInterestIndex;
  bool _isSelectedAboutMe = true;
  bool _isSelectedEmail = true;
  bool _isSelectedPhone = true;
  bool _isSelectedMyCity = true;
  bool _isSelectedMyProvince = true;
  bool _isSelectedMyCountry = true;
  bool _isSelectedPhoto = true;
  bool _isSelectedMaxEducation = true;
  String _myMaxEducation = '';
  bool _isSelected2Page = false;
  List<String> printingOptions = ['1 página', '2 o más páginas'];
  String? currentPrintingOption;

  List<int> mySelectedDateEducation = [];
  List<String> idSelectedDateEducation = [];
  List<int> mySelectedDateSecondaryEducation = [];
  List<String> idSelectedDateSecondaryEducation = [];
  List<int>  mySelectedDateExperience = [];
  List<String> idSelectedDateExperience = [];
  List<int>  mySelectedDatePersonalExperience = [];
  List<String> idSelectedDatePersonalExperience = [];

  @override
  void initState() {
    super.initState();
    currentPrintingOption = printingOptions[0];
    _myMaxEducation = widget.myMaxEducation;
    widget.mySelectedEducation.forEach((element) {
      mySelectedDateEducation.add(element);
      idSelectedDateEducation.add(widget.myEducation!.elementAt(element).id!);
    });
    widget.mySecondarySelectedEducation.forEach((element) {
      mySelectedDateSecondaryEducation.add(element);
      idSelectedDateSecondaryEducation.add(widget.mySecondaryEducation!.elementAt(element).id!);
    });
    widget.mySelectedExperiences.forEach((element) {
      mySelectedDateExperience.add(element);
      idSelectedDateExperience.add(widget.myExperiences!.elementAt(element).id!);
    });
    widget.myPersonalSelectedExperiences.forEach((element) {
      mySelectedDatePersonalExperience.add(element);
      idSelectedDatePersonalExperience.add(widget.myPersonalExperiences!.elementAt(element).id!);
    });
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    double fontSize = responsiveSize(context, 20, 22, md: 22);
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Personalizar mi CV',
            textAlign: TextAlign.left,
            style: textTheme.bodySmall?.copyWith(
              color: Constants.white,
              height: 1.5,
              letterSpacing: 0.3,
              fontWeight: FontWeight.w800,
              fontSize: fontSize,
            ),
          ),
          backgroundColor: AppColors.primaryColor,
          elevation: 0.0,
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
        ),
        body: _buildContent(context)
    );
  }


  Widget _buildContent(BuildContext context) {
    return SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Responsive.isDesktop(context) ?
          _myCurriculumWeb(context) :
          _myCurriculumMobile(context),
        ],
      ),
    );
  }

  Widget _myCurriculumWeb(BuildContext context){
    var profilePic = widget.user?.profilePic?.src ?? "";
    return Container(
      margin: EdgeInsets.all(20.0),
      height: MediaQuery.of(context).size.height * 0.90,
      width: MediaQuery.of(context).size.width * 0.80,
      padding: EdgeInsets.all(30.0),
      decoration: BoxDecoration(
        color: Constants.lightLilac,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4.0,
            offset: Offset(0.0, 1.0),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              padding: EdgeInsets.only(
                  top: 20.0, bottom: 20, right: 5, left: 20),
              width: Responsive.isDesktop(context) ? 330 : Responsive.isDesktopS(context) ? 290.0 : 290,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Constants.white,
                shape: BoxShape.rectangle,
                border: Border.all(color: Constants.lilac, width: 1),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: SingleChildScrollView(
                controller: ScrollController(),
                child: Padding(
                  padding: EdgeInsets.only(right: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: (){
                          setState(() {
                            _isSelectedPhoto = !_isSelectedPhoto;
                          });
                        },
                        child: Stack(
                          children: [
                            Padding(
                              padding: Responsive.isMobile(context)
                                  ? const EdgeInsets.all(8.0)
                                  : const EdgeInsets.all(20.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  !kIsWeb ?
                                  ClipRRect(
                                    borderRadius: BorderRadius.all(Radius.circular(60)),
                                    child:
                                    Center(
                                      child:
                                      profilePic == "" ?
                                      Container(
                                        color:  Colors.transparent,
                                        height: 120,
                                        width: 120,
                                        child: Image.asset(ImagePath.USER_DEFAULT),
                                      ):
                                      CachedNetworkImage(
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                          alignment: Alignment.center,
                                          imageUrl: profilePic),
                                    ),
                                  ):
                                  ClipRRect(
                                    borderRadius: BorderRadius.all(Radius.circular(60)),
                                    child:
                                    widget.user?.profilePic?.src == "" ?
                                    Container(
                                      color:  Colors.transparent,
                                      height: 120,
                                      width: 120,
                                      child: Image.asset(ImagePath.USER_DEFAULT),
                                    ):
                                    CachedNetworkImage(
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                        alignment: Alignment.center,
                                        imageUrl: widget.user!.profilePic!.src),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              right: 20,
                              top: 20,
                              child: Icon(
                                _isSelectedPhoto ? Icons.check_box : Icons.crop_square,
                                color: Constants.darkGray,
                                size: 20.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SpaceH20(),
                      _buildPersonalData(context),
                      SpaceH20(),
                      _buildAboutMe(context),
                      SpaceH20(),
                      _buildMyDataOfInterest(context),
                      SpaceH20(),
                      _buildMyLanguages(context),
                      SpaceH20(),
                      _buildMyReferences(context),
                      SpaceH20(),
                    ],
                  ),
                ),
              )),
          SpaceW20(),
          Expanded(
              child: SingleChildScrollView(
                controller: ScrollController(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCVHeader(context),
                    SpaceH40(),
                    _buildMyEducation(context),
                    SpaceH40(),
                    _buildMySecondaryEducation(context),
                    SpaceH40(),
                    _buildMyExperiences(context),
                    SpaceH40(),
                    _buildMyPersonalExperiences(context),
                    SpaceH40(),
                    _buildMyCompetencies(context),
                  ],
                ),
              ))
        ],
      ),
    );
  }

  Widget _myCurriculumMobile(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    var profilePic = widget.user?.profilePic?.src ?? "";
    return SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        margin: EdgeInsets.only(top: Constants.mainPadding, bottom: Constants.mainPadding),
        decoration: BoxDecoration(
          border: Border.all(color: Constants.lightGray, width: 1),
          borderRadius: BorderRadius.all(Radius.circular(40.0)),
          color: Constants.lightLilac,
        ),
        child: Padding(
          padding: EdgeInsets.all(Constants.mainPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        height: 30,
                        width: 180,
                        child: ListTile(
                          title: CustomTextSmall(text: printingOptions[0],),
                          leading: Radio<String>(
                            value: printingOptions[0],
                            groupValue: currentPrintingOption,
                            onChanged: (value) {
                              setState(() {
                                currentPrintingOption = value.toString();
                                _isSelected2Page = false;
                              });
                            },
                          ),
                        ),
                      ),
                      Container(
                        height: 50,
                        width: 180,
                        child: ListTile(
                          title: CustomTextSmall(text: printingOptions[1],),
                          leading: Radio<String>(
                            value: printingOptions[1],
                            groupValue: currentPrintingOption,
                            onChanged: (value) {
                              setState(() {
                                currentPrintingOption = value.toString();
                                _isSelected2Page = true;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: EnredaButton(
                      buttonTitle: "Vista previa",
                      width: 100,
                      onPressed: () async {
                        if(getTotalLeftElements() >= 5 && getTotalRightElements() >= 9 && !_isSelected2Page){
                          showAlertDialog(
                            context,
                            title: StringConst.WARNING,
                            content: StringConst.PAGE_WARNING_5,
                            defaultActionText: StringConst.FORM_ACCEPT,
                            cancelActionText: StringConst.CANCEL,
                          );
                          return;
                        }
                        if(getTotalRightElements() < 9 && _isSelected2Page){
                          showAlertDialog(
                            context,
                            title: StringConst.WARNING,
                            content: StringConst.PAGE_WARNING_1,
                            defaultActionText: StringConst.FORM_ACCEPT,
                            cancelActionText: StringConst.CANCEL,
                          );
                          return;
                        }
                        Navigator.push(
                          context,
                          _isSelected2Page == true ? MaterialPageRoute(
                              builder: (context) =>
                                  MyCvMultiplePages(
                                    user: widget.user!,
                                    myPhoto: _isSelectedPhoto,
                                    city: widget.myCustomCity,
                                    province: widget.myCustomProvince,
                                    country: widget.myCustomCountry,
                                    myExperiences: widget.myCustomExperiences,
                                    myPersonalExperiences: widget.myPersonalCustomExperiences,
                                    myEducation: widget.myCustomEducation,
                                    mySecondaryEducation: widget.mySecondaryCustomEducation,
                                    idSelectedDateEducation: idSelectedDateEducation,
                                    idSelectedDateSecondaryEducation: idSelectedDateSecondaryEducation,
                                    idSelectedDateExperience: idSelectedDateExperience,
                                    idSelectedDatePersonalExperience: idSelectedDatePersonalExperience,
                                    competenciesNames: widget.myCustomCompetencies,
                                    aboutMe: widget.myCustomAboutMe,
                                    languagesNames: widget.myCustomLanguages,
                                    myDataOfInterest: widget.myCustomDataOfInterest,
                                    myCustomEmail: widget.myCustomEmail,
                                    myCustomPhone: widget.myCustomPhone,
                                    myCustomReferences: widget.myCustomReferences,
                                    myMaxEducation: _myMaxEducation,
                                  )) :
                          MaterialPageRoute(
                              builder: (context) =>
                                  MyCvOnePage(
                                    user: widget.user!,
                                    myPhoto: _isSelectedPhoto,
                                    city: widget.myCustomCity,
                                    province: widget.myCustomProvince,
                                    country: widget.myCustomCountry,
                                    myExperiences: widget.myCustomExperiences,
                                    myPersonalExperiences: widget.myPersonalCustomExperiences,
                                    myEducation: widget.myCustomEducation,
                                    mySecondaryEducation: widget.mySecondaryCustomEducation,
                                    idSelectedDateEducation: idSelectedDateEducation,
                                    idSelectedDateSecondaryEducation: idSelectedDateSecondaryEducation,
                                    idSelectedDateExperience: idSelectedDateExperience,
                                    idSelectedDatePersonalExperience: idSelectedDatePersonalExperience,
                                    competenciesNames: widget.myCustomCompetencies,
                                    aboutMe: widget.myCustomAboutMe,
                                    languagesNames: widget.myCustomLanguages,
                                    myDataOfInterest: widget.myCustomDataOfInterest,
                                    myCustomEmail: widget.myCustomEmail,
                                    myCustomPhone: widget.myCustomPhone,
                                    myCustomReferences: widget.myCustomReferences,
                                    myMaxEducation: _myMaxEducation,
                                  )),
                        );
                      },
                    ),
                  ),
                ],
              ),
              SpaceH12(),
              InkWell(
                onTap: (){
                  setState(() {
                    _isSelectedPhoto = !_isSelectedPhoto;
                  });
                },
                child: Stack(
                  children: [
                    Padding(
                      padding: Responsive.isMobile(context)
                          ? const EdgeInsets.all(8.0)
                          : const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          !kIsWeb ?
                          ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(60)),
                            child:
                            Center(
                              child:
                              profilePic == "" ?
                              Container(
                                color:  Colors.transparent,
                                height: 120,
                                width: 120,
                                child: Image.asset(ImagePath.USER_DEFAULT),
                              ):
                              CachedNetworkImage(
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  alignment: Alignment.center,
                                  imageUrl: profilePic),
                            ),
                          ):
                          ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(60)),
                            child:
                            widget.user?.profilePic?.src == "" ?
                            Container(
                              color:  Colors.transparent,
                              height: 120,
                              width: 120,
                              child: Image.asset(ImagePath.USER_DEFAULT),
                            ):
                            CachedNetworkImage(
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                              imageUrl: widget.user!.profilePic!.src),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 20,
                      top: 20,
                      child: Icon(
                        _isSelectedPhoto ? Icons.check_box : Icons.crop_square,
                        color: Constants.darkGray,
                        size: 20.0,
                      ),
                    ),
                  ],
                ),
              ),
              Responsive.isMobile(context) ? SpaceH12() : SpaceH24(),
              Text(
                '${widget.user?.firstName} ${widget.user?.lastName}',
                style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                    fontSize: Responsive.isDesktop(context) ? 45.0 : 32.0,
                    color: AppColors.turquoiseBlue),
                textAlign: TextAlign.center,
              ),
              SpaceH24(),
              InkWell(
                onTap: (){
                  setState(() {
                    _isSelectedMaxEducation = !_isSelectedMaxEducation;
                    if (_myMaxEducation == ""){
                      _myMaxEducation = widget.myMaxEducation;
                    } else {
                      _myMaxEducation = "";
                    }
                  });
                },
                child: Row(
                  children: [
                    CustomTextSmall(text: widget.myMaxEducation),
                    SpaceW8(),
                    Icon(
                      _isSelectedMaxEducation ? Icons.check_box : Icons.crop_square,
                      color: Constants.darkGray,
                      size: 20.0,
                    ),
                  ],
                ),
              ),
              SpaceH24(),
              _buildMyEducation(context),
              SpaceH24(),
              _buildMySecondaryEducation(context),
              SpaceH24(),
              _buildMyExperiences(context),
              SpaceH24(),
              _buildMyPersonalExperiences(context),
              SpaceH24(),
              _buildMyCompetencies(context),
              SpaceH24(),
              _buildPersonalData(context),
              SpaceH24(),
              _buildAboutMe(context),
              SpaceH24(),
              _buildMyDataOfInterest(context),
              SpaceH24(),
              _buildMyLanguages(context),
              SpaceH24(),
              _buildMyReferences(context),
              SpaceH24(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCVHeader(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  height: 30,
                  width: 220,
                  child: ListTile(
                    title: CustomTextSmall(text: printingOptions[0],),
                    leading: Radio<String>(
                      value: printingOptions[0],
                      groupValue: currentPrintingOption,
                      onChanged: (value) {
                        setState(() {
                          currentPrintingOption = value.toString();
                          _isSelected2Page = false;
                        });
                      },
                    ),
                  ),
                ),
                Container(
                  height: 30,
                  width: 220,
                  child: ListTile(
                    title: CustomTextSmall(text: printingOptions[1],),
                    leading: Radio<String>(
                      value: printingOptions[1],
                      groupValue: currentPrintingOption,
                      onChanged: (value) {
                        setState(() {
                          currentPrintingOption = value.toString();
                          _isSelected2Page = true;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            Spacer(),
            EnredaButton(
              buttonTitle: "Vista previa",
              width: 100,
              onPressed: () async {
                if(getTotalLeftElements() >= 5 && !_isSelected2Page) {
                  showAlertDialogImg(
                    context,
                    title: StringConst.WARNING,
                    content: StringConst.PAGE_WARNING_4,
                    defaultActionText: StringConst.FORM_ACCEPT,
                    image: Container(
                      width: 300,
                      height: 450,
                      child: Image.asset(ImagePath.CV_WARNING_2)
                    ),
                  );
                  return;
                }
                if(getTotalRightElements() >= 9 && !_isSelected2Page){
                  showAlertDialogImg(
                    context,
                    title: StringConst.WARNING,
                    content: StringConst.PAGE_WARNING_2,
                    defaultActionText: StringConst.FORM_ACCEPT,
                    image: Container(
                        width: 300,
                        height: 450,
                        child: Image.asset(ImagePath.CV_WARNING_1)
                    ),
                  );
                  return;
                }
                if(getTotalRightElements() < 9 && _isSelected2Page){
                  showAlertDialogImg(
                    context,
                    title: StringConst.WARNING,
                    content: StringConst.PAGE_WARNING_1,
                    defaultActionText: StringConst.OK,
                    image: Container(
                        width: 300,
                        height: 450,
                        child: Image.asset(ImagePath.CV_WARNING_1)
                    ),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  _isSelected2Page == true ? MaterialPageRoute(
                      builder: (context) =>
                          MyCvMultiplePages(
                            user: widget.user!,
                            myPhoto: _isSelectedPhoto,
                            city: widget.myCustomCity,
                            province: widget.myCustomProvince,
                            country: widget.myCustomCountry,
                            myExperiences: widget.myCustomExperiences,
                            myPersonalExperiences: widget.myPersonalCustomExperiences,
                            myEducation: widget.myCustomEducation,
                            mySecondaryEducation: widget.mySecondaryCustomEducation,
                            idSelectedDateEducation: idSelectedDateEducation,
                            idSelectedDateSecondaryEducation: idSelectedDateSecondaryEducation,
                            idSelectedDateExperience: idSelectedDateExperience,
                            idSelectedDatePersonalExperience: idSelectedDatePersonalExperience,
                            competenciesNames: widget.myCustomCompetencies,
                            aboutMe: widget.myCustomAboutMe,
                            languagesNames: widget.myCustomLanguages,
                            myDataOfInterest: widget.myCustomDataOfInterest,
                            myCustomEmail: widget.myCustomEmail,
                            myCustomPhone: widget.myCustomPhone,
                            myCustomReferences: widget.myCustomReferences,
                            myMaxEducation: _myMaxEducation,
                          )) :
                  MaterialPageRoute(
                      builder: (context) =>
                          MyCvOnePage(
                            user: widget.user!,
                            myPhoto: _isSelectedPhoto,
                            city: widget.myCustomCity,
                            province: widget.myCustomProvince,
                            country: widget.myCustomCountry,
                            myExperiences: widget.myCustomExperiences,
                            myPersonalExperiences: widget.myPersonalCustomExperiences,
                            myEducation: widget.myCustomEducation,
                            mySecondaryEducation: widget.mySecondaryCustomEducation,
                            idSelectedDateEducation: idSelectedDateEducation,
                            idSelectedDateSecondaryEducation: idSelectedDateSecondaryEducation,
                            idSelectedDateExperience: idSelectedDateExperience,
                            idSelectedDatePersonalExperience: idSelectedDatePersonalExperience,
                            competenciesNames: widget.myCustomCompetencies,
                            aboutMe: widget.myCustomAboutMe,
                            languagesNames: widget.myCustomLanguages,
                            myDataOfInterest: widget.myCustomDataOfInterest,
                            myCustomEmail: widget.myCustomEmail,
                            myCustomPhone: widget.myCustomPhone,
                            myCustomReferences: widget.myCustomReferences,
                            myMaxEducation: _myMaxEducation,
                          )),
                );
              },
            ),
          ],
        ),
        SpaceH20(),
        Text(
          '${widget.user?.firstName} ${widget.user?.lastName}',
          style: textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: Responsive.isDesktop(context) ? 45.0 : 32.0,
              color: AppColors.turquoiseBlue),
        ),
        SpaceH20(),
        InkWell(
          onTap: (){
            setState(() {
              _isSelectedMaxEducation = !_isSelectedMaxEducation;
              if (_myMaxEducation == ""){
                _myMaxEducation = widget.myMaxEducation;
              } else {
                _myMaxEducation = "";
              }
            });
          },
          child: Row(
            children: [
              CustomTextSmall(text: widget.myMaxEducation),
              SpaceW8(),
              Icon(
                _isSelectedMaxEducation ? Icons.check_box : Icons.crop_square,
                color: Constants.darkGray,
                size: 20.0,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAboutMe(BuildContext context) {
    String aboutMe = widget.user?.aboutMe ?? '';
    return StatefulBuilder(builder: (context, setState) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child:
                CustomTextTitle(title: StringConst.ABOUT_ME.toUpperCase()),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30.0),
              color: Constants.white,
            ),
            child: InkWell(
              onTap: (){
                setState(() {
                  _isSelectedAboutMe = !_isSelectedAboutMe;
                  if (widget.myCustomAboutMe == ""){
                    widget.myCustomAboutMe = aboutMe;
                  } else {
                    widget.myCustomAboutMe = "";
                  }
                });
              },
              child: Row(
                children: [
                  Expanded(
                    child: CustomTextBody(
                        text: widget.user?.aboutMe != null && widget.user!.aboutMe!.isNotEmpty
                            ? widget.user!.aboutMe!
                            : 'Aún no has añadido información adicional sobre ti'),
                  ),
                  SpaceW8(),
                  Icon(
                    _isSelectedAboutMe ? Icons.check_box : Icons.crop_square,
                    color: Constants.darkGray,
                    size: 20.0,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildPersonalData(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    String email = widget.user?.email ?? '';
    String phone = widget.user?.phone ?? '';
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextTitle(title: StringConst.PERSONAL_DATA.toUpperCase()),
        SpaceH4(),
        Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            color: Constants.white,
          ),
          child: Column(
            children: [
              InkWell(
                onTap: (){
                  setState(() {
                    _isSelectedEmail = !_isSelectedEmail;
                    if (widget.myCustomEmail == ""){
                      widget.myCustomEmail = email;
                    } else {
                      widget.myCustomEmail = "";
                    }
                  });
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.mail,
                      color: Constants.darkGray,
                      size: 12.0,
                    ),
                    SpaceW4(),
                    Expanded(
                      child: Text(
                        widget.user?.email ?? '',
                        style: textTheme.bodySmall?.copyWith(
                            fontSize: Responsive.isDesktop(context) ? 14 : 14.0,
                            color: Constants.darkGray),
                      ),
                    ),
                    SpaceW8(),
                    Icon(
                      _isSelectedEmail ? Icons.check_box : Icons.crop_square,
                      color: Constants.darkGray,
                      size: 20.0,
                    ),
                  ],
                ),
              ),
              SpaceH8(),
              InkWell(
                onTap: (){
                  setState(() {
                    _isSelectedPhone = !_isSelectedPhone;
                    if (widget.myCustomPhone == ""){
                      widget.myCustomPhone = phone;
                    } else {
                      widget.myCustomPhone = "";
                    }
                  });
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.phone,
                      color: Constants.darkGray,
                      size: 12.0,
                    ),
                    SpaceW4(),
                    Expanded(
                      child: Text(
                        widget.user?.phone ?? '',
                        style: textTheme.bodySmall?.copyWith(
                            fontSize: Responsive.isDesktop(context) ? 14 : 14.0,
                            color: Constants.darkGray),
                      ),
                    ),
                    SpaceW8(),
                    Icon(
                      _isSelectedPhone ? Icons.check_box : Icons.crop_square,
                      color: Constants.darkGray,
                      size: 20.0,
                    ),
                  ],
                ),
              ),
              SpaceH8(),
              _buildMyLocation(context),
            ],
          ),
        ),

      ],
    );
  }

  Widget _buildMyLocation(BuildContext context) {
    String myCity = widget.city ?? '';
    String myProvince = widget.province ?? '';
    String myCountry = widget.country ?? '';
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.location_on,
          color: Colors.black.withOpacity(0.7),
          size: 16,
        ),
        SpaceW4(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: (){
                setState(() {
                  _isSelectedMyCity = !_isSelectedMyCity;
                  if (widget.myCustomCity == ""){
                    widget.myCustomCity = myCity;
                  } else {
                    widget.myCustomCity = "";
                  }
                });
              },
              child: Row(
                children: [
                  CustomTextSmall(text: widget.city ?? ''),
                  SpaceW8(),
                  Icon(
                    _isSelectedMyCity ? Icons.check_box : Icons.crop_square,
                    color: Constants.darkGray,
                    size: 20.0,
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: (){
                setState(() {
                  _isSelectedMyProvince = !_isSelectedMyProvince;
                  if (widget.myCustomProvince == ""){
                    widget.myCustomProvince = myProvince;
                  } else {
                    widget.myCustomProvince = "";
                  }
                });
              },
              child: Row(
                children: [
                  CustomTextSmall(text: widget.province ?? ''),
                  SpaceW8(),
                  Icon(
                    _isSelectedMyProvince ? Icons.check_box : Icons.crop_square,
                    color: Constants.darkGray,
                    size: 20.0,
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: (){
                setState(() {
                  _isSelectedMyCountry = !_isSelectedMyCountry;
                  if (widget.myCustomCountry == ""){
                    widget.myCustomCountry = myCountry;
                  } else {
                    widget.myCustomCountry = "";
                  }
                });
              },
              child: Row(
                children: [
                  CustomTextSmall(text: widget.country ?? ''),
                  SpaceW8(),
                  Icon(
                    _isSelectedMyCountry ? Icons.check_box : Icons.crop_square,
                    color: Constants.darkGray,
                    size: 20.0,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );

  }

  Widget _buildMyCompetencies(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextTitle(title: StringConst.COMPETENCIES.toUpperCase()),
        SpaceH4(),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            color: Constants.white,
          ),
          child: widget.competenciesNames.isNotEmpty ?
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: widget.competenciesNames.length,
            itemBuilder: (context, index) {
              return Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(vertical: 0),
                  child: ListTile(
                    selected: index == _selectedCompetenciesIndex,
                    onTap: (){
                      print('selected item: ${widget.competenciesNames[index]}');
                      bool exists = widget.myCustomCompetencies.any((element) => element == widget.competenciesNames[index]);
                      setState(() {
                        _selectedCompetenciesIndex = index;
                        if (exists == true){
                          widget.myCustomCompetencies.remove(widget.competenciesNames[index]);
                          widget.mySelectedCompetencies.remove(_selectedCompetenciesIndex);
                        } else {
                          widget.myCustomCompetencies.add(widget.competenciesNames[index]);
                          widget.mySelectedCompetencies.add(_selectedCompetenciesIndex!);
                        }
                        print(widget.myCustomCompetencies);
                        print(widget.mySelectedCompetencies);
                      });
                    },
                    title: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                                widget.competenciesNames[index],
                                style: textTheme.bodySmall
                                    ?.copyWith(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w500,
                                    color: Constants.darkGray)
                            ),
                          ),
                          Icon(
                            widget.mySelectedCompetencies.contains(index) ? Icons.check_box : Icons.crop_square,
                            color: Constants.darkGray,
                            size: 20.0,
                          ),
                        ],
                      ),
                    ),
                  )

              );
            },
          ) :
          Padding(
            padding: EdgeInsets.all(Constants.mainPadding),
            child: Center(
                child: Text(
                  'Aquí aparecerán las competencias evaluadas a través de los microtests',
                  style: textTheme.bodySmall,
                )),
          ),
        ),

      ],
    );
  }

  Widget _buildMyEducation(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final DateFormat formatter = DateFormat('yyyy');
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextTitle(title: StringConst.EDUCATION.toUpperCase()),
        SpaceH4(),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            color: Constants.white,
          ),
          child: widget.myEducation!.isNotEmpty
              ?
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: widget.myEducation!.length,
            itemBuilder: (context, index) {
              return Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(vertical: 0),
                child: ListTile(
                  selected: index == _selectedEducationIndex,
                  title: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text(widget.myEducation![index].institution != null && widget.myEducation![index].nameFormation != null && widget.myEducation![index].nameFormation != "" ?
                              '${widget.myEducation![index].institution} - ${widget.myEducation![index].nameFormation}' :
                              widget.myEducation![index].institution == null && widget.myEducation![index].nameFormation != null ?
                              '${widget.myEducation![index].nameFormation}' : widget.myEducation![index].nameFormation == null && widget.myEducation![index].institution != null ?
                              '${widget.myEducation![index].institution}' : '',
                                  style: textTheme.bodySmall?.copyWith(fontSize: 14.0, fontWeight: FontWeight.bold)),
                              if (widget.myEducation![index].organization != null && widget.myEducation![index].organization != "") Column(
                                children: [
                                  Text(
                                    widget.myEducation![index].organization!,
                                    style: textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text('${widget.myEducation![index].startDate != null ? formatter.format(widget.myEducation![index].startDate!.toDate())
                                      : '-'} / ${widget.myEducation![index].endDate != null ? formatter.format(widget.myEducation![index].endDate!.toDate()) : 'Actualmente' }',
                                    style: textTheme.bodySmall?.copyWith(
                                      fontSize: 14.0,
                                    ),
                                  ),
                                  SpaceW8(),
                                  IconButton(
                                    icon: Icon(mySelectedDateEducation.contains(index) ? Icons.check_box : Icons.crop_square),
                                    color: Constants.darkGray,
                                    iconSize: 15.0,
                                    onPressed: (){

                                      setState(() {
                                        if(widget.mySelectedEducation.contains(index)){
                                          if(mySelectedDateEducation.contains(index)){
                                            mySelectedDateEducation.remove(index);
                                            idSelectedDateEducation.remove(widget.myEducation!.elementAt(index).id);
                                          }
                                          else {
                                            mySelectedDateEducation.add(index);
                                            idSelectedDateEducation.add(widget.myEducation!.elementAt(index).id!);
                                          }
                                          //print(widget.mySelectedEducation);
                                          //print(mySelectedDateEducation);
                                          idSelectedDateEducation.forEach((element) {print(element);});
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                              Text(
                                widget.myEducation![index].location,
                                style: textTheme.bodySmall?.copyWith(
                                  fontSize: 14.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: (){
                            print('selected item: ${widget.myEducation![index].activity}');
                            bool exists = widget.myCustomEducation.any((element) => element.id == widget.myEducation![index].id);
                            setState(() {
                              _selectedEducationIndex = index;
                              if (exists == true){
                                widget.myCustomEducation.remove(widget.myEducation![index]);
                                widget.mySelectedEducation.remove(_selectedEducationIndex);
                                //Disguise date
                                mySelectedDateEducation.remove(index);
                                idSelectedDateEducation.remove(widget.myEducation!.elementAt(index).id);
                              } else {
                                widget.myCustomEducation.add(widget.myEducation![index]);
                                widget.mySelectedEducation.add(_selectedEducationIndex!);
                                //Show date
                                mySelectedDateEducation.add(index);
                                idSelectedDateEducation.add(widget.myEducation!.elementAt(index).id!);
                              }
                              print(widget.myCustomEducation);
                              print(widget.mySelectedEducation);
                            });
                          },
                          icon: Icon(widget.mySelectedEducation.contains(index) ? Icons.check_box : Icons.crop_square),
                          iconSize: 20,
                          color: Constants.darkGray,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          )
              : Padding(
            padding: EdgeInsets.all(Constants.mainPadding),
            child: Center(child: CustomTextBody(text: StringConst.NO_EDUCATION)),
          ),
        ),
      ],
    );
  }

  Widget _buildMySecondaryEducation(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final DateFormat formatter = DateFormat('yyyy');
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextTitle(title: StringConst.SECONDARY_EDUCATION.toUpperCase()),
        SpaceH4(),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            color: Constants.white,
          ),
          child: widget.mySecondaryEducation!.isNotEmpty
              ?
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: widget.mySecondaryEducation!.length,
            itemBuilder: (context, index) {
              return Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(vertical: 0),
                child: ListTile(
                  selected: index == _selectedSecondaryEducationIndex,
                  title: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text(widget.mySecondaryEducation![index].institution != null && widget.mySecondaryEducation![index].nameFormation != null && widget.mySecondaryEducation![index].nameFormation != "" ?
                              '${widget.mySecondaryEducation![index].institution} - ${widget.mySecondaryEducation![index].nameFormation}' :
                              widget.mySecondaryEducation![index].institution == null && widget.mySecondaryEducation![index].nameFormation != null ?
                              '${widget.mySecondaryEducation![index].nameFormation}' : widget.mySecondaryEducation![index].nameFormation == null && widget.mySecondaryEducation![index].institution != null ?
                              '${widget.mySecondaryEducation![index].institution}' : '',
                                  style: textTheme.bodySmall?.copyWith(fontSize: 14.0, fontWeight: FontWeight.bold)),
                              if (widget.mySecondaryEducation![index].organization != null && widget.mySecondaryEducation![index].organization != "") Column(
                                children: [
                                  Text(
                                    widget.mySecondaryEducation![index].organization!,
                                    style: textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text('${widget.mySecondaryEducation![index].startDate != null ? formatter.format(widget.mySecondaryEducation![index].startDate!.toDate())
                                      : '-'} / ${widget.mySecondaryEducation![index].endDate != null ? formatter.format(widget.mySecondaryEducation![index].endDate!.toDate()) : 'Actualmente' }',
                                    style: textTheme.bodySmall?.copyWith(
                                      fontSize: 14.0,
                                    ),
                                  ),
                                  SpaceW8(),
                                  IconButton(
                                    icon: Icon(mySelectedDateSecondaryEducation.contains(index) ? Icons.check_box : Icons.crop_square),
                                    color: Constants.darkGray,
                                    iconSize: 15.0,
                                    onPressed: (){

                                      setState(() {
                                        if(widget.mySecondarySelectedEducation.contains(index)){
                                          if(mySelectedDateSecondaryEducation.contains(index)){
                                            mySelectedDateSecondaryEducation.remove(index);
                                            idSelectedDateSecondaryEducation.remove(widget.mySecondaryEducation!.elementAt(index).id);
                                          }
                                          else {
                                            mySelectedDateSecondaryEducation.add(index);
                                            idSelectedDateSecondaryEducation.add(widget.mySecondaryEducation!.elementAt(index).id!);
                                          }
                                          idSelectedDateSecondaryEducation.forEach((element) {print(element);});
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                              Text(
                                widget.mySecondaryEducation![index].location,
                                style: textTheme.bodySmall?.copyWith(
                                  fontSize: 14.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: (){
                            print('selected item: ${widget.mySecondaryEducation![index].activity}');
                            bool exists = widget.mySecondaryCustomEducation.any((element) => element.id == widget.mySecondaryEducation![index].id);
                            setState(() {
                              _selectedSecondaryEducationIndex = index;
                              if (exists == true){
                                widget.mySecondaryCustomEducation.remove(widget.mySecondaryEducation![index]);
                                widget.mySecondarySelectedEducation.remove(_selectedSecondaryEducationIndex);
                                //Disguise date
                                mySelectedDateSecondaryEducation.remove(index);
                                idSelectedDateSecondaryEducation.remove(widget.mySecondaryEducation!.elementAt(index).id);
                              } else {
                                widget.mySecondaryCustomEducation.add(widget.mySecondaryEducation![index]);
                                widget.mySecondarySelectedEducation.add(_selectedSecondaryEducationIndex!);
                                //Show date
                                mySelectedDateSecondaryEducation.add(index);
                                idSelectedDateSecondaryEducation.add(widget.mySecondaryEducation!.elementAt(index).id!);
                              }
                              print(widget.mySecondaryCustomEducation);
                              print(widget.mySecondarySelectedEducation);
                            });
                          },
                          icon: Icon(widget.mySecondarySelectedEducation.contains(index) ? Icons.check_box : Icons.crop_square),
                          iconSize: 20,
                          color: Constants.darkGray,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          )
              : Padding(
            padding: EdgeInsets.all(Constants.mainPadding),
            child: Center(child: CustomTextBody(text: StringConst.NO_EDUCATION)),
          ),
        ),
      ],
    );
  }

  Widget _buildMyExperiences(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final DateFormat formatter = DateFormat('yyyy');
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextTitle(title: StringConst.MY_PROFESIONAL_EXPERIENCES.toUpperCase()),
        SpaceH4(),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            color: Constants.white,
          ),
          child: widget.myExperiences!.isNotEmpty
              ?
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: widget.myExperiences!.length,
            itemBuilder: (context, index) {
              return Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(vertical: 0),
                child: ListTile(
                  selected: index == _selectedExperienceIndex,
                  title: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              if (widget.myExperiences![index].activity != null)
                                Text(
                                  '${widget.myExperiences![index].activity!}',
                                  style: textTheme.bodySmall?.copyWith(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              Text(widget.myExperiences![index].organization != null && widget.myExperiences![index].organization != "" &&
                                  widget.myExperiences![index].position != null && widget.myExperiences![index].position != "" ?
                              '${widget.myExperiences![index].position} - ${widget.myExperiences![index].organization}' :
                              widget.myExperiences![index].organization != null && widget.myExperiences![index].organization != "" ?
                              '${widget.myExperiences![index].organization}' : widget.myExperiences![index].position != null && widget.myExperiences![index].position != "" ?
                              '${widget.myExperiences![index].position}' : '',
                                  style: textTheme.bodySmall?.copyWith(fontSize: 14.0, fontWeight: FontWeight.bold)),
                              Row(
                                children: [
                                  Text('${widget.myExperiences![index].startDate != null ? formatter.format(widget.myExperiences![index].startDate!.toDate())
                                      : '-'} / ${widget.myExperiences![index].endDate != null ? formatter.format(widget.myExperiences![index].endDate!.toDate()) : 'Actualmente' }',
                                    style: textTheme.bodySmall?.copyWith(
                                      fontSize: 14.0,
                                    ),
                                  ),
                                  SpaceW8(),
                                  IconButton(
                                    icon: Icon(mySelectedDateExperience.contains(index) ? Icons.check_box : Icons.crop_square),
                                    color: Constants.darkGray,
                                    iconSize: 15.0,
                                    onPressed: (){

                                      setState(() {
                                        if(widget.mySelectedExperiences.contains(index)){
                                          if(mySelectedDateExperience.contains(index)){
                                            mySelectedDateExperience.remove(index);
                                            idSelectedDateExperience.remove(widget.myExperiences!.elementAt(index).id);
                                          }
                                          else {
                                            mySelectedDateExperience.add(index);
                                            idSelectedDateExperience.add(widget.myExperiences!.elementAt(index).id!);
                                          }
                                          idSelectedDateExperience.forEach((element) {print(element);});
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                              Text(
                                widget.myExperiences![index].location,
                                style: textTheme.bodySmall?.copyWith(
                                  fontSize: 14.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: (){
                            print('selected item: ${widget.myExperiences![index].activity}');
                            bool exists = widget.myCustomExperiences.any((element) => element.id == widget.myExperiences![index].id);
                            setState(() {
                              _selectedExperienceIndex = index;
                              if (exists == true){
                                widget.myCustomExperiences.remove(widget.myExperiences![index]);
                                widget.mySelectedExperiences.remove(_selectedExperienceIndex);
                                //Disguise date
                                mySelectedDateExperience.remove(index);
                                idSelectedDateExperience.remove(widget.myExperiences!.elementAt(index).id);
                              } else {
                                widget.myCustomExperiences.add(widget.myExperiences![index]);
                                widget.mySelectedExperiences.add(_selectedExperienceIndex!);
                                //Show date
                                mySelectedDateExperience.add(index);
                                idSelectedDateExperience.add(widget.myExperiences!.elementAt(index).id!);
                              }
                              print(widget.myCustomExperiences);
                              print(widget.mySelectedExperiences);
                            });
                          },
                          icon: Icon(widget.mySelectedExperiences.contains(index) ? Icons.check_box : Icons.crop_square),
                          iconSize: 20,
                          color: Constants.darkGray,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          )
              : Padding(
            padding: EdgeInsets.all(Constants.mainPadding),
            child: Center(child: CustomTextBody(text: StringConst.NO_EDUCATION)),
          ),
        ),
      ],
    );
  }

  Widget _buildMyPersonalExperiences(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final DateFormat formatter = DateFormat('yyyy');
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextTitle(title: StringConst.MY_PERSONAL_EXPERIENCES.toUpperCase()),
        SpaceH4(),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            color: Constants.white,
          ),
          child: widget.myPersonalExperiences!.isNotEmpty
              ?
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: widget.myPersonalExperiences!.length,
            itemBuilder: (context, index) {
              return Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(vertical: 0),
                child: ListTile(
                  selected: index == _selectedPersonalExperienceIndex,
                  title: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text(widget.myPersonalExperiences![index].subtype == 'Responsabilidades familiares' || widget.myPersonalExperiences![index].subtype == 'Compromiso social' ? '${widget.myPersonalExperiences![index].subtype}' :
                              widget.myPersonalExperiences![index].subtype != null && widget.myPersonalExperiences![index].activityRole != null && widget.myPersonalExperiences![index].activity != null ?
                              '${widget.myPersonalExperiences![index].subtype} - ${widget.myPersonalExperiences![index].activityRole} - ${widget.myPersonalExperiences![index].activity}' :
                              widget.myPersonalExperiences![index].activityRole != null && widget.myPersonalExperiences![index].activity != null ?
                              '${widget.myPersonalExperiences![index].activityRole} - ${widget.myPersonalExperiences![index].activity}' : widget.myPersonalExperiences![index].activity != null && widget.myPersonalExperiences![index].subtype != null ?
                              '${widget.myPersonalExperiences![index].activity} - ${widget.myPersonalExperiences![index].subtype}' : widget.myPersonalExperiences![index].activity != null ? '${widget.myPersonalExperiences![index].activity}' : '',
                                  style: textTheme.bodySmall?.copyWith(fontSize: 14.0, fontWeight: FontWeight.bold)),
                              Text( widget.myPersonalExperiences![index].organization != null && widget.myPersonalExperiences![index].organization != ''
                                  && widget.myPersonalExperiences![index].position != null && widget.myPersonalExperiences![index].position != '' ?
                              '${widget.myPersonalExperiences![index].organization!} - ${widget.myPersonalExperiences![index].position}' :
                              widget.myPersonalExperiences![index].organization != null && widget.myPersonalExperiences![index].organization != '' ?
                              '${widget.myPersonalExperiences![index].organization!}' : widget.myPersonalExperiences![index].position != null && widget.myPersonalExperiences![index].position != '' ?
                              '${widget.myPersonalExperiences![index].position}' : '', style: textTheme.bodySmall?.copyWith(fontSize: 14.0, fontWeight: FontWeight.bold)),
                              Row(
                                children: [
                                  Text('${widget.myPersonalExperiences![index].startDate != null ? formatter.format(widget.myPersonalExperiences![index].startDate!.toDate())
                                      : '-'} / ${widget.myPersonalExperiences![index].endDate != null ? formatter.format(widget.myPersonalExperiences![index].endDate!.toDate()) : 'Actualmente' }',
                                    style: textTheme.bodySmall?.copyWith(
                                      fontSize: 14.0,
                                    ),
                                  ),
                                  SpaceW8(),
                                  IconButton(
                                    icon: Icon(mySelectedDatePersonalExperience.contains(index) ? Icons.check_box : Icons.crop_square),
                                    color: Constants.darkGray,
                                    iconSize: 15.0,
                                    onPressed: (){

                                      setState(() {
                                        if(widget.myPersonalSelectedExperiences.contains(index)){
                                          if(mySelectedDatePersonalExperience.contains(index)){
                                            mySelectedDatePersonalExperience.remove(index);
                                            idSelectedDatePersonalExperience.remove(widget.myPersonalExperiences!.elementAt(index).id);
                                          }
                                          else {
                                            mySelectedDatePersonalExperience.add(index);
                                            idSelectedDatePersonalExperience.add(widget.myPersonalExperiences!.elementAt(index).id!);
                                          }
                                          idSelectedDatePersonalExperience.forEach((element) {print(element);});
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                              Text(
                                widget.myPersonalExperiences![index].location,
                                style: textTheme.bodySmall?.copyWith(
                                  fontSize: 14.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: (){
                            print('selected item: ${widget.myPersonalExperiences![index].activity}');
                            bool exists = widget.myPersonalCustomExperiences.any((element) => element.id == widget.myPersonalExperiences![index].id);
                            setState(() {
                              _selectedPersonalExperienceIndex = index;
                              if (exists == true){
                                widget.myPersonalCustomExperiences.remove(widget.myPersonalExperiences![index]);
                                widget.myPersonalSelectedExperiences.remove(_selectedPersonalExperienceIndex);
                                //Disguise date
                                mySelectedDatePersonalExperience.remove(index);
                                idSelectedDatePersonalExperience.remove(widget.myPersonalExperiences!.elementAt(index).id);
                              } else {
                                widget.myPersonalCustomExperiences.add(widget.myPersonalExperiences![index]);
                                widget.myPersonalSelectedExperiences.add(_selectedPersonalExperienceIndex!);
                                //Show date
                                mySelectedDatePersonalExperience.add(index);
                                idSelectedDatePersonalExperience.add(widget.myPersonalExperiences!.elementAt(index).id!);
                              }
                              print(widget.myPersonalCustomExperiences);
                              print(widget.myPersonalSelectedExperiences);
                            });
                          },
                          icon: Icon(widget.myPersonalSelectedExperiences.contains(index) ? Icons.check_box : Icons.crop_square),
                          iconSize: 20,
                          color: Constants.darkGray,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          )
              : Padding(
            padding: EdgeInsets.all(Constants.mainPadding),
            child: Center(child: CustomTextBody(text: StringConst.NO_EDUCATION)),
          ),
        ),
      ],
    );
  }

  Widget _buildMyDataOfInterest(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final myDataOfInterest = widget.user?.dataOfInterest ?? [];
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextTitle(title: StringConst.DATA_OF_INTEREST.toUpperCase()),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            color: Constants.white,
          ),
          child: myDataOfInterest.isNotEmpty ?
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: myDataOfInterest.length,
            itemBuilder: (context, index) {
              return Container(
                  child: ListTile(
                    selected: index == _selectedDataOfInterestIndex,
                    onTap: (){
                      print('selected item: ${myDataOfInterest[index]}');
                      bool exists = widget.myCustomDataOfInterest.any((element) => element == myDataOfInterest[index]);
                      setState(() {
                        _selectedDataOfInterestIndex = index;
                        if (exists == true){
                          widget.myCustomDataOfInterest.remove(myDataOfInterest[index]);
                          widget.mySelectedDataOfInterest.remove(_selectedDataOfInterestIndex);
                        } else {
                          widget.myCustomDataOfInterest.add(myDataOfInterest[index]);
                          widget.mySelectedDataOfInterest.add(_selectedDataOfInterestIndex!);
                        }
                        print(widget.myCustomDataOfInterest);
                        print(widget.mySelectedDataOfInterest);
                        print(myDataOfInterest);
                      });
                    },
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                              myDataOfInterest[index],
                              style: textTheme.bodySmall
                                  ?.copyWith(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w500,
                                  color: Constants.darkGray)
                          ),
                        ),
                        Icon(
                          widget.mySelectedDataOfInterest.contains(index) ? Icons.check_box : Icons.crop_square,
                          color: Constants.darkGray,
                          size: 20.0,
                        ),
                      ],
                    ),
                  )

              );
            },
          ) :
          Padding(
            padding: EdgeInsets.all(Constants.mainPadding),
            child: Center(
                child: Text(
                  'Aquí aparecerá la información de interés',
                  style: textTheme.bodySmall,
                )),
          ),
        ),

      ],
    );
  }

  Widget _buildMyLanguages(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    //final myLanguages = widget.user?.languages ?? [];
    final myLanguagesLevels = widget.user?.languagesLevels ?? [];
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextTitle(title: StringConst.LANGUAGES.toUpperCase()),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            color: Constants.white,
          ),
          child: myLanguagesLevels.isNotEmpty ?
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: myLanguagesLevels.length,
            itemBuilder: (context, index) {
              return Container(
                  child: ListTile(
                    selected: index == _selectedLanguagesIndex,
                    onTap: (){
                      print('selected item: ${myLanguagesLevels[index].name}');
                      bool exists = widget.myCustomLanguages.any((element) => element == myLanguagesLevels[index]);
                      setState(() {
                        _selectedLanguagesIndex = index;
                        if (exists == true){
                          widget.myCustomLanguages.remove(myLanguagesLevels[index]);
                          widget.mySelectedLanguages.remove(_selectedLanguagesIndex);
                        } else {
                          widget.myCustomLanguages.add(myLanguagesLevels[index]);
                          widget.mySelectedLanguages.add(_selectedLanguagesIndex!);
                        }
                        print(widget.myCustomLanguages);
                        print(widget.mySelectedLanguages);
                        print(myLanguagesLevels);
                      });
                    },
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                              myLanguagesLevels[index].name,
                              style: textTheme.bodySmall
                                  ?.copyWith(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w500,
                                  color: Constants.darkGray)
                          ),
                        ),
                        Icon(
                          widget.mySelectedLanguages.contains(index) ? Icons.check_box : Icons.crop_square,
                          color: Constants.darkGray,
                          size: 20.0,
                        ),
                      ],
                    ),
                  )

              );
            },
          ) :
          Padding(
            padding: EdgeInsets.all(Constants.mainPadding),
            child: Center(
                child: Text(
                  'Aquí aparecerán mis idiomas',
                  style: textTheme.bodySmall,
                )),
          ),
        ),

      ],
    );
  }

  Widget _buildMyReferences(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextTitle(title: StringConst.PERSONAL_REFERENCES.toUpperCase()),
        SpaceH4(),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            color: Constants.white,
          ),
          child: widget.myReferences!.isNotEmpty ?
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: widget.myReferences!.length,
            itemBuilder: (context, index) {
              return Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(vertical: 0),
                child: ListTile(
                  selected: index == _selectedReferenceIndex,
                  onTap: (){
                    bool exists = widget.myCustomReferences.any((element) => element.certificationRequestId == widget.myReferences![index].certificationRequestId);
                    setState(() {
                      _selectedReferenceIndex = index;
                      if (exists == true){
                        widget.myCustomReferences.remove(widget.myReferences![index]);
                        widget.mySelectedReferences.remove(_selectedReferenceIndex);
                      } else {
                        widget.myCustomReferences.add(widget.myReferences![index]);
                        widget.mySelectedReferences.add(_selectedReferenceIndex!);
                      }
                    });
                  },
                  title: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            CustomTextBold(title: '${widget.myReferences![index].certifierName}'),
                            SpaceH4(),
                            RichText(
                              text: TextSpan(
                                  text: '${widget.myReferences![index].certifierPosition.toUpperCase()} -',
                                  style: textTheme.bodySmall?.copyWith(
                                    fontSize: 14.0,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: ' ${widget.myReferences![index].certifierCompany.toUpperCase()}',
                                      style: textTheme.bodySmall?.copyWith(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  ]),
                            ),
                            CustomTextSmall(text: '${widget.myReferences![index].email}'),
                            widget.myReferences![index].phone != "" ? CustomTextSmall(text: '${widget.myReferences![index].phone}') : Container(),
                          ],
                        ),
                      ),
                      Icon(
                        widget.mySelectedReferences.contains(index) ? Icons.check_box : Icons.crop_square,
                        color: Constants.darkGray,
                        size: 20.0,
                      ),
                    ],
                  ),
                ),
              );
            },
          )
              : Padding(
            padding: EdgeInsets.all(Constants.mainPadding),
            child: Center(child: CustomTextBody(text: StringConst.NO_REFERENCES)),
          ),
        ),
      ],
    );
  }

  int getTotalRightElements(){
    return widget.myPersonalCustomExperiences.length +
        widget.myCustomExperiences.length +
        widget.myCustomEducation.length +
        widget.mySecondaryCustomEducation.length +
        widget.myCustomCompetencies.length;
  }

  int getTotalLeftElements(){
    int sum = 0;
    if(widget.myCustomAboutMe.length > 90){
      print('Texto largo');
      sum = 1;
    }
    return widget.myCustomLanguages.length +
        widget.myCustomDataOfInterest.length +
        widget.myCustomReferences.length +
        sum;
  }

}



