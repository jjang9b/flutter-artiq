import 'package:artiq/data/artiqData.dart';
import 'package:artiq/data/httpData.dart';
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
  int length = 0;

  @override
  void initState() {
    getGuideDb();
    super.initState();
  }

  insertToday() async {
    await SqlLite().delete("guide");

    await SqlLite().insert(ArtiqDb(key: "guide", data: "1", date: new DateTime.now().add(new Duration(days: 1)).toString()));

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
      backgroundColor: ArtiqData.backgroundColor,
      body: SafeArea(
        child: FutureBuilder<List<Guide>>(
          future: Func.getGuideList(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              length = snapshot.data.length;

              return NotificationListener<ScrollNotification>(
                onNotification: (scrollNotification) {
                  setState(() {
                    idx = _guideController.page;
                  });

                  return true;
                },
                child: Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.82,
                      child: PageView.builder(
                        controller: _guideController,
                        itemBuilder: (context, position) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                margin: const EdgeInsets.fromLTRB(50, 50, 50, 10),
                                alignment: Alignment.center,
                                child: Text(
                                  snapshot.data[position].title,
                                  style: GoogleFonts.notoSans(
                                      textStyle: const TextStyle(color: Colors.white, fontSize: 23), fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.fromLTRB(50, 10, 50, 10),
                                alignment: Alignment.center,
                                child: Text(
                                  snapshot.data[position].text,
                                  style: GoogleFonts.notoSans(textStyle: TextStyle(color: ArtiqData.darkGreyColor, fontSize: 15, height: 1.5)),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.fromLTRB(50, 20, 50, 10),
                                  child: CachedNetworkImage(
                                    imageUrl: snapshot.data[position].image,
                                    imageBuilder: (context, imageProvider) => Container(
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                                        image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: (position == snapshot.data.length - 1),
                                child: InkWell(
                                  onTap: () {
                                    insertToday();
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    height: MediaQuery.of(context).size.height * 0.05,
                                    margin: const EdgeInsets.fromLTRB(100, 10, 100, 10),
                                    decoration: BoxDecoration(color: Colors.black, borderRadius: const BorderRadius.all(Radius.circular(5))),
                                    child: Text("guide.today",
                                            style: GoogleFonts.notoSans(textStyle: const TextStyle(color: Colors.white, fontSize: 16)))
                                        .tr(),
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
                                      alignment: Alignment.center,
                                      height: MediaQuery.of(context).size.height * 0.05,
                                      margin: const EdgeInsets.fromLTRB(100, 10, 100, 10),
                                      decoration:
                                          BoxDecoration(color: ArtiqData.fluorescenceColor, borderRadius: const BorderRadius.all(Radius.circular(5))),
                                      child: Text("guide.skip",
                                              style: GoogleFonts.notoSans(textStyle: TextStyle(color: ArtiqData.backgroundColor, fontSize: 16)))
                                          .tr()),
                                ),
                              )
                            ],
                          );
                        },
                        itemCount: snapshot.data.length,
                      ),
                    ),
                    Visibility(
                      visible: (idx.abs() != snapshot.data.length - 1),
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(30, 20, 30, 10),
                        alignment: Alignment.topCenter,
                        child: DotsIndicator(
                          dotsCount: length,
                          position: idx.abs(),
                          decorator: DotsDecorator(
                            activeSize: Size.fromRadius(5),
                            activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                            color: Colors.white54,
                            activeColor: ArtiqData.fluorescenceColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.black,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            );
          },
        ),
      ),
    );
  }
}
