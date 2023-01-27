import 'package:enreda_app/app/home/account/account_page.dart';
import 'package:enreda_app/app/home/competencies/competencies_page.dart';
import 'package:enreda_app/app/home/resources/pages/resources_page.dart';
import 'package:enreda_app/common_widgets/background_web.dart';
import 'package:enreda_app/common_widgets/show_alert_dialog.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../common_widgets/custom_icons_icons.dart';

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

  @override
  void initState() {
    bodyWidget = [
      ResourcesPage(),
      CompetenciesPage(showChatNotifier: widget.showChatNotifier),
      AccountPage()
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);

    return ValueListenableBuilder<int>(
        valueListenable: WebHomeScaffold.selectedIndex,
        builder: (context, selectedIndex, child) {
          return Scaffold(
            appBar: AppBar(
              elevation: 0.0,
              backgroundColor: Constants.white,
              title: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      ImagePath.LOGO,
                      height: 20,
                    ),
                  ),
                  SpaceW24(),
                  // TODO: Grey divider
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
                // TODO: Grey divider
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
                  SizedBox(width: 50,)
              ],
            ),
            body: Stack(
              children: [
                BackgroundWeb(),
                bodyWidget[selectedIndex]
              ],
            ),
          );
        });
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final didRequestSignOut = await showAlertDialog(context,
        title: 'Cerrar sesión',
        content: '¿Estás seguro que quieres cerrar sesión?',
        cancelActionText: 'Cancelar',
        defaultActionText: 'Cerrar');
    if (didRequestSignOut == true) {
      final auth = Provider.of<AuthBase>(context, listen: false);
      setState(() {
        auth.signOut();
      });
    }
  }
}
