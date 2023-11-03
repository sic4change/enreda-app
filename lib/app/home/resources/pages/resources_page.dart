import 'package:enreda_app/app/home/models/city.dart';
import 'package:enreda_app/app/home/models/country.dart';
import 'package:enreda_app/app/home/models/filterResource.dart';
import 'package:enreda_app/app/home/models/organization.dart';
import 'package:enreda_app/app/home/models/province.dart';
import 'package:enreda_app/app/home/models/resource.dart';
import 'package:enreda_app/app/home/models/resourceCategory.dart';
import 'package:enreda_app/app/home/models/resourcePicture.dart';
import 'package:enreda_app/app/home/models/userEnreda.dart';
import 'package:enreda_app/app/home/resources/filter_text_field_row.dart';
import 'package:enreda_app/app/home/resources/list_item_builder_grid.dart';
import 'package:enreda_app/app/home/resources/resource_list_tile.dart';
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

class ResourcesPage extends StatefulWidget {
  @override
  State<ResourcesPage> createState() => _ResourcesPageState();

  String _message = '';
  bool _errorNotValidUser = false;
}

class _ResourcesPageState extends State<ResourcesPage> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final _searchTextController = TextEditingController();
  FilterResource filterResource = FilterResource("", "");
  bool isAlertBoxOpened = false;
  List<ResourceCategory> resourceCategoriesList = [];
  bool _visible = true;
  String _categoryName = '';
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
    return _visible ? _buildResourcesPage(context) :
    _buildFilteredResourcesPage(context);
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
                    AppColors.turquoise_alt,
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
                    padding: Responsive.isMobile(context) ?  EdgeInsets.symmetric(horizontal: 10) : EdgeInsets.symmetric(horizontal: 100.0),
                    child: Text(
                      Responsive.isMobile(context) ? StringConst.PILLS_SUBTITLE : StringConst.SEARCH_SUBTITLE,
                      textAlign: TextAlign.center, style: TextStyle(fontSize: 15,),)),
                  SpaceH20(),
                  _buildCategories(context, resourceCategoriesList),
                  SpaceH30(),
                ],
              ),
            ),
            Container(
              color: AppColors.grey_alt,
              height: 500,
              child: Column(
                children: [
                  SpaceH50(),
                  Text( StringConst.PILLS_TITLE, style: textTheme.titleSmall?.copyWith(
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
                      padding: Responsive.isMobile(context) ?  EdgeInsets.symmetric(horizontal: 10) : EdgeInsets.symmetric(horizontal: 100.0),
                      child: Text(StringConst.PILLS_SUBTITLE, textAlign: TextAlign.center, style: TextStyle(fontSize: 15,),)),
                  SpaceH50(),
                  Container(
                      width: Responsive.isMobile(context) ? MediaQuery.of(context).size.width * 0.9 : MediaQuery.of(context).size.width * 0.7,
                      height: Responsive.isMobile(context) ? 200 : 280,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage(ImagePath.BACKGROUND_PILLS),
                        )
                      ),
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Positioned(
                            bottom: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                    alignment: Alignment.bottomCenter,
                                    height: Responsive.isMobile(context) ? 150 : 300,
                                    child: Image.asset(ImagePath.PERSON_PILL1)),
                                Container(
                                    alignment: Alignment.bottomCenter,
                                    height: Responsive.isMobile(context) ? 200 : 350,
                                    child: Image.asset(ImagePath.PERSON_PILL2)),
                                Container(
                                    alignment: Alignment.bottomCenter,
                                    height: Responsive.isMobile(context) ? 150 : 300,
                                    child: Image.asset(ImagePath.PERSON_PILL3)),
                              ],
                            ),
                          ),
                        ],
                      ),),
                ],
              ),
            )
          ],
        ));
  }

  Widget _buildFilteredResourcesPage(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
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
                padding: const EdgeInsets.symmetric(horizontal: 50.0),
                child: InkWell(
                  onTap: () {
                    setStateIfMounted(() {
                      _visible = !_visible;
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
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w700,
                        fontSize: 25,
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
          margin: const EdgeInsets.only(top: 150.0),
          child: _buildContents(context),
        ),
      ],
    );
  }

  Widget _buildCategories(BuildContext context, List<ResourceCategory> resourceCategories) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return GridView.builder(
      padding: Responsive.isMobile(context) ?  EdgeInsets.symmetric(horizontal: 10): EdgeInsets.symmetric(horizontal: 100,  vertical: 30),
      shrinkWrap: true,
      itemCount: resourceCategories.length,
      scrollDirection: Axis.vertical,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: Responsive.isMobile(context) ? 280 : 520,
          mainAxisExtent: Responsive.isMobile(context) ? 120 : 450,
          crossAxisSpacing: Responsive.isMobile(context) ? 10 : 30,
          mainAxisSpacing: Responsive.isMobile(context) ? 10 : 30
      ),
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            setStateIfMounted(() {
              filterResource.resourceCategoryId = (resourceCategories[index].id);
              _visible = !_visible;
              _categoryName = resourceCategories[index].name;
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
                      child: Text(resourceCategories[index].name,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        height: 1.5,
                        letterSpacing: 1,
                        fontSize: Responsive.isMobile(context) ? 20 : 34,
                        fontWeight: FontWeight.w900,
                        //fontSize: fontSize,
                      ),),
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

  Widget _buildContents(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    final database = Provider.of<Database>(context, listen: false);

    if (auth.currentUser == null) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.isDesktop(context) ? 48.0 : 8.0,
        ),
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
      padding: EdgeInsets.only(
          left: Responsive.isMobile(context) ? 8 : 48,
          right: Responsive.isMobile(context) ? 8 : 48),
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
            else {
              if (!snapshot.hasData && snapshot.connectionState == ConnectionState.active)
                if (!widget._errorNotValidUser) {
                widget._errorNotValidUser = true;
                Future.delayed(Duration.zero, () {
                  _signOut(context);
                  if (!isAlertBoxOpened) {
                    _showDialogNotValidUser(context);
                  }
                });
              }
              return Container(
                width: 0.0,
                height: 0.0,
              );
            }
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
