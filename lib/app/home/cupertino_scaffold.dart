import 'package:enreda_app/app/home/models/city.dart';
import 'package:enreda_app/app/home/models/country.dart';
import 'package:enreda_app/app/home/models/province.dart';
import 'package:enreda_app/app/home/models/userEnreda.dart';
import 'package:enreda_app/app/home/web_home.dart';
import 'package:enreda_app/app/home/assistant/assistant_page_mobile.dart';
import 'package:enreda_app/app/home/competencies/competencies_page.dart';
import 'package:enreda_app/app/home/tab_item.dart';
import 'package:enreda_app/app/home/trainingPills/training_list_tile_mobile.dart';
import 'package:enreda_app/common_widgets/background_mobile.dart';
import 'package:enreda_app/common_widgets/custom_text.dart';
import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/utils/functions.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../common_widgets/show_alert_dialog.dart';
import '../../common_widgets/spaces.dart';
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
  late TextTheme textTheme;
  String _userName = "";
  late UserEnreda _userEnreda;

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
                  return Row(
                    children: [
                      _buildMyUserPhoto(context, _userEnreda.profilePic!.src),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTextBold(title: _userName),
                            _buildMyLocation(context, _userEnreda)
                          ],
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
      appBar: AppBar(
        toolbarHeight: 80,
        elevation: 0.4,
        shadowColor: AppColors.bluePetrol,
        backgroundColor: AppColors.white,
        title: Transform(
          transform:  Matrix4.translationValues(10.0, 0.0, 0.0),
          child: Row(
            children: [
              _buildMyUserName(context),
            ],
          ),
        ),
        // actions: <Widget>[
        //   const SizedBox(width: 15),
        //   SizedBox(
        //     width: 35,
        //     child: InkWell(
        //       onTap: () => _confirmSignOut(context),
        //       child: Image.asset(
        //         ImagePath.LOGOUT,
        //         height: Sizes.ICON_SIZE_30,
        //       ),),
        //   ),
        //   const SizedBox(width: 10,)
        // ],
      ),
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

  Widget _buildMyUserPhoto(BuildContext context, String profilePic) {
    return InkWell(
      onTap: () {
        setState(() {
          CupertinoScaffold.controller.index = 3;
          WebHome.controller.selectIndex(2);
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              !kIsWeb ?
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(60)),
                child:
                Center(
                  child:
                  profilePic == "" ?
                  Container(
                    color:  Colors.transparent,
                    height: 40,
                    width: 40,
                    child: Image.asset(ImagePath.USER_DEFAULT),
                  ) :
                  Image.network(
                    profilePic,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                ),
              ) :
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(60)),
                child:
                profilePic == "" ?
                Container(
                  color:  Colors.transparent,
                  height: 40,
                  width: 40,
                  child: Image.asset(ImagePath.USER_DEFAULT),
                ) :
                Container(
                  child: FadeInImage.assetNetwork(
                    image: profilePic,
                    placeholder: ImagePath.USER_DEFAULT,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

}

Widget _buildMyLocation(BuildContext context, UserEnreda? user) {
  final database = Provider.of<Database>(context, listen: false);
  Country? myCountry;
  Province? myProvince;
  City? myCity;
  String? city;
  String? province;
  String? country;

  return StreamBuilder<Country>(
      stream: database.countryStream(user?.address?.country),
      builder: (context, snapshot) {
        myCountry = snapshot.data;
        return StreamBuilder<Province>(
            stream: database.provinceStream(user?.address?.province),
            builder: (context, snapshot) {
              myProvince = snapshot.data;

              return StreamBuilder<City>(
                  stream: database.cityStream(user?.address?.city),
                  builder: (context, snapshot) {
                    myCity = snapshot.data;
                    city = '${myCity?.name ?? ''}';
                    province = '${myProvince?.name ?? ''}';
                    country = '${myCountry?.name ?? ''}';

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.black.withOpacity(0.7),
                          size: 16,
                        ),
                        SpaceW4(),
                        CustomTextNormalSmall(title: province ?? ''),
                      ],
                    );
                  });
            });
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