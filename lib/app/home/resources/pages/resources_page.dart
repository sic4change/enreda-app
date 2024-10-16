import 'dart:math';

import 'package:enreda_app/app/home/models/city.dart';
import 'package:enreda_app/app/home/models/country.dart';
import 'package:enreda_app/app/home/models/filterResource.dart';
import 'package:enreda_app/app/home/models/filterTrainingPills.dart';
import 'package:enreda_app/app/home/models/organization.dart';
import 'package:enreda_app/app/home/models/province.dart';
import 'package:enreda_app/app/home/models/resource.dart';
import 'package:enreda_app/app/home/models/resourceCategory.dart';
import 'package:enreda_app/app/home/models/trainingPill.dart';
import 'package:enreda_app/app/home/models/userEnreda.dart';
import 'package:enreda_app/app/home/resources/filter_text_field_row.dart';
import 'package:enreda_app/app/home/resources/list_item_builder_grid.dart';
import 'package:enreda_app/app/home/resources/pages/list_item_builder_vertical.dart';
import 'package:enreda_app/app/home/resources/resource_detail/resource_detail_page.dart';
import 'package:enreda_app/app/home/resources/resource_list_tile.dart';
import 'package:enreda_app/app/home/trainingPills/training_list_tile_mobile.dart';
import 'package:enreda_app/app/home/trainingPills/training_list_tile.dart';
import 'package:enreda_app/app/sign_in/sign_out_admin.dart';
import 'package:enreda_app/common_widgets/custom_person_pill_image.dart';
import 'package:enreda_app/common_widgets/custom_text.dart';
import 'package:enreda_app/common_widgets/show_alert_dialog.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';
import 'package:enreda_app/app/home/resources/global.dart' as globals;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../../../utils/functions.dart';
import '../../models/company.dart';
import '../../models/socialEntity.dart';

class ResourcesPage extends StatefulWidget {
  ResourcesPage({Key? key})
      : super(key: key);

  @override
  State<ResourcesPage> createState() => _ResourcesPageState();

  String _message = '';
  bool _errorNotValidUser = false;
  static ValueNotifier<int> selectedIndex = ValueNotifier(0);
}

class _ResourcesPageState extends State<ResourcesPage> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final _searchTextController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  late SharedPreferences _prefs;
  double _scrollPosition = 0;
  FilterResource filterResource = FilterResource("", "");
  FilterTrainingPill filterTrainingPill = FilterTrainingPill("", "");
  bool isAlertBoxOpened = false;
  List<ResourceCategory> resourceCategoriesList = [];
  String _categoryName = 'Empleo';
  String _categoryFormationId = '';
  String _backgroundImageUrl(String categoryId) {
    Map<String, String> backgroundImages = {
      "6ag9Px7zkFpHgRe17PQk": ImagePath.BACKGROUND_2,
      "FNAcayruXghBMjj3RD9h": ImagePath.BACKGROUND_6,
      "LNj2FMTEBsNtBYCRo0MQ": ImagePath.BACKGROUND_4,
      "POUBGFk5gU6c5X1DKo1b": ImagePath.BACKGROUND_1,
      "PlaaW4L4Z36Wu1V6HuBa": ImagePath.BACKGROUND_3,
      "zVusrwQkVoAca9R6iuQo": ImagePath.BACKGROUND_5,
    };
    return backgroundImages[categoryId] ?? "";
  }
  String _personImageUrl(String categoryId) {
    Map<String, String> personImages = {
      "6ag9Px7zkFpHgRe17PQk": ImagePath.PERSON_2,
      "FNAcayruXghBMjj3RD9h": ImagePath.PERSON_6,
      "LNj2FMTEBsNtBYCRo0MQ": ImagePath.PERSON_4,
      "POUBGFk5gU6c5X1DKo1b": ImagePath.PERSON_1,
      "PlaaW4L4Z36Wu1V6HuBa": ImagePath.PERSON_3,
      "zVusrwQkVoAca9R6iuQo": ImagePath.PERSON_5,
    };
    return personImages[categoryId] ?? "";
  }

  var bodyWidget = [];

  Map<String, YoutubePlayerController> _controllers = {};

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  _register(UserEnreda user) {
    if (!kIsWeb) {
      _firebaseMessaging.subscribeToTopic('weeknotification');
      _firebaseMessaging.unsubscribeFromTopic(user.userId!);
      _firebaseMessaging.subscribeToTopic(user.userId!);
      _firebaseMessaging.getToken().then((token) => print('token: $token'));
    }
  }

  getResourceCategories() {
    final database = Provider.of<Database>(context, listen: false);
    database.getCategoriesResources().listen((categoriesList) {
      setStateIfMounted(() => resourceCategoriesList = categoriesList);
    });
  }

  void getMessage() {
    if (!kIsWeb) {
      FirebaseMessaging.onMessage.listen((message) {
        print('on message $message');
        setStateIfMounted(() {
          if (message.notification != null)
            widget._message = message.notification!.title ?? '';
        });
      });

      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        print('on resume $message');
        setStateIfMounted(() {
          if (message.notification != null)
            widget._message = message.notification!.title ?? '';
        });

        if (message.data["resourceId"] != null) {
          context.push(
              '${StringConst.PATH_RESOURCES}/${message.data["resourceId"]}');
          /**
              Navigator.of(context).push(
              MaterialPageRoute<void>(
              fullscreenDialog: true,
              builder: (context) =>  ResourceDetailNotificationPage(
              resource: message.data["resourceId"]),
              ),
              );
           */
        }
      });
      _firebaseMessaging.requestPermission(
          sound: true, badge: true, alert: true);
      _firebaseMessaging.getToken().then((token) {
        if (token != null) print('Token: ' + token);
      });
    }
  }

  void _loadPillControllers() async {
    final database = Provider.of<Database>(context, listen: false);
    final trainingPills = await database.filteredTrainingPillStream(filterTrainingPill).first;
    trainingPills.forEach((pill) {
      _controllers[pill.id] = YoutubePlayerController(
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
        ),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _loadScrollPosition();
    getMessage();
    getResourceCategories();
    _loadPillControllers();
  }


  @override
  void dispose() {
    _searchTextController.dispose();
    _scrollController.dispose();
    _controllers.values.forEach((c) => c.close());
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    bodyWidget = [
      _buildResourcesPage(context),
      _buildFilteredResourcesPage(context),
      _buildTrainingPills(context),
      _buildResourceDetail(context),
    ];

    return ValueListenableBuilder<int>(
        valueListenable: ResourcesPage.selectedIndex,
        builder: (context, selectedIndex, child) {
          return Scaffold(
            body: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: bodyWidget[selectedIndex],
            ),
          );
        });
  }


  Widget _buildResourcesPage(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return SingleChildScrollView(
        child: Column(
          children: [
            Column(
              children: [
                Responsive.isMobile(context) ? SpaceH12() : SpaceH50(),
                Text( StringConst.SEARCH, style: textTheme.titleSmall?.copyWith(
                  color: AppColors.greyAlt,
                  height: 1.5,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w700,
                  fontSize: Responsive.isMobile(context) ? 20 : 25,
                  //fontSize: fontSize,
                ),),
                Responsive.isMobile(context) ? SpaceH8() : SpaceH20(),
                Container(
                  alignment: Alignment.center,
                  padding: Responsive.isMobile(context) ?  EdgeInsets.symmetric(horizontal: 30) : EdgeInsets.symmetric(horizontal: 100.0),
                  child: Text(
                    Responsive.isMobile(context) ? StringConst.SEARCH_SUBTITLE_MOBILE : StringConst.SEARCH_SUBTITLE,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: Responsive.isMobile(context) ? 13.0 : 16.0,
                    ),
                  ),
                ),
                SpaceH20(),
                _buildCategories(context, resourceCategoriesList),
                SpaceH30(),
              ],
            ),
            _buildTrainingPillsButton(context)
          ],
        ));
  }

  Widget _buildTrainingPillsButton(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      margin: Responsive.isMobile(context)
          ? EdgeInsets.symmetric(horizontal: 30, vertical: 20)
          : Responsive.isDesktopS(context)
          ? EdgeInsets.symmetric(horizontal: 30)
          : EdgeInsets.symmetric(horizontal: 100),
      height: Responsive.isMobile(context) ? 380 : Responsive.isDesktopS(context) ? 550 : 450,
      child: Stack(
        alignment: Responsive.isMobile(context) ? Alignment.topCenter : Alignment.center,
        children: [
          InkWell(
            onTap: () {
              setStateIfMounted(() {
                ResourcesPage.selectedIndex.value = 2;
              });
            },
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      margin: Responsive.isDesktop(context) ? EdgeInsets.only(top: 25) : EdgeInsets.only(top: 0),
                      height: Responsive.isMobile(context) ? 220 : Responsive.isDesktopS(context) ? 380 : 280,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage(ImagePath.BACKGROUND_PILLS),
                          )
                      ),
                    ),
                    Responsive.isDesktop(context) ? Positioned(
                      left: Responsive.isDesktopS(context) ? 50 : 100,
                      child: Container(
                        constraints:  BoxConstraints(
                          maxWidth: 400
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(StringConst.PILLS_TITLE,
                              style: textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                letterSpacing: 1,
                                fontSize: Responsive.isMobile(context) ? 15 : Responsive.isDesktopS(context) ? 25 : 34,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SpaceH8(),
                            Text(StringConst.PILLS_SUBTITLE, style: textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              letterSpacing: 1,
                              fontSize: Responsive.isMobile(context) ? 12 : Responsive.isDesktopS(context) ? 15 : 18,
                             ),),
                          ],
                        ),
                      ),
                    ) : Positioned(
                      top: 0,
                      child: Container(
                        constraints:  BoxConstraints(
                            maxWidth: Responsive.isMobile(context) ? 280 : 400
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 30.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: Responsive.isDesktop(context) ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                            children: [
                              Text(StringConst.PILLS_TITLE,
                                style: textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  letterSpacing: 1,
                                  fontSize: Responsive.isMobile(context) ? 15 : Responsive.isDesktopS(context) ? 25 : 34,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              SpaceH8(),
                              Text(StringConst.PILLS_SUBTITLE,
                                textAlign: Responsive.isDesktop(context) ? TextAlign.left : TextAlign.center,
                                style: textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                letterSpacing: 1,
                                fontSize: Responsive.isMobile(context) ? 12 : Responsive.isDesktopS(context) ? 15 : 18,
                              ),),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Responsive.isDesktop(context) ? Positioned(
                      bottom: 0,
                      left: constraints.maxWidth * 0.45,
                      child: CustomPersonPillImage(
                        personPillImagePath: ImagePath.PERSON_PILL1,
                        height: Responsive.isMobile(context) ? 100 : Responsive.isDesktopS(context) ? 220 : 280,),
                    ) : Positioned(
                      bottom: 0,
                      left: MediaQuery.of(context).size.width * 0.1,
                      child: CustomPersonPillImage(
                        personPillImagePath: ImagePath.PERSON_PILL1,
                        height: Responsive.isMobile(context) ? 100 : Responsive.isDesktopS(context) ? 220 : 280,),
                    ),
                    Responsive.isDesktop(context) ? Positioned(
                      bottom: 0,
                      left: constraints.maxWidth * 0.8,
                      child: CustomPersonPillImage(
                        personPillImagePath: ImagePath.PERSON_PILL3,
                        height: Responsive.isMobile(context) ? 100 : Responsive.isDesktopS(context) ? 220 : 290,),
                    ) : Positioned(
                      bottom: 0,
                      right: MediaQuery.of(context).size.width * 0.1,
                      child: CustomPersonPillImage(
                        personPillImagePath: ImagePath.PERSON_PILL3,
                        height: Responsive.isMobile(context) ? 100 : Responsive.isDesktopS(context) ? 220 : 290,),
                    ),
                    Responsive.isDesktop(context) ? Positioned(
                      bottom: 0,
                      left: constraints.maxWidth * 0.6,
                      child: CustomPersonPillImage(
                        personPillImagePath: ImagePath.PERSON_PILL2,
                        height: Responsive.isMobile(context) ? 120 : Responsive.isDesktopS(context) ? 280 : 350,),
                    ) : Positioned(
                      bottom: 0,
                      right: 0,
                      left: 0,
                      child: CustomPersonPillImage(
                          personPillImagePath: ImagePath.PERSON_PILL2,
                          height: Responsive.isMobile(context) ? 120 : Responsive.isDesktopS(context) ? 280 : 350),
                    ),
                  ],
                );
              }
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilteredResourcesPage(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    final isBigScreen = Responsive.isDesktop(context);
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 20.0),
          child: Column(
            children: [
              Padding(
                padding: Responsive.isMobile(context)
                    ? EdgeInsets.symmetric(horizontal: 15)
                    : Responsive.isDesktopS(context)
                    ? EdgeInsets.symmetric(horizontal: 30)
                    : EdgeInsets.symmetric(horizontal: 100),
                child: InkWell(
                  onTap: () {
                    setStateIfMounted(() {
                      ResourcesPage.selectedIndex.value = 0;
                      _clearFilter();
                      _clearScrollPosition();
                    });
                  },
                  child: Row(
                    children: [
                      Image.asset(ImagePath.ARROW_B, height: 30),
                      Spacer(),
                      CustomTextMediumBold(text: _categoryName),
                      Spacer(),
                      SizedBox(width: 30),
                    ],
                  ),
                ),
              ),
              SpaceH12(),
              FilterTextFieldRow(
                searchTextController: _searchTextController,
                onPressed: () => setStateIfMounted(() {
                  filterResource.searchText = _searchTextController.text;
                }),
                onFieldSubmitted: (value) => setStateIfMounted(() {
                  filterResource.searchText = _searchTextController.text;
                }),
                clearFilter: () => _clearFilter(),
                hintText: 'Nombre del recurso, organizador, país...',
              ),
              SpaceH20(),
              _categoryFormationId == "6ag9Px7zkFpHgRe17PQk" ?
              Padding(
                padding: const EdgeInsets.only(bottom: 18.0),
                child: Stack(
                  children: [
                    Padding(
                      padding: Responsive.isMobile(context)
                          ? EdgeInsets.symmetric(horizontal: 20)
                          : Responsive.isDesktopS(context)
                          ? EdgeInsets.symmetric(horizontal: 30)
                          : EdgeInsets.symmetric(horizontal: 100),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () => launchURL(StringConst.WEB_FUNDAULA_ACCESS),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  stops: [0.6, 1,],
                                  colors: [
                                    AppColors.lightPurple,
                                    AppColors.ultraLightPurple,
                                  ],
                                ),
                                color: AppColors.lightPurple,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.darkPurple,
                                    offset: Offset(8.0, -8.0),
                                    blurRadius: 0.0,
                                  ),
                                ],
                              ),
                              padding: Responsive.isMobile(context)
                                  ? EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 8.0)
                                      : EdgeInsets.symmetric(
                                          horizontal: 30.0, vertical: 15.0),
                              child: Row(
                                children: [
                                      Expanded(
                                        child: Text(
                                          StringConst.FUNDAULA_BUTTON,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 3,
                                          style: textTheme.bodySmall?.copyWith(
                                          color: Colors.white,
                                          height: 1.5,
                                          letterSpacing: 1,
                                          fontSize: Responsive.isMobile(context) ? 10 : Responsive.isDesktopS(context) ? 14 : 16,
                                          fontWeight: FontWeight.w600,
                                        )),
                                      ),
                                      SpaceW8(),
                                      Image.asset(ImagePath.LOGO_FUNDAULA, height: isBigScreen ? 30 : Responsive.isMobile(context) ? 20 : 25,),
                                      isBigScreen ? SpaceW30() : SpaceW24(),
                                  ],
                                ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                        right: isBigScreen ? 120 : 25,
                        bottom: 0,
                        child: Image.asset(ImagePath.ICON_CLICK_FUNDAULA, height: isBigScreen ? 40 : 30,)),
                  ],
                ),
              ) : Container(),
            ],
          ),
        ),
        Container(
          margin: _categoryFormationId == "6ag9Px7zkFpHgRe17PQk"
              ? EdgeInsets.only(top: 230.0)
              : EdgeInsets.only(top: 120.0),
          child: _buildContents(context),
        ),
      ],
    );
  }

  Widget _buildTrainingPills(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 20.0),
          child: Column(
            children: [
              Padding(
                padding: Responsive.isMobile(context)
                    ? EdgeInsets.symmetric(horizontal: 15)
                    : Responsive.isDesktopS(context)
                    ? EdgeInsets.symmetric(horizontal: 30)
                    : EdgeInsets.symmetric(horizontal: 100),
                child: InkWell(
                  onTap: () {
                    setStateIfMounted(() {
                      ResourcesPage.selectedIndex.value = 0;
                      _clearFilter();
                    });
                  },
                  child: Row(
                    children: [
                      Image.asset(ImagePath.ARROW_B, height: 30),
                      Spacer(),
                      CustomTextMediumBold(text: 'Píldoras formativas'),
                      Spacer(),
                      SizedBox(width: 30),
                    ],
                  ),
                ),
              ),
              SpaceH12(),
              FilterTextFieldRow(
                searchTextController: _searchTextController,
                onPressed: () => setStateIfMounted(() {
                  filterTrainingPill.searchText = _searchTextController.text;
                }),
                onFieldSubmitted: (value) => setStateIfMounted(() {
                  filterTrainingPill.searchText = _searchTextController.text;
                }),
                clearFilter: () => _clearFilter(),
                hintText: 'Nombre del video, categoría...',
              ),
            ],
          ),
        ),
        Container(
            margin: !kIsWeb ? EdgeInsets.only(top: 120.0) : EdgeInsets.only(top: 120.0),
            child: Responsive.isMobile(context) || Responsive.isMobileHorizontal(context) ?
            _buildTrainingPillsListMobile(context)
                : _buildTrainingPillsList(context)),
      ],
    );
  }

  Widget _buildCategories(BuildContext context, List<ResourceCategory> resourceCategories) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return GridView.builder(
      padding: Responsive.isMobile(context)
          ? EdgeInsets.symmetric(horizontal: 30)
          : Responsive.isDesktopS(context)
              ? EdgeInsets.symmetric(horizontal: 30, vertical: 30)
              : EdgeInsets.symmetric(horizontal: 100, vertical: 30),
      shrinkWrap: true,
      itemCount: resourceCategories.length,
      scrollDirection: Axis.vertical,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: Responsive.isMobile(context) ? 280 : 520,
          mainAxisExtent: Responsive.isMobile(context) ? 120 : 450,
          crossAxisSpacing: Responsive.isMobile(context) ? 15 : 30,
          mainAxisSpacing: Responsive.isMobile(context) ? 15 : 30
      ),
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            setStateIfMounted(() {
              filterResource.resourceCategoryId = (resourceCategories[index].id);
              ResourcesPage.selectedIndex.value = 1;
              _categoryName = resourceCategories[index].name;
              _categoryFormationId = resourceCategories[index].id;
              _clearScrollPosition();
            });
          },
          child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(_backgroundImageUrl(resourceCategories[index].id)),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Positioned(
                    top: 0,
                    child: Padding(
                      padding: Responsive.isMobile(context) ? EdgeInsets.only(top: 10.0) : EdgeInsets.only(top: 25.0),
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: Responsive.isMobile(context) ? 150 : 300,
                        ),
                        child: Text(resourceCategories[index].name,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          letterSpacing: 1,
                          fontSize: Responsive.isMobile(context) ? 15 : Responsive.isDesktopS(context) ? 25 : 34,
                          fontWeight: FontWeight.w900,
                        ),),
                      ),
                    ),
                  ),
                  Padding(
                    padding: Responsive.isMobile(context) ? EdgeInsets.only(top: 35.0) : EdgeInsets.only(top: 60),
                    child: Image.asset(_personImageUrl(resourceCategories[index].id)),
                  ),
                ],
              ),
          ),
        );
      },
    );
  }

  Widget _buildTrainingPillsList(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);

    return Container(
      padding: Responsive.isMobile(context)
          ? EdgeInsets.symmetric(horizontal: 10)
          : Responsive.isDesktopS(context)
          ? EdgeInsets.symmetric(horizontal: 20, vertical: 30)
          : EdgeInsets.symmetric(horizontal: 100, vertical: 30),
      child: StreamBuilder<List<TrainingPill>>(
          stream: database.filteredTrainingPillStream(filterTrainingPill),
          builder: (context, snapshot) {
            double? mainAxisExtentValue;
            double? maxCrossAxisExtentValue;
            bool showDescription = true;
            if (snapshot.hasData && snapshot.data!.where((t) => t.description.isNotEmpty).length == 0) {
              mainAxisExtentValue = Responsive.isDesktopS(context) ? 310 : 400;
              maxCrossAxisExtentValue = Responsive.isDesktopS(context) ? 350 : 490;
              showDescription = false;

              return ListItemBuilderGrid<TrainingPill>(
                  scrollController: ScrollController(),
                  snapshot: snapshot,
                  maxCrossAxisExtentValue: maxCrossAxisExtentValue,
                  mainAxisExtentValue: mainAxisExtentValue,
                  itemBuilder: (context, trainingPill) {
                    trainingPill.setTrainingPillCategoryName();
                    return Container(
                      key: Key('trainingPill-${trainingPill.id}'),
                      child: TrainingPillListTile(
                        trainingPill: trainingPill,
                        showDescription: showDescription,
                        controller: _controllers[trainingPill.id]!,
                        pauseOthers: _pauseOthers,
                      ),
                    );
                  }
              );
            }

            return Center(child: CircularProgressIndicator(),);

          }),
    );
  }

  void _pauseOthers(String pillId) {
    for (var key in _controllers.keys) {
      if (key != pillId) {
        _controllers[key]!.pauseVideo();
      }
    }
  }

  Widget _buildTrainingPillsListMobile(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: StreamBuilder<List<TrainingPill>>(
            stream: database.filteredTrainingPillStream(filterTrainingPill),
            builder: (context, snapshot) {
              return ListItemBuilderVertical<TrainingPill>(
                  snapshot: snapshot,
                  itemBuilder: (context, trainingPill) {
                    trainingPill.setTrainingPillCategoryName();
                    return Container(
                      key: Key('trainingPill-${trainingPill.id}'),
                      child: Column(
                        children: [
                          TrainingPillsListTileMobile(
                            trainingPill: trainingPill,
                            onTap: () => context.push(
                                '${StringConst.PATH_TRAINING_PILLS}/${trainingPill.id}'),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Divider(thickness: 1, color: AppColors.blue050,),
                          ),
                        ],
                      ),
                    );
                  },
                emptyTitle: 'Sin píldoras formativas',
                emptyMessage: 'No tenemos videos que mostrarte con la búsqueda',
              );
            }),
      ),
    );
  }

  Widget _buildContents(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    final database = Provider.of<Database>(context, listen: false);
    if (auth.currentUser == null) {
      return Container(
        padding: Responsive.isMobile(context)
            ? EdgeInsets.symmetric(horizontal: 10)
            : Responsive.isDesktopS(context)
            ? EdgeInsets.symmetric(horizontal: 20, vertical: 30)
            : EdgeInsets.symmetric(horizontal: 100, vertical: 30),
        child: StreamBuilder<List<Resource>>(
            stream: database.filteredResourcesCategoryStream(filterResource),
            builder: (context, snapshot) {
              return StreamBuilder<List<Resource>>(
                  stream: database.filteredResourcesCategoryStream(filterResource),
                  builder: (context, snapshot) {
                    return ListItemBuilderGrid<Resource>(
                      scrollController: _scrollController,
                      snapshot: snapshot,
                      itemBuilder: (context, resource) {
                        return StreamBuilder(
                          stream: resource.organizerType == 'Organización' ? database.organizationStream(resource.organizer) :
                          resource.organizerType == 'Entidad Social' ? database.socialEntityStream(resource.organizer)
                              : resource.organizerType == 'Empresa' ? database.companyStream(resource.organizer) :
                          database.mentorStream(resource.organizer),
                          builder: (context, snapshotOrganizer) {
                            if (snapshotOrganizer.hasData) {
                              if (snapshotOrganizer.data is Organization) {
                                final organization = snapshotOrganizer.data as Organization;
                                resource.organizerName = organization.name;
                                resource.organizerImage = organization.photo;
                              } else if (snapshotOrganizer.data is SocialEntity) {
                                final organization = snapshotOrganizer.data as SocialEntity;
                                resource.organizerName = organization.name;
                                resource.organizerImage = organization.photo;
                              } else if (snapshotOrganizer.data is Company) {
                                final organization = snapshotOrganizer.data as Company;
                                resource.organizerName = organization.name;
                                resource.organizerImage = organization.photo;
                              } else {
                                final mentor = snapshotOrganizer.data as UserEnreda;
                                resource.organizerName = '${mentor.firstName} ${mentor.lastName} ';
                                resource.organizerImage = mentor.photo;
                              }
                              resource.setResourceTypeName();
                              resource.setResourceCategoryName();
                            }
                            return StreamBuilder<Country>(
                                stream: database.countryStream(resource.country),
                                builder: (context, snapshot) {
                                  final country = snapshot.data;
                                  resource.countryName =
                                  country == null ? '' : country.name;
                                  return StreamBuilder<Province>(
                                    stream: database
                                        .provinceStream(resource.province),
                                    builder: (context, snapshot) {
                                      final province = snapshot.data;
                                      resource.provinceName = province == null
                                          ? ''
                                          : province.name;
                                      return StreamBuilder<City>(
                                          stream: database
                                              .cityStream(resource.city),
                                          builder: (context, snapshot) {
                                            final city = snapshot.data;
                                            resource.cityName =
                                            city == null ? '' : city.name;
                                            return Container(
                                              key: Key(
                                                  'resource-${resource.resourceId}'),
                                              child: ResourceListTile(
                                                resource: resource,
                                                onTap: () {
                                                  _saveScrollPosition();
                                                  setState(() {
                                                    globals.currentResource = resource;
                                                    ResourcesPage.selectedIndex.value = 3;
                                                  });
                                                },
                                              ),
                                            );
                                          });
                                    },
                                  );
                                });
                          },
                        );
                        // if (resource.organizerType == 'Organización') {
                        //   return StreamBuilder<Organization>(
                        //     stream:
                        //         database.organizationStream(resource.organizer),
                        //     builder: (context, snapshot) {
                        //       final organization = snapshot.data;
                        //       resource.organizerName =
                        //           organization == null ? '' : organization.name;
                        //       resource.organizerImage = organization == null
                        //           ? ''
                        //           : organization.photo;
                        //       resource.setResourceTypeName();
                        //       resource.setResourceCategoryName();
                        //       return StreamBuilder<Country>(
                        //           stream:
                        //               database.countryStream(resource.country),
                        //           builder: (context, snapshot) {
                        //             final country = snapshot.data;
                        //             resource.countryName =
                        //                 country == null ? '' : country.name;
                        //             return StreamBuilder<Province>(
                        //               stream: database
                        //                   .provinceStream(resource.province),
                        //               builder: (context, snapshot) {
                        //                 final province = snapshot.data;
                        //                 resource.provinceName = province == null
                        //                     ? ''
                        //                     : province.name;
                        //                 return StreamBuilder<City>(
                        //                     stream: database
                        //                         .cityStream(resource.city),
                        //                     builder: (context, snapshot) {
                        //                       final city = snapshot.data;
                        //                       resource.cityName =
                        //                           city == null ? '' : city.name;
                        //                       return Container(
                        //                         key: Key(
                        //                             'resource-${resource.resourceId}'),
                        //                         child: ResourceListTile(
                        //                           resource: resource,
                        //                           onTap: () {
                        //                             _saveScrollPosition();
                        //                             setState(() {
                        //                               globals.currentResource = resource;
                        //                               ResourcesPage.selectedIndex.value = 3;
                        //                             });
                        //                           },
                        //                           // onTap: () => context.push(
                        //                           //     '${StringConst.PATH_RESOURCES}/${resource.resourceId}'),
                        //                         ),
                        //                       );
                        //                     });
                        //               },
                        //             );
                        //           });
                        //     },
                        //   );
                        // } else {
                        //   return StreamBuilder<UserEnreda>(
                        //     stream: database.mentorStream(resource.organizer),
                        //     builder: (context, snapshot) {
                        //       final mentor = snapshot.data;
                        //       resource.organizerName = mentor == null
                        //           ? ''
                        //           : '${mentor.firstName} ${mentor.lastName} ';
                        //       resource.organizerImage =
                        //           mentor == null ? '' : mentor.photo;
                        //       resource.setResourceTypeName();
                        //       resource.setResourceCategoryName();
                        //       return StreamBuilder<Country>(
                        //           stream:
                        //               database.countryStream(resource.country),
                        //           builder: (context, snapshot) {
                        //             final country = snapshot.data;
                        //             resource.countryName =
                        //                 country == null ? '' : country.name;
                        //             return StreamBuilder<Province>(
                        //               stream: database
                        //                   .provinceStream(resource.province),
                        //               builder: (context, snapshot) {
                        //                 final province = snapshot.data;
                        //                 resource.provinceName = province == null
                        //                     ? ''
                        //                     : province.name;
                        //                 return StreamBuilder<City>(
                        //                     stream: database
                        //                         .cityStream(resource.city),
                        //                     builder: (context, snapshot) {
                        //                       final city = snapshot.data;
                        //                       resource.cityName =
                        //                           city == null ? '' : city.name;
                        //                       return Container(
                        //                         key: Key(
                        //                             'resource-${resource.resourceId}'),
                        //                         child: ResourceListTile(
                        //                           resource: resource,
                        //                           onTap: () {
                        //                             _saveScrollPosition();
                        //                             setState(() {
                        //                               globals.currentResource = resource;
                        //                               ResourcesPage.selectedIndex.value = 3;
                        //                             });
                        //                           },
                        //                           // onTap: () => context.push(
                        //                           //     '${StringConst.PATH_RESOURCES}/${resource.resourceId}'),
                        //                         ),
                        //                       );
                        //                     });
                        //               },
                        //             );
                        //           });
                        //     },
                        //   );
                        // }
                      },
                      emptyTitle: 'Sin recursos',
                      emptyMessage: 'Aún no tenemos recursos que mostrarte',
                    );
                  });
            }),
      );
    }
    String email = auth.currentUser!.email ?? '';
    return Container(
      padding: Responsive.isMobile(context)
          ? EdgeInsets.symmetric(horizontal: 10)
          : Responsive.isDesktopS(context)
          ? EdgeInsets.symmetric(horizontal: 20, vertical: 30)
          : EdgeInsets.symmetric(horizontal: 100, vertical: 30),
      child: StreamBuilder<List<UserEnreda>>(
          stream: database.userStream(email),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.isNotEmpty) {
                final user = snapshot.data![0];
                if (user.role == 'Desempleado') {
                  _register(user);
                } else {
                  if (!widget._errorNotValidUser) {
                    widget._errorNotValidUser = true;
                    Future.delayed(Duration.zero, () {
                      _signOut(context);
                      if (!isAlertBoxOpened) {
                        adminSignOut(context);
                      }
                    });
                  }
                }
              }
              return StreamBuilder<List<Resource>>(
                  stream: database.filteredResourcesCategoryStream(filterResource),
                  builder: (context, snapshot) {
                    return ListItemBuilderGrid<Resource>(
                      scrollController: _scrollController,
                      snapshot: snapshot,
                      itemBuilder: (context, resource) {
                        return StreamBuilder(
                          stream: resource.organizerType == 'Organización' ? database.organizationStream(resource.organizer) :
                          resource.organizerType == 'Entidad Social' ? database.socialEntityStream(resource.organizer)
                              : resource.organizerType == 'Empresa' ? database.companyStream(resource.organizer) :
                          database.mentorStream(resource.organizer),
                          builder: (context, snapshotOrganizer) {
                            if (snapshotOrganizer.hasData) {
                              if (snapshotOrganizer.data is Organization) {
                                final organization = snapshotOrganizer.data as Organization;
                                resource.organizerName = organization.name;
                                resource.organizerImage = organization.photo;
                              } else if (snapshotOrganizer.data is SocialEntity) {
                                final organization = snapshotOrganizer.data as SocialEntity;
                                resource.organizerName = organization.name;
                                resource.organizerImage = organization.photo;
                              } else if (snapshotOrganizer.data is Company) {
                                final organization = snapshotOrganizer.data as Company;
                                resource.organizerName = organization.name;
                                resource.organizerImage = organization.photo;
                              } else {
                                final mentor = snapshotOrganizer.data as UserEnreda;
                                resource.organizerName = '${mentor.firstName} ${mentor.lastName} ';
                                resource.organizerImage = mentor.photo;
                              }
                              resource.setResourceTypeName();
                              resource.setResourceCategoryName();
                            }
                            return StreamBuilder<Country>(
                              stream: database.countryStream(resource.country),
                              builder: (context, snapshot) {
                                final country = snapshot.data;
                                resource.countryName =
                                    country == null ? '' : country.name;
                                return StreamBuilder<Province>(
                                  stream: database
                                      .provinceStream(resource.province),
                                  builder: (context, snapshot) {
                                    final province = snapshot.data;
                                    resource.provinceName = province == null
                                        ? ''
                                        : province.name;
                                    return StreamBuilder<City>(
                                        stream: database
                                            .cityStream(resource.city),
                                        builder: (context, snapshot) {
                                          final city = snapshot.data;
                                          resource.cityName =
                                              city == null ? '' : city.name;
                                          return Container(
                                            key: Key(
                                                'resource-${resource.resourceId}'),
                                            child: ResourceListTile(
                                              resource: resource,
                                              onTap: () {
                                                _saveScrollPosition();
                                                setState(() {
                                                  globals.currentResource = resource;
                                                  ResourcesPage.selectedIndex.value = 3;
                                                });
                                              },
                                            ),
                                          );
                                        });
                                  },
                                );
                              });
                          },
                        );
                        // if (resource.organizerType == 'Organización') {
                        //   return StreamBuilder<Organization>(
                        //     stream:
                        //         database.organizationStream(resource.organizer),
                        //     builder: (context, snapshot) {
                        //       final organization = snapshot.data;
                        //       resource.organizerName =
                        //           organization == null ? '' : organization.name;
                        //       resource.organizerImage = organization == null
                        //           ? ''
                        //           : organization.photo;
                        //       resource.setResourceTypeName();
                        //       resource.setResourceCategoryName();
                        //       return StreamBuilder<Country>(
                        //           stream:
                        //               database.countryStream(resource.country),
                        //           builder: (context, snapshot) {
                        //             final country = snapshot.data;
                        //             resource.countryName =
                        //                 country == null ? '' : country.name;
                        //             return StreamBuilder<Province>(
                        //               stream: database
                        //                   .provinceStream(resource.province),
                        //               builder: (context, snapshot) {
                        //                 final province = snapshot.data;
                        //                 resource.provinceName = province == null
                        //                     ? ''
                        //                     : province.name;
                        //                 return StreamBuilder<City>(
                        //                     stream: database
                        //                         .cityStream(resource.city),
                        //                     builder: (context, snapshot) {
                        //                       final city = snapshot.data;
                        //                       resource.cityName =
                        //                           city == null ? '' : city.name;
                        //                       return Container(
                        //                         key: Key(
                        //                             'resource-${resource.resourceId}'),
                        //                         child: ResourceListTile(
                        //                           resource: resource,
                        //                           onTap: () {
                        //                             _saveScrollPosition();
                        //                             setState(() {
                        //                               globals.currentResource = resource;
                        //                               ResourcesPage.selectedIndex.value = 3;
                        //                             });
                        //                           },
                        //                           // onTap: () => context.push(
                        //                           //     '${StringConst.PATH_RESOURCES}/${resource.resourceId}'),
                        //                         ),
                        //                       );
                        //                     });
                        //               },
                        //             );
                        //           });
                        //     },
                        //   );
                        // } else {
                        //   return StreamBuilder<UserEnreda>(
                        //     stream: database.mentorStream(resource.organizer),
                        //     builder: (context, snapshot) {
                        //       final mentor = snapshot.data;
                        //       resource.organizerName = mentor == null
                        //           ? ''
                        //           : '${mentor.firstName} ${mentor.lastName} ';
                        //       resource.organizerImage =
                        //           mentor == null ? '' : mentor.photo;
                        //       resource.setResourceTypeName();
                        //       resource.setResourceCategoryName();
                        //       return StreamBuilder<Country>(
                        //           stream:
                        //               database.countryStream(resource.country),
                        //           builder: (context, snapshot) {
                        //             final country = snapshot.data;
                        //             resource.countryName =
                        //                 country == null ? '' : country.name;
                        //             return StreamBuilder<Province>(
                        //               stream: database
                        //                   .provinceStream(resource.province),
                        //               builder: (context, snapshot) {
                        //                 final province = snapshot.data;
                        //                 resource.provinceName = province == null
                        //                     ? ''
                        //                     : province.name;
                        //                 return StreamBuilder<City>(
                        //                     stream: database
                        //                         .cityStream(resource.city),
                        //                     builder: (context, snapshot) {
                        //                       final city = snapshot.data;
                        //                       resource.cityName =
                        //                           city == null ? '' : city.name;
                        //                       return Container(
                        //                         key: Key(
                        //                             'resource-${resource.resourceId}'),
                        //                         child: ResourceListTile(
                        //                           resource: resource,
                        //                           onTap: () {
                        //                             _saveScrollPosition();
                        //                             setState(() {
                        //                               globals.currentResource = resource;
                        //                               ResourcesPage.selectedIndex.value = 3;
                        //                             });
                        //                           },
                        //                           // onTap: () => context.push(
                        //                           //     '${StringConst.PATH_RESOURCES}/${resource.resourceId}'),
                        //                         ),
                        //                       );
                        //                     });
                        //               },
                        //             );
                        //           });
                        //     },
                        //   );
                        // }
                      },
                      emptyTitle: 'Sin recursos',
                      emptyMessage: 'Aún no tenemos recursos que mostrarte',
                    );
                  });
            }
            return Container();
          }),
    );
  }

  Widget _buildResourceDetail(BuildContext context) {
    return Padding(
      padding: Responsive.isMobile(context) ? EdgeInsets.symmetric(horizontal: 0, vertical: 0)
          : Responsive.isDesktopS(context) ? EdgeInsets.symmetric(horizontal: 30, vertical: 20)
          : EdgeInsets.symmetric(horizontal: 100, vertical: 20),
      child: SingleChildScrollView(
        child: Stack(
          children: [
            ResourceDetailPage(),
            InkWell(
              onTap: () {
                _loadScrollPosition();
                setStateIfMounted(() {
                  ResourcesPage.selectedIndex.value = 1;
                  _clearFilter();
                });
              },
              child: Padding(
                padding: MediaQuery.of(context).size.width >= 1200 || Responsive.isMobile(context) ? EdgeInsets.all(10.0)
                    : EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
                child: Image.asset(ImagePath.ARROW_BACK_SHADOW, scale: 1.2, height: 40,),
              ),
            ),
            Responsive.isMobile(context) || Responsive.isTablet(context) ? SpaceH8() : SpaceH4(),
            SpaceH50(),
          ],
        ),
      ),
    );
  }

  Future<void> _showDialogNotValidUser(BuildContext context) async {
    isAlertBoxOpened = true;
    final didRequestNotValidUser = await showAlertDialog(context,
        title: 'Notificación al usuario',
        content:
            'Hemos detectado que esta cuenta pertenece a una Organización, Mentor o SuperAdmin. Por favor autenticarse en la Web de Administración.',
        cancelActionText: 'Ok',
        defaultActionText: 'Ir a la Web');
    if (didRequestNotValidUser == true) {
      //launchURL(StringConst.WEB_COMPANIES_URL_ACCESS);
      launchURL(StringConst.WEB_ADMIN_ACCESS);
    }
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      final auth = Provider.of<AuthBase>(context, listen: false);
      await auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }

  void _clearFilter() {
    setStateIfMounted(() {
      _searchTextController.clear();
      filterResource.searchText = '';
      filterTrainingPill.searchText = '';
    });
  }

  void _clearScrollPosition() {
    _scrollController = ScrollController(initialScrollOffset: 0);
  }

  void _loadScrollPosition() async {
    final prefs = await SharedPreferences.getInstance();
    double scrollPosition = prefs.getDouble('scrollPosition') ?? 0;
    _scrollController = ScrollController(initialScrollOffset: scrollPosition);
  }

  void _saveScrollPosition() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('scrollPosition', _scrollController.offset);
  }

}
