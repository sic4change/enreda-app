import 'package:enreda_app/app/anallytics/analytics.dart';
import 'package:enreda_app/app/home/assistant/assistant_page_web.dart';
import 'package:enreda_app/app/home/web_home.dart';
import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/utils/functions.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/values.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'onboarding/onboarding_carusel.dart';

class HomePage extends StatefulWidget {
  static final textKey = GlobalKey<FormState>();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ValueNotifier<bool> showChatNotifier = ValueNotifier<bool>(false);


  @override
  void dispose() {
    showChatNotifier.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    sendBasicAnalyticsEvent(context, "enreda_app_visit_home_page");
    return StreamBuilder<User?>(
        stream: Provider.of<AuthBase>(context).authStateChanges(),
        builder: (context, snapshot) {
          return LayoutBuilder(builder: (context, constraints) {
            return !snapshot.hasData && !kIsWeb
                ? OnboardingCarrusel()
                : Stack(
                  children: [
                    WebHome(showChatNotifier: showChatNotifier),
                    if (snapshot.hasData) _buildChatFAB(context),
                    if (snapshot.hasData) _buildChatContainer(),
                  ],
                );
          });
        });
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
                showChatNotifier.value = !showChatNotifier.value; // Optimizado sin setState
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
            right: Constants.mainPadding,
            bottom: showChat ? 50 : -800,
            child: Visibility(
              visible: showChat,
              maintainState: true,
              maintainAnimation: true,
              child: Container(
                clipBehavior: Clip.antiAlias,
                width: Responsive.isMobile(context) ? 300.0 : 400.0,
                height: 500.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 4),
                  ],
                ),
                child: showChat ? AssistantPageWeb(
                  onClose: (showSuccessMessage, gamificationFlagName) {
                    showChatNotifier.value = !showChatNotifier.value;
                    if (gamificationFlagName.isNotEmpty) {
                      setGamificationFlag(context: context, flagId: gamificationFlagName);
                    }
                  },
                ) : SizedBox.shrink(),
              ),
            ),
          );
        }
    );
  }
  
}
