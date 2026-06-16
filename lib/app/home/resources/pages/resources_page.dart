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
import 'package:enreda_app/app/home/resources/models/resource_metadata.dart';
import 'package:enreda_app/app/home/resources/filter_text_field_row.dart';
import 'dart:async';
import 'package:enreda_app/services/location_cache.dart';
import 'package:async/async.dart' show StreamGroup;
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
  ResourceMetadata _metadata = ResourceMetadata();
  List<StreamSubscription> _metadataSubscriptions = [];

  String _categoryName = 'Empleo';
  String _categoryFormationId = '';

  // ---------------------------------------------------------------------------
  // Resource pagination state (replaces stream-based, growing-.limit() pattern)
  //
  // The old code created a fresh `filteredResourcesCategoryStream(filter)`
  // subscription inside `_buildContents`'s `build()` AND grew `filter.limit`
  // by 50 on every scroll page — which forced Firestore to replay the entire
  // window from doc 0 each step. The new flow does cursor-paged one-shot
  // fetches, accumulating results in `_resourceItems`.
  // ---------------------------------------------------------------------------
  static const int _kResourcesPageSize = 50;
  List<Resource> _resourceItems = <Resource>[];
  ResourcesPageCursor? _resourceCursor;
  bool _isInitialResourcesLoad = true;
  bool _isLoadingMoreResources = false;
  bool _hasMoreResources = true;
  Object? _resourcesLoadError;
  String _activeResourceFilterSignature = '';

  // Auth/role gate (replaces the nested StreamBuilder<List<UserEnreda>> that
  // re-subscribed on every rebuild). `null` while verifying, `true` once the
  // current user has been confirmed as a valid 'Desempleado' (or is anon).
  bool? _userRoleVerified;
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

  void getResourceCategories() {
    setStateIfMounted(() => resourceCategoriesList = LocationCache.instance.resourceCategories);
  }

  void _getMetadata() async {
    final database = Provider.of<Database>(context, listen: false);

    // warmUpAll caches countries, provinces, cities AND organizers.
    // Subsequent page mounts are a no-op — all data served from memory.
    await LocationCache.instance.warmUpAll(database);

    setStateIfMounted(() {
      resourceCategoriesList = LocationCache.instance.resourceCategories;
      _metadata = ResourceMetadata.fromLists(
        countries: LocationCache.instance.countries,
        provinces: LocationCache.instance.provinces,
        cities: LocationCache.instance.allCities,
        organizers: LocationCache.instance.organizers,
      );
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
          origin: 'https://www.youtube-nocookie.com',
        ),
      );
    });
  }

  // ---------------------------------------------------------------------------
  // Resource pagination + auth-role helpers
  // ---------------------------------------------------------------------------

  /// Stable key for the current resource filter. Compared against
  /// [_activeResourceFilterSignature] to decide whether a filter mutation
  /// (category or search text) requires a fresh first page.
  String _computeResourceFilterSignature() =>
      '${filterResource.resourceCategoryId}|${filterResource.searchText}';

  /// Resets pagination state and fetches the first page for the current
  /// filter. Safe to call from anywhere; deduplicates against the active
  /// signature so back-to-back identical filter sets are a no-op.
  Future<void> _loadFirstResourcesPage({bool force = false}) async {
    final signature = _computeResourceFilterSignature();
    if (!force && signature == _activeResourceFilterSignature && _resourceItems.isNotEmpty) {
      return;
    }
    final database = Provider.of<Database>(context, listen: false);
    setStateIfMounted(() {
      _activeResourceFilterSignature = signature;
      _resourceItems = <Resource>[];
      _resourceCursor = null;
      _hasMoreResources = true;
      _isInitialResourcesLoad = true;
      _resourcesLoadError = null;
    });
    try {
      final page = await database.resourcesPage(
        filter: filterResource,
        pageSize: _kResourcesPageSize,
      );
      if (!mounted) return;
      // Drop the result if the filter changed while we were waiting on the
      // network (a newer load is already in flight or done).
      if (_computeResourceFilterSignature() != signature) return;
      setStateIfMounted(() {
        _resourceItems = page.items;
        _resourceCursor = page.cursor;
        _hasMoreResources = page.hasMore;
        _isInitialResourcesLoad = false;
      });
    } catch (e, st) {
      debugPrint('[ResourcesPage] First-page fetch failed: $e\n$st');
      if (!mounted) return;
      setStateIfMounted(() {
        _isInitialResourcesLoad = false;
        _hasMoreResources = false;
        _resourcesLoadError = e;
      });
    }
  }

  /// Appends the next page using the stored cursor. Guarded against
  /// concurrent triggers and end-of-list.
  Future<void> _loadNextResourcesPage() async {
    if (_isLoadingMoreResources ||
        _isInitialResourcesLoad ||
        !_hasMoreResources ||
        _resourceCursor == null) {
      return;
    }
    final database = Provider.of<Database>(context, listen: false);
    final signatureAtStart = _activeResourceFilterSignature;
    setStateIfMounted(() => _isLoadingMoreResources = true);
    try {
      final page = await database.resourcesPage(
        filter: filterResource,
        startAfter: _resourceCursor,
        pageSize: _kResourcesPageSize,
      );
      if (!mounted) return;
      // If the filter changed mid-flight, the returned page is no longer
      // contiguous with `_resourceItems`. Drop it; the new first page will
      // be loaded by `_loadFirstResourcesPage`.
      if (_activeResourceFilterSignature != signatureAtStart) return;
      setStateIfMounted(() {
        _resourceItems = <Resource>[..._resourceItems, ...page.items];
        _resourceCursor = page.cursor ?? _resourceCursor;
        _hasMoreResources = page.hasMore;
        _isLoadingMoreResources = false;
      });
    } catch (e, st) {
      debugPrint('[ResourcesPage] Next-page fetch failed: $e\n$st');
      if (!mounted) return;
      setStateIfMounted(() => _isLoadingMoreResources = false);
    }
  }

  /// One-shot replacement for the legacy `StreamBuilder<List<UserEnreda>>`
  /// that wrapped the resources content. Verifies the current user is a
  /// 'Desempleado' (or unauthenticated) before rendering the resources
  /// list; signs out non-participants on the same path the old code did.
  Future<void> _verifyUserRole() async {
    final auth = Provider.of<AuthBase>(context, listen: false);
    if (auth.currentUser == null) {
      setStateIfMounted(() => _userRoleVerified = true);
      return;
    }
    final database = Provider.of<Database>(context, listen: false);
    final email = auth.currentUser!.email ?? '';
    try {
      // `.first` collects exactly one snapshot then closes the subscription —
      // a single Firestore read instead of an open per-rebuild listener.
      final users = await database.userStream(email).first;
      if (!mounted) return;
      if (users.isEmpty) {
        setStateIfMounted(() => _userRoleVerified = true);
        return;
      }
      final user = users.first;
      if (user.role == 'Desempleado') {
        _register(user);
        setStateIfMounted(() => _userRoleVerified = true);
        return;
      }
      // Non-participant logged in — same defensive sign-out the legacy
      // nested StreamBuilder performed.
      if (!widget._errorNotValidUser) {
        widget._errorNotValidUser = true;
        await _signOut(context);
        if (!isAlertBoxOpened && mounted) {
          adminSignOut(context);
        }
      }
    } catch (e, st) {
      debugPrint('[ResourcesPage] User role verification failed: $e\n$st');
      if (!mounted) return;
      // Fail-open: render resources anyway rather than blocking the UI on
      // a transient network error.
      setStateIfMounted(() => _userRoleVerified = true);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadScrollPosition();
    getMessage();
    getResourceCategories();
    _getMetadata();
    _loadPillControllers();
    _verifyUserRole();
    _loadFirstResourcesPage(force: true);

    // Infinite scroll listener — cursor-paged. Each trigger appends ONE page
    // (50 docs max) instead of replaying the whole window from doc 0.
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent * 0.8) {
        _loadNextResourcesPage();
      }
    });
  }


  @override
  void dispose() {
    _searchTextController.dispose();
    _scrollController.dispose();
    _controllers.values.forEach((c) => c.close());
    _metadataSubscriptions.forEach((s) => s.cancel());
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
                onPressed: () {
                  setStateIfMounted(() {
                    filterResource.searchText = _searchTextController.text;
                  });
                  _loadFirstResourcesPage();
                },
                onFieldSubmitted: (value) {
                  setStateIfMounted(() {
                    filterResource.searchText = _searchTextController.text;
                  });
                  _loadFirstResourcesPage();
                },
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
            // Category changed → reset pagination + fetch fresh first page.
            _loadFirstResourcesPage();
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
    final EdgeInsets contentPadding = Responsive.isMobile(context)
        ? const EdgeInsets.symmetric(horizontal: 10)
        : Responsive.isDesktopS(context)
            ? const EdgeInsets.symmetric(horizontal: 20, vertical: 30)
            : const EdgeInsets.symmetric(horizontal: 100, vertical: 30);

    // User-role verification is a one-shot kicked off in `initState` via
    // `_verifyUserRole`. Don't render the resources grid until it resolves;
    // this avoids the nested `StreamBuilder<List<UserEnreda>>` that
    // re-subscribed on every parent rebuild.
    if (_userRoleVerified != true) {
      return Container(
        padding: contentPadding,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
    }

    // Compose an AsyncSnapshot from cached pagination state so the existing
    // ListItemBuilderGrid (which expects a snapshot) keeps working unchanged.
    final AsyncSnapshot<List<Resource>> resourcesSnapshot;
    if (_resourcesLoadError != null && _resourceItems.isEmpty) {
      resourcesSnapshot = AsyncSnapshot<List<Resource>>.withError(
        ConnectionState.done,
        _resourcesLoadError!,
      );
    } else if (_isInitialResourcesLoad) {
      resourcesSnapshot = const AsyncSnapshot<List<Resource>>.nothing();
    } else {
      resourcesSnapshot = AsyncSnapshot<List<Resource>>.withData(
        ConnectionState.active,
        _resourceItems,
      );
    }

    // Preserve the original layout flow (ListItemBuilderGrid sits directly
    // inside a Container, sized by the Stack ancestor) and overlay a small
    // spinner via `Positioned` while a subsequent page is loading.
    return Container(
      padding: contentPadding,
      child: Stack(
        children: [
          ListItemBuilderGrid<Resource>(
            scrollController: _scrollController,
            snapshot: resourcesSnapshot,
            itemBuilder: (context, resource) {
              resource.organizerName =
                  _metadata.organizerNames[resource.organizer] ?? '';
              resource.organizerImage =
                  _metadata.organizerImages[resource.organizer];
              resource.countryName =
                  _metadata.countryNames[resource.country] ?? '';
              resource.provinceName =
                  _metadata.provinceNames[resource.province] ?? '';
              resource.cityName = _metadata.cityNames[resource.city] ?? '';
              resource.setResourceTypeName();
              resource.setResourceCategoryName();

              return Container(
                key: Key('resource-${resource.resourceId}'),
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
            },
            emptyTitle: 'Sin recursos',
            emptyMessage: 'Aún no tenemos recursos que mostrarte',
          ),
          if (_isLoadingMoreResources)
            const Positioned(
              left: 0,
              right: 0,
              bottom: 12,
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ),
            ),
        ],
      ),
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
    // Filter cleared → reload first page so results reflect the new state.
    _loadFirstResourcesPage();
  }

  void _clearScrollPosition() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  void _loadScrollPosition() async {
    final prefs = await SharedPreferences.getInstance();
    double scrollPosition = prefs.getDouble('scrollPosition') ?? 0;
    if (scrollPosition > 0 && _scrollController.hasClients) {
      _scrollController.jumpTo(scrollPosition);
    }
  }

  void _saveScrollPosition() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('scrollPosition', _scrollController.offset);
  }

}
