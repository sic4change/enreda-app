import 'package:country_picker/country_picker.dart';
import 'package:enreda_app/app/home/home_page.dart';
import 'package:enreda_app/app/home/resources/resource_detail/resource_detail_link_page.dart';
import 'package:enreda_app/app/home/trainingPills/pages/training_pill_page_mobile.dart';
import 'package:enreda_app/app_theme.dart';
import 'package:enreda_app/firebase_options.dart';
import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:layout/layout.dart';
import 'package:provider/provider.dart';

import 'app/error_page.dart';
import 'app/home/competencies/certificate_competency_form.dart';
import 'app/sign_in/access/access_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  final _router = GoRouter(
    initialLocation: StringConst.PATH_HOME,
    urlPathStrategy: UrlPathStrategy.path,
    routes: [
      GoRoute(
        path: StringConst.PATH_HOME,
        builder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: HomePage(),
        ),
      ),
      GoRoute(
        path: StringConst.PATH_LOGIN,
        builder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: AccessPage(),
          //child: EmailSignInPage(),
        ),
      ),
      GoRoute(
        path: StringConst.PATH_ACCESS,
        builder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: AccessPage(),
        ),
      ),
      GoRoute(
        path: '${StringConst.PATH_RESOURCES}/:rid',
        builder: (context, state) => MaterialPage<void>(
          fullscreenDialog: false,
          // child: Responsive.isMobile(context) || Responsive.isTablet(context)
          //     ? ResourceDetailPageMobile(resourceId: state.params['rid']!)
          //     : ResourceDetailPageWeb(resourceId: state.params['rid']!),
          child: ResourceDetailLinkPage(resourceId: state.params['rid']!)
        ),

      ),
      GoRoute(
        path: '${StringConst.PATH_TRAINING_PILLS}/:rid',
        builder: (context, state) => MaterialPage<void>(
          fullscreenDialog: false,
          child: TrainingPillDetailPage(trainingPillId: state.params['rid']!),
        ),

      ),
      GoRoute(
        path: '${StringConst.PATH_COMPETENCIES}/:rid',
        builder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: CertificateCompetencyForm(certificationRequestId: state.params['rid']!),
        ),
      ),
    ],
    error: (context, state) => MaterialPage<void>(
      key: state.pageKey,
      child: ErrorPage(state.error),
    ),
  );

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthBase>(create: (context) => Auth()),
        Provider<Database>(create: (_) => FirestoreDatabase()),
        Provider<FirebaseAnalytics>.value(value: analytics),
        Provider<FirebaseAnalyticsObserver>.value(value: observer),
      ],
      child: Layout(
        child: MaterialApp.router(
          //routeInformationProvider: _router.routeInformationProvider,
          routeInformationParser: _router.routeInformationParser,
          routerDelegate: _router.routerDelegate,
          debugShowCheckedModeBanner: false,
          title: 'enREDa',
          theme: AppTheme.lightThemeData,
          localizationsDelegates: [
            CountryLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          supportedLocales: [
            const Locale('es'),
          ],
          //scrollBehavior: MyCustomScrollBehavior(),
        ),
      ),
    );
  }
}
