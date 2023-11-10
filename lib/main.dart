import 'package:country_picker/country_picker.dart';
import 'package:enreda_app/app/home/home_page.dart';
import 'package:enreda_app/app/home/resources/pages/resource_detail_mobile.dart';
import 'package:enreda_app/app/home/resources/pages/resource_detail_web.dart';
import 'package:enreda_app/app/home/trainingPills/pages/training_pill_page_mobile.dart';
import 'package:enreda_app/app/sign_in/email_sign_in_page.dart';
import 'package:enreda_app/app_theme.dart';
import 'package:enreda_app/firebase_options.dart';
import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/strings.dart';
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
          child: EmailSignInPage(),
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
          child: Responsive.isMobile(context) || Responsive.isTablet(context)
              ? ResourceDetailPageMobile(resourceId: state.params['rid']!)
              : ResourceDetailPageWeb(resourceId: state.params['rid']!),
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

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthBase>(create: (context) => Auth()),
        Provider<Database>(create: (_) => FirestoreDatabase()),
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
