import 'package:enreda_app/app/home/control_panel/gamification-item.dart';
import 'package:enreda_app/app/home/control_panel/gamification-slider.dart';
import 'package:enreda_app/app/home/models/competency.dart';
import 'package:enreda_app/app/home/models/userEnreda.dart';
import 'package:enreda_app/app/home/web_home.dart';
import 'package:enreda_app/common_widgets/card_button_contact.dart';
import 'package:enreda_app/common_widgets/custom_text.dart';
import 'package:enreda_app/common_widgets/show_custom_dialog.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/functions.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ControlPanelMobileNoInterventionPage extends StatefulWidget {
  const ControlPanelMobileNoInterventionPage({super.key, required this.user});

  final UserEnreda? user;

  @override
  State<ControlPanelMobileNoInterventionPage> createState() => _ControlPanelMobileNoInterventionPageState();
}

class _ControlPanelMobileNoInterventionPageState extends State<ControlPanelMobileNoInterventionPage> {
  @override
  Widget build(BuildContext context) {
    return myControlPanelMobile(context);
  }

  Widget myControlPanelMobile(BuildContext context){
    return Container(
      height: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  WebHome.controller.selectIndex(1);
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 10.0),
                decoration: BoxDecoration(
                  color: AppColors.primary600,
                  shape: BoxShape.rectangle,
                  border: Border.all(color: AppColors.primary600.withOpacity(0.3), width: 1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    CustomTextBoldTitle(title: StringConst.MY_CV, color: Colors.white,),
                    Spacer(),
                    Image.asset(ImagePath.MY_CV, height: 60),
                  ]
                ),
              ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  WebHome.controller.selectIndex(4);
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 10.0),
                decoration: BoxDecoration(
                  color: AppColors.primary900,
                  shape: BoxShape.rectangle,
                  border: Border.all(color: AppColors.primary900.withOpacity(0.3), width: 1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                    children: [
                      CustomTextBoldTitle(title: StringConst.MY_RESOURCES, color: Colors.white,),
                      Spacer(),
                      Image.asset(ImagePath.MY_RESOURCES, height: 60),
                    ]
                ),
              ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  WebHome.controller.selectIndex(5);
                });
              },
              child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  decoration: BoxDecoration(
                    color: AppColors.primary030,
                    shape: BoxShape.rectangle,
                    border: Border.all(color: AppColors.primary030.withOpacity(0.3), width: 1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: _buildGamificationSection(context)),
            ),
            Container(
              height: 170,
              margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Flex(
                  direction: Axis.horizontal,
                  children: [
                    Expanded(
                        flex: 1,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              WebHome.controller.selectIndex(3);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: AppColors.yellowDark,
                              shape: BoxShape.rectangle,
                              border: Border.all(color: AppColors.yellowDark.withOpacity(0.3), width: 1),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomTextBoldTitle(title: StringConst.MY_COMPETENCIES),
                                SpaceH4(),
                                Image.asset(ImagePath.MY_COMPETENCIES, height: 110),
                              ]
                            ),
                          ),
                        )),
                    SpaceW12(),
                    Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: AppColors.primary100,
                            shape: BoxShape.rectangle,
                            border: Border.all(color: AppColors.primary100.withOpacity(0.3), width: 1),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomTextBoldTitle(title: StringConst.ENREDA_CONTACT),
                                SpaceH4(),
                                Image.asset(ImagePath.LOGO_S4C, height: 50),
                                SpaceH4(),
                                CustomTextSmall(text: 'Sede SIC4Change'),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CardButtonContact(
                                      //title: StringConst.EMAIL,
                                      title: '',
                                      icon: Icon(Icons.email_outlined, color: AppColors.primary900, size: 20,),
                                      width: 60,
                                      onTap: () {
                                        sendEmail(
                                          toEmail: 'hello@sic4change.org',
                                          subject: StringConst.SUBJECT,
                                          body: StringConst.BODY,
                                        ).catchError((error) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Hubo un error al enviar el correo: $error')),
                                          );
                                        });
                                      },
                                    ),
                                    SpaceW4(),
                                    Container(
                                        height: 15,
                                        child: VerticalDivider(color: AppColors.white,)),
                                    SpaceW4(),
                                    CardButtonContact(
                                      //title: StringConst.CALL,
                                      title: '',
                                      width: 60,
                                      icon: Icon(Icons.phone, color: AppColors.primary900, size: 20),
                                      onTap: () {
                                        kIsWeb ? showCustomDialog(
                                          context,
                                          content: Container(
                                              height: 100,
                                              width: 200,
                                              child: Center(child:
                                              Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    SpaceH12(),
                                                    CustomTextBold(title:StringConst.CALL_NUMBER),
                                                    SpaceH12(),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Icon(Icons.local_phone, color: AppColors.primary900, size: 20),
                                                      ],),
                                                    SpaceH8(),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Icon(Icons.phone_android, color: AppColors.primary900, size: 20),
                                                      ],),
                                                  ]
                                              ))),
                                        ) : makePhoneCall('123 123 112');
                                      },
                                    ),
                                  ],
                                ),
                              ]
                          ),
                        )),
                  ],
              ),
            ),
            SizedBox(height: 80),
          ],
        ),
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
            Expanded(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextBoldTitle(title: StringConst.GAMIFICATION),
                    GamificationSlider(
                      height: Responsive.isDesktop(context) ? 20.0 : 10.0,
                      value: widget.user!.gamificationFlags.length,
                    ),
                    SpaceH20(),
                    Container(
                      height: 105,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(top: 4.0),
                            margin: const EdgeInsets.only(right: 8.0),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.rectangle,
                              border: Border.all(color: AppColors.primary900.withOpacity(0.3), width: 1),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: GamificationItem(
                              imagePath: ImagePath.GAMIFICATION_CHAT_ICON,
                              progress: (widget.user!.gamificationFlags[UserEnreda.FLAG_CHAT]?? false)? 100 : 0,
                              title: (widget.user!.gamificationFlags[UserEnreda.FLAG_CHAT]?? false)? "CHAT INICIADO": "CHAT NO INICIADO",
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 4.0),
                            margin: const EdgeInsets.only(right: 8.0),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.rectangle,
                              border: Border.all(color: AppColors.primary900.withOpacity(0.3), width: 1),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: GamificationItem(
                              imagePath: ImagePath.GAMIFICATION_PILL_ICON,
                              progress: (_getUserPillsConsumed()/totalGamificationPills) * 100,
                              progressText: "${_getUserPillsConsumed()}",
                              title: "PÍLDORAS CONSUMIDAS",
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 4.0),
                            margin: const EdgeInsets.only(right: 8.0),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.rectangle,
                              border: Border.all(color: AppColors.primary900.withOpacity(0.3), width: 1),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: StreamBuilder<List<Competency>>(
                                stream: database.competenciesStream(),
                                builder: (context, competenciesStream) {
                                  double competenciesProgress = 0;
                                  Map<String, String> certifiedCompetencies = {};
                                  if (competenciesStream.hasData) {
                                    certifiedCompetencies = Map.from(widget.user!.competencies);
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
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 4.0),
                            margin: const EdgeInsets.only(right: 8.0),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.rectangle,
                              border: Border.all(color: AppColors.primary900.withOpacity(0.3), width: 1),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: GamificationItem(
                              imagePath: ImagePath.GAMIFICATION_RESOURCES_ICON,
                              progress: ((widget.user!.resourcesAccessCount?? 0) / 15) * 100,
                              progressText: "${widget.user!.resourcesAccessCount}",
                              title: "RECURSOS INSCRITOS",
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 4.0),
                            margin: const EdgeInsets.only(right: 8.0),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.rectangle,
                              border: Border.all(color: AppColors.primary900.withOpacity(0.3), width: 1),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: GamificationItem(
                              imagePath: ImagePath.GAMIFICATION_CV_ICON,
                              progress: (_getUserCvStepsCompleted()/cvTotalSteps) * 100,
                              progressText: "${(_getUserCvStepsCompleted() / cvTotalSteps * 100).toStringAsFixed(2)}%",
                              title: "CV COMPLETADO",
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ],);
  }

  int _getUserPillsConsumed() {
    int userPillsConsumed = 2; // 2 first pills are always consumed
    if (widget.user!.gamificationFlags[UserEnreda.FLAG_PILL_COMPETENCIES]?? false) {
      userPillsConsumed++;
    }
    if (widget.user!.gamificationFlags[UserEnreda.FLAG_PILL_CV_COMPETENCIES]?? false) {
      userPillsConsumed++;
    }
    if (widget.user!.gamificationFlags[UserEnreda.FLAG_PILL_HOW_TO_DO_CV]?? false) {
      userPillsConsumed++;
    }
    return userPillsConsumed;
  }

  int _getUserCvStepsCompleted() {
    int userCvStepsCompleted = 0;

    if (widget.user!.gamificationFlags[UserEnreda.FLAG_CV_PHOTO]?? false) {
      userCvStepsCompleted++;
    }
    if (widget.user!.gamificationFlags[UserEnreda.FLAG_CV_ABOUT_ME]?? false) {
      userCvStepsCompleted++;
    }
    if (widget.user!.gamificationFlags[UserEnreda.FLAG_CV_DATA_OF_INTEREST]?? false) {
      userCvStepsCompleted++;
    }
    if (widget.user!.gamificationFlags[UserEnreda.FLAG_CV_FORMATION]?? false) {
      userCvStepsCompleted++;
    }
    if (widget.user!.gamificationFlags[UserEnreda.FLAG_CV_COMPLEMENTARY_FORMATION]?? false) {
      userCvStepsCompleted++;
    }
    if (widget.user!.gamificationFlags[UserEnreda.FLAG_CV_PERSONAL]?? false) {
      userCvStepsCompleted++;
    }
    if (widget.user!.gamificationFlags[UserEnreda.FLAG_CV_PROFESSIONAL]?? false) {
      userCvStepsCompleted++;
    }
    return userCvStepsCompleted;
  }

}
