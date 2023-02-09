import 'package:cached_network_image/cached_network_image.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:enreda_app/app/home/competencies/competency_tile.dart';
import 'package:enreda_app/app/home/curriculum/experience_form.dart';
import 'package:enreda_app/app/home/curriculum/experience_tile.dart';
import 'package:enreda_app/app/home/models/competency.dart';
import 'package:enreda_app/app/home/models/experience.dart';
import 'package:enreda_app/app/home/models/province.dart';
import 'package:enreda_app/app/home/models/userEnreda.dart';
import 'package:enreda_app/common_widgets/custom_chip.dart';
import 'package:enreda_app/common_widgets/delete_button.dart';
import 'package:enreda_app/common_widgets/precached_avatar.dart';
import 'package:enreda_app/common_widgets/show_custom_dialog.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/utils/my_scroll_behaviour.dart';
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
import '../../../values/values.dart';
import '../models/city.dart';
import '../models/country.dart';

class MyCurriculumPageWeb extends StatefulWidget {
  @override
  State<MyCurriculumPageWeb> createState() => _MyCurriculumPageWebState();
}

class _MyCurriculumPageWebState extends State<MyCurriculumPageWeb> {
  UserEnreda? user;
  String? myLocation;
  List<Competency> myCompetencies = [];
  List<Experience> myExperiences = [];
  List<Experience> myEducation = [];

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    final database = Provider.of<Database>(context, listen: false);
    return StreamBuilder<List<UserEnreda>>(
        stream: database.userStream(auth.currentUser?.email ?? ''),
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.active) {
            user = snapshot.data!.isNotEmpty ? snapshot.data!.first : null;
            var profilePic = user?.profilePic?.src ?? "";
            if (profilePic == "") {
              profilePic = ImagePath.USER_DEFAULT;
            }
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
                      width: 290.0,
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
                                      Stack(
                                        children: <Widget>[
                                          const Center(child: CircularProgressIndicator()),
                                          Center(
                                            child: CachedNetworkImage(
                                                width: 120,
                                                height: 120,
                                                fit: BoxFit.cover,
                                                alignment: Alignment.center,
                                                imageUrl: profilePic),
                                          ),
                                        ],
                                      ),
                                    ):
                                        PrecacheAvatarCard(
                                          imageUrl: profilePic,
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
                        _buildCVHeader(context),
                        SpaceH40(),
                        _buildMyEducation(context, user),
                        SpaceH40(),
                        _buildMyExperiences(context, user),
                        SpaceH40(),
                        _buildMyCompetencies(context),
                      ],
                    ),
                  ))
                ],
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }

  Widget _buildMyCompetencies(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    final controller = ScrollController();
    final textTheme = Theme.of(context).textTheme;
    var scrollJump = 137.5;
    final auth = Provider.of<AuthBase>(context, listen: false);
    return StreamBuilder<List<Competency>>(
        stream: database.competenciesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.active) {
            final competenciesIds = user!.competencies.keys.toList();
            myCompetencies = snapshot.data!
                .where((competency) => competenciesIds.any((id) =>
                    competency.id == id &&
                    (user!.competencies[id] == StringConst.BADGE_VALIDATED ||
                        user!.competencies[id] == StringConst.BADGE_CERTIFIED)))
                .toList();
            return Container(
                decoration: BoxDecoration(
                  color: Constants.white,
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: InkWell(
                                  onTap: () {
                                    if (controller.position.pixels >=
                                        controller.position.minScrollExtent)
                                      controller.animateTo(
                                          controller.position.pixels -
                                              scrollJump,
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
                                  height: 200.0,
                                  child: ScrollConfiguration(
                                    behavior: MyCustomScrollBehavior(),
                                    child: ListView(
                                      controller: controller,
                                      scrollDirection: Axis.horizontal,
                                      children:
                                          myCompetencies.map((competency) {
                                        final status =
                                            user?.competencies[competency.id] ??
                                                StringConst.BADGE_EMPTY;
                                        return Column(
                                          children: [
                                            CompetencyTile(
                                              competency: competency,
                                              status: status,
                                              mini: true,
                                            ),
                                            Text(
                                                status ==
                                                        StringConst
                                                            .BADGE_VALIDATED
                                                    ? 'EVALUADA'
                                                    : 'CERTIFICADA',
                                                style: textTheme.bodyText1
                                                    ?.copyWith(
                                                        fontSize: 12.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Constants
                                                            .turquoise)),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: InkWell(
                                  onTap: () {
                                    if (controller.position.pixels <=
                                        controller.position.maxScrollExtent)
                                      controller.animateTo(
                                          controller.position.pixels +
                                              scrollJump,
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
                ));
          } else {
            return Center(child: CircularProgressIndicator());
          }
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
    final textTheme = Theme.of(context).textTheme;
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
                      return Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.black.withOpacity(0.7),
                            size: 16,
                          ),
                          SpaceW4(),
                          Expanded(
                            child: Text(
                              myLocation ?? '',
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodyText1?.copyWith(
                                  fontSize:
                                      Responsive.isDesktop(context) ? 14 : 11.0,
                                  color: Constants.darkGray,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ),
                        ],
                      );
                    });
              });
        });
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
                child: Text(
                  StringConst.ABOUT_ME.toUpperCase(),
                  style: textTheme.bodyText1?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: Responsive.isDesktop(context) ? 18 : 14.0,
                    color: Constants.darkLilac,
                  ),
                ),
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
                  size: Responsive.isDesktop(context) ? 18 : 14.0,
                  color: Constants.darkGray,
                ),
              ),
            ],
          ),
          SpaceH20(),
          if (!isEditable)
            Text(
              user?.aboutMe != null && user!.aboutMe!.isNotEmpty
                  ? user!.aboutMe!
                  : 'Aún no has añadido información adicional sobre ti',
              style: textTheme.bodyText1?.copyWith(
                  fontSize: Responsive.isDesktop(context) ? 14 : 11.0,
                  color: Constants.darkGray),
            ),
          if (isEditable)
            TextField(
              controller: textController,
              focusNode: focusNode,
              minLines: 1,
              maxLines: null,
              style: textTheme.bodyText1?.copyWith(
                  fontSize: Responsive.isDesktop(context) ? 14 : 11.0,
                  color: Constants.darkGray),
            )
        ],
      );
    });
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
            InkWell(
              onTap: () async {
                if (await _hasEnoughExperiences(context)) _createPDF(context);
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
          style: textTheme.bodyText1?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: Responsive.isDesktop(context) ? 45.0 : 32.0,
              color: Constants.penBlue),
        ),
        SpaceH20(),
        Text(
          user?.education?.toUpperCase() ?? '',
          style: textTheme.bodyText1?.copyWith(
              fontSize: Responsive.isDesktop(context) ? 16 : 12.0,
              color: Constants.darkGray),
        ),
      ],
    );
  }

  Widget _buildMyExperiences(BuildContext context, UserEnreda? user) {
    final database = Provider.of<Database>(context, listen: false);
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Row(
          children: [
            Text(
              StringConst.MY_EXPERIENCES.toUpperCase(),
              style: textTheme.bodyText1?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: Responsive.isDesktop(context) ? 18 : 14.0,
                color: Constants.darkLilac,
              ),
            ),
            SpaceW12(),
            TextButton(
              style: TextButton.styleFrom(
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
                size: Responsive.isDesktop(context) ? 18 : 14.0,
                color: Constants.darkGray,
              ),
            ),
          ],
        ),
        SpaceH20(),
        StreamBuilder<List<Experience>>(
            stream: database.myExperiencesStream(user?.userId ?? ''),
            builder: (context, snapshot) {
              if (snapshot.hasData &&
                  snapshot.connectionState == ConnectionState.active) {
                myExperiences = snapshot.data!
                    .where((experience) => experience.type != 'Formativa')
                    .toList();
                return myExperiences.isNotEmpty
                    ? Column(
                        children: myExperiences
                            .map((e) => Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      child: ExperienceTile(experience: e),
                                    ),
                                    SpaceH20(),
                                  ],
                                ))
                            .toList(),
                      )
                    : Text(
                        'Todavía no has añadido ninguna experiencia, ¡chatea con nuestro asistente para añadir una!',
                        style: textTheme.bodyText1,
                      );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }),
      ],
    );
  }

  Widget _buildMyEducation(BuildContext context, UserEnreda? user) {
    final database = Provider.of<Database>(context, listen: false);
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Row(
          children: [
            Text(
              StringConst.EDUCATION.toUpperCase(),
              style: textTheme.bodyText1?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: Responsive.isDesktop(context) ? 18 : 14.0,
                color: Constants.darkLilac,
              ),
            ),
            SpaceW12(),
            TextButton(
              style: TextButton.styleFrom(
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
                size: Responsive.isDesktop(context) ? 18 : 14.0,
                color: Constants.darkGray,
              ),
            ),
          ],
        ),
        SpaceH8(),
        StreamBuilder<List<Experience>>(
            stream: database.myExperiencesStream(user?.userId ?? ''),
            builder: (context, snapshot) {
              if (snapshot.hasData &&
                  snapshot.connectionState == ConnectionState.active) {
                myEducation = snapshot.data!
                    .where((experience) => experience.type == 'Formativa')
                    .toList();
                return myEducation.isNotEmpty
                    ? Column(
                        children: myEducation
                            .map((e) => Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      child: ExperienceTile(experience: e),
                                    ),
                                    SpaceH20(),
                                  ],
                                ))
                            .toList(),
                      )
                    : Text(
                        'Todavía no has añadido ninguna formación, ¡chatea con nuestro asistente para añadir una!',
                        style: textTheme.bodyText1,
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
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                StringConst.DATA_OF_INTEREST.toUpperCase(),
                style: textTheme.bodyText1?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: Responsive.isDesktop(context) ? 18 : 14.0,
                  color: Constants.darkLilac,
                ),
              ),
            ),
            InkWell(
              onTap: () => _showDataOfInterestDialog(context, ''),
              child: Icon(
                Icons.add,
                size: Responsive.isDesktop(context) ? 18 : 14.0,
                color: Constants.darkGray,
              ),
            ),
          ],
        ),
        SpaceH20(),
        myDataOfInterest.isNotEmpty
            ? ChipsChoice<String>.single(
                wrapped: true,
                alignment: WrapAlignment.start,
                padding: EdgeInsets.only(left: 0.0, right: 0.0),
                value: '',
                onChanged: (choice) {
                  showCustomDialog(context,
                      content: Text(
                        '¿Quieres eliminar este dato de interés?',
                        style: textTheme.bodyText1,
                      ),
                      defaultActionText: 'Eliminar',
                      cancelActionText: 'Cancelar',
                      onDefaultActionPressed: (dialogContext) {
                    user!.dataOfInterest.remove(choice);
                    database.setUserEnreda(user!);
                    Navigator.of(dialogContext).pop();
                  });
                },
                choiceItems: C2Choice.listFrom<String, String>(
                  source: myDataOfInterest,
                  value: (i, v) => v,
                  label: (i, v) => v,
                ),
                choiceBuilder: (item, i) => CustomChip(
                  label: item.label,
                  selected: item.selected,
                  onSelect: item.select!,
                ),
                runSpacing: kIsWeb ? 4 : 0,
              )
            : Center(
                child: Text(
                StringConst.NO_DATA_OF_INTEREST,
                style: textTheme.bodyText1,
              )),
      ],
    );
  }

  Widget _buildMyLanguages(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    final myLanguages = user?.languages ?? [];
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                StringConst.LANGUAGES.toUpperCase(),
                style: textTheme.bodyText1?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: Responsive.isDesktop(context) ? 18 : 14.0,
                  color: Constants.darkLilac,
                ),
              ),
            ),
            InkWell(
              onTap: () => _showLanguagesDialog(context, ''),
              child: Icon(
                Icons.add,
                size: Responsive.isDesktop(context) ? 18 : 14.0,
                color: Constants.darkGray,
              ),
            ),
          ],
        ),
        SpaceH20(),
        myLanguages.isNotEmpty
            ? ListView(
                shrinkWrap: true,
                children: myLanguages
                    .map((choice) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    choice,
                                    style: textTheme.bodyText1,
                                  ),
                                ),
                                DeleteButton(
                                    onTap: () => showCustomDialog(context,
                                            content: Text(
                                              '¿Quieres eliminar $choice de tus idiomas?',
                                              style: textTheme.bodyText1,
                                            ),
                                            defaultActionText: 'Eliminar',
                                            cancelActionText: 'Cancelar',
                                            onDefaultActionPressed:
                                                (dialogContext) {
                                          user!.languages.remove(choice);
                                          database.setUserEnreda(user!);
                                          Navigator.of(dialogContext).pop();
                                        }))
                              ],
                            ),
                            SpaceH8(),
                          ],
                        ))
                    .toList(),
              )
            : Center(
                child: Text(
                StringConst.NO_DATA_OF_INTEREST,
                style: textTheme.bodyText1,
              )),
      ],
    );
  }

  void _showDataOfInterestDialog(BuildContext context, String currentText) {
    final database = Provider.of<Database>(context, listen: false);
    final controller = TextEditingController();
    final textTheme = Theme.of(context).textTheme;

    if (currentText.isNotEmpty) {
      controller.text = currentText;
    }
    showCustomDialog(context,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              StringConst.NEW_DATA_OF_INTEREST,
              style: textTheme.bodyText1,
            ),
            SpaceH12(),
            TextField(
              controller: controller,
              style: textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
            )
          ],
        ),
        defaultActionText: StringConst.FORM_ACCEPT,
        onDefaultActionPressed: (context) {
      if (currentText.isNotEmpty) {
        user!.dataOfInterest.remove(currentText);
      }
      if (controller.text.isNotEmpty) {
        user!.dataOfInterest.add(controller.text);
        database.setUserEnreda(user!);
      }
      Navigator.of(context).pop();
    });
  }

  void _showLanguagesDialog(BuildContext context, String currentText) {
    final database = Provider.of<Database>(context, listen: false);
    final controller = TextEditingController();
    final textTheme = Theme.of(context).textTheme;

    if (currentText.isNotEmpty) {
      controller.text = currentText;
    }
    showCustomDialog(context,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              StringConst.NEW_LANGUAGE,
              style: textTheme.bodyText1,
            ),
            SpaceH12(),
            TextField(
              controller: controller,
              style: textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
            )
          ],
        ),
        defaultActionText: StringConst.FORM_ACCEPT,
        onDefaultActionPressed: (context) {
      if (currentText.isNotEmpty) {
        user!.languages.remove(currentText);
      }
      if (controller.text.isNotEmpty) {
        user!.languages.add(controller.text);
        database.setUserEnreda(user!);
      }
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
    if (url == "") {
      url = ImagePath.USER_DEFAULT;
    }

    var response = await get(Uri.parse(url));
    PdfBitmap imageProfile = PdfBitmap(response.bodyBytes);
    PdfBitmap image = PdfBitmap(response.bodyBytes);
    page.graphics.drawImage(imageProfile, Rect.fromLTWH(0, y, 100, 100));
    y += 120;

    page.graphics.drawString(
        '${user?.firstName} ${user?.lastName}',
        PdfStandardFont(
          PdfFontFamily.helvetica,
          fontSize * 2.5,
          style: PdfFontStyle.bold,
        ),
        brush: PdfBrushes.darkBlue,
        bounds: Rect.fromLTWH(0, y, 0, 0));
    y += mainSpacing * 3;

    page.graphics.drawString(
      '${user?.education}',
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
            PdfStandardFont(PdfFontFamily.helvetica, fontSize,
                style: PdfFontStyle.italic),
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
          PdfStandardFont(PdfFontFamily.helvetica, fontSize,
              style: PdfFontStyle.italic),
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
    competencies = competencies
        .where((competency) => competenciesIds.any((id) => competency.id == id))
        .toList();
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
      page.graphics.drawImage(image, Rect.fromLTWH(0 + leftMargin, y, 60, 60));
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
      user?.aboutMe != null && user!.aboutMe!.isNotEmpty ? user!.aboutMe! : '',
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
          brush: PdfBrushes.slateGray, bounds: Rect.fromLTWH(0, y, 0, 0));
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
          brush: PdfBrushes.slateGray, bounds: Rect.fromLTWH(0, y, 0, 0));
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
