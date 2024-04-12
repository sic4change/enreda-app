import 'package:enreda_app/app/home/account_main_page.dart';
import 'package:enreda_app/app/home/competencies/competency_tile.dart';
import 'package:enreda_app/app/home/control_panel/documentation_page.dart';
import 'package:enreda_app/app/home/control_panel/gamification-item.dart';
import 'package:enreda_app/app/home/control_panel/gamification-slider.dart';
import 'package:enreda_app/app/home/curriculum/my_curriculum_page.dart';
import 'package:enreda_app/app/home/models/competency.dart';
import 'package:enreda_app/app/home/models/resource.dart';
import 'package:enreda_app/app/home/models/userEnreda.dart';
import 'package:enreda_app/common_widgets/custom_text.dart';
import 'package:enreda_app/common_widgets/main_container.dart';
import 'package:enreda_app/common_widgets/rounded_container.dart';
import 'package:enreda_app/common_widgets/show_custom_dialog.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/my_scroll_behaviour.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ParticipantControlPanelPage extends StatefulWidget {
  const ParticipantControlPanelPage({required this.participantUser, super.key});

  final UserEnreda participantUser;

  @override
  State<ParticipantControlPanelPage> createState() => _ParticipantControlPanelPageState();
}

class _ParticipantControlPanelPageState extends State<ParticipantControlPanelPage> {
  @override
  Widget build(BuildContext context) {
    return Responsive.isMobile(context) || Responsive.isDesktopS(context) ? _buildBodyMobile(context) : _buildBodyDesktop(context);
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
                    _buildCompetenciesSection(context),
                    SpaceH20(),
                    widget.participantUser.assignedEntityId != null && widget.participantUser.assignedEntityId != "" ?
                      ParticipantDocumentationPage(participantUser: widget.participantUser,) :
                    _buildResourcesSection(context),
                    SpaceH8(),
                    if(widget.participantUser.assignedEntityId != null && widget.participantUser.assignedEntityId != "")
                      _buildContactSection(context),
                  ],
                ),
              ),
              SpaceW30(),
              Container(
                margin: const EdgeInsets.only(top: 10.0, right: 10.0, left: 0.0, bottom: 10.0,),
                padding: const EdgeInsets.all(Sizes.kDefaultPaddingDouble),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  border: Border.all(color: AppColors.greyLight2.withOpacity(0.3), width: 1),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: _buildCvSection(context)),
              SpaceH40(),
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
          SpaceH30(),
          _buildCompetenciesSection(context),
          SpaceH30(),
          _buildCvSection(context),
          SpaceH30(),
          widget.participantUser.assignedEntityId != null && widget.participantUser.assignedEntityId != "" ?
          ParticipantDocumentationPage(participantUser: widget.participantUser,) :
          _buildResourcesSection(context),
          SpaceH30(),
          if(widget.participantUser.assignedEntityId != null && widget.participantUser.assignedEntityId != "")
            _buildContactSection(context),
          SpaceH30(),
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
            Responsive.isMobile(context) || Responsive.isDesktopS(context) ? Container() :
            Container(
                height: 250,
                child: Image.asset(ImagePath.GAMIFICATION_LOGO, height: 250.0,)),
            SpaceW8(),
            Expanded(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextBoldTitle(title: StringConst.GAMIFICATION),
                    GamificationSlider(
                      height: Responsive.isDesktop(context) ? 20.0 : 10.0,
                      value: widget.participantUser.gamificationFlags.length,
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
                                progress: (widget.participantUser.gamificationFlags[UserEnreda.FLAG_CHAT]?? false)? 100 : 0,
                                title: (widget.participantUser.gamificationFlags[UserEnreda.FLAG_CHAT]?? false)? "CHAT INICIADO": "CHAT NO INICIADO",
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
                                      certifiedCompetencies = Map.from(widget.participantUser.competencies);
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
                                progress: ((widget.participantUser.resourcesAccessCount?? 0) / 15) * 100,
                                progressText: "${widget.participantUser.resourcesAccessCount}",
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
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: () {
        setState(() {
          WebHome.controller.selectIndex(5);
        });
      },
      child: Container(
        height: 280,
        child:
        Stack(
          children: [
            Container(
              height: double.infinity,
              width: double.infinity,
              margin: const EdgeInsets.only(top: 25.0, bottom: 30.0),
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
                    CustomTextBold(title: 'Ver más', color: AppColors.yellowDark,),
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
      ),
    );
  }

  Widget _buildCompetenciesSection(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: Responsive.isMobile(context) ? const EdgeInsets.only(top: 10.0, right: 0, left: 0.0, bottom: 10.0,) :
        const EdgeInsets.only(top: 10.0, right: 10.0, left: 0.0, bottom: 10.0,),
      padding: const EdgeInsets.all(Sizes.kDefaultPaddingDouble),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        border: Border.all(color: AppColors.greyLight2.withOpacity(0.3), width: 1),
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextBoldTitle(title: StringConst.MY_COMPETENCIES),
          SpaceH8(),
          StreamBuilder<List<Competency>>(
              stream: database.competenciesStream(),
              builder: (context, snapshotCompetencies) {
                if (snapshotCompetencies.hasData) {
                  final controller = ScrollController();
                  var scrollJump = Responsive.isDesktopS(context) ? 350 : 410;
                  List<Competency> myCompetencies = snapshotCompetencies.data!;
                  final competenciesIds = widget.participantUser.competencies.keys.toList();
                  myCompetencies = myCompetencies
                      .where((competency) => competenciesIds.any((id) => competency.id == id))
                      .toList();
                  return myCompetencies.isEmpty ? Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Center(child: CustomTextSubTitle(title: StringConst.NO_COMPETENCIES,)),
                  ) : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: Responsive.isDesktop(context) ? 210.0 : Responsive.isDesktopS(context) ? 200 : 150.0,
                        child: ScrollConfiguration(
                          behavior: MyCustomScrollBehavior(),
                          child: ListView(
                            controller: controller,
                            scrollDirection: Axis.horizontal,
                            children: myCompetencies.map((competency) {
                              final status = widget.participantUser.competencies[competency.id] ?? StringConst.BADGE_EMPTY;
                              return Column(
                                children: [
                                  Container(
                                    height: Responsive.isDesktop(context) ? 210.0 : Responsive.isDesktopS(context) ? 200 : 150.0,
                                    child: CompetencyTile(
                                      competency: competency,
                                      status: status,
                                      height: 40,
                                      medium: true,
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      Container(
                        child: Row(
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
                                ImagePath.ARROW_BACK_ALT,
                                width: 30.0,
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
                                ImagePath.ARROW_FORWARD_ALT,
                                width: 30.0,
                              ),
                            ),
                          ],
                        ),
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
    return Container(
      margin: Responsive.isMobile(context) ? const EdgeInsets.all(0) :
        const EdgeInsets.only(top: 10.0, right: 10.0, left: 0.0, bottom: 10.0,),
      padding: const EdgeInsets.all(Sizes.kDefaultPaddingDouble),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        border: Border.all(color: AppColors.greyLight2.withOpacity(0.3), width: 1),
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextBoldTitle(title: StringConst.CV),
              SpaceH12(),
              RoundedContainer(
                margin: const EdgeInsets.all(0),
                contentPadding: const EdgeInsets.all(0),
                //height: 450.0,
                height: Responsive.isMobile(context) ? 360 : MediaQuery.sizeOf(context).height * 0.4,
                //width: 340.0,
                width: Responsive.isMobile(context) ? MediaQuery.of(context).size.width * 0.7 :
                  Responsive.isDesktopS(context) ? MediaQuery.of(context).size.width * 0.5 : MediaQuery.sizeOf(context).width * 0.2,
                borderColor: AppColors.greyAlt.withOpacity(0.15),
                child: SingleChildScrollView(
                  physics: NeverScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () => showCustomDialog(
                          context,
                          content: Container(
                              height: MediaQuery.sizeOf(context).height * 0.85,
                              width: Responsive.isDesktop(context) || Responsive.isDesktopS(context) ? MediaQuery.sizeOf(context).width * 0.6
                                  : MediaQuery.sizeOf(context).width * 0.9,
                              child: MyCurriculumPage()),
                        ),
                        child: Transform.scale(
                          scale: Responsive.isMobile(context) ? 0.25 : 0.33,
                          child: MyCurriculumPage(
                            mini: true,
                          ),
                          alignment: Alignment.topLeft,),
                      ),
                    ],
                  ),
                ),)
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResourcesSection(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextBoldTitle(title: StringConst.RESOURCES_JOINED),
        SpaceH20(),
        StreamBuilder<List<Resource>>(
            stream: database.resourcesStream(),
            builder: (context, snapshot) {
              List<Resource> myResources = [];
              if (snapshot.hasData) {
                myResources = snapshot.data!.where((resource) =>
                    widget.participantUser.resources.any((id) => resource.resourceId == id))
                    .toList();
              }

              return myResources.isEmpty? Text(
                StringConst.NO_RESOURCES,
                style: textTheme.bodyMedium,
              ): Wrap(
                spacing: 10.0,
                runSpacing: 10.0,
                children: myResources.map((r) => Container(
                  padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: AppColors.altWhite,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: AppColors.greyAlt.withOpacity(0.15), width: 2.0,),
                  ),
                  child: Text(r.title),)).toList(),
              );
            }
        )
      ],
    );
  }

  int _getUserPillsConsumed() {
    int userPillsConsumed = 2; // 2 first pills are always consumed
    if (widget.participantUser.gamificationFlags[UserEnreda.FLAG_PILL_COMPETENCIES]?? false) {
      userPillsConsumed++;
    }
    if (widget.participantUser.gamificationFlags[UserEnreda.FLAG_PILL_CV_COMPETENCIES]?? false) {
      userPillsConsumed++;
    }
    if (widget.participantUser.gamificationFlags[UserEnreda.FLAG_PILL_HOW_TO_DO_CV]?? false) {
      userPillsConsumed++;
    }
    return userPillsConsumed;
  }

  int _getUserCvStepsCompleted() {
    int userCvStepsCompleted = 0;

    if (widget.participantUser.gamificationFlags[UserEnreda.FLAG_CV_PHOTO]?? false) {
      userCvStepsCompleted++;
    }
    if (widget.participantUser.gamificationFlags[UserEnreda.FLAG_CV_ABOUT_ME]?? false) {
      userCvStepsCompleted++;
    }
    if (widget.participantUser.gamificationFlags[UserEnreda.FLAG_CV_DATA_OF_INTEREST]?? false) {
      userCvStepsCompleted++;
    }
    if (widget.participantUser.gamificationFlags[UserEnreda.FLAG_CV_FORMATION]?? false) {
      userCvStepsCompleted++;
    }
    if (widget.participantUser.gamificationFlags[UserEnreda.FLAG_CV_COMPLEMENTARY_FORMATION]?? false) {
      userCvStepsCompleted++;
    }
    if (widget.participantUser.gamificationFlags[UserEnreda.FLAG_CV_PERSONAL]?? false) {
      userCvStepsCompleted++;
    }
    if (widget.participantUser.gamificationFlags[UserEnreda.FLAG_CV_PROFESSIONAL]?? false) {
      userCvStepsCompleted++;
    }
    return userCvStepsCompleted;
  }
}
