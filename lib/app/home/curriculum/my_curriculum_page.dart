import 'package:cached_network_image/cached_network_image.dart';
import 'package:enreda_app/app/home/competencies/competency_tile.dart';
import 'package:enreda_app/app/home/curriculum/experience_form.dart';
import 'package:enreda_app/app/home/curriculum/experience_tile.dart';
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
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import 'package:enreda_app/utils/save_pdf_mobile.dart'
    if (dart.library.html) 'package:enreda_app/utils/save_pdf_web.dart';

import '../../../common_widgets/custom_text.dart';
import '../../../utils/my_scroll_behaviour.dart';
import '../../../values/values.dart';

class MyCurriculumPage extends StatelessWidget {
  UserEnreda? user;
  String? myLocation;
  String? city;
  String? province;
  String? country;
  List<Competency> myCompetencies = [];
  List<Experience> myExperiences = [];
  List<Experience> myEducation = [];

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    final database = Provider.of<Database>(context, listen: false);
    final textTheme = Theme.of(context).textTheme;
    return Stack(
      children: [
        StreamBuilder<List<UserEnreda>>(
            stream: database.userStream(auth.currentUser?.email ?? ''),
            builder: (context, snapshot) {
              if (snapshot.hasData &&
                  snapshot.connectionState == ConnectionState.active) {
                user = snapshot.data!.isNotEmpty ? snapshot.data!.first : null;
                var profilePic = user?.profilePic?.src ?? "";
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
                                  // onTap: () async {
                                  //   if (await _hasEnoughExperiences(context)) _createPDF(context);
                                  // },
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => MyCv(user: user!, city: city!, province: province!, country: country!, myExperiences: myExperiences, myEducation: myEducation,)),
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
                                  Stack(
                                    children: <Widget>[
                                      const Center(child: CircularProgressIndicator()),
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
                                    ],
                                  ),
                                ):
                                ClipRRect(
                                  borderRadius: BorderRadius.all(Radius.circular(60)),
                                  child:
                                  Stack(
                                    children: <Widget>[
                                      const Center(child: CircularProgressIndicator()),
                                      Center(
                                        child:
                                        FadeInImage.assetNetwork(
                                          placeholder: ImagePath.USER_DEFAULT,
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                          image: profilePic,
                                        ),
                                      ),
                                    ],
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
                          SpaceH2(),
                          _buildMyLocation(context, user),
                          SpaceH24(),
                          _buildMyEducation(context, user),
                          SpaceH24(),
                          _buildMyExperiences(context, user),
                          SpaceH24(),
                          _buildMyCompetencies(context, user),
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
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }),
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
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.black.withOpacity(0.7),
                            size: 16,
                          ),
                          SpaceW4(),
                          CustomTextSmall(text: myLocation ?? ''),
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
                myCompetencies.isNotEmpty
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
                        height: 160.0,
                        //padding: const EdgeInsets.all(10.0),
                        color: Colors.white,
                        child: ScrollConfiguration(
                          behavior: MyCustomScrollBehavior(),
                          child: ListView(
                            controller: controller,
                            scrollDirection: Axis.horizontal,
                            children: myCompetencies.map((competency) {
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
                return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
                    color: Constants.lightLilac,
                  ),
                  child: myEducation.isNotEmpty
                      ? Wrap(
                          children: myEducation
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
                return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
                    color: Constants.lightLilac,
                  ),
                  child: myExperiences.isNotEmpty
                      ? Wrap(
                          children: myExperiences
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
            color: Constants.lightLilac,
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
            color: Constants.lightLilac,
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

  Future<void> _createPDF(BuildContext context) async {
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (_) {
          return AlertDialog(
            content: SizedBox(
              width: 400.0,
              child: Padding(
                padding: EdgeInsets.all(Constants.mainPadding * 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                        child: Text(
                          'Espere unos segundos mientras se genera el PDF...',
                        )),
                    SpaceH48(),
                    Center(
                      child: CircularProgressIndicator(),
                    ),
                  ],
                ),
              ),
            ),
          );
     });

    final database = Provider.of<Database>(context, listen: false);
    double y = 0.0;
    double x = 0.0;
    double mainSpacing = 16.0;
    double fontSize = 11.0;

    PdfDocument document = PdfDocument();
    PdfPage page = document.pages.add();

    var url = user?.profilePic?.src ?? "";
    if (url == "" ) {
      url = ImagePath.USER_DEFAULT;
    }

    var response = await get(Uri.parse(url));
    PdfBitmap imageProfile = PdfBitmap(response.bodyBytes);
    PdfBitmap image = PdfBitmap(response.bodyBytes);
    page.graphics.drawImage(imageProfile, Rect.fromLTWH(0, y, 100, 100));
    y += 120;

    page.graphics.drawString(
        '${user?.firstName} ${user?.lastName}',
        PdfStandardFont(PdfFontFamily.helvetica, fontSize * 2.5,
          style: PdfFontStyle.bold,
        ),
        brush: PdfBrushes.darkBlue,
        bounds: Rect.fromLTWH(0, y, 0, 0));
    y += mainSpacing * 3;

    page.graphics.drawString('${user?.education}',
      PdfStandardFont(PdfFontFamily.helvetica, fontSize),
      brush: PdfBrushes.slateGray,
      bounds: Rect.fromLTWH(0, y, 0, 0),
    );
    y += mainSpacing;

    page.graphics.drawString(
      '${user?.email}',
      PdfStandardFont(PdfFontFamily.helvetica, fontSize),
      bounds: Rect.fromLTWH(0, y, 0, 0),
      brush: PdfBrushes.slateGray,
    );
    y += mainSpacing;

    page.graphics.drawString(
      user?.phone ?? '',
      PdfStandardFont(PdfFontFamily.helvetica, fontSize),
      bounds: Rect.fromLTWH(0, y, 0, 0),
      brush: PdfBrushes.slateGray,
    );
    y += mainSpacing;

    page.graphics.drawString(
      '$myLocation',
      PdfStandardFont(PdfFontFamily.helvetica, fontSize),
      bounds: Rect.fromLTWH(0, y, 0, 0),
      brush: PdfBrushes.slateGray,
    );
    y += mainSpacing * 2;


    page.graphics.drawString(
      StringConst.EDUCATION.toUpperCase(),
      PdfStandardFont(PdfFontFamily.helvetica, fontSize * 1.2),
      brush: PdfBrushes.darkSlateBlue,
      bounds: Rect.fromLTWH(0, y, 0, 0),
    );
    y += mainSpacing * 1.5;

    myEducation.forEach((education) {
      final DateFormat formatter = DateFormat('yyyy-MM-dd');
      String startDate = formatter.format(education.startDate.toDate());
      String endDate = education.endDate != null
          ? formatter.format(education.endDate!.toDate())
          : 'Actualmente';
      String activityText = education.activityRole == null
          ? education.activity!
          : '${education.activityRole!} - ${education.activity!}';

      if (y + 100 >= page.getClientSize().height) {
        page = document.pages.add();
        y = 0;
      }
      if (education.activity != null) {
        page.graphics.drawString(
            '$activityText, ${education.location}, $startDate - $endDate',
            PdfStandardFont(PdfFontFamily.helvetica, fontSize, style: PdfFontStyle.italic),
            brush: PdfBrushes.slateGray,
            bounds: Rect.fromLTWH(0, y, 0, 0));
        y += mainSpacing;
      }

    });
    y += mainSpacing;

    page.graphics.drawString(
      StringConst.EXPERIENCES.toUpperCase(),
      PdfStandardFont(PdfFontFamily.helvetica, fontSize * 1.2),
      brush: PdfBrushes.darkSlateBlue,
      bounds: Rect.fromLTWH(0, y, 0, 0),
    );
    y += mainSpacing * 1.5;
    myExperiences.forEach((experience) {
      final DateFormat formatter = DateFormat('yyyy-MM-dd');
      String endDate = experience.endDate != null
          ? formatter.format(experience.endDate!.toDate())
          : 'Actualmente';
      if (y + 100 >= page.getClientSize().height) {
        page = document.pages.add();
        y = 0;
      }
      if (experience.activity != null) {
        String activityText = experience.activityRole == null
            ? experience.activity!
            : '${experience.activityRole!} - ${experience.activity!}';

        page.graphics.drawString(
          '$activityText, ${experience.location}, ${formatter.format(experience.startDate.toDate())} - $endDate',
          PdfStandardFont(PdfFontFamily.helvetica, fontSize, style: PdfFontStyle.italic),
          brush: PdfBrushes.slateGray,
          bounds: Rect.fromLTWH(0, y, page.getClientSize().width, 0),
          //bounds: Rect.fromLTWH(0, y, 0, 0),
        );
        y += mainSpacing * 1.5;
      }

    });
    y += mainSpacing * 1.5;


    page.graphics.drawString(
      StringConst.COMPETENCIES.toUpperCase(),
      PdfStandardFont(PdfFontFamily.helvetica, fontSize * 1.2),
      brush: PdfBrushes.darkSlateBlue,
      bounds: Rect.fromLTWH(0, y, 0, 0),
    );
    y += mainSpacing;

    List<Competency> competencies = await database.competenciesStream().first;
    final competenciesIds = user!.competencies.keys.toList();
    competencies = competencies.where((competency) => competenciesIds.any((id) => competency.id == id )).toList();
    List<String> competenciesImages = [];
    competencies.forEach((competency) {
      final status =
          user?.competencies[competency.id] ?? StringConst.BADGE_EMPTY;
      if (competency.badgesImages[status] != null &&
          status != StringConst.BADGE_EMPTY &&
          status != StringConst.BADGE_IDENTIFIED) {
        competenciesImages.add(competency.badgesImages[status]!);
      }
    });
    var leftMargin = 0.0;
    for (int i = 0; i < competenciesImages.length; i++) {
      url = competenciesImages[i];
      response = await get(Uri.parse(url));
      image = PdfBitmap(response.bodyBytes);
      page.graphics
          .drawImage(image, Rect.fromLTWH(0 + leftMargin, y, 60, 60));
      leftMargin += 60;
    }
    y += 80;

    if (user?.aboutMe != null && user!.aboutMe!.isNotEmpty) {
      page.graphics.drawString(
        StringConst.ABOUT_ME.toUpperCase(),
        PdfStandardFont(PdfFontFamily.helvetica, fontSize * 1.2),
        brush: PdfBrushes.darkSlateBlue,
        bounds: Rect.fromLTWH(0, y, 0, 0),
      );
      y += mainSpacing * 1.5;
    }

    if (y + 100 >= page.getClientSize().height) {
      page = document.pages.add();
      y = 0;
    }
    page.graphics.drawString(
      user?.aboutMe != null && user!.aboutMe!.isNotEmpty
          ? user!.aboutMe!
          : '',
      PdfStandardFont(PdfFontFamily.helvetica, fontSize),
      bounds: Rect.fromLTWH(0, y, page.getClientSize().width, 0),
      brush: PdfBrushes.slateGray,
    );
    y += mainSpacing * 3.5;

    page.graphics.drawString(
      StringConst.DATA_OF_INTEREST.toUpperCase(),
      PdfStandardFont(PdfFontFamily.helvetica, fontSize * 1.2),
      brush: PdfBrushes.darkSlateBlue,
      bounds: Rect.fromLTWH(0, y, 0, 0),
    );
    y += mainSpacing * 1.5;

    final dataOfInterest = user?.dataOfInterest ?? [];
    dataOfInterest.forEach((data) {
      if (y + 100 >= page.getClientSize().height) {
        page = document.pages.add();
        y = 0;
      }
      page.graphics.drawString(
          data, PdfStandardFont(PdfFontFamily.helvetica, fontSize),
          brush: PdfBrushes.slateGray,
          bounds: Rect.fromLTWH(0, y, 0, 0));
      y += mainSpacing;
    });
    y += mainSpacing;

    page.graphics.drawString(
      StringConst.LANGUAGES.toUpperCase(),
      PdfStandardFont(PdfFontFamily.helvetica, fontSize * 1.2),
      brush: PdfBrushes.darkSlateBlue,
      bounds: Rect.fromLTWH(0, y, 0, 0),
    );
    y += mainSpacing * 1.5;
    final languages = user?.languages ?? [];
    languages.forEach((language) {
      if (y + 100 >= page.getClientSize().height) {
        page = document.pages.add();
        y = 0;
      }
      page.graphics.drawString(
          language, PdfStandardFont(PdfFontFamily.helvetica, fontSize),
          brush: PdfBrushes.slateGray,
          bounds: Rect.fromLTWH(0, y, 0, 0));
      y += mainSpacing;
    });
    y += mainSpacing * 1.5;

    List<int> bytes = await document.save();
    document.dispose();

    savePDF(bytes, 'myCV.pdf');
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future<bool> _hasEnoughExperiences(BuildContext context) async {
    if (myCompetencies.length < 3 || myExperiences.length < 2) {
      showCustomDialog(context,
          content: Text(StringConst.ADD_MORE_EXPERIENCES),
          defaultActionText: StringConst.OK,
          onDefaultActionPressed: (context) => Navigator.of(context).pop(true));
      return false;
    } else {
      return true;
    }
  }
}
