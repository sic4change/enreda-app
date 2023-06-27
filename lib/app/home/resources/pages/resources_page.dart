import 'package:chips_choice/chips_choice.dart';
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
import 'package:enreda_app/common_widgets/background_mobile.dart';
import 'package:enreda_app/common_widgets/background_web.dart';
import 'package:enreda_app/common_widgets/custom_chip.dart';
import 'package:enreda_app/common_widgets/show_alert_dialog.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/utils/my_scroll_behaviour.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  FilterResource filterResource = FilterResource("", []);
  bool isAlertboxOpened = false;
  final _searchTextController = TextEditingController();
  List<ResourceCategory> resourceCategoriesList = [];


  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  _register(UserEnreda user) {
    if (!kIsWeb) {
      _firebaseMessaging.subscribeToTopic('weeknotification');
      _firebaseMessaging.unsubscribeFromTopic(user.userId!);
      _firebaseMessaging.subscribeToTopic(user.userId!);
      _firebaseMessaging.getToken().then((token) => print('token: ${token}'));
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
    return Stack(
      children: <Widget>[
        Responsive.isDesktop(context)
            ? BackgroundWeb()
            : BackgroundMobileAccount(backgroundHeight: BackgroundHeight.Large),
        Padding(
          padding: Responsive.isDesktop(context)
              ? EdgeInsets.only(top: 32.0)
              : EdgeInsets.only(top: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              _buildFilterRow(),
              SpaceH20(),
              Expanded(
                child: StreamBuilder<User?>(
                    stream: Provider.of<AuthBase>(context).authStateChanges(),
                    builder: (context, snapshot) {
                      return _buildContents(context);
                    }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterRow() {
    final double margin = Responsive.isDesktop(context) ? 48.0 : 12.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilterTextFieldRow(
            searchTextController: _searchTextController,
            onPressed: () => setState(() {
                  filterResource.searchText = _searchTextController.text;
                }),
            onFieldSubmitted: (value) => setState(() {
                  filterResource.searchText = _searchTextController.text;
                }),
            clearFilter: () => _clearFilter()),
        SpaceH8(),
        Container(
          height: 50.0,
          margin: EdgeInsets.symmetric(horizontal: margin),
          child:
          resourceCategoriesList.isEmpty ? Center(child: LinearProgressIndicator()) :
          ScrollConfiguration(
            behavior: MyCustomScrollBehavior(),
            child: ChipsChoice<String>.multiple(
              alignment: WrapAlignment.start,
              padding: EdgeInsets.only(left: 0.0, right: 0.0),
              value: filterResource.resourceCategories,
              onChanged: (val) {
                setState(() {
                  filterResource.resourceCategories = val;
                });
              },
              choiceItems: C2Choice.listFrom<String, ResourceCategory>(
                source: resourceCategoriesList,
                value: (i, v) => v.id,
                label: (i, v) => v.name,
              ),
              choiceBuilder: (item, i) => Row(
                children: [
                  CustomChip(
                    label: item.label,
                    selected: item.selected,
                    onSelect: item.select!,
                  ),
                  SpaceW8(),
                ],
              ),
            ),
          ),
        ),
      ],
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
                      if (!isAlertboxOpened) {
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
                  if (!isAlertboxOpened) {
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
    isAlertboxOpened = true;
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
      filterResource.resourceCategories = [];
    });
  }
}
