import 'package:enreda_app/app/home/account/account_page.dart';
import 'package:enreda_app/app/home/assistant/assistant_page_mobile.dart';
import 'package:enreda_app/app/home/competencies/competencies_page.dart';
import 'package:enreda_app/app/home/tab_item.dart';
import 'package:enreda_app/app/home/trainingPills/training_list_tile_mobile.dart';
import 'package:enreda_app/common_widgets/background_mobile.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/utils/functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'resources/pages/resources_page.dart';

class CupertinoScaffold extends StatefulWidget {
  const CupertinoScaffold({
    Key? key,
    required this.showChatNotifier,
  }) : super(key: key);

  final ValueNotifier<bool> showChatNotifier;
  static final controller = CupertinoTabController();

  @override
  State<CupertinoScaffold> createState() => _CupertinoScaffoldState();
}

class _CupertinoScaffoldState extends State<CupertinoScaffold> {
  @override
  Widget build(BuildContext context) {
    final tabItems = [
      TabItem.resources,
      TabItem.competencies,
      TabItem.chat,
      TabItem.account
    ];

    final Map<TabItem, WidgetBuilder> widgetBuilders = {
      TabItem.resources: (_) => Stack(
        children: [
          BackgroundMobile(backgroundHeight: BackgroundHeight.Small),
          ResourcesPage(),
        ],
      ),
      TabItem.competencies: (_) => Stack(
            children: [
              BackgroundMobileAccount(backgroundHeight: BackgroundHeight.Small),
              CompetenciesPage(
                showChatNotifier: widget.showChatNotifier,
              ),
            ],
          ),
      TabItem.chat: (_) => Stack(
            children: [
              BackgroundMobile(backgroundHeight: BackgroundHeight.Small),
              AssistantPageMobile(
                onFinish: (gamificationFlagName) {
                  if (gamificationFlagName.isNotEmpty){
                    setGamificationFlag(context: context, flagId: gamificationFlagName);
                  }
                },
              ),
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
      body: CupertinoTabScaffold(
        controller: CupertinoScaffold.controller,
        tabBar: CupertinoTabBar(
            inactiveColor: Constants.chatDarkGray,
            items: [
              _buildItem(TabItem.resources),
              _buildItem(TabItem.competencies),
              _buildItem(TabItem.chat),
              _buildItem(TabItem.account),
            ],
            height: TrainingPillsListTileMobile.isFullScreen.value == true ? 0 : 70,
            onTap: (index) {
              CupertinoScaffold.controller.index = index;
              if(index == 0){
                setState(() {
                  ResourcesPage.selectedIndex.value = 0;
                });
              }
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
}
