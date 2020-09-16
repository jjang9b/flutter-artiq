import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:artiq/data/artiqData.dart';
import 'package:artiq/data/httpData.dart';
import 'package:artiq/func/func.dart';
import 'package:artiq/page/morePage.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';

class PostPage extends StatefulWidget {
  static const routeName = '/post';

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> with TickerProviderStateMixin {
  PageController _categoryController;
  PageController _pageController;
  bool isExit = false;
  double titleScale = 1;
  Curve postCurve = Curves.ease;

  void exitButton() {
    isExit = true;
    setState(() {});

    Timer.periodic(Duration(milliseconds: 2000), (timer) {
      timer.cancel();

      isExit = false;
      setState(() {});
    });
  }

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

  void scrollPost() {
    if (_pageController.position.pixels <= 0 && _pageController.position.userScrollDirection == ScrollDirection.forward) {
      if (titleScale >= 1) {
        return;
      }

      setState(() {
        titleScale += 0.05;
      });
    }

    if (_pageController.position.pixels > 0 && _pageController.position.userScrollDirection == ScrollDirection.reverse) {
      if (titleScale <= 0.2) {
        return;
      }

      setState(() {
        titleScale -= 0.05;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    Func.setIsFavorite();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ArtiqData.isOnload) {
        Func.categoryTab(_categoryController, ArtiqData.category, ArtiqData.categoryIdx);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double fontSize = (titleScale < 0.4) ? 20 : titleScale * 50;
    double moreSize = (titleScale < 0.4) ? 30 : titleScale * 50;
    double scaleHeight = (titleScale < 0.4) ? MediaQuery.of(context).size.height * 0.04 : MediaQuery.of(context).size.height * titleScale * 0.2;

    _categoryController = new PageController()
      ..addListener(() {
        setState(() {
          Func.setCategoryPage(_categoryController.page);
        });
      });
    _pageController = new PageController();

    return WillPopScope(
      onWillPop: () {
        if (isExit) {
          exit(0);
          return;
        }

        exitButton();
        return;
      },
      child: Scaffold(
        backgroundColor: ArtiqData.backgroundColor,
        body: SafeArea(
          child: Container(
            margin: const EdgeInsets.only(left: 15, right: 15),
            child: Column(
              children: <Widget>[
                Transform.scale(
                  scale: 1,
                  child: Container(
                    margin: const EdgeInsets.only(top: 10),
                    height: scaleHeight,
                    child: Container(
                      alignment: Alignment.topLeft,
                      child: Row(
                        children: <Widget>[
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "A",
                                  style: TextStyle(color: Color(0xff26A69A), fontSize: fontSize, fontWeight: FontWeight.bold, fontFamily: 'UTOIMAGE'),
                                ),
                                Text(
                                  "r",
                                  style: TextStyle(color: Color(0xffffdd40), fontSize: fontSize, fontWeight: FontWeight.bold, fontFamily: 'UTOIMAGE'),
                                ),
                                Text(
                                  "t",
                                  style: TextStyle(color: Color(0xff039be5), fontSize: fontSize, fontWeight: FontWeight.bold, fontFamily: 'UTOIMAGE'),
                                ),
                                Text(
                                  "i",
                                  style: TextStyle(color: Color(0xffF5F5F5), fontSize: fontSize, fontWeight: FontWeight.bold, fontFamily: 'UTOIMAGE'),
                                ),
                                Text(
                                  "Q",
                                  style: TextStyle(color: Colors.red, fontSize: fontSize, fontWeight: FontWeight.bold, fontFamily: 'UTOIMAGE'),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Container(),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 0, right: 20),
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
                                child: Icon(
                                  Icons.more_horiz,
                                  color: Colors.white,
                                  size: moreSize,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(top: 5, right: 0),
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
                                        return Container(
                                          height: MediaQuery.of(context).size.height * 0.66,
                                          child: NotificationListener<ScrollNotification>(
                                            onNotification: (scrollNotification) {
                                              scrollPost();

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
                                );
                              },
                              itemCount: 2),
                        ),
                      ),
                      Positioned(
                        right: 20,
                        bottom: 20,
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
                                          textStyle: TextStyle(color: Colors.white, height: 0.9, fontWeight: FontWeight.bold, fontSize: 11)),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                      ),
                      Positioned(
                        bottom: 0,
                        child: AnimatedOpacity(
                          opacity: isExit ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 500),
                          child: Container(
                            width: 250,
                            height: 35,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: const BorderRadius.all(Radius.circular(5)),
                            ),
                            child: Text("post.exit", style: GoogleFonts.notoSans(textStyle: TextStyle(color: Colors.white, fontSize: 13))).tr(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.07,
                      decoration: BoxDecoration(
                        color: ArtiqData.fluorescenceColor,
                        border: Border.all(color: Colors.black, width: 0),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Func.getCategory(_categoryController, 'music', 'MUSIC', 0),
                          Func.getCategory(_categoryController, 'art', 'ART', 1),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
