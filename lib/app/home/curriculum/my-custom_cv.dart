import 'package:cached_network_image/cached_network_image.dart';
import 'package:enreda_app/app/home/curriculum/pdf_generator/pdf_preview.dart';
import 'package:enreda_app/app/home/models/certificationRequest.dart';
import 'package:enreda_app/common_widgets/precached_avatar.dart';
import 'package:enreda_app/common_widgets/show_alert_dialog.dart';
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
  List<String> myCustomLanguages;
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

  @override
  void initState() {
    super.initState();
    _myMaxEducation = widget.myMaxEducation;
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
            style: textTheme.bodyText1?.copyWith(
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
                                    PrecacheAvatarCard(
                                      imageUrl: profilePic,
                                    ),
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
                children: [
                  Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: CustomTextBody(text: StringConst.MY_CV.toUpperCase()),
                      )),
                  Expanded(
                    flex: Responsive.isMobile(context) ? 4 : 2,
                    child: EnredaButton(
                      buttonTitle: "Vista previa",
                      width: 80,
                      onPressed: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  MyCv(
                                    user: widget.user!,
                                    myPhoto: _isSelectedPhoto,
                                    city: widget.myCustomCity,
                                    province: widget.myCustomProvince,
                                    country: widget.myCustomCountry,
                                    myExperiences: widget.myCustomExperiences,
                                    myPersonalExperiences: widget.myPersonalCustomExperiences,
                                    myEducation: widget.myCustomEducation,
                                    mySecondaryEducation: widget.mySecondaryCustomEducation,
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
              SpaceH20(),
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
                            PrecacheAvatarCard(
                              imageUrl: profilePic,
                            ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${widget.user?.firstName} ${widget.user?.lastName}',
                    style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: Responsive.isDesktop(context) ? 45.0 : 32.0,
                        color: Constants.penBlue),
                    textAlign: TextAlign.center,
                  ),
                ],
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
              _buildPersonalData(context),
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
          children: [
            CustomTextBody(text: StringConst.MY_CV.toUpperCase()),
            Spacer(),
            EnredaButton(
              buttonTitle: "Vista previa",
              width: 100,
              onPressed: () async {
                if(widget.myPersonalCustomExperiences.length > 2){
                  showAlertDialog(
                    context,
                    title: 'Error',
                    content: 'Ha seleccionado demasiadas experiencias personales',
                    defaultActionText: 'Ok',
                  );
                  return;
                }
                if(widget.myCustomExperiences.length > 2){
                  showAlertDialog(
                    context,
                    title: 'Error',
                    content: 'Ha seleccionado demasiadas experiencias profesionales',
                    defaultActionText: 'Ok',
                  );
                  return;
                }
                if(widget.mySecondaryCustomEducation.length > 2){
                  showAlertDialog(
                    context,
                    title: 'Error',
                    content: 'Ha seleccionado demasiadas formaciones complementarias',
                    defaultActionText: 'Ok',
                  );
                  return;
                }
                if(widget.myCustomEducation.length > 2){
                  showAlertDialog(
                    context,
                    title: 'Error',
                    content: 'Ha seleccionado demasiadas formaciones',
                    defaultActionText: 'Ok',
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          MyCv(
                            user: widget.user!,
                            myPhoto: _isSelectedPhoto,
                            city: widget.myCustomCity,
                            province: widget.myCustomProvince,
                            country: widget.myCustomCountry,
                            myExperiences: widget.myCustomExperiences,
                            myPersonalExperiences: widget.myPersonalCustomExperiences,
                            myEducation: widget.myCustomEducation,
                            mySecondaryEducation: widget.mySecondaryCustomEducation,
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
            SpaceW8(),
          ],
        ),
        SpaceH20(),
        Text(
          '${widget.user?.firstName} ${widget.user?.lastName}',
          style: textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: Responsive.isDesktop(context) ? 45.0 : 32.0,
              color: Constants.penBlue),
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
                        style: textTheme.bodyText1?.copyWith(
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
                        style: textTheme.bodyText1?.copyWith(
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
                                    style: textTheme.bodyText1
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
                padding: const EdgeInsets.all(20.0),
                child: Center(
                    child: Text(
                      'Aquí aparecerán las competencias evaluadas a través de los microtests',
                      style: textTheme.bodyText1,
                    )),
              ),
        ),

      ],
    );
  }

  Widget _buildMyEducation(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
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
              shrinkWrap: true,
              itemCount: widget.myEducation!.length,
              itemBuilder: (context, index) {
                return Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(vertical: 0),
                    child: ListTile(
                      selected: index == _selectedEducationIndex,
                      onTap: (){
                        print('selected item: ${widget.myEducation![index].activity}');
                        bool exists = widget.myCustomEducation.any((element) => element.id == widget.myEducation![index].id);
                        setState(() {
                          _selectedEducationIndex = index;
                          if (exists == true){
                            widget.myCustomEducation.remove(widget.myEducation![index]);
                            widget.mySelectedEducation.remove(_selectedEducationIndex);
                          } else {
                            widget.myCustomEducation.add(widget.myEducation![index]);
                            widget.mySelectedEducation.add(_selectedEducationIndex!);
                          }
                          print(widget.myCustomEducation);
                          print(widget.mySelectedEducation);
                        });
                      },
                      title: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  if (widget.myEducation![index].activity != null && widget.myEducation![index].activityRole != null && widget.myEducation![index].activity != '')
                                    RichText(
                                      text: TextSpan(
                                          text: '${widget.myEducation![index].activityRole!.toUpperCase()} -',
                                          style: textTheme.bodyText1?.copyWith(
                                            fontSize: 14.0,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: ' ${widget.myEducation![index].activity!.toUpperCase()}',
                                              style: textTheme.bodyText1?.copyWith(
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          ]),
                                    ),
                                  if (widget.myEducation![index].nameFormation != null )
                                    Text('${widget.myEducation![index].nameFormation!}',
                                        style: textTheme.bodyText1
                                            ?.copyWith(fontSize: 14.0, fontWeight: FontWeight.bold)),
                                  if (widget.myEducation![index].activity != null && widget.myEducation![index].activityRole == null)
                                    Text('${widget.myEducation![index].activity!}',
                                        style: textTheme.bodyText1
                                            ?.copyWith(fontSize: 14.0, fontWeight: FontWeight.bold)),
                                  if (widget.myEducation![index].activity != null) SpaceH8(),
                                  if (widget.myEducation![index].organization != null && widget.myEducation![index].organization != "") Column(
                                    children: [
                                      Text(
                                        widget.myEducation![index].organization!,
                                        style: textTheme.bodyText1?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.0,
                                        ),
                                      ),
                                      SpaceH8()
                                    ],
                                  ),
                                  Text(
                                    '${formatter.format(widget.myEducation![index].startDate.toDate())} / ${widget.myEducation![index].endDate != null
                                        ? formatter.format(widget.myEducation![index].endDate!.toDate())
                                        : 'Actualmente'}',
                                    style: textTheme.bodyText1?.copyWith(
                                      fontSize: 14.0,
                                    ),
                                  ),
                                  SpaceH8(),
                                  Text(
                                    widget.myEducation![index].location,
                                    style: textTheme.bodyText1?.copyWith(
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              widget.mySelectedEducation.contains(index) ? Icons.check_box : Icons.crop_square,
                              color: Constants.darkGray,
                              size: 20.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                );
              },
          )
              : CustomTextBody(text: StringConst.NO_EDUCATION),
        ),
      ],
    );
  }

  Widget _buildMySecondaryEducation(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
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
            shrinkWrap: true,
            itemCount: widget.mySecondaryEducation!.length,
            itemBuilder: (context, index) {
              return Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(vertical: 0),
                child: ListTile(
                  selected: index == _selectedSecondaryEducationIndex,
                  onTap: (){
                    print('selected item: ${widget.mySecondaryEducation![index].activity}');
                    bool exists = widget.mySecondaryCustomEducation.any((element) => element.id == widget.mySecondaryEducation![index].id);
                    setState(() {
                      _selectedSecondaryEducationIndex = index;
                      if (exists == true){
                        widget.mySecondaryCustomEducation.remove(widget.mySecondaryEducation![index]);
                        widget.mySecondarySelectedEducation.remove(_selectedSecondaryEducationIndex);
                      } else {
                        widget.mySecondaryCustomEducation.add(widget.mySecondaryEducation![index]);
                        widget.mySecondarySelectedEducation.add(_selectedSecondaryEducationIndex!);
                      }
                      print(widget.mySecondaryCustomEducation);
                      print(widget.mySecondarySelectedEducation);
                    });
                  },
                  title: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              if (widget.mySecondaryEducation![index].activity != null && widget.mySecondaryEducation![index].activityRole != null && widget.mySecondaryEducation![index].activity != '')
                                RichText(
                                  text: TextSpan(
                                      text: '${widget.mySecondaryEducation![index].activityRole!.toUpperCase()} -',
                                      style: textTheme.bodyText1?.copyWith(
                                        fontSize: 14.0,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: ' ${widget.mySecondaryEducation![index].activity!.toUpperCase()}',
                                          style: textTheme.bodyText1?.copyWith(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      ]),
                                ),
                              if (widget.mySecondaryEducation![index].nameFormation != null )
                                Text('${widget.mySecondaryEducation![index].nameFormation!}',
                                    style: textTheme.bodyText1
                                        ?.copyWith(fontSize: 14.0, fontWeight: FontWeight.bold)),
                              if (widget.mySecondaryEducation![index].activity != null && widget.mySecondaryEducation![index].activityRole == null)
                                Text('${widget.mySecondaryEducation![index].activity!}',
                                    style: textTheme.bodyText1
                                        ?.copyWith(fontSize: 14.0, fontWeight: FontWeight.bold)),
                              if (widget.mySecondaryEducation![index].activity != null) SpaceH8(),
                              if (widget.mySecondaryEducation![index].organization != null && widget.mySecondaryEducation![index].organization != "") Column(
                                children: [
                                  Text(
                                    widget.mySecondaryEducation![index].organization!,
                                    style: textTheme.bodyText1?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.0,
                                    ),
                                  ),
                                  SpaceH8()
                                ],
                              ),
                              Text(
                                '${formatter.format(widget.mySecondaryEducation![index].startDate.toDate())} / ${widget.mySecondaryEducation![index].endDate != null
                                    ? formatter.format(widget.mySecondaryEducation![index].endDate!.toDate())
                                    : 'Actualmente'}',
                                style: textTheme.bodyText1?.copyWith(
                                  fontSize: 14.0,
                                ),
                              ),
                              SpaceH8(),
                              Text(
                                widget.mySecondaryEducation![index].location,
                                style: textTheme.bodyText1?.copyWith(
                                  fontSize: 14.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          widget.mySecondarySelectedEducation.contains(index) ? Icons.check_box : Icons.crop_square,
                          color: Constants.darkGray,
                          size: 20.0,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          )
              : CustomTextBody(text: StringConst.NO_EDUCATION),
        ),
      ],
    );
  }

  Widget _buildMyExperiences(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
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
            shrinkWrap: true,
            itemCount: widget.myExperiences!.length,
            itemBuilder: (context, index) {
              return Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(vertical: 0),
                  child: ListTile(
                    selected: index == _selectedExperienceIndex,
                    onTap: (){
                      print('selected item: ${widget.myExperiences![index].activity}');
                      bool exists = widget.myCustomExperiences.any((element) => element.id == widget.myExperiences![index].id);
                      setState(() {
                        _selectedExperienceIndex = index;
                        if (exists == true){
                          widget.myCustomExperiences.remove(widget.myExperiences![index]);
                          widget.mySelectedExperiences.remove(_selectedExperienceIndex);
                        } else {
                          widget.myCustomExperiences.add(widget.myExperiences![index]);
                          widget.mySelectedExperiences.add(_selectedExperienceIndex!);
                        }
                        print(widget.myCustomExperiences);
                        print(widget.mySelectedExperiences);
                      });
                    },
                    title: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                if (widget.myExperiences![index].activity != null && widget.myExperiences![index].activityRole != null)
                                  RichText(
                                    text: TextSpan(
                                        text: '${widget.myExperiences![index].activityRole!.toUpperCase()} -',
                                        style: textTheme.bodyText1?.copyWith(
                                          fontSize: 14.0,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: ' ${widget.myExperiences![index].activity!.toUpperCase()}',
                                            style: textTheme.bodyText1?.copyWith(
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        ]),
                                  ),
                                if (widget.myExperiences![index].activity != null && widget.myExperiences![index].activityRole == null)
                                  Text( widget.myExperiences![index].position == null || widget.myExperiences![index].position == "" ? '${widget.myExperiences![index].activity!}' : '${widget.myExperiences![index].position}',
                                      style: textTheme.bodyText1
                                          ?.copyWith(fontSize: 14.0, fontWeight: FontWeight.bold)),
                                if (widget.myExperiences![index].position != null || widget.myExperiences![index].activity != null) SpaceH8(),
                                if (widget.myExperiences![index].organization != null && widget.myExperiences![index].organization != "") Column(
                                  children: [
                                    Text(
                                      widget.myExperiences![index].organization!,
                                      style: textTheme.bodyText1?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.0,
                                      ),
                                    ),
                                    SpaceH8()
                                  ],
                                ),
                                Text(
                                  '${formatter.format(widget.myExperiences![index].startDate.toDate())} / ${widget.myExperiences![index].endDate != null
                                      ? formatter.format(widget.myExperiences![index].endDate!.toDate())
                                      : 'Actualmente'}',
                                  style: textTheme.bodyText1?.copyWith(
                                    fontSize: 14.0,
                                  ),
                                ),
                                SpaceH8(),
                                Text(
                                  widget.myExperiences![index].location,
                                  style: textTheme.bodyText1?.copyWith(
                                    fontSize: 14.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            widget.mySelectedExperiences.contains(index) ? Icons.check_box : Icons.crop_square,
                            color: Constants.darkGray,
                            size: 20.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
            },
          )
              : CustomTextBody(text: StringConst.NO_EDUCATION),
        ),
      ],
    );
  }

  Widget _buildMyPersonalExperiences(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
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
            shrinkWrap: true,
            itemCount: widget.myPersonalExperiences!.length,
            itemBuilder: (context, index) {
              return Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(vertical: 0),
                child: ListTile(
                  selected: index == _selectedPersonalExperienceIndex,
                  onTap: (){
                    print('selected item: ${widget.myPersonalExperiences![index].activity}');
                    bool exists = widget.myPersonalCustomExperiences.any((element) => element.id == widget.myPersonalExperiences![index].id);
                    setState(() {
                      _selectedPersonalExperienceIndex = index;
                      if (exists == true){
                        widget.myPersonalCustomExperiences.remove(widget.myPersonalExperiences![index]);
                        widget.myPersonalSelectedExperiences.remove(_selectedPersonalExperienceIndex);
                      } else {
                        widget.myPersonalCustomExperiences.add(widget.myPersonalExperiences![index]);
                        widget.myPersonalSelectedExperiences.add(_selectedPersonalExperienceIndex!);
                      }
                      print(widget.myPersonalCustomExperiences);
                      print(widget.myPersonalSelectedExperiences);
                    });
                  },
                  title: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              if (widget.myPersonalExperiences![index].activity != null && widget.myPersonalExperiences![index].activityRole != null)
                                RichText(
                                  text: TextSpan(
                                      text: '${widget.myPersonalExperiences![index].activityRole!.toUpperCase()} -',
                                      style: textTheme.bodyText1?.copyWith(
                                        fontSize: 14.0,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: ' ${widget.myPersonalExperiences![index].activity!.toUpperCase()}',
                                          style: textTheme.bodyText1?.copyWith(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      ]),
                                ),
                              if (widget.myPersonalExperiences![index].activity != null && widget.myPersonalExperiences![index].activityRole == null)
                                Text( widget.myPersonalExperiences![index].position == null || widget.myPersonalExperiences![index].position == "" ? '${widget.myPersonalExperiences![index].activity!}' : '${widget.myPersonalExperiences![index].position}',
                                    style: textTheme.bodyText1
                                        ?.copyWith(fontSize: 14.0, fontWeight: FontWeight.bold)),
                              if (widget.myPersonalExperiences![index].position != null || widget.myPersonalExperiences![index].activity != null) SpaceH8(),
                              if (widget.myPersonalExperiences![index].organization != null && widget.myPersonalExperiences![index].organization != "") Column(
                                children: [
                                  Text(
                                    widget.myPersonalExperiences![index].organization!,
                                    style: textTheme.bodyText1?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.0,
                                    ),
                                  ),
                                  SpaceH8()
                                ],
                              ),
                              Text(
                                '${formatter.format(widget.myPersonalExperiences![index].startDate.toDate())} / ${widget.myPersonalExperiences![index].endDate != null
                                    ? formatter.format(widget.myPersonalExperiences![index].endDate!.toDate())
                                    : 'Actualmente'}',
                                style: textTheme.bodyText1?.copyWith(
                                  fontSize: 14.0,
                                ),
                              ),
                              SpaceH8(),
                              Text(
                                widget.myPersonalExperiences![index].location,
                                style: textTheme.bodyText1?.copyWith(
                                  fontSize: 14.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          widget.myPersonalSelectedExperiences.contains(index) ? Icons.check_box : Icons.crop_square,
                          color: Constants.darkGray,
                          size: 20.0,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          )
              : CustomTextBody(text: StringConst.NO_EDUCATION),
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
                              style: textTheme.bodyText1
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
            padding: const EdgeInsets.all(10.0),
            child: Center(
                child: Text(
                  'Aquí aparecerá la información de interés',
                  style: textTheme.bodyText1,
                )),
          ),
        ),

      ],
    );
  }

  Widget _buildMyLanguages(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final myLanguages = widget.user?.languages ?? [];
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
          child: myLanguages.isNotEmpty ?
          ListView.builder(
            shrinkWrap: true,
            itemCount: myLanguages.length,
            itemBuilder: (context, index) {
              return Container(
                  child: ListTile(
                    selected: index == _selectedLanguagesIndex,
                    onTap: (){
                      print('selected item: ${myLanguages[index]}');
                      bool exists = widget.myCustomLanguages.any((element) => element == myLanguages[index]);
                      setState(() {
                        _selectedLanguagesIndex = index;
                        if (exists == true){
                          widget.myCustomLanguages.remove(myLanguages[index]);
                          widget.mySelectedLanguages.remove(_selectedLanguagesIndex);
                        } else {
                          widget.myCustomLanguages.add(myLanguages[index]);
                          widget.mySelectedLanguages.add(_selectedLanguagesIndex!);
                        }
                        print(widget.myCustomLanguages);
                        print(widget.mySelectedLanguages);
                        print(myLanguages);
                      });
                    },
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                              myLanguages[index],
                              style: textTheme.bodyText1
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
            padding: const EdgeInsets.all(10.0),
            child: Center(
                child: Text(
                  'Aquí aparecerán mis idiomas',
                  style: textTheme.bodyText1,
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
                                    style: textTheme.bodyText1?.copyWith(
                                      fontSize: 14.0,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: ' ${widget.myReferences![index].certifierCompany.toUpperCase()}',
                                        style: textTheme.bodyText1?.copyWith(
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
              : CustomTextBody(text: StringConst.NO_REFERENCES),
        ),
      ],
    );
  }

}


