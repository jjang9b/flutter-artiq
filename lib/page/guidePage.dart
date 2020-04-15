import 'package:artiq/data.dart';
import 'package:artiq/func/func.dart';
import 'package:artiq/sql/artiqDb.dart';
import 'package:artiq/sql/sqlLite.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  insertToday() async {
    await SqlLite().delete("guide");

    await SqlLite().upsert(ArtiqDb(key: "guide", data: "1", date: new DateTime.now().add(new Duration(days: 1)).toString()));

    Func.goPostPage(context);
  }

  getGuideDb() async {
    ArtiqDb artiqDb = await SqlLite().get("guide");

    if (artiqDb != null) {
      DateTime guideDate = DateTime.parse(artiqDb.date);

      if (DateTime.now().compareTo(guideDate) < 0) {
        Func.goPostPage(context);
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
                    BoxFit boxFit;

                    switch (position) {
                      case 0:
                      case 1:
                        con1 = 0.55;
                        con2 = 0.05;
                        con3 = 0.09;
                        boxFit = BoxFit.cover;
                        break;
                      case 2:
                        con1 = 0.35;
                        con2 = 0.05;
                        con3 = 0.2;
                        boxFit = BoxFit.cover;
                        break;
                      default:
                        con1 = 0.4;
                        con2 = 0.05;
                        con3 = 0.3;
                        boxFit = BoxFit.cover;
                        break;
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          height: MediaQuery.of(context).size.height * con1,
                          margin: EdgeInsets.fromLTRB(30, 20, 30, 10),
                          child: CachedNetworkImage(
                            imageUrl: snapshot.data[position].image,
                            imageBuilder: (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(image: imageProvider, fit: boxFit),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height * con2,
                          margin: EdgeInsets.fromLTRB(30, 20, 30, 10),
                          alignment: Alignment.topCenter,
                          child: Text(
                            snapshot.data[position].title,
                            style: GoogleFonts.notoSans(textStyle: TextStyle(fontSize: 20)),
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height * con3,
                          margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
                          alignment: Alignment.topCenter,
                          child: Text(
                            snapshot.data[position].text,
                            style: GoogleFonts.notoSans(textStyle: TextStyle(fontSize: 16, height: 1.5)),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(30, 0, 30, 10),
                          alignment: Alignment.topCenter,
                          child: DotsIndicator(
                            dotsCount: snapshot.data.length,
                            position: idx.abs(),
                            decorator: DotsDecorator(
                              activeSize: Size.fromRadius(5),
                              activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
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
                              insertToday();
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height * 0.09,
                              child: Container(
                                margin: EdgeInsets.fromLTRB(50, 20, 50, 20),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.all(Radius.circular(30))),
                                child: Text("guide.today", style: GoogleFonts.notoSans(textStyle: TextStyle(color: Colors.white, fontSize: 16))).tr(),
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: (position == snapshot.data.length - 1),
                          child: InkWell(
                            onTap: () {
                              Func.goPostPage(context);
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height * 0.09,
                              child: Container(
                                  margin: EdgeInsets.fromLTRB(50, 0, 50, 40),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.all(Radius.circular(30))),
                                  child:
                                      Text("guide.skip", style: GoogleFonts.notoSans(textStyle: TextStyle(color: Colors.white, fontSize: 16))).tr()),
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
