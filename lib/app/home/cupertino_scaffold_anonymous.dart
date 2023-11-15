import 'package:enreda_app/app/home/account/account_page.dart';
import 'package:enreda_app/app/home/competencies/competencies_page.dart';
import 'package:enreda_app/app/home/tab_item.dart';
import 'package:enreda_app/common_widgets/background_mobile.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'resources/pages/resources_page.dart';

class CupertinoScaffoldAnonymous extends StatefulWidget {
  const CupertinoScaffoldAnonymous({
    Key? key,
    required this.showChatNotifier,
  }) : super(key: key);

  final ValueNotifier<bool> showChatNotifier;

  static final controller = CupertinoTabController();

  @override
  State<CupertinoScaffoldAnonymous> createState() => _CupertinoScaffoldAnonymousState();
}

class _CupertinoScaffoldAnonymousState extends State<CupertinoScaffoldAnonymous> {
  @override
  Widget build(BuildContext context) {
    final tabItems = [TabItem.resources, TabItem.competencies, TabItem.account];

    Map<TabItem, WidgetBuilder> widgetBuilders = {
      TabItem.resources: (_) => Stack(
        children: [
          BackgroundMobile(backgroundHeight: BackgroundHeight.Small),
          ResourcesPage(),
        ],
      ),
      TabItem.competencies: (_) => Stack(
            children: [
              BackgroundMobile(backgroundHeight: BackgroundHeight.Small),
              CompetenciesPage(
                showChatNotifier: widget.showChatNotifier,
              ),
            ],
          ),
      TabItem.account: (_) => Stack(
            children: [
              BackgroundMobile(backgroundHeight: BackgroundHeight.Small),
              AccountPage(),
            ],
          )
    };

    return Scaffold(
      body: CupertinoTabScaffold(
        backgroundColor: Colors.transparent,
        controller: CupertinoScaffoldAnonymous.controller,
        tabBar: CupertinoTabBar(
            items: [
              _buildItem(TabItem.resources),
              _buildItem(TabItem.competencies),
              _buildItem(TabItem.account),
            ],
            onTap: (index) {
              CupertinoScaffoldAnonymous.controller.index = index;
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
    //final color = currentTab == tabItem ? Colors.indigo : Colors.grey;
    return BottomNavigationBarItem(
      icon: Icon(
        itemData.icon,
        //color: color,
      ),
      label: itemData.title,
    );
  }
}
