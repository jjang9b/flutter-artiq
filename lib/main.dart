import 'package:artiq/page/guidePage.dart';
import 'package:artiq/page/morePage.dart';
import 'package:artiq/page/postPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.white,
    statusBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'UTOIMAGE, JSDongkang, Arita'),
      home: GuidePage(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case GuidePage.routeName:
            return PageRouteBuilder(pageBuilder: (_, a1, a2) => GuidePage());
          case PostPage.routeName:
            return PageRouteBuilder(pageBuilder: (_, a1, a2) => PostPage());
          case MorePage.routeName:
            return PageRouteBuilder(pageBuilder: (_, a1, a2) => MorePage());
        }

        return PageRouteBuilder(pageBuilder: (_, a1, a2) => PostPage());
      },
    );
  }
}
