import 'package:enreda_app/app/home/account/account_page.dart';
import 'package:enreda_app/app/home/assistant/assistant_page_mobile.dart';
import 'package:enreda_app/app/home/competencies/competencies_page.dart';
import 'package:enreda_app/app/home/cupertino_scaffold_anonymous.dart';
import 'package:enreda_app/app/home/tab_item.dart';
import 'package:enreda_app/common_widgets/background_mobile.dart';
import 'package:enreda_app/common_widgets/show_alert_dialog.dart';
import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'resources/pages/resources_page.dart';

class CupertinoScaffold extends StatelessWidget {
  const CupertinoScaffold({
    Key? key,
    required this.showChatNotifier,
  }) : super(key: key);

  final ValueNotifier<bool> showChatNotifier;
  static final controller = CupertinoTabController();

  @override
  Widget build(BuildContext context) {
    final tabItems = [
      TabItem.resources,
      TabItem.competencies,
      TabItem.chat,
      TabItem.account
    ];

    final Map<TabItem, WidgetBuilder> widgetBuilders = {
      TabItem.resources: (_) => ResourcesPage(),
      TabItem.competencies: (_) => Stack(
            children: [
              BackgroundMobileAccount(backgroundHeight: BackgroundHeight.Small),
              CompetenciesPage(
                showChatNotifier: showChatNotifier,
              ),
            ],
          ),
      TabItem.chat: (_) => Stack(
            children: [
              BackgroundMobile(backgroundHeight: BackgroundHeight.Small),
              AssistantPageMobile(),
            ],
          ),
      TabItem.account: (_) => Stack(
            children: [
              BackgroundMobileAccount(backgroundHeight: BackgroundHeight.Small),
              AccountPage(),
            ],
          )
    };

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, 80),
        child: AppBar(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20),
              Row(
                children: [
                  Image.asset(
                    ImagePath.LOGO_WHITE,
                    height: 30.0,
                  ),
                ],
              ),
            ],
          ),
          backgroundColor: Constants.turquoise,
          elevation: 0.0,
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    _confirmSignOut(context);
                    CupertinoScaffoldAnonymous.controller.index = 2;
                  },
                  child: Image.asset(
                    ImagePath.LOGOUT,
                    height: Sizes.ICON_SIZE_30,
                  ),),
                SizedBox(width: 20,)
              ],
            ),
          ],
        ),
      ),
      body: CupertinoTabScaffold(
        controller: controller,
        tabBar: CupertinoTabBar(
            inactiveColor: Constants.chatDarkGray,
            items: [
              _buildItem(TabItem.resources),
              _buildItem(TabItem.competencies),
              _buildItem(TabItem.chat),
              _buildItem(TabItem.account),
            ],
            height: 70,
            onTap: (index) {
              controller.index = index;
            }),
        tabBuilder: (context, index) {
          final item = tabItems[index];
          return CupertinoTabView(
            builder: (context) {
              return widgetBuilders[item]!(context);
            },
          );
        },
      ),
    );
  }

  BottomNavigationBarItem _buildItem(TabItem tabItem) {
    final itemData = TabItemData.allTabs[tabItem]!;
    return BottomNavigationBarItem(
      icon: Icon(
        itemData.icon,
      ),
      label: itemData.title,
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final didRequestSignOut = await showAlertDialog(context,
        title: 'Cerrar sesión',
        content: '¿Estás seguro que quieres cerrar sesión?',
        cancelActionText: 'Cancelar',
        defaultActionText: 'Cerrar');
    if (didRequestSignOut == true) {
      final auth = Provider.of<AuthBase>(context, listen: false);
      await auth.signOut();
    }
  }
}
