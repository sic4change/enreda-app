import 'package:cached_network_image/cached_network_image.dart';
import 'package:enreda_app/app/home/account/gamification_page.dart';
import 'package:enreda_app/app/home/account/personal_data_page.dart';
import 'package:enreda_app/app/home/competencies/my_competencies_page.dart';
import 'package:enreda_app/app/home/control_panel/control_panel_page.dart';
import 'package:enreda_app/app/home/curriculum/my_curriculum_page.dart';
import 'package:enreda_app/app/home/resources/pages/favorite_resources_page.dart';
import 'package:enreda_app/app/home/resources/pages/my_resources_page.dart';
import 'package:enreda_app/app/home/side_bar_widget.dart';
import 'package:enreda_app/app/sign_in/access/access_page.dart';
import 'package:enreda_app/common_widgets/enreda_button.dart';
import 'package:enreda_app/common_widgets/show_alert_dialog.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/adaptive.dart';
import 'package:enreda_app/utils/functions.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sidebarx/sidebarx.dart';

import 'models/userEnreda.dart';


class WebHome extends StatefulWidget {
  const WebHome({Key? key})
      : super(key: key);

  static final SidebarXController controller = SidebarXController(selectedIndex: 0, extended: true);
  static ValueNotifier<int> selectedIndex = ValueNotifier(2);

  static goToControlPanel() {
    WebHome.selectedIndex.value = 2;
    WebHome.controller.selectIndex(0);
  }

  static goToParticipants() {
    WebHome.selectedIndex.value = 2;
    WebHome.controller.selectIndex(1);
  }

  static goToEntities() {
    WebHome.selectedIndex.value = 2;
    WebHome.controller.selectIndex(4);
  }

  static goResources() {
    WebHome.selectedIndex.value = 2;
    WebHome.controller.selectIndex(2);
  }

  static goToolBox() {
    WebHome.selectedIndex.value = 2;
    WebHome.controller.selectIndex(3);
  }

  @override
  State<WebHome> createState() => _WebHomeState();
}

class _WebHomeState extends State<WebHome> {
  var bodyWidget = [];
  final _key = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    bodyWidget = [
      const PersonalData(),
      Container(),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    final database = Provider.of<Database>(context, listen: false);

    return StreamBuilder<User?>(
        stream: Provider.of<AuthBase>(context).authStateChanges(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return AccessPage();
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.active) {
            return StreamBuilder<UserEnreda>(
              stream: database.userEnredaStreamByUserId(auth.currentUser!.uid),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  UserEnreda _userEnreda;
                  _userEnreda = snapshot.data!;
                  if (_userEnreda.role != 'Desempleado') {
                    Future.delayed(Duration.zero, () {
                      _signOut(context);
                      adminSignOut(context);
                    });
                    return Container();
                  }
                  var _photo = (_userEnreda.profilePic?.src == null || _userEnreda.profilePic?.src == ""
                      ? "" : _userEnreda.profilePic?.src)!;
                  var userName = '${_userEnreda.firstName ?? ""} ${_userEnreda.lastName ?? ""}';
                  return _buildContent(context, _userEnreda, _photo, userName);
                }
                else {
                  return Container();
                }
              },
            );
          }
          return CircularProgressIndicator();
        });
  }

  Widget _buildContent(BuildContext context, UserEnreda user, String profilePic, String userName){
    final auth = Provider.of<AuthBase>(context, listen: false);
    return ValueListenableBuilder<int>(
        valueListenable: WebHome.selectedIndex,
        builder: (context, selectedIndex, child) {
          final isSmallScreen = MediaQuery.of(context).size.width < 600;
          return Scaffold(
            key: _key,
            drawer: SideBarWidget(controller: WebHome.controller, profilePic: profilePic, userName: userName, keyWebHome: _key,),
            body: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 1600),
                child: Padding(
                  padding: Responsive.isMobile(context) ? const EdgeInsets.all(0.0) : const EdgeInsets.only(left: 20.0,),
                  child: Row(
                    children: [
                      if(!isSmallScreen) SideBarWidget(controller: WebHome.controller, profilePic: profilePic, userName: userName, keyWebHome: _key,),
                      if (WebHome.selectedIndex.value == 0) Expanded(child: Center(child: bodyWidget[0]))
                      else if (WebHome.selectedIndex.value == 1) Expanded(child: Center(child: bodyWidget[1]))
                      else Expanded(child: Center(child: Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: AnimatedBuilder(
                            animation: WebHome.controller,
                            builder: (context, child){
                              switch(WebHome.controller.selectedIndex){
                                case 0: _key.currentState?.closeDrawer();
                                return ControlPanelPage(user: user,);
                                case 1: _key.currentState?.closeDrawer();
                                return MyCurriculumPage();
                                case 2: _key.currentState?.closeDrawer();
                                return PersonalData();
                                case 3: _key.currentState?.closeDrawer();
                                return MyCompetenciesPage();
                                case 4: _key.currentState?.closeDrawer();
                                return MyResourcesPage();
                                case 5: _key.currentState?.closeDrawer();
                                return Container();
                                default:
                                  return Container();
                              }
                            },
                          ),
                      ),))
                    ],
                  ),
                ),
              ),
            ),

          );
        });

  }

  Widget _buildMyCompanyName(BuildContext context, String userName) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Text(' &  $userName',
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.penBlue,
                fontSize: 16.0,)
          ),
        ),
      ],
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final auth = Provider.of<AuthBase>(context, listen: false);
    final didRequestSignOut = await showAlertDialog(context,
        title: 'Cerrar sesión',
        content: '¿Estás seguro que quieres cerrar sesión?',
        cancelActionText: 'Cancelar',
        defaultActionText: 'Cerrar');
    if (didRequestSignOut == true) {
      await auth.signOut();
      GoRouter.of(context).go(StringConst.PATH_HOME);
    }
  }
}

Future<void> _signOut(BuildContext context) async {
  try {
    final auth = Provider.of<AuthBase>(context, listen: false);
    await auth.signOut();
  } catch (e) {
    print(e.toString());
  }
}


Future<void> adminSignOut(BuildContext context) async {
  String targetWeb = "";

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final auth = Provider.of<AuthBase>(context, listen: false);
    final textTheme = Theme.of(context).textTheme;
    double fontSize = responsiveSize(context, 14, 18, md: 15);
    await showDialog(
      context: context,
      builder: (BuildContext context) => Center(
        child: AlertDialog(
          insetPadding: const EdgeInsets.all(20),
          contentPadding: const EdgeInsets.only(left: 20, right: 20, top: 30),
          content: SizedBox(
            height: 100,
            width: MediaQuery.of(context).size.width * 0.5,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    ImagePath.LOGO,
                    height: 30,
                  ),
                  SpaceH20(),
                  Text(StringConst.ARENT_YOU_PARTICIPANT,
                      style: textTheme.bodyText1?.copyWith(
                        color: AppColors.greyDark,
                        height: 1.5,
                        fontWeight: FontWeight.w800,
                        fontSize: fontSize,
                      )
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: EnredaButton(
                  width: 250.0,
                  buttonTitle: StringConst.GO_ORGANIZATION_WEB,
                  onPressed: () {
                    targetWeb = StringConst.WEB_COMPANIES_URL_ACCESS;
                    auth.signOut();
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20.0),
              child: Center(
                child: EnredaButton(
                  width: 250.0,
                  buttonTitle: StringConst.GO_SOCIAL_ENTITY_WEB,
                  onPressed: () {
                    targetWeb = StringConst.WEB_SOCIAL_ENTITIES_URL_ACCESS;
                    auth.signOut();
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    ).then((exit) {
      if (exit == null) {
        auth.signOut();
        launchURL(targetWeb);
      }
    });
  });
}