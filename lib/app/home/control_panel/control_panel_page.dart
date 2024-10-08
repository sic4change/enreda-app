import 'package:enreda_app/app/home/control_panel/participant_control_panel_page.dart';
import 'package:enreda_app/app/home/models/trainingPill.dart';
import 'package:enreda_app/app/home/models/userEnreda.dart';
import 'package:enreda_app/app/home/trainingPills/videos_tooltip_widget/pill_tooltip.dart';
import 'package:enreda_app/common_widgets/rounded_container.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ControlPanelPage extends StatefulWidget {
  const ControlPanelPage({super.key, required this.user});

  final UserEnreda? user;

  @override
  State<ControlPanelPage> createState() => _ControlPanelPageState();
}

class _ControlPanelPageState extends State<ControlPanelPage> {
  @override
  Widget build(BuildContext context) {
    return myWelcomePageDesktop(context);
  }

  Widget myWelcomePageDesktop(BuildContext context){
    final textTheme = Theme.of(context).textTheme;
    return RoundedContainer(
      contentPadding: Responsive.isMobile(context) ?
        EdgeInsets.only(left: 0, right: 0, bottom: Sizes.kDefaultPaddingDouble, top: Sizes.kDefaultPaddingDouble) :
        EdgeInsets.only(left: 0, right: Sizes.kDefaultPaddingDouble, bottom: Sizes.kDefaultPaddingDouble, top: Sizes.kDefaultPaddingDouble),
      margin: Responsive.isMobile(context) ? const EdgeInsets.all(0) :
        const EdgeInsets.all(Sizes.kDefaultPaddingDouble),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  margin: Responsive.isMobile(context) ? const EdgeInsets.only(top: 10.0, right: 10.0, left: 10.0, bottom: 10.0,) :
                    const EdgeInsets.only(top: 10.0, right: 10.0, left: 30.0, bottom: 10.0,),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.rectangle,
                    border: Border.all(color: AppColors.greyLight2.withOpacity(0.3), width: 1),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Stack(
                      children: [
                        Container(
                            margin: const EdgeInsets.only(top: 30.0, right: 0.0, left: 50, bottom: 30.0,),
                            child: Image.asset(ImagePath.LOGO_LINES)),
                        Container(
                          width: Responsive.isMobile(context) ? MediaQuery.of(context).size.width :
                            MediaQuery.of(context).size.width * 0.4,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 70.0, left: 20.0, right: 0, bottom: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                  child: Text('Hola ${widget.user?.firstName},',
                                    style: textTheme.displaySmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: Responsive.isMobile(context) ? 30 : 42.0,
                                        color: AppColors.primary900),),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                  child: Text(StringConst.WELCOME_COMPANY,
                                    style: textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: Responsive.isMobile(context) ? 30 : 42.0,
                                        color: Colors.black),),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 20.0),
                                  child: Text(StringConst.WELCOME_TEXT,
                                    style: textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.normal,
                                        fontSize: Responsive.isMobile(context) ? 15 : 18.0,
                                        color: AppColors.greyAlt),),
                                )
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(22.0),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: PillTooltip(
                              title: StringConst.PILL_TRAVEL_BEGINS,
                              pillId: TrainingPill.TRAVEL_BEGINS_ID,
                            ),
                          ),
                        ),
                        SizedBox(width: 20,),
                      ]
                  )),
                Responsive.isDesktop(context) ? Positioned(
                    right: Responsive.isDesktopS(context) ? 20 : 200,
                    top: -20,
                    bottom: -10,
                    child: Image.asset(ImagePath.CONTROL_PANEL, height: 300,)) : Container(),
              ],
            ),
            ParticipantControlPanelPage(participantUser: widget.user!),
          ],
        ),
      ),
    );
  }

}
