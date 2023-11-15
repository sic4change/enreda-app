import 'package:enreda_app/app/home/account/account_page.dart';
import 'package:enreda_app/app/home/competencies/competencies_page.dart';
import 'package:enreda_app/app/home/resources/pages/resources_page.dart';
import 'package:enreda_app/common_widgets/show_alert_dialog.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/services/auth.dart';
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

import '../../common_widgets/custom_icons_icons.dart';
import '../../services/database.dart';
import 'models/userEnreda.dart';

class WebHomeScaffold extends StatefulWidget {
  const WebHomeScaffold({Key? key, required this.showChatNotifier})
      : super(key: key);

  final ValueNotifier<bool> showChatNotifier;

  static ValueNotifier<int> selectedIndex = ValueNotifier(0);

  static goToResources() {
    selectedIndex.value = 0;
  }

  @override
  State<WebHomeScaffold> createState() => _WebHomeScaffoldState();
}

class _WebHomeScaffoldState extends State<WebHomeScaffold> {
  Color _underlineColor = Constants.lilac;
  var bodyWidget = [];
  late UserEnreda _userEnreda;
  String _userName = "";
  late TextTheme textTheme;

  @override
  void initState() {
    bodyWidget = [
      ResourcesPage(),
      CompetenciesPage(showChatNotifier: widget.showChatNotifier),
      AccountPage()
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
                                  fontWeight: FontWeight.bold,
                                  color: Constants.penBlue,
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
    return ValueListenableBuilder<int>(
        valueListenable: WebHomeScaffold.selectedIndex,
        builder: (context, selectedIndex, child) {
          return Scaffold(
            appBar: AppBar(
              elevation: 1.0,
              backgroundColor: Constants.white,
              title: Row(
                children: [
                  Responsive.isDesktop(context) ? SizedBox(width: 100,) : Container(),
                  InkWell(
                    onTap: () => launchURL(StringConst.NEW_WEB_ENREDA_URL),
                    child: Image.asset(
                      ImagePath.LOGO,
                      height: 20,
                    ),
                  ),
                  SpaceW24(),
                  Container(
                    decoration: BoxDecoration(
                        border: Border(
                      bottom: BorderSide(
                        color: selectedIndex == 0
                            ? _underlineColor
                            : Colors.transparent,
                        width: 4.0,
                      ),
                    )),
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          WebHomeScaffold.selectedIndex.value = 0;
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
                  ),
                  SpaceW24(),
                  Container(
                    decoration: BoxDecoration(
                        border: Border(
                      bottom: BorderSide(
                        color: WebHomeScaffold.selectedIndex.value == 1
                            ? _underlineColor
                            : Colors.transparent,
                        width: 4.0,
                      ),
                    )),
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          WebHomeScaffold.selectedIndex.value = 1;
                        });
                      },
                      child: Text(
                        StringConst.COMPETENCIES,
                        style: GoogleFonts.ibmPlexMono(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                if (!auth.isNullUser)
                VerticalDivider(
                  color: AppColors.grey100,
                  thickness: 1,
                ),
                IconButton(
                  icon: const Icon(
                    CustomIcons.cuenta,
                    color: AppColors.blueDark,
                    size: 30,
                  ),
                  tooltip: 'Cuenta',
                  onPressed: () {
                    setState(() {
                      WebHomeScaffold.selectedIndex.value = 2;
                    });
                  },
                ),
                InkWell(
                    onTap: () {
                      setState(() {
                        WebHomeScaffold.selectedIndex.value = 2;
                      });
                    },
                    child: _buildMyUserName(context)
                ),
                if (!auth.isNullUser)
                VerticalDivider(
                  color: AppColors.grey100,
                  thickness: 1,
                ),
                SizedBox(width: 10),
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
                Responsive.isDesktop(context) || Responsive.isDesktopS(context) ? SizedBox(width: 100,) : Container(),
              ],
            ),
            body: bodyWidget[selectedIndex],
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
