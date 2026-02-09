import 'package:enreda_app/common_widgets/main_container.dart';
import 'package:enreda_app/common_widgets/rounded_container.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:enreda_app/app/home/curriculum/pdf_generator/my_cv_multiple_pages.dart';
import 'package:enreda_app/app/home/curriculum/pdf_generator/my_cv_one_page.dart';
import 'package:enreda_app/app/home/models/certificationRequest.dart';
import 'package:enreda_app/app/home/models/language.dart';

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
    this.onBack,
  }) : super(key: key);

  final VoidCallback? onBack;

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
  List<int> mySelectedDateExperience = [];
  List<String> idSelectedDateExperience = [];
  List<int> mySelectedDatePersonalExperience = [];
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
      idSelectedDateSecondaryEducation
          .add(widget.mySecondaryEducation!.elementAt(element).id!);
    });
    widget.mySelectedExperiences.forEach((element) {
      mySelectedDateExperience.add(element);
      idSelectedDateExperience
          .add(widget.myExperiences!.elementAt(element).id!);
    });
    widget.myPersonalSelectedExperiences.forEach((element) {
      mySelectedDatePersonalExperience.add(element);
      idSelectedDatePersonalExperience
          .add(widget.myPersonalExperiences!.elementAt(element).id!);
    });
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    double fontSize = responsiveSize(context, 20, 22, md: 22);
    return _buildContent(context);
  }

  Widget _buildContent(BuildContext context) {
    return RoundedContainer(
      margin: Responsive.isMobile(context)
          ? const EdgeInsets.all(0)
          : const EdgeInsets.all(Sizes.kDefaultPaddingDouble),
      contentPadding: Responsive.isMobile(context)
          ? EdgeInsets.all(Sizes.mainPadding)
          : EdgeInsets.all(Sizes.kDefaultPaddingDouble * 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Responsive.isDesktop(context)
              ? _myCurriculumWeb(context)
              : _myCurriculumMobile(context),
        ],
      ),
    );
  }

  Widget _myCurriculumWeb(BuildContext context) {
    var profilePic = widget.user?.profilePic?.src ?? "";
    final double sidebarWidth = 350.0;

    // Custom Colors for this design
    final Color tealColor = Color(0xFF005B5B);
    final Color sectionHeaderColor = tealColor;

    return Center(
      child: SingleChildScrollView(
        controller: ScrollController(),
        child: MainContainer(
          //height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.all(0),
          margin: EdgeInsets.only(top: Sizes.kDefaultPaddingDouble * 2.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: AppColors.blue050, width: 1),
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                          color: Constants.white),
                      child: Text(
                        'Volver atrás',
                        style: TextStyle(
                          letterSpacing: 1,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.blue050,
                        ),
                      ),
                    ),
                    onTap: () {
                      //Agente Antigravity
                      if (widget.onBack != null) {
                        widget.onBack!();
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: EnredaButton(
                      borderRadius:
                          BorderRadiusGeometry.all(Radius.circular(25)),
                      padding: EdgeInsetsGeometry.symmetric(
                          horizontal: 50, vertical: 10),
                      buttonTitle: "Siguiente >",
                      width: 100,
                      onPressed: () async {
                        /*if (_isSelectedAboutMe == true &&
                            widget.myCustomAboutMe.length > 330 &&
                            !_isSelected2Page) {
                          showAlertDialog(
                            context,
                            title: StringConst.WARNING,
                            content: StringConst.PAGE_WARNING_6,
                            defaultActionText: StringConst.FORM_ACCEPT,
                          );
                          return;
                        }
                        if (getTotalLeftElements() >= 5 &&
                            getTotalRightElements() > 9 &&
                            !_isSelected2Page &&
                            _isSelectedAboutMe == true &&
                            widget.myCustomAboutMe.length > 130) {
                          showAlertDialog(
                            context,
                            title: StringConst.WARNING,
                            content: StringConst.PAGE_WARNING_3,
                            defaultActionText: StringConst.FORM_ACCEPT,
                          );
                          return;
                        }
                        if (getTotalLeftElements() > 5 &&
                            getTotalRightElements() > 9 &&
                            !_isSelected2Page) {
                          showAlertDialog(
                            context,
                            title: StringConst.WARNING,
                            content: widget.myCustomAboutMe.length > 130
                                ? StringConst.PAGE_WARNING_3
                                : StringConst.PAGE_WARNING_5,
                            defaultActionText: StringConst.FORM_ACCEPT,
                            cancelActionText: StringConst.CANCEL,
                          );
                          return;
                        }
                        if (getTotalRightElements() < 9 && _isSelected2Page) {
                          showAlertDialog(
                            context,
                            title: StringConst.WARNING,
                            content: StringConst.PAGE_WARNING_1,
                            defaultActionText: StringConst.FORM_ACCEPT,
                            cancelActionText: StringConst.CANCEL,
                          );
                          return;
                        }*/
                        Navigator.push(
                          context,
                          _isSelected2Page == true
                              ? MaterialPageRoute(
                                  builder: (context) => MyCvMultiplePages(
                                        user: widget.user!,
                                        myPhoto: _isSelectedPhoto,
                                        city: widget.myCustomCity,
                                        province: widget.myCustomProvince,
                                        country: widget.myCustomCountry,
                                        myExperiences:
                                            widget.myCustomExperiences,
                                        myPersonalExperiences:
                                            widget.myPersonalCustomExperiences,
                                        myEducation: widget.myCustomEducation,
                                        mySecondaryEducation:
                                            widget.mySecondaryCustomEducation,
                                        idSelectedDateEducation:
                                            idSelectedDateEducation,
                                        idSelectedDateSecondaryEducation:
                                            idSelectedDateSecondaryEducation,
                                        idSelectedDateExperience:
                                            idSelectedDateExperience,
                                        idSelectedDatePersonalExperience:
                                            idSelectedDatePersonalExperience,
                                        competenciesNames:
                                            widget.myCustomCompetencies,
                                        aboutMe: widget.myCustomAboutMe,
                                        languagesNames:
                                            widget.myCustomLanguages,
                                        myDataOfInterest:
                                            widget.myCustomDataOfInterest,
                                        myCustomEmail: widget.myCustomEmail,
                                        myCustomPhone: widget.myCustomPhone,
                                        myCustomReferences:
                                            widget.myCustomReferences,
                                        myMaxEducation: _myMaxEducation,
                                      ))
                              : MaterialPageRoute(
                                  builder: (context) => MyCvOnePage(
                                        user: widget.user!,
                                        myPhoto: _isSelectedPhoto,
                                        city: widget.myCustomCity,
                                        province: widget.myCustomProvince,
                                        country: widget.myCustomCountry,
                                        myExperiences:
                                            widget.myCustomExperiences,
                                        myPersonalExperiences:
                                            widget.myPersonalCustomExperiences,
                                        myEducation: widget.myCustomEducation,
                                        mySecondaryEducation:
                                            widget.mySecondaryCustomEducation,
                                        idSelectedDateEducation:
                                            idSelectedDateEducation,
                                        idSelectedDateSecondaryEducation:
                                            idSelectedDateSecondaryEducation,
                                        idSelectedDateExperience:
                                            idSelectedDateExperience,
                                        idSelectedDatePersonalExperience:
                                            idSelectedDatePersonalExperience,
                                        competenciesNames:
                                            widget.myCustomCompetencies,
                                        aboutMe: widget.myCustomAboutMe,
                                        languagesNames:
                                            widget.myCustomLanguages,
                                        myDataOfInterest:
                                            widget.myCustomDataOfInterest,
                                        myCustomEmail: widget.myCustomEmail,
                                        myCustomPhone: widget.myCustomPhone,
                                        myCustomReferences:
                                            widget.myCustomReferences,
                                        myMaxEducation: _myMaxEducation,
                                      )),
                        );
                      },
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.user?.firstName?.toUpperCase() ?? ''}',
                          style: GoogleFonts.rubik(
                            // Assuming we can use GoogleFonts or fallback
                            fontSize: 50.0,
                            fontWeight: FontWeight.w900,
                            color: tealColor,
                            height: 0.9,
                          ),
                        ),
                        Text(
                          '${widget.user?.lastName?.toUpperCase() ?? ''}',
                          style: GoogleFonts.rubik(
                              fontSize: 30.0,
                              fontWeight: FontWeight.normal,
                              color: tealColor,
                              height: 1.2),
                        ),
                        SpaceH20(),
                        _buildAboutMe(context), // Modified below
                      ],
                    ),
                  ),
                  SpaceW40(),
                  // PHOTO SECTION
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isSelectedPhoto = !_isSelectedPhoto;
                      });
                    },
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: tealColor, width: 2),
                          ),
                          padding: EdgeInsets.all(5),
                          child: CircleAvatar(
                            radius: 90,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: (profilePic != "")
                                ? (kIsWeb
                                        ? NetworkImage(profilePic)
                                        : NetworkImage(profilePic))
                                    as ImageProvider // Simplified for now, use CachedNetworkImage in real impl
                                : AssetImage(ImagePath.USER_DEFAULT),
                          ),
                        ),
                        // Selection Checkbox Overlay
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                          child: Icon(
                            _isSelectedPhoto
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: tealColor,
                            size: 30.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SpaceH20(),

              // BODY SECTION (2 COLUMNS)
              Stack(
                children: [
                  Positioned.fill(
                    child: _Separator(),
                  ),
                  Column(
                    children: [
                      SpaceH40(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // LEFT COLUMN
                          Container(
                            width: MediaQuery.of(context).size.width * 0.2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildPersonalData(
                                    context), // Refactor to remove box
                                SpaceH30(),
                                _buildMyReferences(context),
                                SpaceH30(),
                                _buildMyCompetencies(context),
                                SpaceH30(),
                                _buildMyDataOfInterest(context),
                                SpaceH30(),
                                _buildMyLanguages(context),
                              ],
                            ),
                          ),
                          SpaceW30(),

                          // RIGHT COLUMN
                          Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 30.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildMyExperiences(context),
                                  SpaceH30(),
                                  _buildMyPersonalExperiences(context),
                                  SpaceH30(),
                                  _buildMyEducation(context),
                                  SpaceH30(),
                                  _buildMySecondaryEducation(context),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _myCurriculumMobile(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    var profilePic = widget.user?.profilePic?.src ?? "";
    return SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        margin: EdgeInsets.only(
            top: Constants.mainPadding, bottom: Constants.mainPadding),
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
                          title: CustomTextSmall(
                            text: printingOptions[0],
                          ),
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
                          title: CustomTextSmall(
                            text: printingOptions[1],
                          ),
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
                        if (_isSelectedAboutMe == true &&
                            widget.myCustomAboutMe.length > 330 &&
                            !_isSelected2Page) {
                          showAlertDialog(
                            context,
                            title: StringConst.WARNING,
                            content: StringConst.PAGE_WARNING_6,
                            defaultActionText: StringConst.FORM_ACCEPT,
                          );
                          return;
                        }
                        if (getTotalLeftElements() >= 5 &&
                            getTotalRightElements() > 9 &&
                            !_isSelected2Page &&
                            _isSelectedAboutMe == true &&
                            widget.myCustomAboutMe.length > 130) {
                          showAlertDialog(
                            context,
                            title: StringConst.WARNING,
                            content: StringConst.PAGE_WARNING_3,
                            defaultActionText: StringConst.FORM_ACCEPT,
                          );
                          return;
                        }
                        if (getTotalLeftElements() > 5 &&
                            getTotalRightElements() > 9 &&
                            !_isSelected2Page) {
                          showAlertDialog(
                            context,
                            title: StringConst.WARNING,
                            content: widget.myCustomAboutMe.length > 130
                                ? StringConst.PAGE_WARNING_3
                                : StringConst.PAGE_WARNING_5,
                            defaultActionText: StringConst.FORM_ACCEPT,
                            cancelActionText: StringConst.CANCEL,
                          );
                          return;
                        }
                        if (getTotalRightElements() < 9 && _isSelected2Page) {
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
                          _isSelected2Page == true
                              ? MaterialPageRoute(
                                  builder: (context) => MyCvMultiplePages(
                                        user: widget.user!,
                                        myPhoto: _isSelectedPhoto,
                                        city: widget.myCustomCity,
                                        province: widget.myCustomProvince,
                                        country: widget.myCustomCountry,
                                        myExperiences:
                                            widget.myCustomExperiences,
                                        myPersonalExperiences:
                                            widget.myPersonalCustomExperiences,
                                        myEducation: widget.myCustomEducation,
                                        mySecondaryEducation:
                                            widget.mySecondaryCustomEducation,
                                        idSelectedDateEducation:
                                            idSelectedDateEducation,
                                        idSelectedDateSecondaryEducation:
                                            idSelectedDateSecondaryEducation,
                                        idSelectedDateExperience:
                                            idSelectedDateExperience,
                                        idSelectedDatePersonalExperience:
                                            idSelectedDatePersonalExperience,
                                        competenciesNames:
                                            widget.myCustomCompetencies,
                                        aboutMe: widget.myCustomAboutMe,
                                        languagesNames:
                                            widget.myCustomLanguages,
                                        myDataOfInterest:
                                            widget.myCustomDataOfInterest,
                                        myCustomEmail: widget.myCustomEmail,
                                        myCustomPhone: widget.myCustomPhone,
                                        myCustomReferences:
                                            widget.myCustomReferences,
                                        myMaxEducation: _myMaxEducation,
                                      ))
                              : MaterialPageRoute(
                                  builder: (context) => MyCvOnePage(
                                        user: widget.user!,
                                        myPhoto: _isSelectedPhoto,
                                        city: widget.myCustomCity,
                                        province: widget.myCustomProvince,
                                        country: widget.myCustomCountry,
                                        myExperiences:
                                            widget.myCustomExperiences,
                                        myPersonalExperiences:
                                            widget.myPersonalCustomExperiences,
                                        myEducation: widget.myCustomEducation,
                                        mySecondaryEducation:
                                            widget.mySecondaryCustomEducation,
                                        idSelectedDateEducation:
                                            idSelectedDateEducation,
                                        idSelectedDateSecondaryEducation:
                                            idSelectedDateSecondaryEducation,
                                        idSelectedDateExperience:
                                            idSelectedDateExperience,
                                        idSelectedDatePersonalExperience:
                                            idSelectedDatePersonalExperience,
                                        competenciesNames:
                                            widget.myCustomCompetencies,
                                        aboutMe: widget.myCustomAboutMe,
                                        languagesNames:
                                            widget.myCustomLanguages,
                                        myDataOfInterest:
                                            widget.myCustomDataOfInterest,
                                        myCustomEmail: widget.myCustomEmail,
                                        myCustomPhone: widget.myCustomPhone,
                                        myCustomReferences:
                                            widget.myCustomReferences,
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
                onTap: () {
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
                          !kIsWeb
                              ? ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(60)),
                                  child: Center(
                                    child: profilePic == ""
                                        ? Container(
                                            color: Colors.transparent,
                                            height: 120,
                                            width: 120,
                                            child: Image.asset(
                                                ImagePath.USER_DEFAULT),
                                          )
                                        : CachedNetworkImage(
                                            width: 120,
                                            height: 120,
                                            fit: BoxFit.cover,
                                            alignment: Alignment.center,
                                            imageUrl: profilePic),
                                  ),
                                )
                              : ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(60)),
                                  child: widget.user?.profilePic?.src == ""
                                      ? Container(
                                          color: Colors.transparent,
                                          height: 120,
                                          width: 120,
                                          child: Image.asset(
                                              ImagePath.USER_DEFAULT),
                                        )
                                      : CachedNetworkImage(
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                          alignment: Alignment.center,
                                          imageUrl:
                                              widget.user!.profilePic!.src),
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
                    color: AppColors.primary900),
                textAlign: TextAlign.center,
              ),
              SpaceH24(),
              InkWell(
                onTap: () {
                  setState(() {
                    _isSelectedMaxEducation = !_isSelectedMaxEducation;
                    if (_myMaxEducation == "") {
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
                      _isSelectedMaxEducation
                          ? Icons.check_box
                          : Icons.crop_square,
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

  Widget _buildAboutMe(BuildContext context) {
    String aboutMe = widget.user?.aboutMe ?? '';
    // Custom Colors
    final Color tealColor = Color(0xFF005B5B);

    return StatefulBuilder(builder: (context, setState) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            StringConst.ABOUT_ME.toUpperCase(),
            style: GoogleFonts.rubik(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: tealColor,
            ),
          ),
          SpaceH8(),
          InkWell(
            onTap: () {
              setState(() {
                _isSelectedAboutMe = !_isSelectedAboutMe;
                if (widget.myCustomAboutMe == "") {
                  widget.myCustomAboutMe = aboutMe;
                } else {
                  widget.myCustomAboutMe = "";
                }
              });
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: Text(
                    widget.user?.aboutMe != null &&
                            widget.user!.aboutMe!.isNotEmpty
                        ? widget.user!.aboutMe!
                        : 'Aún no has añadido información adicional sobre ti',
                    style: GoogleFonts.rubik(
                        fontSize: 14.0, color: Colors.black87, height: 1.4),
                  ),
                ),
                SpaceW8(),
                Icon(
                  _isSelectedAboutMe
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: tealColor,
                  size: 20.0,
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildPersonalData(BuildContext context) {
    String email = widget.user?.email ?? '';
    String phone = widget.user?.phone ?? '';
    // Custom Colors
    final Color tealColor = Color(0xFF005B5B);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          StringConst.PERSONAL_DATA.toUpperCase(),
          style: GoogleFonts.rubik(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: tealColor,
          ),
        ),
        SpaceH12(),
        Column(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _isSelectedEmail = !_isSelectedEmail;
                  if (widget.myCustomEmail == "") {
                    widget.myCustomEmail = email;
                  } else {
                    widget.myCustomEmail = "";
                  }
                });
              },
              child: Row(
                children: [
                  Icon(
                    Icons.mail_outline,
                    color: tealColor,
                    size: 18.0,
                  ),
                  SpaceW8(),
                  Expanded(
                    child: Text(
                      widget.user?.email ?? '',
                      style: GoogleFonts.rubik(
                          fontSize: 14.0, color: Colors.black54),
                    ),
                  ),
                  SpaceW8(),
                  Icon(
                    _isSelectedEmail
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: tealColor,
                    size: 18.0,
                  ),
                ],
              ),
            ),
            SpaceH8(),
            InkWell(
              onTap: () {
                setState(() {
                  _isSelectedPhone = !_isSelectedPhone;
                  if (widget.myCustomPhone == "") {
                    widget.myCustomPhone = phone;
                  } else {
                    widget.myCustomPhone = "";
                  }
                });
              },
              child: Row(
                children: [
                  Icon(
                    Icons.phone_outlined,
                    color: tealColor,
                    size: 18.0,
                  ),
                  SpaceW8(),
                  Expanded(
                    child: Text(
                      widget.user?.phone ?? '',
                      style: GoogleFonts.rubik(
                          fontSize: 14.0, color: Colors.black54),
                    ),
                  ),
                  SpaceW8(),
                  Icon(
                    _isSelectedPhone
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: tealColor,
                    size: 18.0,
                  ),
                ],
              ),
            ),
            SpaceH8(),
            _buildMyLocation(context),
          ],
        ),
      ],
    );
  }

  Widget _buildMyLocation(BuildContext context) {
    String myCity = widget.city ?? '';
    String myProvince = widget.province ?? '';
    String myCountry = widget.country ?? '';
    // Custom Colors
    final Color tealColor = Color(0xFF005B5B);

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.location_on_outlined,
          color: tealColor,
          size: 18,
        ),
        SpaceW8(),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    _isSelectedMyCity = !_isSelectedMyCity;
                    if (widget.myCustomCity == "") {
                      widget.myCustomCity = myCity;
                    } else {
                      widget.myCustomCity = "";
                    }
                  });
                },
                child: Row(
                  children: [
                    Text(
                      (widget.city ?? '') + ", ",
                      style: GoogleFonts.rubik(
                          fontSize: 14.0, color: Colors.black54),
                    ),
                    Icon(
                      _isSelectedMyCity
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: tealColor,
                      size: 14.0,
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    _isSelectedMyProvince = !_isSelectedMyProvince;
                    if (widget.myCustomProvince == "") {
                      widget.myCustomProvince = myProvince;
                    } else {
                      widget.myCustomProvince = "";
                    }
                  });
                },
                child: Row(
                  children: [
                    Text(
                      (widget.province ?? '') + ", ",
                      style: GoogleFonts.rubik(
                          fontSize: 14.0, color: Colors.black54),
                    ),
                    Icon(
                      _isSelectedMyProvince
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: tealColor,
                      size: 14.0,
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    _isSelectedMyCountry = !_isSelectedMyCountry;
                    if (widget.myCustomCountry == "") {
                      widget.myCustomCountry = myCountry;
                    } else {
                      widget.myCustomCountry = "";
                    }
                  });
                },
                child: Row(
                  children: [
                    Text(
                      widget.country ?? '',
                      style: GoogleFonts.rubik(
                          fontSize: 14.0, color: Colors.black54),
                    ),
                    SpaceW4(),
                    Icon(
                      _isSelectedMyCountry
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: tealColor,
                      size: 14.0,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMyCompetencies(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // Custom Colors
    final Color tealColor = Color(0xFF005B5B);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          StringConst.COMPETENCIES.toUpperCase(),
          style: GoogleFonts.rubik(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: tealColor,
          ),
        ),
        SpaceH12(),
        Container(
          width: double.infinity,
          child: widget.competenciesNames.isNotEmpty
              ? Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children:
                      List.generate(widget.competenciesNames.length, (index) {
                    bool isSelected =
                        widget.mySelectedCompetencies.contains(index);
                    return InkWell(
                        onTap: () {
                          print(
                              'selected item: ${widget.competenciesNames[index]}');
                          bool exists = widget.myCustomCompetencies.any(
                              (element) =>
                                  element == widget.competenciesNames[index]);
                          setState(() {
                            if (exists == true) {
                              widget.myCustomCompetencies
                                  .remove(widget.competenciesNames[index]);
                              widget.mySelectedCompetencies.remove(
                                  index); // This was _selectedCompetenciesIndex logic which works but passing explicit index is safer for check
                            } else {
                              widget.myCustomCompetencies
                                  .add(widget.competenciesNames[index]);
                              widget.mySelectedCompetencies.add(index);
                            }
                          });
                        },
                        child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: tealColor),
                              color: Colors.white,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(widget.competenciesNames[index],
                                    style: GoogleFonts.rubik(
                                      color: Colors.black87,
                                      fontSize: 13,
                                    )),
                                if (isSelected) ...[
                                  SpaceW4(),
                                  Icon(Icons.check, size: 14, color: tealColor)
                                ]
                              ],
                            )));
                  }))
              : Padding(
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
    final DateFormat formatter = DateFormat('yyyy');
    // Custom Colors
    final Color tealColor = Color(0xFF005B5B);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          StringConst.EDUCATION.toUpperCase(),
          style: GoogleFonts.rubik(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: tealColor,
          ),
        ),
        SpaceH12(),
        Container(
          width: double.infinity,
          child: widget.myEducation!.isNotEmpty
              ? ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: widget.myEducation!.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                        onTap: () {
                          print(
                              'selected item: ${widget.myEducation![index].activity}');
                          bool exists = widget.myCustomEducation.any(
                              (element) =>
                                  element.id == widget.myEducation![index].id);
                          setState(() {
                            if (exists == true) {
                              widget.myCustomEducation
                                  .remove(widget.myEducation![index]);
                              widget.mySelectedEducation.remove(index);
                              //Disguise date
                              mySelectedDateEducation.remove(index);
                              idSelectedDateEducation.remove(
                                  widget.myEducation!.elementAt(index).id);
                            } else {
                              widget.myCustomEducation
                                  .add(widget.myEducation![index]);
                              widget.mySelectedEducation.add(index);
                              //Show date
                              mySelectedDateEducation.add(index);
                              idSelectedDateEducation.add(
                                  widget.myEducation!.elementAt(index).id!);
                            }
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Dot decoration
                              Column(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(top: 5),
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: tealColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ),
                              SpaceW12(),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Date and Location
                                    Row(
                                      children: [
                                        Text(
                                          '${widget.myEducation![index].startDate != null ? formatter.format(widget.myEducation![index].startDate!.toDate()) : '-'} / ${widget.myEducation![index].endDate != null ? formatter.format(widget.myEducation![index].endDate!.toDate()) : 'Actualmente'}',
                                          style: GoogleFonts.rubik(
                                            fontSize: 12.0,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        if (widget.myEducation![index].location
                                            .isNotEmpty) ...[
                                          Text(' - ',
                                              style: TextStyle(
                                                  color: Colors.grey)),
                                          Text(
                                            widget.myEducation![index].location,
                                            style: GoogleFonts.rubik(
                                              fontSize: 12.0,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ]
                                      ],
                                    ),
                                    SpaceH4(),
                                    // Title
                                    Text(
                                      widget.myEducation![index]
                                              .nameFormation ??
                                          '',
                                      style: GoogleFonts.rubik(
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.w700, // Bold
                                          color: Colors.black87),
                                    ),
                                    // Institution
                                    if (widget
                                            .myEducation![index].institution !=
                                        null)
                                      Text(
                                        widget.myEducation![index].institution!,
                                        style: GoogleFonts.rubik(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.black87),
                                      ),
                                  ],
                                ),
                              ),
                              // Selection Checkbox
                              Icon(
                                widget.mySelectedEducation.contains(index)
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: tealColor,
                                size: 20.0,
                              ),
                            ],
                          ),
                        ));
                  },
                )
              : Padding(
                  padding: EdgeInsets.all(Constants.mainPadding),
                  child: Center(
                      child: CustomTextBody(text: StringConst.NO_EDUCATION)),
                ),
        ),
      ],
    );
  }

  Widget _buildMySecondaryEducation(BuildContext context) {
    final DateFormat formatter = DateFormat('yyyy');
    // Custom Colors
    final Color tealColor = Color(0xFF005B5B);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          StringConst.SECONDARY_EDUCATION.toUpperCase(),
          style: GoogleFonts.rubik(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: tealColor,
          ),
        ),
        SpaceH12(),
        Container(
          width: double.infinity,
          child: widget.mySecondaryEducation!.isNotEmpty
              ? ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: widget.mySecondaryEducation!.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                        onTap: () {
                          if (widget.mySecondarySelectedEducation
                              .contains(index)) {
                            if (mySelectedDateSecondaryEducation
                                .contains(index)) {
                              mySelectedDateSecondaryEducation.remove(index);
                              idSelectedDateSecondaryEducation.remove(widget
                                  .mySecondaryEducation!
                                  .elementAt(index)
                                  .id);
                            } else {
                              mySelectedDateSecondaryEducation.add(index);
                              idSelectedDateSecondaryEducation.add(widget
                                  .mySecondaryEducation!
                                  .elementAt(index)
                                  .id!);
                            }
                          }
                          setState(() {
                            bool exists = widget.mySecondaryCustomEducation.any(
                                (element) =>
                                    element.id ==
                                    widget.mySecondaryEducation![index].id);

                            if (exists) {
                              widget.mySecondaryCustomEducation
                                  .remove(widget.mySecondaryEducation![index]);
                              widget.mySecondarySelectedEducation.remove(index);
                            } else {
                              widget.mySecondaryCustomEducation
                                  .add(widget.mySecondaryEducation![index]);
                              widget.mySecondarySelectedEducation.add(index);
                            }
                          });
                        },
                        child: Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Dot
                                  Column(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(top: 5),
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: tealColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SpaceW12(),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(children: [
                                          Text(
                                            '${widget.mySecondaryEducation![index].startDate != null ? formatter.format(widget.mySecondaryEducation![index].startDate!.toDate()) : '-'} / ${widget.mySecondaryEducation![index].endDate != null ? formatter.format(widget.mySecondaryEducation![index].endDate!.toDate()) : 'Actualmente'}',
                                            style: GoogleFonts.rubik(
                                                fontSize: 12,
                                                color: Colors.grey[600]),
                                          ),
                                          if (widget
                                              .mySecondaryEducation![index]
                                              .location
                                              .isNotEmpty) ...[
                                            Text(' - ',
                                                style: TextStyle(
                                                    color: Colors.grey)),
                                            Text(
                                              widget
                                                  .mySecondaryEducation![index]
                                                  .location,
                                              style: GoogleFonts.rubik(
                                                fontSize: 12.0,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ]
                                        ]),
                                        SpaceH4(),
                                        Text(
                                            widget.mySecondaryEducation![index]
                                                    .nameFormation ??
                                                '',
                                            style: GoogleFonts.rubik(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.black87)),
                                        if (widget.mySecondaryEducation![index]
                                                .institution !=
                                            null)
                                          Text(
                                              widget
                                                  .mySecondaryEducation![index]
                                                  .institution!,
                                              style: GoogleFonts.rubik(
                                                  fontSize: 14,
                                                  color: Colors.black87))
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    widget.mySecondarySelectedEducation
                                            .contains(index)
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    color: tealColor,
                                    size: 20.0,
                                  ),
                                ])));
                  },
                )
              : Padding(
                  padding: EdgeInsets.all(Constants.mainPadding),
                  child: Center(
                      child: CustomTextBody(text: StringConst.NO_EDUCATION)),
                ),
        ),
      ],
    );
  }

  Widget _buildMyExperiences(BuildContext context) {
    final DateFormat formatter = DateFormat('yyyy');
    // Custom Colors
    final Color tealColor = Color(0xFF005B5B);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          StringConst.MY_PROFESIONAL_EXPERIENCES.toUpperCase(),
          style: GoogleFonts.rubik(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: tealColor,
          ),
        ),
        SpaceH12(),
        Container(
          width: double.infinity,
          child: widget.myExperiences!.isNotEmpty
              ? ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: widget.myExperiences!.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                        onTap: () {
                          print(
                              'selected item: ${widget.myExperiences![index].activity}');
                          bool exists = widget.myCustomExperiences.any(
                              (element) =>
                                  element.id ==
                                  widget.myExperiences![index].id);
                          setState(() {
                            if (exists == true) {
                              widget.myCustomExperiences
                                  .remove(widget.myExperiences![index]);
                              widget.mySelectedExperiences.remove(index);
                              //Disguise date
                              mySelectedDateExperience.remove(index);
                              idSelectedDateExperience.remove(
                                  widget.myExperiences!.elementAt(index).id);
                            } else {
                              widget.myCustomExperiences
                                  .add(widget.myExperiences![index]);
                              widget.mySelectedExperiences.add(index);
                              //Show date
                              mySelectedDateExperience.add(index);
                              idSelectedDateExperience.add(
                                  widget.myExperiences!.elementAt(index).id!);
                            }
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Dot
                              Column(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(top: 5),
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: tealColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ),
                              SpaceW12(),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    // Date and Location
                                    Row(
                                      children: [
                                        Text(
                                          '${widget.myExperiences![index].startDate != null ? formatter.format(widget.myExperiences![index].startDate!.toDate()) : '-'} / ${widget.myExperiences![index].endDate != null ? formatter.format(widget.myExperiences![index].endDate!.toDate()) : 'Actualmente'}',
                                          style: GoogleFonts.rubik(
                                            fontSize: 12.0,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        if (widget.myExperiences![index]
                                            .location.isNotEmpty) ...[
                                          Text(' - ',
                                              style: TextStyle(
                                                  color: Colors.grey)),
                                          Text(
                                            widget
                                                .myExperiences![index].location,
                                            style: GoogleFonts.rubik(
                                              fontSize: 12.0,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ]
                                      ],
                                    ),
                                    SpaceH4(),
                                    // Position
                                    Text(
                                      widget.myExperiences![index].position !=
                                                  null &&
                                              widget.myExperiences![index]
                                                  .position!.isNotEmpty
                                          ? widget
                                              .myExperiences![index].position!
                                          : (widget.myExperiences![index]
                                                  .organization ??
                                              ''),
                                      style: GoogleFonts.rubik(
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87),
                                    ),
                                    // Organization (if different/available)
                                    if (widget.myExperiences![index]
                                                .organization !=
                                            null &&
                                        widget.myExperiences![index]
                                            .organization!.isNotEmpty &&
                                        widget.myExperiences![index]
                                                .organization !=
                                            widget
                                                .myExperiences![index].position)
                                      Text(
                                          widget.myExperiences![index]
                                              .organization!,
                                          style: GoogleFonts.rubik(
                                              fontSize: 14.0,
                                              color: Colors.black87))
                                  ],
                                ),
                              ),
                              // Selection Checkbox
                              Icon(
                                widget.mySelectedExperiences.contains(index)
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: tealColor,
                                size: 20.0,
                              ),
                            ],
                          ),
                        ));
                  },
                )
              : Padding(
                  padding: EdgeInsets.all(Constants.mainPadding),
                  child: Center(
                      child: CustomTextBody(text: StringConst.NO_EDUCATION)),
                ),
        ),
      ],
    );
  }

  Widget _buildMyPersonalExperiences(BuildContext context) {
    final DateFormat formatter = DateFormat('yyyy');
    // Custom Colors
    final Color tealColor = Color(0xFF005B5B);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          StringConst.MY_PERSONAL_EXPERIENCES.toUpperCase(),
          style: GoogleFonts.rubik(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: tealColor,
          ),
        ),
        SpaceH12(),
        Container(
          width: double.infinity,
          child: widget.myPersonalExperiences!.isNotEmpty
              ? ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: widget.myPersonalExperiences!.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                        onTap: () {
                          print(
                              'selected item: ${widget.myPersonalExperiences![index].activity}');
                          bool exists = widget.myPersonalCustomExperiences.any(
                              (element) =>
                                  element.id ==
                                  widget.myPersonalExperiences![index].id);
                          setState(() {
                            if (exists == true) {
                              widget.myPersonalCustomExperiences
                                  .remove(widget.myPersonalExperiences![index]);
                              widget.myPersonalSelectedExperiences
                                  .remove(index);
                              //Disguise date
                              mySelectedDatePersonalExperience.remove(index);
                              idSelectedDatePersonalExperience.remove(widget
                                  .myPersonalExperiences!
                                  .elementAt(index)
                                  .id);
                            } else {
                              widget.myPersonalCustomExperiences
                                  .add(widget.myPersonalExperiences![index]);
                              widget.myPersonalSelectedExperiences.add(index);
                              //Show date
                              mySelectedDatePersonalExperience.add(index);
                              idSelectedDatePersonalExperience.add(widget
                                  .myPersonalExperiences!
                                  .elementAt(index)
                                  .id!);
                            }
                          });
                        },
                        child: Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Dot
                                Column(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(top: 5),
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: tealColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ),
                                SpaceW12(),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      // Date styling
                                      Row(children: [
                                        Text(
                                          '${widget.myPersonalExperiences![index].startDate != null ? formatter.format(widget.myPersonalExperiences![index].startDate!.toDate()) : '-'} / ${widget.myPersonalExperiences![index].endDate != null ? formatter.format(widget.myPersonalExperiences![index].endDate!.toDate()) : 'Actualmente'}',
                                          style: GoogleFonts.rubik(
                                              fontSize: 12,
                                              color: Colors.grey[600]),
                                        ),
                                      ]),
                                      SpaceH4(),
                                      // Title logic
                                      Builder(builder: (context) {
                                        var exp = widget
                                            .myPersonalExperiences![index];
                                        String title = exp.activity ?? '';
                                        String subtitle = exp.subtype ?? '';

                                        if (exp.subtype ==
                                                'Responsabilidades familiares' ||
                                            exp.subtype ==
                                                'Compromiso social') {
                                          title = exp.subtype!;
                                          subtitle = exp.activity ?? '';
                                        }

                                        return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                title,
                                                style: GoogleFonts.rubik(
                                                    fontSize: 15.0,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.black87),
                                              ),
                                              if (subtitle.isNotEmpty &&
                                                  subtitle != title)
                                                Text(subtitle,
                                                    style: GoogleFonts.rubik(
                                                        fontSize: 14.0,
                                                        color: Colors.black87)),
                                              if (exp.organization != null &&
                                                  exp.organization!.isNotEmpty)
                                                Text(exp.organization!,
                                                    style: GoogleFonts.rubik(
                                                        fontSize: 14.0,
                                                        color: Colors.black87)),
                                            ]);
                                      })
                                    ],
                                  ),
                                ),
                                // Selection
                                Icon(
                                  widget.myPersonalSelectedExperiences
                                          .contains(index)
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  color: tealColor,
                                  size: 20.0,
                                ),
                              ],
                            )));
                  },
                )
              : Padding(
                  padding: EdgeInsets.all(Constants.mainPadding),
                  child: Center(
                      child: CustomTextBody(text: StringConst.NO_EDUCATION)),
                ),
        ),
      ],
    );
  }

  Widget _buildMyDataOfInterest(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final myDataOfInterest = widget.user?.dataOfInterest ?? [];

    // Custom Colors
    final Color tealColor = Color(0xFF005B5B);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          StringConst.DATA_OF_INTEREST.toUpperCase(),
          style: GoogleFonts.rubik(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: tealColor,
          ),
        ),
        SpaceH12(),
        Container(
          width: double.infinity,
          child: myDataOfInterest.isNotEmpty
              ? ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: myDataOfInterest.length,
                  itemBuilder: (context, index) {
                    bool isSelected =
                        widget.mySelectedDataOfInterest.contains(index);
                    return InkWell(
                      onTap: () {
                        bool exists = widget.myCustomDataOfInterest.any(
                            (element) => element == myDataOfInterest[index]);
                        setState(() {
                          if (exists == true) {
                            widget.myCustomDataOfInterest
                                .remove(myDataOfInterest[index]);
                            widget.mySelectedDataOfInterest.remove(index);
                          } else {
                            widget.myCustomDataOfInterest
                                .add(myDataOfInterest[index]);
                            widget.mySelectedDataOfInterest.add(index);
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(myDataOfInterest[index],
                                  style: GoogleFonts.rubik(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black87)),
                            ),
                            Icon(
                              isSelected
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: tealColor,
                              size: 18.0,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : Padding(
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
    final myLanguagesLevels = widget.user?.languagesLevels ?? [];

    // Custom Colors
    final Color tealColor = Color(0xFF005B5B);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          StringConst.LANGUAGES.toUpperCase(),
          style: GoogleFonts.rubik(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: tealColor,
          ),
        ),
        SpaceH12(),
        Container(
          width: double.infinity,
          child: myLanguagesLevels.isNotEmpty
              ? ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: myLanguagesLevels.length,
                  itemBuilder: (context, index) {
                    bool isSelected =
                        widget.mySelectedLanguages.contains(index);
                    return InkWell(
                      onTap: () {
                        bool exists = widget.myCustomLanguages.any(
                            (element) => element == myLanguagesLevels[index]);
                        setState(() {
                          if (exists == true) {
                            widget.myCustomLanguages
                                .remove(myLanguagesLevels[index]);
                            widget.mySelectedLanguages.remove(index);
                          } else {
                            widget.myCustomLanguages
                                .add(myLanguagesLevels[index]);
                            widget.mySelectedLanguages.add(index);
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(myLanguagesLevels[index].name,
                                  style: GoogleFonts.rubik(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black87)),
                            ),
                            Icon(
                              isSelected
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: tealColor,
                              size: 18.0,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : Padding(
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
    // Custom Colors
    final Color tealColor = Color(0xFF005B5B);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          StringConst.PERSONAL_REFERENCES.toUpperCase(),
          style: GoogleFonts.rubik(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: tealColor,
          ),
        ),
        SpaceH12(),
        Container(
          width: double.infinity,
          child: widget.myReferences!.isNotEmpty
              ? ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: widget.myReferences!.length,
                  itemBuilder: (context, index) {
                    bool isSelected =
                        widget.mySelectedReferences.contains(index);
                    return InkWell(
                      onTap: () {
                        bool exists = widget.myCustomReferences.any((element) =>
                            element.certificationRequestId ==
                            widget.myReferences![index].certificationRequestId);
                        setState(() {
                          if (exists == true) {
                            widget.myCustomReferences
                                .remove(widget.myReferences![index]);
                            widget.mySelectedReferences.remove(index);
                          } else {
                            widget.myCustomReferences
                                .add(widget.myReferences![index]);
                            widget.mySelectedReferences.add(index);
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${widget.myReferences![index].certifierName}',
                                    style: GoogleFonts.rubik(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SpaceH4(),
                                  Text(
                                    '${widget.myReferences![index].certifierPosition.toUpperCase()} - ${widget.myReferences![index].certifierCompany.toUpperCase()}',
                                    style: GoogleFonts.rubik(
                                      fontSize: 12.0,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  SpaceH4(),
                                  Text(
                                    '${widget.myReferences![index].email}',
                                    style: GoogleFonts.rubik(
                                      fontSize: 12.0,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  if (widget.myReferences![index].phone != "")
                                    Text(
                                      '${widget.myReferences![index].phone}',
                                      style: GoogleFonts.rubik(
                                        fontSize: 12.0,
                                        color: Colors.black54,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Icon(
                              isSelected
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: tealColor,
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
                  child: Center(
                      child: CustomTextBody(text: StringConst.NO_REFERENCES)),
                ),
        ),
      ],
    );
  }

  int getTotalRightElements() {
    return widget.myPersonalCustomExperiences.length +
        widget.myCustomExperiences.length +
        widget.myCustomEducation.length +
        widget.mySecondaryCustomEducation.length +
        widget.myCustomCompetencies.length;
  }

  int getTotalLeftElements() {
    int sum = 0;
    if (widget.myCustomAboutMe.length < 130 &&
        widget.myCustomAboutMe.length > 0) {
      sum = 1;
    }
    if (widget.myCustomAboutMe.length > 130 &&
        widget.myCustomAboutMe.length > 0) {
      sum = 2;
    }
    return widget.myCustomLanguages.length +
        widget.myCustomDataOfInterest.length +
        widget.myCustomReferences.length +
        sum;
  }
}

class SeparatorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary900
      ..strokeWidth = 2;

    final circleFillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final circleBorderPaint = Paint()
      ..color = AppColors.primary900
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final centerX = size.width / 2.8;
    final circleRadius = 8.0;

    // Línea vertical
    canvas.drawLine(
      Offset(centerX, 0),
      Offset(centerX, size.height),
      paint,
    );

    // Línea horizontal superior
    canvas.drawLine(
      Offset(0, 0),
      Offset(size.width, 0),
      paint,
    );

    canvas.drawCircle(
      Offset(centerX, 00),
      circleRadius,
      circleFillPaint,
    );

    // Borde color primary
    canvas.drawCircle(
      Offset(centerX, 00),
      circleRadius,
      circleBorderPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _Separator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SeparatorPainter(),
    );
  }
}
