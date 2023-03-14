import 'package:cached_network_image/cached_network_image.dart';
import 'package:enreda_app/app/home/competencies/competency_tile.dart';
import 'package:enreda_app/app/home/curriculum/experience_form.dart';
import 'package:enreda_app/app/home/curriculum/experience_tile.dart';
import 'package:enreda_app/app/home/curriculum/my-custom_cv.dart';
import 'package:enreda_app/app/home/curriculum/pdf_generator/pdf_preview.dart';
import 'package:enreda_app/app/home/models/city.dart';
import 'package:enreda_app/app/home/models/competency.dart';
import 'package:enreda_app/app/home/models/country.dart';
import 'package:enreda_app/app/home/models/experience.dart';
import 'package:enreda_app/app/home/models/province.dart';
import 'package:enreda_app/app/home/models/userEnreda.dart';
import 'package:enreda_app/common_widgets/delete_button.dart';
import 'package:enreda_app/common_widgets/edit_button.dart';
import 'package:enreda_app/common_widgets/show_custom_dialog.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../common_widgets/custom_text.dart';
import '../../../common_widgets/precached_avatar.dart';
import '../../../utils/my_scroll_behaviour.dart';
import '../../../values/values.dart';

class MyCurriculumPage extends StatefulWidget {
  @override
  State<MyCurriculumPage> createState() => _MyCurriculumPageState();
}

class _MyCurriculumPageState extends State<MyCurriculumPage> {
  UserEnreda? user;
  String? myLocation;
  String? city;
  String? province;
  String? country;
  String myCustomAboutMe = "";
  String myCustomEmail = "";
  String myCustomPhone = "";
  List<Competency>? myCompetencies = [];
  List<Experience>? myExperiences = [];
  List<Experience> myCustomExperiences = [];
  List<int> mySelectedExperiences = [];
  List<Experience>? myEducation = [];
  List<Experience> myCustomEducation = [];
  List<int> mySelectedEducation = [];
  List<String> competenciesNames = [];
  List<String> myCustomCompetencies = [];
  List<int> mySelectedCompetencies = [];
  List<String> myCustomDataOfInterest = [];
  List<int> mySelectedDataOfInterest = [];
  List<String> myCustomLanguages = [];
  List<int> mySelectedLanguages = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    final database = Provider.of<Database>(context, listen: false);

    return Stack(
      children: [
        StreamBuilder<List<UserEnreda>>(
            stream: database.userStream(auth.currentUser?.email ?? ''),
            builder: (context, snapshot) {
              if (snapshot.hasData &&
                  snapshot.connectionState == ConnectionState.active) {
                user = snapshot.data!.isNotEmpty ? snapshot.data!.first : null;
                var profilePic = user?.profilePic?.src ?? "";
                return StreamBuilder<List<Competency>>(
                    stream: database.competenciesStream(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return Container();
                      if (snapshot.hasError)
                        return Center(child: Text('Ocurrió un error'));
                      List<Competency> competencies = snapshot.data!;
                      final competenciesIds = user!.competencies.keys.toList();
                      competencies = competencies
                          .where((competency) => competenciesIds.any((id) => competency.id == id))
                          .toList();
                      competencies.forEach((competency) {
                        final status =
                            user?.competencies[competency.id] ?? StringConst.BADGE_EMPTY;
                        if (competency.name !="" && status != StringConst.BADGE_EMPTY && status != StringConst.BADGE_IDENTIFIED ) {
                          final index1 = competenciesNames.indexWhere((element) => element == competency.name);
                          if (index1 == -1) competenciesNames.add(competency.name);
                        }
                      });

                      final myAboutMe = user?.aboutMe ?? "";
                      myCustomAboutMe = myAboutMe;

                      final myEmail = user?.email ?? "";
                      myCustomEmail = myEmail;

                      final myPhone = user?.phone ?? "";
                      myCustomPhone = myPhone;

                      myCustomCompetencies = competenciesNames.map((element) => element).toList();
                      mySelectedCompetencies = List.generate(myCustomCompetencies.length, (i) => i);

                      final myDataOfInterest = user?.dataOfInterest ?? [];
                      myCustomDataOfInterest = myDataOfInterest.map((element) => element).toList();
                      mySelectedDataOfInterest = List.generate(myCustomDataOfInterest.length, (i) => i);

                      final myLanguages = user?.languages ?? [];
                      myCustomLanguages = myLanguages.map((element) => element).toList();
                      mySelectedLanguages = List.generate(myCustomLanguages.length, (i) => i);

                      return Responsive.isDesktop(context)
                          ? _myCurriculumWeb(context, user, profilePic, competenciesNames )
                          : _myCurriculumMobile(context, user, profilePic, competenciesNames);
                    });
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }),
      ],
    );
  }

  Widget _myCurriculumWeb(BuildContext context, UserEnreda? user, String profilePic, List<String> competenciesNames){
    return Container(
      margin: EdgeInsets.only(
          top: 60.0, left: 4.0, right: 4.0, bottom: 4.0),
      padding: const EdgeInsets.only(
          left: 48.0, top: 72.0, right: 48.0, bottom: 48.0),
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
                              profilePic == "" ?
                              Container(
                                color:  Colors.transparent,
                                height: 120,
                                width: 120,
                                child: Image.asset(ImagePath.USER_DEFAULT),
                              ):
                              PrecacheAvatarCard(
                                imageUrl: profilePic,
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
          SpaceW40(),
          Expanded(
              child: SingleChildScrollView(
                controller: ScrollController(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCVHeader(context, user, profilePic, competenciesNames),
                    SpaceH40(),
                    _buildMyEducation(context, user),
                    SpaceH40(),
                    _buildMyExperiences(context, user),
                    SpaceH40(),
                    _buildMyCompetencies(context, user),
                  ],
                ),
              ))
        ],
      ),
    );
  }

  Widget _myCurriculumMobile(BuildContext context, UserEnreda? user, String profilePic, List<String> competenciesNames) {
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
                        if (await _hasEnoughExperiences(context))
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MyCv(
                                      user: user!,
                                      city: city!,
                                      province: province!,
                                      country: country!,
                                      myExperiences: myExperiences!,
                                      myEducation: myEducation!,
                                      competenciesNames: competenciesNames,
                                      languagesNames: [],
                                      aboutMe: "",
                                      myDataOfInterest:[],
                                      myCustomEmail: "",
                                      myCustomPhone: "",
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
                      Center(
                        child: profilePic == "" ?
                        Container(
                          color:  Colors.transparent,
                          height: 120,
                          width: 120,
                          child: Image.asset(ImagePath.USER_DEFAULT),
                        ):
                        FadeInImage.assetNetwork(
                          placeholder: ImagePath.USER_DEFAULT,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          image: profilePic,
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
                    '${user?.firstName} ${user?.lastName}',
                    style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: Responsive.isDesktop(context) ? 45.0 : 32.0,
                        color: Constants.penBlue),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              SpaceH24(),
              CustomText(title: user?.education!.toUpperCase() ?? ''),
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
                  CustomTextSmall(text: user?.email ?? ''),
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
                    user?.phone ?? '',
                    style: textTheme.bodyText1?.copyWith(
                        fontSize: Responsive.isDesktop(context) ? 16 : 14.0,
                        color: Constants.darkGray),
                  ),
                ],
              ),
              SpaceH8(),
              _buildMyLocation(context, user),
              SpaceH24(),
              _buildMyEducation(context, user),
              SpaceH24(),
              _buildMyExperiences(context, user),
              SpaceH24(),
              _buildMyCompetencies(context, user),
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

  Widget _buildCVHeader(BuildContext context, UserEnreda? user, String profilePic, List<String> competenciesNames) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomTextBody(text: StringConst.MY_CV.toUpperCase()),
            Spacer(),
            InkWell(
              onTap: () async {
                if (await _hasEnoughExperiences(context))
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (context) => MyCv(
                  //             user: user!,
                  //             city: city!,
                  //             province: province!,
                  //             country: country!,
                  //             myExperiences: myExperiences!,
                  //             myEducation: myEducation!,
                  //             competenciesNames: competenciesNames,
                  //           )),
                  // );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            MyCvModelsPage(
                              user: user!,
                              city: city!,
                              province: province!,
                              country: country!,
                              myCustomAboutMe: myCustomAboutMe,
                              myCustomEmail: myCustomEmail,
                              myCustomPhone: myCustomPhone,
                              myExperiences: myExperiences!,
                              myCustomExperiences: myCustomExperiences,
                              mySelectedExperiences: mySelectedExperiences,
                              myEducation: myEducation!,
                              myCustomEducation: myCustomEducation,
                              mySelectedEducation: mySelectedEducation,
                              competenciesNames: competenciesNames,
                              myCustomCompetencies: myCustomCompetencies,
                              mySelectedCompetencies: mySelectedCompetencies,
                              myCustomDataOfInterest: myCustomDataOfInterest,
                              mySelectedDataOfInterest: mySelectedDataOfInterest,
                              myCustomLanguages: myCustomLanguages,
                              mySelectedLanguages: mySelectedLanguages,
                            )),
                  );
              },
              child: Image.asset(
                ImagePath.DOWNLOAD,
                height:
                Responsive.isTablet(context) || Responsive.isMobile(context)
                    ? Sizes.ICON_SIZE_26
                    : Sizes.ICON_SIZE_50,
              ),
            ),
            SpaceW8(),
          ],
        ),
        SpaceH20(),
        Text(
          '${user?.firstName} ${user?.lastName}',
          style: textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: Responsive.isDesktop(context) ? 45.0 : 32.0,
              color: Constants.penBlue),
        ),
        SpaceH20(),
        Text(
          user?.education?.toUpperCase() ?? '',
          style: textTheme.bodyLarge?.copyWith(
              fontSize: Responsive.isDesktop(context) ? 16 : 12.0,
              color: Constants.darkGray),
        ),
      ],
    );
  }

  Widget _buildAboutMe(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    final textTheme = Theme.of(context).textTheme;
    var isEditable = false;
    final textController = TextEditingController();
    final focusNode = FocusNode();
    textController.text = user?.aboutMe ?? '';

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
              InkWell(
                onTap: () {
                  if (isEditable)
                    database.setUserEnreda(
                        user!.copyWith(aboutMe: textController.text));
                  setState(() {
                    isEditable = !isEditable;
                    if (isEditable) focusNode.requestFocus();
                  });
                },
                child: Icon(
                  isEditable ? Icons.save : Icons.edit_outlined,
                  size: Responsive.isDesktop(context) ? 18 : 15.0,
                  color: Constants.darkGray,
                ),
              ),
            ],
          ),
          SpaceH20(),
          if (!isEditable)
          CustomTextBody(
            text: user?.aboutMe != null && user!.aboutMe!.isNotEmpty
                ? user!.aboutMe!
                : 'Aún no has añadido información adicional sobre ti'),
          if (isEditable)
            TextField(
              controller: textController,
              focusNode: focusNode,
              minLines: 1,
              maxLines: null,
              style: textTheme.bodyLarge?.copyWith(
                  fontSize: Responsive.isDesktop(context) ? 15 : 14,
                  color: Constants.darkGray),
            )
        ],
      );
    });
  }

  Widget _buildPersonalData(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
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
        Row(
          children: [
            Icon(
              Icons.mail,
              color: Constants.darkGray,
              size: 12.0,
            ),
            SpaceW4(),
            Flexible(
              child: Text(
                user?.email ?? '',
                style: textTheme.bodyText1?.copyWith(
                    fontSize: Responsive.isDesktop(context) ? 14 : 11.0,
                    color: Constants.darkGray),
              ),
            ),
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
              user?.phone ?? '',
              style: textTheme.bodyText1?.copyWith(
                  fontSize: Responsive.isDesktop(context) ? 14 : 11.0,
                  color: Constants.darkGray),
            ),
          ],
        ),
        SpaceH8(),
        _buildMyLocation(context, user),
      ],
    );
  }

  Widget _buildMyLocation(BuildContext context, UserEnreda? user) {
    final database = Provider.of<Database>(context, listen: false);

    Country? myCountry;
    Province? myProvince;
    City? myCity;

    return StreamBuilder<Country>(
        stream: database.countryStream(user?.address?.country),
        builder: (context, snapshot) {
          myCountry = snapshot.data;
          return StreamBuilder<Province>(
              stream: database.provinceStream(user?.address?.province),
              builder: (context, snapshot) {
                myProvince = snapshot.data;

                return StreamBuilder<City>(
                    stream: database.cityStream(user?.address?.city),
                    builder: (context, snapshot) {
                      myCity = snapshot.data;

                      myLocation =
                          '${myCity?.name ?? ''}, ${myProvince?.name ?? ''}, ${myCountry?.name ?? ''}';
                      city = '${myCity?.name ?? ''}';
                      province = '${myProvince?.name ?? ''}';
                      country = '${myCountry?.name ?? ''}';

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
                          Responsive.isMobile(context) ? CustomTextSmall(text: myLocation ?? '') :
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomTextSmall(text: city ?? ''),
                              CustomTextSmall(text: province ?? ''),
                              CustomTextSmall(text: country ?? ''),
                            ],
                          ),
                        ],
                      );
                    });
              });
        });
  }

  Widget _buildMyCompetencies(BuildContext context, UserEnreda? user) {
    final database = Provider.of<Database>(context, listen: false);
    final textTheme = Theme.of(context).textTheme;
    final controller = ScrollController();
    var scrollJump = 137.5;
    return StreamBuilder<List<Competency>>(
      stream: database.competenciesStream(),
      builder: (context, snapshot) {
        if (snapshot.hasData &&
            snapshot.connectionState == ConnectionState.active) {
          final competenciesIds = user!.competencies.keys.toList();
          myCompetencies = snapshot.data!
              .where((competency) => competenciesIds.any((id) => competency.id == id &&
                (user.competencies[id] == StringConst.BADGE_VALIDATED ||
                user.competencies[id] == StringConst.BADGE_CERTIFIED) ))
              .toList();
          return Container(
            width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                border: Border.all(color: Constants.lilac, width: 1),
                borderRadius: BorderRadius.circular(20.0),
              ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Text(
                    StringConst.COMPETENCIES.toUpperCase(),
                    style: TextStyle(
                        color: Constants.darkLilac,
                        fontWeight: FontWeight.w600,
                        fontSize: 18.0),
                  ),
                ),
                myCompetencies!.isNotEmpty
                    ? Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: InkWell(
                        onTap: () {
                          if (controller.position.pixels >=
                              controller.position.minScrollExtent)
                            controller.animateTo(
                                controller.position.pixels - scrollJump,
                                duration: Duration(milliseconds: 500),
                                curve: Curves.ease);
                        },
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: Constants.penBlue,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 180.0,
                        color: Colors.white,
                        child: ScrollConfiguration(
                          behavior: MyCustomScrollBehavior(),
                          child: ListView(
                            controller: controller,
                            scrollDirection: Axis.horizontal,
                            children: myCompetencies!.map((competency) {
                              final status =
                                  user.competencies[competency.id] ??
                                      StringConst.BADGE_EMPTY;
                              return Column(
                                children: [
                                  CompetencyTile(
                                    competency: competency,
                                    status: status,
                                    mini: true,
                                  ),
                                  SpaceH12(),
                                  Text(
                                      status ==
                                              StringConst
                                                  .BADGE_VALIDATED
                                          ? 'EVALUADA'
                                          : 'CERTIFICADA',
                                      style: textTheme.bodyText1
                                          ?.copyWith(
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w500,
                                          color: Constants.turquoise)),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 10.0),
                      child: InkWell(
                        onTap: () {
                          if (controller.position.pixels <=
                              controller.position.maxScrollExtent)
                            controller.animateTo(
                                controller.position.pixels + scrollJump,
                                duration: Duration(milliseconds: 500),
                                curve: Curves.ease);
                        },
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: Constants.penBlue,
                        ),
                      ),
                    ),
                  ],
                )
                    : Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Center(
                          child: Text(
                            'Aquí aparecerán las competencias evaluadas a través de los microtests',
                            style: textTheme.bodyText1,
                          )),
                    ),
              ],
            )
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildMyEducation(BuildContext context, UserEnreda? user) {
    final database = Provider.of<Database>(context, listen: false);

    return Column(
      children: [
        Row(
          children: [
            CustomTextTitle(title: StringConst.EDUCATION.toUpperCase()),
            SpaceW12(),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Constants.salmonMain,
                shape: CircleBorder(),
              ),
              onPressed: () {
                showCustomDialog(
                  context,
                  content: ExperienceForm(
                    isEducation: true,
                  ),
                );
              },
              child: Icon(
                Icons.add,
                size: 15.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
        SpaceH4(),
        StreamBuilder<List<Experience>>(
            stream: database.myExperiencesStream(user?.userId ?? ''),
            builder: (context, snapshot) {
              if (snapshot.hasData &&
                  snapshot.connectionState == ConnectionState.active) {
                myEducation = snapshot.data!
                    .where((experience) => experience.type == 'Formativa')
                    .toList();
                myCustomEducation = myEducation!.map((element) => element).toList();
                mySelectedEducation = List.generate(myCustomEducation.length, (i) => i);
                return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
                    color: Constants.lightLilac,
                  ),
                  child: myEducation!.isNotEmpty
                      ? Wrap(
                          children: myEducation!
                              .map((e) => Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SpaceH12(),
                                      Container(
                                        width: double.infinity,
                                        child: ExperienceTile(experience: e),
                                      ),
                                      Divider(),
                                    ],
                                  ))
                              .toList(),
                        )
                      : CustomTextBody(text: StringConst.NO_EDUCATION),
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }),
      ],
    );
  }

  Widget _buildMyExperiences(BuildContext context, UserEnreda? user) {
    final database = Provider.of<Database>(context, listen: false);

    return Column(
      children: [
        Row(
          children: [
            CustomTextTitle(title: StringConst.MY_EXPERIENCES.toUpperCase()),
            SpaceW12(),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Constants.salmonMain,
                shape: CircleBorder(),
              ),
              onPressed: () {
                showCustomDialog(
                  context,
                  content: ExperienceForm(
                    isEducation: false,
                  ),
                );
              },
              child: Icon(
                Icons.add,
                size: 15.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
        SpaceH4(),
        StreamBuilder<List<Experience>>(
            stream: database.myExperiencesStream(user?.userId ?? ''),
            builder: (context, snapshot) {
              if (snapshot.hasData &&
                  snapshot.connectionState == ConnectionState.active) {
                myExperiences = snapshot.data!
                    .where((experience) => experience.type != 'Formativa')
                    .toList();
                myCustomExperiences = myExperiences!.map((element) => element).toList();
                mySelectedExperiences = List.generate(myCustomExperiences.length, (i) => i);
                return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
                    color: Constants.lightLilac,
                  ),
                  child: myExperiences!.isNotEmpty
                      ? Wrap(
                          children: myExperiences!
                              .map((e) => Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SpaceH12(),
                                      Container(
                                        width: double.infinity,
                                        child: ExperienceTile(experience: e),
                                      ),
                                      Divider(),
                                    ],
                                  ))
                              .toList(),
                        )
                      : CustomTextBody(text: StringConst.NO_EXPERIENCE),
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }),
      ],
    );
  }

  Widget _buildMyDataOfInterest(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    final myDataOfInterest = user?.dataOfInterest ?? [];

    return Column(
      children: [
        Row(
          children: [
            CustomTextTitle(title: StringConst.DATA_OF_INTEREST.toUpperCase()),
            SpaceW12(),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Constants.salmonMain,
                shape: CircleBorder(),
              ),
              child: Icon(
                Icons.add,
                size: 15.0,
                color: Colors.white,
              ),
              onPressed: () {
                _showDataOfInterestDialog(context, '');
              },
            ),
          ],
        ),
        SpaceH4(),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            color: Colors.transparent,
          ),
          child: myDataOfInterest.isNotEmpty
              ? Wrap(
                  children: myDataOfInterest
                      .map((d) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SpaceH12(),
                              Container(
                                height: 40.0,
                                child: Row(
                                  children: [
                                    Expanded(child: CustomTextBody(text: d)),
                                    SpaceW12(),
                                    EditButton(
                                      onTap: () =>
                                          _showDataOfInterestDialog(context, d),
                                    ),
                                    SpaceW12(),
                                    DeleteButton(
                                      onTap: () {
                                        user!.dataOfInterest.remove(d);
                                        database.setUserEnreda(user!);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              Divider(),
                            ],
                          ))
                      .toList(),
                )
              : CustomTextBody(text: StringConst.NO_DATA_OF_INTEREST),
        ),
      ],
    );
  }

  Widget _buildMyLanguages(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    final myLanguages = user?.languages ?? [];

    return Column(
      children: [
        Row(
          children: [
            CustomTextTitle(title: StringConst.LANGUAGES.toUpperCase()),
            SpaceW12(),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Constants.salmonMain,
                shape: CircleBorder(),
              ),
              child: Icon(
                Icons.add,
                size: 15.0,
                color: Colors.white,
              ),
              onPressed: () {
                _showLanguagesDialog(context, '');
              },
            ),
          ],
        ),
        SpaceH4(),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            color: Colors.transparent,
          ),
          child: myLanguages.isNotEmpty
              ? Wrap(
                  children: myLanguages
                      .map((d) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SpaceH12(),
                              Container(
                                height: 40.0,
                                child: Row(
                                  children: [
                                    Expanded(child: CustomTextBody(text: d)),
                                    SpaceW12(),
                                    EditButton(
                                      onTap: () =>
                                          _showLanguagesDialog(context, d),
                                    ),
                                    SpaceW12(),
                                    DeleteButton(
                                      onTap: () {
                                        user!.languages.remove(d);
                                        database.setUserEnreda(user!);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              Divider(),
                            ],
                          ))
                      .toList(),
                )
              : Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Center(child: Text(StringConst.NO_LANGUAGES)),
                ),
        ),
      ],
    );
  }

  void _showDataOfInterestDialog(BuildContext context, String currentText) {
    final database = Provider.of<Database>(context, listen: false);
    final controller = TextEditingController();
    if (currentText.isNotEmpty) {
      controller.text = currentText;
    }
    showCustomDialog(context,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              StringConst.NEW_DATA_OF_INTEREST,
            ),
            SpaceH12(),
            TextField(
              controller: controller,
            )
          ],
        ),
        defaultActionText: StringConst.FORM_ACCEPT,
        onDefaultActionPressed: (context) {
      if (currentText.isNotEmpty) {
        user!.dataOfInterest.remove(currentText);
      }
      user!.dataOfInterest.add(controller.text);
      database.setUserEnreda(user!);
      Navigator.of(context).pop();
    });
  }

  void _showLanguagesDialog(BuildContext context, String currentText) {
    final database = Provider.of<Database>(context, listen: false);
    final controller = TextEditingController();
    if (currentText.isNotEmpty) {
      controller.text = currentText;
    }
    showCustomDialog(context,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              StringConst.NEW_LANGUAGE,
            ),
            SpaceH12(),
            TextField(
              controller: controller,
            )
          ],
        ),
        defaultActionText: StringConst.FORM_ACCEPT,
        onDefaultActionPressed: (context) {
      if (currentText.isNotEmpty) {
        user!.languages.remove(currentText);
      }
      user!.languages.add(controller.text);
      database.setUserEnreda(user!);
      Navigator.of(context).pop();
    });
  }

  Future<bool> _hasEnoughExperiences(BuildContext context) async {
    if (myCompetencies!.length < 3 || myExperiences!.length < 2) {
      showCustomDialog(context,
          content: CustomTextBody(text: StringConst.ADD_MORE_EXPERIENCES),
          defaultActionText: StringConst.OK,
          onDefaultActionPressed: (context) => Navigator.of(context).pop(true));
      return false;
    } else {
      return true;
    }
  }
}
