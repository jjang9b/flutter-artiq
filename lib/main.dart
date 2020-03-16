import 'package:artiq/data.dart';
import 'package:artiq/func/func.dart';
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
      theme: ThemeData(fontFamily: 'UTOIMAGE, JSDongkang, Arita'),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  PageController _categoryController;
  PageController _pageController;
  Fetch fetch;
  Func func;

  @override
  void initState() {
    super.initState();

    func = new Func();
    fetch = new Fetch();
    _categoryController = PageController();
    _pageController = PageController(viewportFraction: 0.7);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            child: Container(
              height: MediaQuery.of(context).size.height,
              color: Colors.white,
            ),
          ),
          SafeArea(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.15,
              child: Stack(
                children: <Widget>[
                  Container(
                    alignment: Alignment.topCenter,
                    margin: EdgeInsets.only(top: 30),
                    child: Column(
                      children: <Widget>[
                        Container(
                          alignment: Alignment.topCenter,
                          margin: EdgeInsets.only(bottom: 6),
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: Text(
                            "ArtiQ",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'UTOIMAGE'),
                          ),
                        ),
                        Container(
                          alignment: Alignment.topCenter,
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: Text(
                            "cultural and artistic post",
                            style: TextStyle(fontSize: 18, fontFamily: 'Arita'),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.67,
              margin: EdgeInsets.fromLTRB(
                  0, MediaQuery.of(context).size.height * 0.19, 0, 20),
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
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: FutureBuilder<List<Post>>(
                            future: func.getData(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return NotificationListener<ScrollNotification>(
                                    onNotification: (scrollNotification) {
                                      setState(() {
                                        func.setPage(_pageController.page);
                                      });

                                      return true;
                                    },
                                    child: PageView.builder(
                                      controller: _pageController,
                                      itemBuilder: (context, position) {
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
                                  valueColor: new AlwaysStoppedAnimation<Color>(
                                      Colors.white),
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
          ),
          SafeArea(
            child: Container(
              margin: EdgeInsets.fromLTRB(
                  10, MediaQuery.of(context).size.height * 0.11, 10, 20),
              height: MediaQuery.of(context).size.height * 0.07,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  func.getCategory(_categoryController, 'art', 'ART', 0),
                  func.getCategory(_categoryController, 'music', 'MUSIC', 1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
