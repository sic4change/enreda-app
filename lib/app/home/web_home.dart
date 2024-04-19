import 'package:enreda_app/app/home/account/gamification_page.dart';
import 'package:enreda_app/app/home/account/personal_data_page.dart';
import 'package:enreda_app/app/home/competencies/competencies_page.dart';
import 'package:enreda_app/app/home/competencies/my_competencies_page.dart';
import 'package:enreda_app/app/home/control_panel/control_panel_page.dart';
import 'package:enreda_app/app/home/curriculum/my_curriculum_page.dart';
import 'package:enreda_app/app/home/documentation/documentation_page.dart';
import 'package:enreda_app/app/home/enreda-contact/enreda_contact_page.dart';
import 'package:enreda_app/app/home/resources/pages/my_resources_page.dart';
import 'package:enreda_app/app/home/resources/pages/resources_page.dart';
import 'package:enreda_app/app/home/side_bar_widget.dart';
import 'package:enreda_app/app/sign_in/access/access_page.dart';
import 'package:enreda_app/common_widgets/enreda_button.dart';
import 'package:enreda_app/common_widgets/show_alert_dialog.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/adaptive.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/utils/functions.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sidebarx/sidebarx.dart';

import '../../common_widgets/custom_icons_icons.dart';
import 'models/userEnreda.dart';


class WebHome extends StatefulWidget {
  const WebHome({Key? key, required this.showChatNotifier})
      : super(key: key);

  static final SidebarXController controller = SidebarXController(selectedIndex: 0, extended: true);
  static ValueNotifier<int> selectedIndex = ValueNotifier(2);
  final ValueNotifier<bool> showChatNotifier;

  static goToControlPanel() {
    WebHome.selectedIndex.value = 2;
    WebHome.controller.selectIndex(0);
  }

  static goToParticipants() {
    WebHome.selectedIndex.value = 2;
    WebHome.controller.selectIndex(1);
  }

  static goResources() {
    WebHome.selectedIndex.value = 2;
    WebHome.controller.selectIndex(2);
  }

  @override
  State<WebHome> createState() => _WebHomeState();
}

class _WebHomeState extends State<WebHome> {
  var bodyWidget = [];
  final _key = GlobalKey<ScaffoldState>();

  Color _underlineColor = Constants.lilac;
  late UserEnreda _userEnreda;
  String _userName = "";
  late TextTheme textTheme;

  @override
  void initState() {
    bodyWidget = [
      const PersonalData(),
      Container(),
    ];
    super.initState();
  }

  Widget _buildMyUserName(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    final database = Provider.of<Database>(context, listen: false);
    textTheme = Theme.of(context).textTheme;
    return StreamBuilder<User?>(
        stream: Provider.of<AuthBase>(context).authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return StreamBuilder<UserEnreda>(
              stream: database.userEnredaStreamByUserId(auth.currentUser!.uid),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  _userEnreda = snapshot.data!;
                  _userName = '${_userEnreda.firstName} ${_userEnreda.lastName}';
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(_userName,
                            style: textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.bluePetrol,
                              fontSize: 16.0,)
                        ),
                      ),
                    ],
                  );
                } else {
                  return Center(child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: SizedBox(
                      child: CircularProgressIndicator(),
                      height: 20.0,
                      width: 20.0,
                    ),
                  ),);
                }
              },
            );
          } else if (!snapshot.hasData) {
            return Container();
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
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
            appBar: AppBar(
              toolbarHeight: !isSmallScreen ? 100 : 80,
              elevation: 1.0,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              bottom: const PreferredSize(
                preferredSize: Size.fromHeight(1),
                child: Divider(
                    height: 1,
                    color: AppColors.grey100),
              ),
              leading: isSmallScreen ? IconButton(
                onPressed: () {
                  _key.currentState?.openDrawer();
                },
                icon: const Icon(Icons.menu),
              ) : Container(),
              title: Transform(
                transform:  Responsive.isMobile(context) ? Matrix4.translationValues(0.0, 0.0, 0.0) : Matrix4.translationValues(-35.0, 0.0, 0.0),
                child: Row(
                  children: [
                    Padding(
                      padding: Responsive.isMobile(context)
                          ? EdgeInsets.only(right: 30)
                          : Responsive.isDesktopS(context)
                          ? EdgeInsets.only(right: 30)
                          : EdgeInsets.only(right: 50),
                      child: InkWell(
                        onTap: () => launchURL(StringConst.NEW_WEB_ENREDA_URL),
                        child: Image.asset(
                          ImagePath.LOGO,
                          height: 55,
                          width: !isSmallScreen ? 125 : 85,
                        ),
                      ),
                    ),
                    !isSmallScreen ? Container(
                      width: 1,
                      height: 120,
                      color: AppColors.grey100,
                    ) : Container(),
                    SpaceW24(),
                    !isSmallScreen ? Container(
                      decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: selectedIndex == 8
                                  ? _underlineColor
                                  : Colors.transparent,
                              width: 4.0,
                            ),
                          )),
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            WebHome.controller.selectIndex(8);
                            ResourcesPage.selectedIndex.value = 0;
                          });
                        },
                        child: Text(
                          StringConst.RESOURCES,
                          style: GoogleFonts.ibmPlexMono(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ) : Container(),
                    SpaceW24(),
                    !isSmallScreen ? Container(
                      decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: WebHome.selectedIndex.value == 9
                                  ? _underlineColor
                                  : Colors.transparent,
                              width: 4.0,
                            ),
                          )),
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            WebHome.controller.selectIndex(9);
                          });
                        },
                        child: Text(
                          StringConst.COMPETENCIES,
                          style: GoogleFonts.ibmPlexMono(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ) : Container(),
                  ],
                ),
              ),
              actions: <Widget>[
                if (!auth.isNullUser && !isSmallScreen)
                  Container(
                    width: 1,
                    height: 120,
                    color: AppColors.grey100,
                  ),
                SizedBox(width: 20),
                !isSmallScreen ? IconButton(
                  icon: const Icon(
                    CustomIcons.cuenta,
                    color: AppColors.bluePetrol,
                    size: 30,
                  ),
                  tooltip: 'Cuenta',
                  onPressed: () {
                    setState(() {
                      WebHome.controller.selectIndex(0);
                    });
                  },
                ) : Container(),
                !isSmallScreen ? InkWell(
                    onTap: () {
                      setState(() {
                        WebHome.controller.selectIndex(0);
                      });
                    },
                    child: _buildMyUserName(context)
                ) : Container(),
                if (!auth.isNullUser)
                  SizedBox(width: 20),
                if (!auth.isNullUser)
                  Container(
                    width: 30,
                    child: InkWell(
                      onTap: () => _confirmSignOut(context),
                      child: Image.asset(
                        ImagePath.LOGOUT,
                        height: Sizes.ICON_SIZE_30,
                      ),),
                  ),
                Padding(
                  padding: Responsive.isMobile(context)
                      ? EdgeInsets.only(right: 20)
                      : Responsive.isDesktopS(context)
                      ? EdgeInsets.only(right: 20)
                      : EdgeInsets.only(right: 30),
                  child: SizedBox(),
                ),
              ],
            ),
            drawer: SideBarWidget(controller: WebHome.controller, profilePic: profilePic, user: user, keyWebHome: _key,),
            body: Container(
              width: MediaQuery.of(context).size.width,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 1600),
                child: Padding(
                  padding: WebHome.controller.selectedIndex == 8
                      || WebHome.controller.selectedIndex == 9 || Responsive.isMobile(context) ?
                    const EdgeInsets.all(0) : const EdgeInsets.only(left: Sizes.kDefaultPaddingDouble),
                  child: Row(
                    children: [
                      !isSmallScreen && WebHome.controller.selectedIndex != 8 && WebHome.controller.selectedIndex != 9 ?
                        SideBarWidget(controller: WebHome.controller, profilePic: profilePic, user: user, keyWebHome: _key,) : Container(),
                      Expanded(child: Center(child: Padding(
                        padding: Responsive.isMobile(context) ? EdgeInsets.only(top: 10) :
                          WebHome.controller.selectedIndex != 8
                              && WebHome.controller.selectedIndex != 9 ? EdgeInsets.only(top: 20) :
                          EdgeInsets.only(top: 0),
                        child: AnimatedBuilder(
                            animation: WebHome.controller,
                            builder: (context, child){
                              bool hasEntity = user.assignedEntityId == null || user.assignedEntityId == "" ? false : true;
                              _key.currentState?.closeDrawer();
                              if (!hasEntity && WebHome.controller.selectedIndex > 6) {
                                WebHome.controller.selectIndex(WebHome.controller.selectedIndex + 2);
                              }
                              switch(WebHome.controller.selectedIndex){
                                case 0:
                                  return ControlPanelPage(user: user,);
                                case 1:
                                  return MyCurriculumPage();
                                case 2:
                                  return PersonalData();
                                case 3:
                                  return MyCompetenciesPage();
                                case 4:
                                  return MyResourcesPage();
                                case 5:
                                  if (hasEntity) {
                                    return EnredaContactPage();
                                  }
                                  break;
                                case 6:
                                  if (hasEntity) {
                                    return ParticipantDocumentationPage(participantUser: user);
                                  }
                                  break;
                                case 7:
                                  return GamificationPage(
                                    showChatNotifier: widget.showChatNotifier,
                                    goBackToCV: () => setState(() {
                                      WebHome.controller.selectIndex(1);
                                    }),
                                    goBackToCompetencies: () => setState(() {
                                      WebHome.controller.selectIndex(3);
                                    }),
                                  );
                                case 8:
                                  return ResourcesPage();
                                case 9:
                                  return CompetenciesPage(showChatNotifier: widget.showChatNotifier);
                                default:
                                  return Container();
                              }
                              return Container();
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
                      style: textTheme.bodySmall?.copyWith(
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
