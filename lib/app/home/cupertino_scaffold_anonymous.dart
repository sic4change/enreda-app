import 'package:enreda_app/app/home/account/account_page.dart';
import 'package:enreda_app/app/home/competencies/competencies_page.dart';
import 'package:enreda_app/app/home/tab_item.dart';
import 'package:enreda_app/common_widgets/background_mobile.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'resources/pages/resources_page.dart';

class CupertinoScaffoldAnonymous extends StatelessWidget {
  const CupertinoScaffoldAnonymous({
    Key? key,
    required this.showChatNotifier,
  }) : super(key: key);

  final ValueNotifier<bool> showChatNotifier;

  static final controller = CupertinoTabController();

  @override
  Widget build(BuildContext context) {
    final tabItems = [TabItem.resources, TabItem.competencies, TabItem.account];

    Map<TabItem, WidgetBuilder> widgetBuilders = {
      TabItem.resources: (_) => ResourcesPage(),
      TabItem.competencies: (_) => Stack(
            children: [
              //BackgroundMobile(backgroundHeight: BackgroundHeight.Small),
              CompetenciesPage(
                showChatNotifier: showChatNotifier,
              ),
            ],
          ),
      TabItem.account: (_) => Stack(
            children: [
              //BackgroundMobile(backgroundHeight: BackgroundHeight.Small),
              AccountPage(),
            ],
          )
    };

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, 60),
        child: AppBar(
          title: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Image.asset(
              ImagePath.LOGO,
              height: 25.0,
              color: Colors.white,
            ),
          ),
          backgroundColor: Constants.turquoise,
          elevation: 0.0,
        ),
      ),
      body: CupertinoTabScaffold(
        controller: controller,
        tabBar: CupertinoTabBar(
            items: [
              _buildItem(TabItem.resources),
              _buildItem(TabItem.competencies),
              _buildItem(TabItem.account),
            ],
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
