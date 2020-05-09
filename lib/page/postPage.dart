import 'dart:async';
import 'dart:ui';

import 'package:artiq/data.dart';
import 'package:artiq/func/func.dart';
import 'package:artiq/page/morePage.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PostPage extends StatefulWidget {
  static const routeName = '/post';

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  PageController _categoryController;
  PageController _pageController;

  bool isRefresh() {
    if (ArtiqData.refreshSec > 0) {
      return false;
    }

    return true;
  }

  void refreshTimer() {
    ArtiqData.refreshTimer = Timer.periodic(Duration(milliseconds: 5000), (timer) {
      setState(() {
        ArtiqData.refreshSec -= 5;
      });

      if (ArtiqData.refreshSec <= 0) {
        ArtiqData.refreshColor = Colors.white;
        timer.cancel();
      }
    });
  }

  @override
  void initState() {
    super.initState();

    Func.setPostPage(0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ArtiqData.isOnload) {
        Func.categoryTab(_categoryController, ArtiqData.category, ArtiqData.categoryIdx);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _categoryController = new PageController()
      ..addListener(() {
        setState(() {
          Func.setCategoryPage(_categoryController.page);
        });
      });
    _pageController = new PageController()
      ..addListener(() {
        setState(() {
          Func.setPostPage(_pageController.page);
        });
      });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 30),
              height: MediaQuery.of(context).size.height * 0.08,
              child: Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.only(top: 15),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width * 0.78,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "A",
                            style: TextStyle(color: Colors.black, fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'UTOIMAGE'),
                          ),
                          Text(
                            "r",
                            style: TextStyle(color: Color(0xffffd54f), fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'UTOIMAGE'),
                          ),
                          Text(
                            "t",
                            style: TextStyle(color: Color(0xff455a64), fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'UTOIMAGE'),
                          ),
                          Text(
                            "i",
                            style: TextStyle(color: Color(0xffef0078), fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'UTOIMAGE'),
                          ),
                          Text(
                            "Q",
                            style: TextStyle(color: Colors.red, fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'UTOIMAGE'),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      child: InkWell(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap: () {
                          if (ArtiqData.isPostScrolling) {
                            return;
                          }

                          Func.goPage(context, MorePage.routeName);
                        },
                        child: Container(
                          width: 50,
                          child: Column(
                            children: <Widget>[
                              Icon(
                                Icons.more_horiz,
                                size: 30,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Stack(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 20, left: 20, right: 20),
                  height: MediaQuery.of(context).size.height * 0.77,
                  child: Container(
                    child: PageView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        controller: _categoryController,
                        itemBuilder: (context, position) {
                          return Container(
                            child: FutureBuilder<List<Post>>(
                              future: Func.getPostList(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return SizedBox(
                                    child: Column(
                                      children: <Widget>[
                                        Container(
                                          height: MediaQuery.of(context).size.height * 0.77,
                                          child: NotificationListener<ScrollNotification>(
                                            onNotification: (scrollNotification) {
                                              if (scrollNotification is ScrollStartNotification) {
                                                ArtiqData.isPostScrolling = true;
                                              } else if (scrollNotification is ScrollEndNotification) {
                                                ArtiqData.isPostScrolling = false;
                                              }

                                              return true;
                                            },
                                            child: ListView.builder(
                                              controller: _pageController,
                                              itemBuilder: (context, position) {
                                                return Func.getContent(context, snapshot.data.length, position, snapshot.data[position]);
                                              },
                                              itemCount: snapshot.data.length,
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
                                    valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        itemCount: 2),
                  ),
                ),
                Positioned(
                  right: 20,
                  bottom: 0,
                  child: Container(
                      width: 38,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            child: FloatingActionButton(
                              mini: true,
                              heroTag: null,
                              backgroundColor: (ArtiqData.refreshSec > 0) ? Colors.red : Colors.white,
                              onPressed: () {
                                if (ArtiqData.isPostScrolling) {
                                  return;
                                }

                                if (!isRefresh()) {
                                  return;
                                }

                                refreshTimer();
                                Func.refreshPost(context, _pageController);
                                setState(() {});
                              },
                              child: Container(
                                child: Icon(
                                  Icons.cached,
                                  color: (ArtiqData.refreshSec > 0) ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: (ArtiqData.refreshSec > 0),
                            child: Container(
                              child: Text(
                                "${ArtiqData.refreshSec} sec",
                                style: GoogleFonts.notoSans(
                                    textStyle: TextStyle(color: Colors.black, height: 0.9, fontWeight: FontWeight.bold, fontSize: 11)),
                              ),
                            ),
                          ),
                        ],
                      )),
                )
              ],
            ),
            Container(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.06,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Func.getCategory(_categoryController, 'music', 'MUSIC', 0),
                    Func.getCategory(_categoryController, 'art', 'ART', 1),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
