import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:artiq/data.dart';
import 'package:artiq/func/func.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.white,
    statusBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));

  runApp(MyApp());
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
  Func func;
  Future<List<Post>> futureStory;
  PageController _pageController;

  @override
  void initState() {
    super.initState();

    func = new Func();
    futureStory = fetchStory();
    _pageController = PageController(viewportFraction: 0.7);
  }

  @override
  Widget build(BuildContext context) {
    double contentTop = MediaQuery.of(context).size.height * 0.15;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            child: Container(
              height: MediaQuery.of(context).size.height,
              color: Colors.white,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.195,
            left: 0,
            child: Container(
              width: 130,
              height: 130,
              child: Transform.translate(
                offset: Offset(-50, -50),
                child: Container(
                  decoration: BoxDecoration(
                      color: Color(0xff4A148C), shape: BoxShape.circle),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Container(
              margin: EdgeInsets.only(top: 25, left: 25),
              height: MediaQuery.of(context).size.height * 0.1,
              child: Row(
                children: <Widget>[
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: Text(
                            "아티크",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'JSDongkang'),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: Text(
                            "cultural and artistic post",
                            style: TextStyle(
                                fontSize: 14, fontFamily: 'JSDongkang'),
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 25),
                    child: Container(
                      alignment: Alignment.topLeft,
                      width: 40,
                      child: Icon(Icons.scatter_plot, size: 30),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.6,
              margin: EdgeInsets.fromLTRB(0, contentTop, 0, 20),
              child: FutureBuilder<List<Post>>(
                future: futureStory,
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
                                context, position, snapshot.data[position]);
                          },
                          itemCount: snapshot.data.length,
                        ));
                  }

                  return Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.black,
                      valueColor:
                          new AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 170,
              height: 170,
              child: Transform.translate(
                offset: Offset(50, 50),
                child: Container(
                  decoration: BoxDecoration(
                      color: Color(0xff4A148C), shape: BoxShape.circle),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              margin: EdgeInsets.fromLTRB(
                  25, MediaQuery.of(context).size.height * 0.1, 25, 20),
              height: MediaQuery.of(context).size.height * 0.08,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(right: 30),
                    child: InkWell(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.perm_identity,
                              color: Colors.black87, size: 18),
                          Text("내정보",
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 13,
                                  fontFamily: 'UTOIMAGE'))
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 30),
                    child: InkWell(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.favorite, color: Colors.black87, size: 18),
                          Text("공유",
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 13,
                                  fontFamily: 'UTOIMAGE'))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
