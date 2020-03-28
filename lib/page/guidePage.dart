import 'package:artiq/data.dart';
import 'package:artiq/func/func.dart';
import 'package:artiq/page/postPage.dart';
import 'package:artiq/sql/artiqDb.dart';
import 'package:artiq/sql/sqlLite.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GuidePage extends StatefulWidget {
  static const routeName = '/guide';

  @override
  _GuidePageState createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> {
  PageController _guideController = new PageController();
  double idx = 0;

  @override
  void initState() {
    getGuideDb();
    super.initState();
  }

  goPostPage() {
    Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context) {
      return new PostPage();
    }));
  }

  getGuideDb() async {
    ArtiqDb artiqDb = await SqlLite().get("guide");

    if (artiqDb != null) {
      DateTime guideDate = DateTime.parse(artiqDb.date);

      if (DateTime.now().compareTo(guideDate) < 0) {
        goPostPage();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: FutureBuilder<List<Guide>>(
        future: Func.getGuideList(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return NotificationListener<ScrollNotification>(
                onNotification: (scrollNotification) {
                  setState(() {
                    idx = _guideController.page;
                  });

                  return true;
                },
                child: PageView.builder(
                  controller: _guideController,
                  itemBuilder: (context, position) {
                    double con1;
                    double con2;
                    double con3;

                    switch (position) {
                      case 0:
                        con1 = 0.4;
                        con2 = 0.05;
                        con3 = 0.3;
                        break;
                      case 1:
                        con1 = 0.55;
                        con2 = 0.05;
                        con3 = 0.15;
                        break;
                      default:
                        con1 = 0.35;
                        con2 = 0.05;
                        con3 = 0.2;
                        break;
                    }

                    return Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(top: 20),
                          height: MediaQuery.of(context).size.height * con1,
                          child: CachedNetworkImage(
                            imageUrl: snapshot.data[position].image,
                            imageBuilder: (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: imageProvider, fit: BoxFit.contain),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 30),
                          height: MediaQuery.of(context).size.height * con2,
                          child: Text(
                            snapshot.data[position].title,
                            style: TextStyle(
                                fontSize: 20, fontFamily: "JSDongkang"),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
                          height: MediaQuery.of(context).size.height * con3,
                          child: Text(
                            snapshot.data[position].text,
                            style: TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                fontFamily: "JSDongkang"),
                          ),
                        ),
                        Container(
                          alignment: Alignment.bottomCenter,
                          width: MediaQuery.of(context).size.width * 0.68,
                          margin: EdgeInsets.only(top: 8),
                          child: DotsIndicator(
                            dotsCount: snapshot.data.length,
                            position: idx.abs(),
                            decorator: DotsDecorator(
                              activeSize: Size.fromRadius(5),
                              activeShape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0)),
                              color: Colors.black26,
                              activeColor: Colors.red,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(),
                        ),
                        Visibility(
                          visible: (position == snapshot.data.length - 1),
                          child: InkWell(
                            onTap: () {
                              SqlLite().upsert(ArtiqDb(
                                  key: "guide",
                                  data: "1",
                                  date: new DateTime.now()
                                      .add(new Duration(days: 1))
                                      .toString()));

                              goPostPage();
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height * 0.09,
                              child: Container(
                                margin: EdgeInsets.fromLTRB(50, 20, 50, 20),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30))),
                                child: Text("오늘 하루 안내 보지 않기",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontFamily: "JSDongkang")),
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: (position == snapshot.data.length - 1),
                          child: InkWell(
                            onTap: () {
                              goPostPage();
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height * 0.09,
                              child: Container(
                                margin: EdgeInsets.fromLTRB(50, 0, 50, 40),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: Color(0xFFef0078),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30))),
                                child: Text("들어가기",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontFamily: "JSDongkang")),
                              ),
                            ),
                          ),
                        )
                      ],
                    );
                  },
                  itemCount: snapshot.data.length,
                ));
          }

          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.black,
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          );
        },
      )),
    );
  }
}
