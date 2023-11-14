import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:enreda_app/app/home/assistant/assistant_page_web.dart';
import 'package:enreda_app/app/home/cupertino_scaffold.dart';
import 'package:enreda_app/app/home/cupertino_scaffold_anonymous.dart';
import 'package:enreda_app/app/home/models/userEnreda.dart';
import 'package:enreda_app/app/home/models/userPoints.dart';
import 'package:enreda_app/app/home/web_home_scafold.dart';
import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/values/values.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'onboarding/onboarding_carusel.dart';

class HomePage extends StatefulWidget {
  static final textKey = GlobalKey<FormState>();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ValueNotifier<bool> showChatNotifier = ValueNotifier<bool>(false);
  late SharedPreferences _prefs;

  @override
  void dispose() {
    showChatNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: Provider.of<AuthBase>(context).authStateChanges(),
        builder: (context, snapshot) {
          return LayoutBuilder(builder: (context, constraints) {
            final isBigScreen = constraints.maxWidth >= 900;

            if (snapshot.hasData) {
              _initPrefs(snapshot.data!);
            }
            return Stack(
              children: [
                !snapshot.hasData && !kIsWeb
                    ? OnboardingCarrusel()
                    : isBigScreen
                        ? WebHomeScaffold(showChatNotifier: showChatNotifier)
                        : snapshot.hasData
                            ? CupertinoScaffold(
                                showChatNotifier: showChatNotifier)
                            : CupertinoScaffoldAnonymous(
                                showChatNotifier: showChatNotifier),
                if (snapshot.hasData && isBigScreen) _buildChatFAB(context),
                if (snapshot.hasData && isBigScreen) _buildChatContainer(),
              ],
            );
          });
        });
  }

  _initPrefs(User user) async {
    _prefs = await SharedPreferences.getInstance();

    int? lastOpenYear = _prefs.getInt('lastOpenYear');
    int? lastOpenMonth = _prefs.getInt('lastOpenMonth');
    int? lastOpenDay = _prefs.getInt('lastOpenDay');
    int? lastOpenHour = _prefs.getInt('lastOpenHour');
    DateTime now = DateTime.now();

    if (lastOpenYear == null || lastOpenMonth == null || lastOpenDay == null || lastOpenHour == null ||
        lastOpenYear != now.year || lastOpenMonth != now.month ||
        lastOpenDay != now.day || lastOpenHour != now.hour
    ) {
      _showPointsSnackbar(user);
    }

    _prefs.setInt('lastOpenYear', DateTime.now().year);
    _prefs.setInt('lastOpenMonth', DateTime.now().month);
    _prefs.setInt('lastOpenDay', DateTime.now().day);
    _prefs.setInt('lastOpenHour', DateTime.now().hour);
  }

  Future<void> _showPointsSnackbar(User user) async {
    final database = Provider.of<Database>(context, listen: false);
    final userEnreda = await database.userEnredaStreamByUserId(user.uid).first;
    final userPoints = await database.userPointsStreamById(UserPoints.ACCESS_ID).first;
    final snackBar = SnackBar(
      /// need to set following properties for best effect of awesome_snackbar_content
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: AwesomeSnackbarContent(
          title: "",
          message: userPoints.message,
          titleFontSize: 0.0,
          messageFontSize: 20.0,
          /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
          contentType: ContentType.success,
          color: Constants.turquoise,
        ),
      ),
    );

    await database.addPointsToUserEnreda(userEnreda, userPoints.points);

    ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(snackBar);
  }

  Widget _buildChatFAB(BuildContext context) {
    return ValueListenableBuilder<bool>(
        valueListenable: showChatNotifier,
        builder: (context, showChat, child) {
          return AnimatedPositioned(
            duration: Duration(seconds: 1),
            child: FloatingActionButton(
              foregroundColor: Constants.white,
              backgroundColor: Constants.penBlue,
              child: Image.asset(ImagePath.CHAT_ICON),
              onPressed: () {
                setState(() {
                  showChatNotifier.value = !showChatNotifier.value;
                });
              },
            ),
            right: Constants.mainPadding,
            bottom: showChat ? -120.0 : Constants.mainPadding,
          );
        });
  }

  Widget _buildChatContainer() {
    return ValueListenableBuilder<bool>(
        valueListenable: showChatNotifier,
        builder: (context, showChat, child) {
          return AnimatedPositioned(
            duration: Duration(seconds: 1),
            child: Container(
              clipBehavior: Clip.antiAlias,
              width: 400.0,
              height: 500.0,
              child: showChat
                  ? AssistantPageWeb(
                      onClose: (showSuccessMessage) {
                        setState(() {
                          showChatNotifier.value = !showChatNotifier.value;
                        });
                      },
                    )
                  : Container(),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(15),
                ),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.25), blurRadius: 4),
                ],
              ),
            ),
            right: Constants.mainPadding,
            bottom: showChat ? 50 : -800,
          );
        });
  }
}
