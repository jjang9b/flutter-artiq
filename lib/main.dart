import 'package:artiq/func/assetLoader.dart';
import 'package:artiq/page/guidePage.dart';
import 'package:artiq/page/morePage.dart';
import 'package:artiq/page/postPage.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Color(0xff2B2B2B),
    statusBarColor: Color(0xff2B2B2B),
    systemNavigationBarIconBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.light,
  ));

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runApp(EasyLocalization(
      supportedLocales: [Locale('ko'), Locale('en')],
      path: 'res/languages',
      saveLocale: false,
      useOnlyLangCode: true,
      assetLoader: FileAssetLoader(),
      child: MyApp(),
    ));
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics analytics = FirebaseAnalytics();

    return MaterialApp(
      localizationsDelegates: [GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
      supportedLocales: [
        const Locale('en'),
        const Locale('ko'),
      ],
      locale: EasyLocalization.of(context).locale,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'UTOIMAGE'),
      home: GuidePage(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case GuidePage.routeName:
            return PageRouteBuilder(pageBuilder: (_, a1, a2) => GuidePage(), settings: RouteSettings(name: GuidePage.routeName));
          case PostPage.routeName:
            return PageRouteBuilder(pageBuilder: (_, a1, a2) => PostPage(), settings: RouteSettings(name: PostPage.routeName));
          case MorePage.routeName:
            return PageRouteBuilder(pageBuilder: (_, a1, a2) => MorePage(), settings: RouteSettings(name: MorePage.routeName));
        }

        return PageRouteBuilder(pageBuilder: (_, a1, a2) => PostPage(), settings: RouteSettings(name: PostPage.routeName));
      },
    );
  }
}
