import 'package:enreda_app/app/home/curriculum/pdf_generator/pdf_preview.dart';
import 'package:enreda_app/utils/adaptive.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/values/values.dart';
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
    required this.myEducation,
    required this.myCustomEducation,
    required this.mySelectedEducation,
    required this.competenciesNames,
    required this.myCustomCompetencies,
    required this.mySelectedCompetencies,
    required this.myCustomDataOfInterest,
    required this.mySelectedDataOfInterest,
    required this.myCustomLanguages,
    required this.mySelectedLanguages,
  }) : super(key: key);

  final UserEnreda? user;
  final String? city;
  final String? province;
  final String? country;
  String myCustomAboutMe;
  String myCustomEmail;
  String myCustomPhone;
  final List<Experience>? myExperiences;
  List<Experience> myCustomExperiences;
  List<int> mySelectedExperiences;
  final List<Experience>? myEducation;
  List<Experience> myCustomEducation;
  List<int> mySelectedEducation;
  final List<String> competenciesNames;
  List<String> myCustomCompetencies;
  List<int> mySelectedCompetencies;
  List<String> myCustomDataOfInterest;
  List<int> mySelectedDataOfInterest;
  List<String> myCustomLanguages;
  List<int> mySelectedLanguages;

  @override
  _MyCvModelsPageState createState() => _MyCvModelsPageState();
}

class _MyCvModelsPageState extends State<MyCvModelsPage> {
  int? _selectedEducationIndex;
  int? _selectedExperienceIndex;
  int? _selectedCompetenciesIndex;
  int? _selectedLanguagesIndex;
  int? _selectedDataOfInterestIndex;
  bool _isSelectedAboutMe = true;
  bool _isSelectedEmail = true;
  bool _isSelectedPhone = true;

  @override
  void initState() {
    super.initState();
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
                      Padding(
                        padding: Responsive.isMobile(context)
                            ? const EdgeInsets.all(8.0)
                            : const EdgeInsets.all(20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.all(Radius.circular(60)),
                              child:
                              Center(
                                child:
                                widget.user?.profilePic?.src == "" ?
                                Container(
                                  color:  Colors.transparent,
                                  height: 120,
                                  width: 120,
                                  child: Image.asset(ImagePath.USER_DEFAULT),
                                ) :
                                Image.network(
                                    widget.user?.profilePic?.src ?? ImagePath.USER_DEFAULT,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    alignment: Alignment.center,
                                    ),
                              ),
                            )
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
                    _buildMyExperiences(context),
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
    return SingleChildScrollView(
      child: Container(
        margin: Responsive.isTablet(context) ? EdgeInsets.only(top: 30, bottom: Constants.mainPadding * 3 ) : EdgeInsets.symmetric(vertical: 0.0),
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
                      flex: 1,
                      child: SizedBox(width: Responsive.isTablet(context) || Responsive.isMobile(context) ? 26: 50,)),
                  Expanded(
                      flex: 6,
                      child: Center(child: CustomTextBody(text: StringConst.MY_CV.toUpperCase()))),
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MyCv(
                                user: widget.user!,
                                city: widget.city!,
                                province: widget.province!,
                                country: widget.country!,
                                myCustomEmail: widget.myCustomEmail,
                                myCustomPhone: widget.myCustomPhone,
                                myExperiences: widget.myExperiences!,
                                myEducation: widget.myEducation!,
                                competenciesNames: widget.competenciesNames,
                                languagesNames: widget.myCustomLanguages,
                                aboutMe: widget.myCustomAboutMe,
                                myDataOfInterest: widget.myCustomDataOfInterest,
                              )),
                        );
                      },
                      child: Image.asset(
                        ImagePath.DOWNLOAD,
                        height: Responsive.isTablet(context) || Responsive.isMobile(context) ? Sizes.ICON_SIZE_30 : Sizes.ICON_SIZE_50,
                      ),),
                  ),
                ],
              ),
              SpaceH20(),
              Padding(
                padding: Responsive.isMobile(context)
                    ? const EdgeInsets.all(8.0)
                    : const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(60)),
                      child:
                      Center(
                        child: widget.user?.profilePic?.src == "" ?
                        Container(
                          color:  Colors.transparent,
                          height: 120,
                          width: 120,
                          child: Image.asset(ImagePath.USER_DEFAULT),
                        ):
                        Image.network(
                          widget.user?.profilePic?.src ?? ImagePath.USER_DEFAULT,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
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
              CustomText(title: widget.user?.education!.toUpperCase() ?? ''),
              SpaceH24(),
              CustomTextTitle(title: StringConst.PERSONAL_DATA.toUpperCase()),
              Row(
                children: [
                  Icon(
                    Icons.mail,
                    color: Colors.black.withOpacity(0.7),
                    size: 16,
                  ),
                  SpaceW4(),
                  CustomTextSmall(text: widget.user?.email ?? ''),
                ],
              ),
              SpaceH8(),
              Row(
                children: [
                  Icon(
                    Icons.phone,
                    color: Constants.darkGray,
                    size: 12.0,
                  ),
                  SpaceW4(),
                  Text(
                    widget.user?.phone ?? '',
                    style: textTheme.bodyText1?.copyWith(
                        fontSize: Responsive.isDesktop(context) ? 16 : 14.0,
                        color: Constants.darkGray),
                  ),
                ],
              ),
              SpaceH8(),
              _buildMyLocation(context),
              SpaceH24(),
              _buildMyEducation(context),
              SpaceH24(),
              _buildMyExperiences(context),
              SpaceH24(),
              _buildMyCompetencies(context),
              SpaceH24(),
              _buildAboutMe(context),
              SpaceH24(),
              _buildMyDataOfInterest(context),
              SpaceH24(),
              _buildMyLanguages(context),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          MyCv(
                            user: widget.user!,
                            city: widget.city!,
                            province: widget.province!,
                            country: widget.country!,
                            myExperiences: widget.myCustomExperiences,
                            myEducation: widget.myCustomEducation,
                            competenciesNames: widget.myCustomCompetencies,
                            aboutMe: widget.myCustomAboutMe,
                            languagesNames: widget.myCustomLanguages,
                            myDataOfInterest: widget.myCustomDataOfInterest,
                            myCustomEmail: widget.myCustomEmail,
                            myCustomPhone: widget.myCustomPhone,
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
        Text(
          widget.user?.education?.toUpperCase() ?? '',
          style: textTheme.bodyLarge?.copyWith(
              fontSize: Responsive.isDesktop(context) ? 16 : 12.0,
              color: Constants.darkGray),
        ),
      ],
    );
  }

  Widget _buildAboutMe(BuildContext context) {
    String aboutMe = widget.user?.aboutMe ?? '';
    return StatefulBuilder(builder: (context, setState) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
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
            SpaceH20(),
            InkWell(
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
          ],
        ),
      );
    });
  }

  Widget _buildPersonalData(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    String email = widget.user?.email ?? '';
    String phone = widget.user?.phone ?? '';
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            StringConst.PERSONAL_DATA.toUpperCase(),
            style: textTheme.bodyText1?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: Responsive.isDesktop(context) ? 18 : 14.0,
              color: Constants.darkLilac,
            ),
          ),
          SpaceH20(),
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
                        fontSize: Responsive.isDesktop(context) ? 14 : 11.0,
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
                        fontSize: Responsive.isDesktop(context) ? 14 : 11.0,
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
    );
  }

  Widget _buildMyLocation(BuildContext context) {
    String myLocation = '${widget.city ?? ''}, ${widget.province ?? ''}, ${widget.country ?? ''}';
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
        Responsive.isMobile(context) ? CustomTextSmall(text: myLocation) :
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextSmall(text: widget.city ?? ''),
            CustomTextSmall(text: widget.province ?? ''),
            CustomTextSmall(text: widget.country ?? ''),
          ],
        ),
      ],
    );

  }

  Widget _buildMyCompetencies(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Row(
          children: [
            CustomTextTitle(title: StringConst.COMPETENCIES.toUpperCase()),
          ],
        ),
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
      children: [
        Row(
          children: [
            CustomTextTitle(title: StringConst.EDUCATION.toUpperCase()),
          ],
        ),
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
                                  if (widget.myEducation![index].activity != null && widget.myEducation![index].activityRole != null)
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
                                  if (widget.myEducation![index].activity != null && widget.myEducation![index].activityRole == null)
                                    Text('${widget.myEducation![index].activity!}',
                                        style: textTheme.bodyText1
                                            ?.copyWith(fontSize: 14.0, fontWeight: FontWeight.bold)),
                                  if (widget.myEducation![index].activity != null) SpaceH8(),
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

  Widget _buildMyExperiences(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return Column(
      children: [
        Row(
          children: [
            CustomTextTitle(title: StringConst.MY_EXPERIENCES.toUpperCase()),
          ],
        ),
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
                                  Text('${widget.myExperiences![index].activity!}',
                                      style: textTheme.bodyText1
                                          ?.copyWith(fontSize: 14.0, fontWeight: FontWeight.bold)),
                                if (widget.myExperiences![index].activity != null) SpaceH8(),
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

  Widget _buildMyDataOfInterest(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final myDataOfInterest = widget.user?.dataOfInterest ?? [];
    return Column(
      children: [
        Row(
          children: [
            CustomTextTitle(title: StringConst.DATA_OF_INTEREST.toUpperCase()),
          ],
        ),
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
                  'Aquí aparecerán las competencias evaluadas a través de los microtests',
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
      children: [
        Row(
          children: [
            CustomTextTitle(title: StringConst.LANGUAGES.toUpperCase()),
          ],
        ),
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
                  'Aquí aparecerán las competencias evaluadas a través de los microtests',
                  style: textTheme.bodyText1,
                )),
          ),
        ),

      ],
    );
  }

}


