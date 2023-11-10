import 'package:enreda_app/app/home/models/city.dart';
import 'package:enreda_app/app/home/models/country.dart';
import 'package:enreda_app/app/home/models/filterResource.dart';
import 'package:enreda_app/app/home/models/organization.dart';
import 'package:enreda_app/app/home/models/province.dart';
import 'package:enreda_app/app/home/models/resource.dart';
import 'package:enreda_app/app/home/models/resourceCategory.dart';
import 'package:enreda_app/app/home/models/resourcePicture.dart';
import 'package:enreda_app/app/home/models/trainingPill.dart';
import 'package:enreda_app/app/home/models/userEnreda.dart';
import 'package:enreda_app/app/home/resources/filter_text_field_row.dart';
import 'package:enreda_app/app/home/resources/list_item_builder_grid.dart';
import 'package:enreda_app/app/home/resources/pages/list_item_builder_vertical.dart';
import 'package:enreda_app/app/home/resources/resource_list_tile.dart';
import 'package:enreda_app/app/home/trainingPills/training_list_tile.dart';
import 'package:enreda_app/common_widgets/show_alert_dialog.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../utils/functions.dart';
import '../../assistant/list_item_builder.dart';

class ResourcesPage extends StatefulWidget {
  @override
  State<ResourcesPage> createState() => _ResourcesPageState();

  String _message = '';
  bool _errorNotValidUser = false;
  static ValueNotifier<int> selectedIndex = ValueNotifier(0);
}

class _ResourcesPageState extends State<ResourcesPage> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final _searchTextController = TextEditingController();
  FilterResource filterResource = FilterResource("", "POUBGFk5gU6c5X1DKo1b");
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
      setState(() => resourceCategoriesList = categoriesList);
    });
  }

  @override
  void initState() {
    super.initState();
    getMessage();
    getResourceCategories();
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

  @override
  void dispose() {
    _searchTextController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    bodyWidget = [
      _buildResourcesPage(context),
      _buildFilteredResourcesPage(context),
      _buildTrainingPills(context)
    ];

    return ValueListenableBuilder<int>(
        valueListenable: ResourcesPage.selectedIndex,
        builder: (context, selectedIndex, child) {
          return Scaffold(
            body: bodyWidget[selectedIndex],
          );
        });
  }


  Widget _buildResourcesPage(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.1, 0.5, 0.9,],
                  colors: [
                    AppColors.white.withOpacity(0.1),
                    AppColors.greyViolet.withOpacity(0.1),
                    AppColors.turquoiseAlt,
                  ],
                ),
              ),
              child: Column(
                children: [
                  SpaceH50(),
                  Text( StringConst.SEARCH, style: textTheme.titleSmall?.copyWith(
                    color: AppColors.greyAlt,
                    height: 1.5,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w700,
                    fontSize: 25,
                    //fontSize: fontSize,
                  ),),
                  SpaceH20(),
                  Container(
                    alignment: Alignment.center,
                    padding: Responsive.isMobile(context) ?  EdgeInsets.symmetric(horizontal: 30) : EdgeInsets.symmetric(horizontal: 100.0),
                    child: Text(
                      Responsive.isMobile(context) ? StringConst.PILLS_SUBTITLE : StringConst.SEARCH_SUBTITLE,
                      textAlign: TextAlign.center, style: TextStyle(fontSize: 15,),)),
                  SpaceH20(),
                  _buildCategories(context, resourceCategoriesList),
                  SpaceH30(),
                ],
              ),
            ),
            _buildTrainingPillsButton(context)
          ],
        ));
  }

  Widget _buildTrainingPillsButton(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    final isDesktopScreen = MediaQuery.of(context).size.width >= 1350;
    return Container(
      color: AppColors.greyLightAlt,
      height: Responsive.isMobile(context) ? 400 : Responsive.isDesktopS(context) ? 600 : 500,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Responsive.isMobile(context) ? SpaceH20(): SpaceH50(),
          Text( StringConst.PILLS_TITLE, style: textTheme.titleSmall?.copyWith(
            color: AppColors.greyAlt,
            height: 1.5,
            letterSpacing: 0.5,
            fontWeight: FontWeight.w700,
            fontSize: 25,
          ),),
          SpaceH20(),
          Container(
              alignment: Alignment.center,
              padding: Responsive.isMobile(context) ?  EdgeInsets.symmetric(horizontal: 30) : EdgeInsets.symmetric(horizontal: 100.0),
              child: Text(StringConst.PILLS_SUBTITLE, textAlign: TextAlign.center, style: TextStyle(fontSize: 15,),)),
          Responsive.isMobile(context) ? SpaceH12() : SpaceH50(),
          InkWell(
            onTap: () {
              setStateIfMounted(() {
                ResourcesPage.selectedIndex.value = 2;
              });
            },
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Padding(
                  padding: Responsive.isMobile(context) ? EdgeInsets.only(right: 30, left: 30, top: 30) : EdgeInsets.all(0),
                  child: Container(
                    width: Responsive.isMobile(context) ? MediaQuery.of(context).size.width * 0.9 : MediaQuery.of(context).size.width * 0.7,
                    height: Responsive.isMobile(context) ? 140 : 280,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage(ImagePath.BACKGROUND_PILLS),
                        )
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: isDesktopScreen ? (MediaQuery.of(context).size.width * 0.7)/5 : 5,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                          alignment: Alignment.bottomCenter,
                          height: Responsive.isMobile(context) ? 120 : 300,
                          child: Image.asset(ImagePath.PERSON_PILL1)),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: isDesktopScreen ? (MediaQuery.of(context).size.width * 0.7)/5 : 15,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                          alignment: Alignment.bottomCenter,
                          height: Responsive.isMobile(context) ? 120 : 300,
                          child: Image.asset(ImagePath.PERSON_PILL3)),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                          alignment: Alignment.bottomCenter,
                          height: Responsive.isMobile(context) ? 180 : 300,
                          child: Image.asset(ImagePath.PERSON_PILL2)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilteredResourcesPage(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    final isBigScreen = MediaQuery.of(context).size.width >= 900;
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 20.0),
          child: Column(
            children: [
              FilterTextFieldRow(
                  searchTextController: _searchTextController,
                  onPressed: () => setStateIfMounted(() {
                    filterResource.searchText = _searchTextController.text;
                  }),
                  onFieldSubmitted: (value) => setStateIfMounted(() {
                    filterResource.searchText = _searchTextController.text;
                  }),
                  clearFilter: () => _clearFilter()),
              SpaceH20(),
              Padding(
                padding: isBigScreen ? EdgeInsets.symmetric(horizontal: 100.0) : EdgeInsets.symmetric(horizontal: 20.0),
                child: InkWell(
                  onTap: () {
                    setStateIfMounted(() {
                      ResourcesPage.selectedIndex.value = 0;
                      _clearFilter();
                    });
                  },
                  child: Row(
                    children: [
                      Icon(Icons.arrow_back, color: AppColors.primaryColor),
                      SpaceW12(),
                      Text(_categoryName, style: textTheme.titleSmall?.copyWith(
                        color: AppColors.greyAlt,
                        height: 1.5,
                        letterSpacing: 0.2,
                        fontWeight: FontWeight.w700,
                        fontSize:  isBigScreen ? 25 : 20,
                        //fontSize: fontSize,
                      ),),
                    ],
                  ),
                ),
              ),
              SpaceH20(),
              _categoryFormationId == "6ag9Px7zkFpHgRe17PQk" ?
              Padding(
                padding: const EdgeInsets.only(bottom: 18.0),
                child: Stack(
                  children: [
                    Padding(
                      padding: isBigScreen ? EdgeInsets.symmetric(horizontal: 110.0) : EdgeInsets.symmetric(horizontal: 20.0),
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
              : EdgeInsets.only(top: 150.0),
          child: _buildContents(context),
        ),
      ],
    );
  }

  Widget _buildTrainingPills(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    final isBigScreen = MediaQuery.of(context).size.width >= 900;
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 20.0),
          child: Column(
            children: [
              FilterTextFieldRow(
                  searchTextController: _searchTextController,
                  onPressed: () => setStateIfMounted(() {
                    filterResource.searchText = _searchTextController.text;
                  }),
                  onFieldSubmitted: (value) => setStateIfMounted(() {
                    filterResource.searchText = _searchTextController.text;
                  }),
                  clearFilter: () => _clearFilter()),
              SpaceH20(),
              Padding(
                padding: isBigScreen ? EdgeInsets.symmetric(horizontal: 100.0) : EdgeInsets.symmetric(horizontal: 20.0),
                child: InkWell(
                  onTap: () {
                    setStateIfMounted(() {
                      ResourcesPage.selectedIndex.value = 0;
                      _clearFilter();
                    });
                  },
                  child: Row(
                    children: [
                      Icon(Icons.arrow_back, color: AppColors.primaryColor),
                      SpaceW12(),
                      Text('Píldoras formativas', style: textTheme.titleSmall?.copyWith(
                        color: AppColors.greyAlt,
                        height: 1.5,
                        letterSpacing: 0.2,
                        fontWeight: FontWeight.w700,
                        fontSize:  isBigScreen ? 25 : 20,
                        //fontSize: fontSize,
                      ),),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
            margin: EdgeInsets.only(top: 150.0),
            child: Responsive.isMobile(context) ?
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
                      padding: Responsive.isMobile(context) ? EdgeInsets.only(top: 10.0) : EdgeInsets.only(top: 30.0),
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
                          fontSize: Responsive.isMobile(context) ? 15 : 34,
                          fontWeight: FontWeight.w900,
                        ),),
                      ),
                    ),
                  ),
                  Padding(
                    padding: Responsive.isMobile(context) ? EdgeInsets.only(top: 35.0) : EdgeInsets.all(0),
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
          stream: database.trainingPillStream(),
          builder: (context, snapshot) {
            return ListItemBuilderGrid<TrainingPill>(
              snapshot: snapshot,
              maxCrossAxisExtentValue: 490,
              mainAxisExtentValue: 500,
              itemBuilder: (context, trainingPill) {
                trainingPill.setTrainingPillCategoryName();
                return Container(
                  key: Key('trainingPill-${trainingPill.id}'),
                  child: TrainingPillListTile(
                    trainingPill: trainingPill,
                    onTap: () => context.push(
                        '${StringConst.PATH_RESOURCES}/${trainingPill.id}'),
                  ),
                );
              }
            );
          }),
    );
  }

  Widget _buildTrainingPillsListMobile(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: StreamBuilder<List<TrainingPill>>(
          stream: database.trainingPillStream(),
          builder: (context, snapshot) {
            return ListItemBuilderVertical<TrainingPill>(
                snapshot: snapshot,
                itemBuilder: (context, trainingPill) {
                  trainingPill.setTrainingPillCategoryName();
                  return Container(
                    key: Key('trainingPill-${trainingPill.id}'),
                    child: Column(
                      children: [
                        TrainingPillListTile(
                          trainingPill: trainingPill,
                          onTap: () => context.push(
                              '${StringConst.PATH_RESOURCES}/${trainingPill.id}'),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Divider(thickness: 1.5),
                        ),
                      ],
                    ),
                  );
                }
            );
          }),
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
              return ListItemBuilderGrid<Resource>(
                snapshot: snapshot,
                itemBuilder: (context, resource) {
                  if (resource.organizerType == 'Organización') {
                    return StreamBuilder<Organization>(
                      stream: database.organizationStream(resource.organizer),
                      builder: (context, snapshot) {
                        final organization = snapshot.data;
                        resource.organizerName =
                            organization == null ? '' : organization.name;
                        resource.organizerImage =
                            organization == null ? '' : organization.photo;
                        resource.setResourceTypeName();
                        resource.setResourceCategoryName();
                        return StreamBuilder<Country>(
                            stream: database.countryStream(resource.country),
                            builder: (context, snapshot) {
                              final country = snapshot.data;
                              resource.countryName =
                                  country == null ? '' : country.name;
                              return StreamBuilder<Province>(
                                stream:
                                    database.provinceStream(resource.province),
                                builder: (context, snapshot) {
                                  final province = snapshot.data;
                                  resource.provinceName =
                                      province == null ? '' : province.name;
                                  return StreamBuilder<City>(
                                      stream: database.cityStream(resource.city),
                                      builder: (context, snapshot) {
                                        final city = snapshot.data;
                                        resource.cityName = city == null ? '' : city.name;
                                        return StreamBuilder<ResourcePicture?>(
                                            stream: database.resourcePictureStream(resource.resourcePictureId),
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData) resource.resourcePhoto = snapshot.data!.resourcePhoto;
                                              return Container(
                                                key: Key(
                                                    'resource-${resource.resourceId}'),
                                                child: ResourceListTile(
                                                  resource: resource,
                                                  onTap: () => context.push(
                                                      '${StringConst.PATH_RESOURCES}/${resource.resourceId}'),
                                                ),
                                              );
                                            });
                                      });
                                },
                              );
                            });
                      },
                    );
                  } else {
                    return StreamBuilder<UserEnreda>(
                      stream: database.mentorStream(resource.organizer),
                      builder: (context, snapshot) {
                        final mentor = snapshot.data;
                        resource.organizerName = mentor == null
                            ? ''
                            : '${mentor.firstName} ${mentor.lastName} ';
                        resource.organizerImage =
                            mentor == null ? '' : mentor.photo;
                        resource.setResourceTypeName();
                        resource.setResourceCategoryName();
                        return StreamBuilder<Country>(
                            stream: database.countryStream(resource.country),
                            builder: (context, snapshot) {
                              final country = snapshot.data;
                              resource.countryName =
                                  country == null ? '' : country.name;
                              return StreamBuilder<Province>(
                                stream:
                                    database.provinceStream(resource.province),
                                builder: (context, snapshot) {
                                  final province = snapshot.data;
                                  resource.provinceName =
                                      province == null ? '' : province.name;
                                  return StreamBuilder<City>(
                                      stream:
                                          database.cityStream(resource.city),
                                      builder: (context, snapshot) {
                                        final city = snapshot.data;
                                        resource.cityName =
                                            city == null ? '' : city.name;
                                        return StreamBuilder<ResourcePicture?>(
                                            stream:
                                                database.resourcePictureStream(
                                                    resource.resourcePictureId),
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData) resource.resourcePhoto = snapshot.data!.resourcePhoto;
                                              return Container(
                                                key: Key(
                                                    'resource-${resource.resourceId}'),
                                                child: ResourceListTile(
                                                  resource: resource,
                                                  onTap: () => context.push(
                                                      '${StringConst.PATH_RESOURCES}/${resource.resourceId}'),
                                                ),
                                              );
                                            });
                                      });
                                },
                              );
                            });
                      },
                    );
                  }
                },
                emptyTitle: 'Sin recursos',
                emptyMessage: 'Aún no tenemos recursos que mostrarte',
              );
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
                        _showDialogNotValidUser(context);
                      }
                    });
                  }
                }
              }
              return StreamBuilder<List<Resource>>(
                  stream: database.filteredResourcesCategoryStream(filterResource),
                  builder: (context, snapshot) {
                    return ListItemBuilderGrid<Resource>(
                      snapshot: snapshot,
                      itemBuilder: (context, resource) {
                        if (resource.organizerType == 'Organización') {
                          return StreamBuilder<Organization>(
                            stream:
                                database.organizationStream(resource.organizer),
                            builder: (context, snapshot) {
                              final organization = snapshot.data;
                              resource.organizerName =
                                  organization == null ? '' : organization.name;
                              resource.organizerImage = organization == null
                                  ? ''
                                  : organization.photo;
                              resource.setResourceTypeName();
                              resource.setResourceCategoryName();
                              return StreamBuilder<Country>(
                                  stream:
                                      database.countryStream(resource.country),
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
                                              return StreamBuilder<
                                                      ResourcePicture>(
                                                  stream: database
                                                      .resourcePictureStream(
                                                          resource
                                                              .resourcePictureId),
                                                  builder: (context, snapshot) {
                                                    if (snapshot.hasData) resource.resourcePhoto = snapshot.data!.resourcePhoto;
                                                    return Container(
                                                      key: Key(
                                                          'resource-${resource.resourceId}'),
                                                      child: ResourceListTile(
                                                        resource: resource,
                                                        onTap: () => context.push(
                                                            '${StringConst.PATH_RESOURCES}/${resource.resourceId}'),
                                                      ),
                                                    );
                                                  });
                                            });
                                      },
                                    );
                                  });
                            },
                          );
                        } else {
                          return StreamBuilder<UserEnreda>(
                            stream: database.mentorStream(resource.organizer),
                            builder: (context, snapshot) {
                              final mentor = snapshot.data;
                              resource.organizerName = mentor == null
                                  ? ''
                                  : '${mentor.firstName} ${mentor.lastName} ';
                              resource.organizerImage =
                                  mentor == null ? '' : mentor.photo;
                              resource.setResourceTypeName();
                              resource.setResourceCategoryName();
                              return StreamBuilder<Country>(
                                  stream:
                                      database.countryStream(resource.country),
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
                                              return StreamBuilder<ResourcePicture>(
                                                  stream: database.resourcePictureStream(resource.resourcePictureId),
                                                  builder: (context, snapshot) {
                                                    if (snapshot.hasData) resource.resourcePhoto = snapshot.data!.resourcePhoto;
                                                    return Container(
                                                      key: Key(
                                                          'resource-${resource.resourceId}'),
                                                      child: ResourceListTile(
                                                        resource: resource,
                                                        onTap: () => context.push(
                                                            '${StringConst.PATH_RESOURCES}/${resource.resourceId}'),
                                                      ),
                                                    );
                                                  });
                                            });
                                      },
                                    );
                                  });
                            },
                          );
                        }
                      },
                      emptyTitle: 'Sin recursos',
                      emptyMessage: 'Aún no tenemos recursos que mostrarte',
                    );
                  });
            }
            return Container();
            // else {
            //   //if (!snapshot.hasData && snapshot.connectionState == ConnectionState.active)
            //   //if (!snapshot.hasData && snapshot.connectionState == ConnectionState.active)
            //     if (!widget._errorNotValidUser) {
            //     widget._errorNotValidUser = true;
            //     Future.delayed(Duration.zero, () {
            //       _signOut(context);
            //       if (!isAlertBoxOpened) {
            //         _showDialogNotValidUser(context);
            //       }
            //     });
            //   }
            //   return Container(
            //     width: 0.0,
            //     height: 0.0,
            //   );
            // }
          }),
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
    setState(() {
      _searchTextController.clear();
      filterResource.searchText = '';
    });
  }
}
