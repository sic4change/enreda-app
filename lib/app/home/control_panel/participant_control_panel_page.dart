import 'package:enreda_app/app/home/competencies/competency_tile.dart';
import 'package:enreda_app/app/home/control_panel/gamification-item.dart';
import 'package:enreda_app/app/home/control_panel/gamification-slider.dart';
import 'package:enreda_app/app/home/curriculum/my_curriculum_page.dart';
import 'package:enreda_app/app/home/models/ability.dart';
import 'package:enreda_app/app/home/models/competency.dart';
import 'package:enreda_app/app/home/models/education.dart';
import 'package:enreda_app/app/home/models/interest.dart';
import 'package:enreda_app/app/home/models/resource.dart';
import 'package:enreda_app/app/home/models/specificinterest.dart';
import 'package:enreda_app/app/home/models/userEnreda.dart';
import 'package:enreda_app/common_widgets/custom_text.dart';
import 'package:enreda_app/common_widgets/rounded_container.dart';
import 'package:enreda_app/common_widgets/show_custom_dialog.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/adaptive.dart';
import 'package:enreda_app/utils/my_scroll_behaviour.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ParticipantControlPanelPage extends StatelessWidget {
  const ParticipantControlPanelPage({required this.participantUser, super.key});

  final UserEnreda participantUser;

  @override
  Widget build(BuildContext context) {
    return Responsive.isDesktop(context)? _buildBodyDesktop(context):
    _buildBodyMobile(context);
  }

  Widget _buildBodyDesktop(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGamificationSection(context),
          SpaceH50(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildContactSection(context),
                    SpaceH20(),
                    _buildCompetenciesSection(context),
                    SpaceH40(),
                    //_buildResourcesSection(context),
                  ],
                ),
              ),
              SpaceW20(),
              Column(
                children: [
                  _buildCvSection(context),
                  SpaceH40(),
                  //_buildDocumetationSection(context),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBodyMobile(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGamificationSection(context),
          SpaceH20(),
          _buildContactSection(context),
          SpaceH20(),
          _buildCompetenciesSection(context),
          SpaceH20(),
          //_buildResourcesSection(context),
          SpaceH20(),
          _buildCvSection(context),
          SpaceH20(),
          //_buildDocumetationSection(context),
        ],
      ),
    );
  }

  Widget _buildGamificationSection(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    final totalGamificationPills = 5;
    final cvTotalSteps = 7;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (Responsive.isDesktop(context))
              Container(
                height: 250,
                  child: Image.asset(ImagePath.GAMIFICATION_LOGO, height: 250.0,)),
            if (Responsive.isDesktop(context))
              SpaceW8(),
            Expanded(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextBoldTitle(title: StringConst.GAMIFICATION),
                    GamificationSlider(
                      height: Responsive.isDesktop(context)? 20.0 : 10.0,
                      value: participantUser.gamificationFlags.length,
                    ),
                    SpaceH20(),
                    Row(
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: Responsive.isDesktop(context)? 5.0 : 4.0,
                            runSpacing: Responsive.isDesktop(context)? 5.0 : 4.0,
                            alignment: WrapAlignment.spaceEvenly,
                            children: [
                              GamificationItem(
                                imagePath: ImagePath.GAMIFICATION_CHAT_ICON,
                                progress: (participantUser.gamificationFlags[UserEnreda.FLAG_CHAT]?? false)? 100 : 0,
                                title: (participantUser.gamificationFlags[UserEnreda.FLAG_CHAT]?? false)? "CHAT INICIADO": "CHAT NO INICIADO",
                              ),
                              GamificationItem(
                                imagePath: ImagePath.GAMIFICATION_PILL_ICON,
                                progress: (_getUserPillsConsumed()/totalGamificationPills) * 100,
                                progressText: "${_getUserPillsConsumed()}",
                                title: "PÍLDORAS CONSUMIDAS",
                              ),
                              StreamBuilder<List<Competency>>(
                                  stream: database.competenciesStream(),
                                  builder: (context, competenciesStream) {
                                    double competenciesProgress = 0;
                                    Map<String, String> certifiedCompetencies = {};
                                    if (competenciesStream.hasData) {
                                      certifiedCompetencies = Map.from(participantUser.competencies);
                                      certifiedCompetencies.removeWhere((key, value) => value != "certified");
                                      competenciesProgress = (certifiedCompetencies.length / competenciesStream.data!.length) * 100;
                                    }

                                    return GamificationItem(
                                      imagePath: ImagePath.GAMIFICATION_COMPETENCIES_ICON,
                                      progress: competenciesProgress,
                                      progressText: "${certifiedCompetencies.length}",
                                      title: "COMPETENCIAS CERTIFICADAS",
                                    );
                                  }),
                              GamificationItem(
                                imagePath: ImagePath.GAMIFICATION_RESOURCES_ICON,
                                progress: ((participantUser.resourcesAccessCount?? 0) / 15) * 100,
                                progressText: "${participantUser.resourcesAccessCount}",
                                title: "RECURSOS INSCRITOS",
                              ),
                              GamificationItem(
                                imagePath: ImagePath.GAMIFICATION_CV_ICON,
                                progress: (_getUserCvStepsCompleted()/cvTotalSteps) * 100,
                                progressText: "${(_getUserCvStepsCompleted() / cvTotalSteps * 100).toStringAsFixed(2)}%",
                                title: "CV COMPLETADO",
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ],);
  }

  Widget _buildContactSection(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    final textTheme = Theme.of(context).textTheme;
    double fontSize = responsiveSize(context, 15, 18, md: 16);

    return Container(
      height: 300,
      child:
      Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            margin: const EdgeInsets.only(top: 30.0, bottom: 30.0),
            decoration: BoxDecoration(
              color: AppColors.turquoiseBlue,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 30.0, top: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 300,
                    child: Text('Contacto Enreda',
                      style: textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: Responsive.isMobile(context) ? 25 : 35.0,
                          color: AppColors.white),),
                  ),
                  InkWell(
                      onTap: () {

                      },
                      child: CustomTextBold(title: 'Ver más', color: Colors.white,)),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            top: -20,
            right: 0,
            child: InkWell(
              onTap: () {
              },
              child: Container(
                  width: 500,
                  child: Image.asset(ImagePath.CONTACT_ICON, fit: BoxFit.fitHeight,)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompetenciesSection(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    final textTheme = Theme.of(context).textTheme;

    return RoundedContainer(
      margin: EdgeInsets.all(0.0),
      borderColor: AppColors.greyAlt.withOpacity(0.15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextBoldTitle(title: StringConst.COMPETENCIES),
          SpaceH20(),
          StreamBuilder<List<Competency>>(
              stream: database.competenciesStream(),
              builder: (context, snapshotCompetencies) {
                if (snapshotCompetencies.hasData) {
                  final controller = ScrollController();
                  var scrollJump = Responsive.isDesktopS(context) ? 350 : 410;
                  List<Competency> myCompetencies = snapshotCompetencies.data!;
                  final competenciesIds = participantUser.competencies.keys.toList();
                  myCompetencies = myCompetencies
                      .where((competency) => competenciesIds.any((id) => competency.id == id))
                      .toList();
                  return myCompetencies.isEmpty? Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Center(
                        child: Text(
                          StringConst.NO_COMPETENCIES,
                          style: textTheme.bodyMedium,
                        )),
                  ): Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: Responsive.isDesktop(context)? 270.0: 180.0,
                        child: ScrollConfiguration(
                          behavior: MyCustomScrollBehavior(),
                          child: ListView(
                            controller: controller,
                            scrollDirection: Axis.horizontal,
                            children: myCompetencies.map((competency) {
                              final status =
                                  participantUser.competencies[competency.id] ??
                                      StringConst.BADGE_EMPTY;
                              return Column(
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      CompetencyTile(
                                        competency: competency,
                                        status: status,
                                        //mini: true,
                                      ),
                                      Positioned(
                                        bottom: Responsive.isDesktop(context)?5.0: 0.0,
                                        child: Text(
                                            status ==
                                                StringConst
                                                    .BADGE_VALIDATED
                                                ? 'EVALUADA'
                                                : 'CERTIFICADA',
                                            style: textTheme.bodySmall
                                                ?.copyWith(
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.w500)),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              if (controller.position.pixels >=
                                  controller.position.minScrollExtent)
                                controller.animateTo(
                                    controller.position.pixels - scrollJump,
                                    duration: Duration(milliseconds: 500),
                                    curve: Curves.ease);
                            },
                            child: Image.asset(
                              ImagePath.ARROW_BACK,
                              width: 36.0,
                            ),
                          ),
                          SpaceW12(),
                          InkWell(
                            onTap: () {
                              if (controller.position.pixels <=
                                  controller.position.maxScrollExtent)
                                controller.animateTo(
                                    controller.position.pixels + scrollJump,
                                    duration: Duration(milliseconds: 500),
                                    curve: Curves.ease);
                            },
                            child: Image.asset(
                              ImagePath.ARROW_FORWARD,
                              width: 36.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              }),
        ],),
    );
  }

  Widget _buildCvSection(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextBoldTitle(title: StringConst.CV),
        SpaceH12(),
        RoundedContainer(
          margin: EdgeInsets.all(0.0),
          height: 450.0,
          width: 340.0,
          borderColor: AppColors.greyAlt.withOpacity(0.15),
          child: SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  StringConst.MY_CV,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: Responsive.isDesktop(context) ? 18 : 14.0,
                    color: AppColors.penBlue,
                  ),
                ),
                SpaceH12(),
                InkWell(
                  onTap: () => showCustomDialog(
                    context,
                    content: Container(
                        height: MediaQuery.sizeOf(context).height * 0.85,
                        width: Responsive.isDesktop(context)? MediaQuery.sizeOf(context).width * 0.6: MediaQuery.sizeOf(context).width * 0.9,
                        child: MyCurriculumPage()),
                  ),
                  child: Transform.scale(
                    scale: 0.3,
                    child: MyCurriculumPage(
                      mini: true,
                    ),
                    alignment: Alignment.topLeft,),
                ),
              ],
            ),
          ),)
      ],
    );
  }

  // Widget _buildDocumetationSection(BuildContext context) {
  //   final database = Provider.of<Database>(context, listen: false);
  //   double maxValue = 10;
  //   double value = 0;
  //   return StreamBuilder<List<PersonalDocumentType>>(
  //       stream: database.personalDocumentTypeStream(),
  //       builder: (context, snapshot) {
  //         if (snapshot.hasData) {
  //           maxValue = snapshot.data!.length.toDouble();
  //           value = participantUser.personalDocuments.where((userDocument) =>
  //           userDocument.document.isNotEmpty && snapshot.data!.any((document) => document.title == userDocument.name)
  //           ).length.toDouble();
  //         }
  //         return RoundedContainer(
  //           margin: EdgeInsets.all(0.0),
  //           //height: 420.0,
  //           width: 340.0,
  //           borderColor: AppColors.greyAlt.withOpacity(0.15),
  //           child: Column (
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               CustomTextBoldTitle(title: StringConst.DOCUMENTATION),
  //               SpaceH20(),
  //               Stack(
  //                 children: [
  //                   Center(
  //                     child: CircularSeekBar(
  //                       height: 260,
  //                       width: 260,
  //                       startAngle: 45,
  //                       sweepAngle: 270,
  //                       progress: value,
  //                       maxProgress: maxValue,
  //                       barWidth: 15,
  //                       progressColor: AppColors.darkYellow,
  //                       innerThumbStrokeWidth: 15,
  //                       innerThumbColor: AppColors.darkYellow,
  //                       outerThumbColor: Colors.transparent,
  //                       trackColor: AppColors.lightYellow,
  //                       strokeCap: StrokeCap.round,
  //                       animation: true,
  //                       animDurationMillis: 1500,
  //                     ),
  //                   ),
  //                   Center(
  //                     child: Column(
  //                       children: [
  //                         Padding(
  //                           padding: const EdgeInsets.only(left: 40.0),
  //                           child: Image.asset(ImagePath.PARTICIPANT_DOCUMENTATION_ICON, width:220,),
  //                         ),
  //                         CustomTextBoldTitle(title: "${(value/maxValue)*100}%"),
  //                         CustomTextMediumBold(text: StringConst.COMPLETED.toUpperCase()),
  //                       ],
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         );
  //       }
  //   );
  // }

  // Widget _buildResourcesSection(BuildContext context) {
  //   final database = Provider.of<Database>(context, listen: false);
  //   final textTheme = Theme.of(context).textTheme;
  //
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       CustomTextBoldTitle(title: StringConst.RESOURCES_JOINED),
  //       SpaceH20(),
  //       StreamBuilder<List<Resource>>(
  //           stream: database.resourcesStream(),
  //           builder: (context, snapshot) {
  //             List<Resource> myResources = [];
  //             if (snapshot.hasData) {
  //               myResources = snapshot.data!.where((resource) =>
  //                   participantUser.resources.any((id) => resource.resourceId == id))
  //                   .toList();
  //             }
  //
  //             return myResources.isEmpty? Text(
  //               StringConst.NO_RESOURCES,
  //               style: textTheme.bodyMedium,
  //             ): Wrap(
  //               spacing: 10.0,
  //               runSpacing: 10.0,
  //               children: myResources.map((r) => Container(
  //                 padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
  //                 decoration: BoxDecoration(
  //                   color: AppColors.altWhite,
  //                   borderRadius: BorderRadius.circular(50),
  //                   border: Border.all(color: AppColors.greyAlt.withOpacity(0.15), width: 2.0,),
  //                 ),
  //                 child: Text(r.title),)).toList(),
  //             );
  //           }
  //       )
  //     ],
  //   );
  // }

  int _getUserPillsConsumed() {
    int userPillsConsumed = 2; // 2 first pills are always consumed
    if (participantUser.gamificationFlags[UserEnreda.FLAG_PILL_COMPETENCIES]?? false) {
      userPillsConsumed++;
    }
    if (participantUser.gamificationFlags[UserEnreda.FLAG_PILL_CV_COMPETENCIES]?? false) {
      userPillsConsumed++;
    }
    if (participantUser.gamificationFlags[UserEnreda.FLAG_PILL_HOW_TO_DO_CV]?? false) {
      userPillsConsumed++;
    }
    return userPillsConsumed;
  }

  int _getUserCvStepsCompleted() {
    int userCvStepsCompleted = 0;

    if (participantUser.gamificationFlags[UserEnreda.FLAG_CV_PHOTO]?? false) {
      userCvStepsCompleted++;
    }
    if (participantUser.gamificationFlags[UserEnreda.FLAG_CV_ABOUT_ME]?? false) {
      userCvStepsCompleted++;
    }
    if (participantUser.gamificationFlags[UserEnreda.FLAG_CV_DATA_OF_INTEREST]?? false) {
      userCvStepsCompleted++;
    }
    if (participantUser.gamificationFlags[UserEnreda.FLAG_CV_FORMATION]?? false) {
      userCvStepsCompleted++;
    }
    if (participantUser.gamificationFlags[UserEnreda.FLAG_CV_COMPLEMENTARY_FORMATION]?? false) {
      userCvStepsCompleted++;
    }
    if (participantUser.gamificationFlags[UserEnreda.FLAG_CV_PERSONAL]?? false) {
      userCvStepsCompleted++;
    }
    if (participantUser.gamificationFlags[UserEnreda.FLAG_CV_PROFESSIONAL]?? false) {
      userCvStepsCompleted++;
    }

    return userCvStepsCompleted;
  }
}
