import 'package:artiq/data.dart';
import 'package:artiq/func/func.dart';
import 'package:artiq/page/morePage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

void main() {
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
      home: PostPage(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
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

class PostPage extends StatefulWidget {
  static const routeName = '/post';

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  PageController _categoryController = new PageController();
  PageController _pageController = new PageController(viewportFraction: 0.7);
  Fetch fetch = new Fetch();
  Func func = new Func();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height * 0.1,
                  child: Stack(
                    children: <Widget>[
                      Container(
                        alignment: Alignment.topCenter,
                        margin: EdgeInsets.only(top: 22),
                        child: Column(
                          children: <Widget>[
                            Container(
                              alignment: Alignment.topCenter,
                              margin: EdgeInsets.only(bottom: 3),
                              width: MediaQuery.of(context).size.width * 0.6,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    "A",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'UTOIMAGE'),
                                  ),
                                  Text(
                                    "r",
                                    style: TextStyle(
                                        color: Color(0xffffdd40),
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'UTOIMAGE'),
                                  ),
                                  Text(
                                    "t",
                                    style: TextStyle(
                                        color: Color(0xff1565c0),
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'UTOIMAGE'),
                                  ),
                                  Text(
                                    "i",
                                    style: TextStyle(
                                        color: Color(0xff69f0ae),
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'UTOIMAGE'),
                                  ),
                                  Text(
                                    "Q",
                                    style: TextStyle(
                                        color: Color(0xffef0078),
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'UTOIMAGE'),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              alignment: Alignment.topCenter,
                              width: MediaQuery.of(context).size.width * 0.6,
                              child: Text(
                                "cultural and artistic post",
                                style: TextStyle(
                                    fontSize: 18, fontFamily: 'Arita'),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.77,
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
                        height: MediaQuery.of(context).size.height * 0.07,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            func.getCategory(
                                _categoryController, 'art', 'ART', 0),
                            func.getCategory(
                                _categoryController, 'music', 'MUSIC', 1),
                          ],
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.68,
                        margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: Container(
                          child: NotificationListener<ScrollNotification>(
                            onNotification: (scrollNotification) {
                              setState(() {
                                func.setCategoryPage(_categoryController.page);
                              });

                              return true;
                            },
                            child: PageView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                controller: _categoryController,
                                itemBuilder: (context, position) {
                                  return Container(
                                    child: FutureBuilder<List<Post>>(
                                      future: func.getData(),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          return NotificationListener<
                                                  ScrollNotification>(
                                              onNotification:
                                                  (scrollNotification) {
                                                setState(() {
                                                  func.setPage(
                                                      _pageController.page);
                                                });

                                                return true;
                                              },
                                              child: PageView.builder(
                                                controller: _pageController,
                                                itemBuilder:
                                                    (context, position) {
                                                  return func.getContent(
                                                      context,
                                                      snapshot.data.length,
                                                      position,
                                                      snapshot.data[position]);
                                                },
                                                itemCount: snapshot.data.length,
                                              ));
                                        }

                                        return Center(
                                          child: CircularProgressIndicator(
                                            backgroundColor: Colors.black,
                                            valueColor:
                                                new AlwaysStoppedAnimation<
                                                    Color>(Colors.white),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                                itemCount: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                func.getNavigator(context)
              ],
            )
          ],
        ),
      ),
    );
  }
}
