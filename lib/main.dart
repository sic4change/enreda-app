import 'package:country_picker/country_picker.dart';
import 'package:enreda_app/app/home/home_page.dart';
import 'package:enreda_app/app/home/resources/resource_detail/resource_detail_link_page.dart';
import 'package:enreda_app/app/home/trainingPills/pages/training_pill_page_mobile.dart';
import 'package:enreda_app/app_theme.dart';
import 'package:enreda_app/firebase_options.dart';
import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
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

  // Pre-process deep links: if the browser URL already contains a resource or
  // training-pill path, store the ID so WebHome can redirect after Firebase
  // initializes. This is needed because GoRouter always starts at initialLocation
  // on web before the URL history is resolved.
  if (kIsWeb) {
    _processInitialDeepLink();
  }

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  runApp(MyApp());
}

/// Reads the browser's initial URL and extracts any deep-link ID into
/// Constants so WebHome / email_sign_in can redirect the user after auth.
void _processInitialDeepLink() {
  try {
    final uri = Uri.base;
    final segments = uri.pathSegments;
    // Matches /resources/<id>  →  e.g. ['resources', 'mLRm36lvC6NiDLXNMsJh']
    if (segments.length >= 2 && segments[0] == 'resources') {
      Constants.initialDeepLinkResourceId = segments[1];
      debugPrint('>>> Deep link detected — initialDeepLinkResourceId: ${segments[1]}');
    } else if (segments.length >= 2 && segments[0] == 'training-pills') {
      Constants.initialDeepLinkTrainingPillId = segments[1];
      debugPrint('>>> Deep link detected — initialDeepLinkTrainingPillId: ${segments[1]}');
    }
  } catch (e) {
    debugPrint('>>> Deep link pre-processing failed: $e');
  }
}

class MyApp extends StatelessWidget {

  final _router = GoRouter(
    initialLocation: StringConst.PATH_HOME,
    routes: [
      GoRoute(
        path: StringConst.PATH_HOME,
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: HomePage(),
        ),
      ),
      GoRoute(
        path: StringConst.PATH_LOGIN,
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: AccessPage(),
          //child: EmailSignInPage(),
        ),
      ),
      GoRoute(
        path: StringConst.PATH_ACCESS,
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: AccessPage(),
        ),
      ),
      GoRoute(
        path: '${StringConst.PATH_RESOURCES}/:rid',
        pageBuilder: (context, state) => MaterialPage<void>(
          fullscreenDialog: false,
          child: ResourceDetailLinkPage(resourceId: state.pathParameters['rid']!)
        ),

      ),
      GoRoute(
        path: '${StringConst.PATH_TRAINING_PILLS}/:rid',
        pageBuilder: (context, state) => MaterialPage<void>(
          fullscreenDialog: false,
          child: TrainingPillDetailPage(trainingPillId: state.pathParameters['rid']!),
        ),

      ),
      GoRoute(
        path: '${StringConst.PATH_COMPETENCIES}/:rid',
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: CertificateCompetencyForm(certificationRequestId: state.pathParameters['rid']!),
        ),
      ),
    ],
    errorBuilder: (context, state) => ErrorPage(state.error),
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
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
          title: 'Enreda',
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
