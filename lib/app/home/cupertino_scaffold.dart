import 'package:enreda_app/app/home/web_home.dart';
import 'package:enreda_app/app/home/assistant/assistant_page_mobile.dart';
import 'package:enreda_app/app/home/competencies/competencies_page.dart';
import 'package:enreda_app/app/home/tab_item.dart';
import 'package:enreda_app/app/home/trainingPills/training_list_tile_mobile.dart';
import 'package:enreda_app/common_widgets/background_mobile.dart';
import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/utils/functions.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../common_widgets/show_alert_dialog.dart';
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
  final _key = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
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
              WebHome(showChatNotifier: widget.showChatNotifier,),
            ],
          )
    };

    return Scaffold(
      key: _key,
      appBar: isSmallScreen ? AppBar(
        toolbarHeight: 80,
        elevation: 0.4,
        backgroundColor: AppColors.white,
        leading: isSmallScreen ? IconButton(
          onPressed: () {
            _key.currentState?.openDrawer();
          },
          icon: const Icon(Icons.menu),
        ) : Container(),
        title: Transform(
          transform:  Responsive.isMobile(context) ? Matrix4.translationValues(0.0, 0.0, 0.0) : Matrix4.translationValues(-40.0, 0.0, 0.0),
          child: Row(
            children: [
              Image.asset(
                ImagePath.LOGO,
                height: 35,
              ),
            ],
          ),
        ),
        actions: <Widget>[
          const SizedBox(width: 15),
          SizedBox(
            width: 35,
            child: InkWell(
              onTap: () => _confirmSignOut(context),
              child: Image.asset(
                ImagePath.LOGOUT,
                height: Sizes.ICON_SIZE_30,
              ),),
          ),
          const SizedBox(width: 10,)
        ],
      ) : null,
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