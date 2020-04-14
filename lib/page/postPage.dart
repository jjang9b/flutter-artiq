import 'dart:async';
import 'dart:ui';

import 'package:artiq/data.dart';
import 'package:artiq/func/func.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
    ArtiqData.refreshTimer =
        Timer.periodic(Duration(milliseconds: 5000), (timer) {
      setState(() {
        ArtiqData.refreshSec -= 5;
      });

      if (ArtiqData.refreshSec <= 0) {
        ArtiqData.refreshColor = Colors.black;
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
        Func.categoryTab(
            _categoryController, ArtiqData.category, ArtiqData.categoryIdx);
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
                margin: EdgeInsets.only(top: 25),
                child: Column(
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
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
                                color: Color(0xffffd54f),
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'UTOIMAGE'),
                          ),
                          Text(
                            "t",
                            style: TextStyle(
                                color: Color(0xff455a64),
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'UTOIMAGE'),
                          ),
                          Text(
                            "i",
                            style: TextStyle(
                                color: Color(0xffef0078),
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'UTOIMAGE'),
                          ),
                          Text(
                            "Q",
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'UTOIMAGE'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 30),
              height: MediaQuery.of(context).size.height * 0.79,
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
                                      child: Stack(
                                        children: <Widget>[
                                          Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.08,
                                            child: Row(
                                              children: <Widget>[
                                                Func.getCategory(
                                                    _categoryController,
                                                    'music',
                                                    'MUSIC',
                                                    0),
                                                Func.getCategory(
                                                    _categoryController,
                                                    'art',
                                                    'ART',
                                                    1),
                                              ],
                                            ),
                                          ),
                                          Positioned(
                                            right: 17,
                                            top: 5,
                                            child: InkWell(
                                              highlightColor:
                                                  Colors.transparent,
                                              splashColor: Colors.transparent,
                                              onTap: () {
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
                                                  width: 38,
                                                  height: 50,
                                                  child: Column(
                                                    children: <Widget>[
                                                      Icon(
                                                        Icons.fiber_new,
                                                        size: 28,
                                                        color: ArtiqData
                                                            .refreshColor,
                                                      ),
                                                      Text(
                                                        "${ArtiqData.refreshSec}s",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black87,
                                                            fontSize: 12,
                                                            fontFamily:
                                                                'UTOIMAGE'),
                                                      )
                                                    ],
                                                  )),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: NotificationListener<
                                          ScrollNotification>(
                                        onNotification: (scrollNotification) {
                                          if (scrollNotification
                                              is ScrollStartNotification) {
                                            ArtiqData.isPostScrolling = true;
                                          } else if (scrollNotification
                                              is ScrollEndNotification) {
                                            ArtiqData.isPostScrolling = false;
                                          }

                                          return true;
                                        },
                                        child: PageView.builder(
                                          controller: _pageController,
                                          itemBuilder: (context, position) {
                                            return Func.getContent(
                                                context,
                                                snapshot.data.length,
                                                position,
                                                snapshot.data[position]);
                                          },
                                          itemCount: snapshot.data.length,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      alignment: Alignment.topCenter,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.11,
                                      child: DotsIndicator(
                                        dotsCount: snapshot.data.length,
                                        position: Func.getPostPage(),
                                        decorator: DotsDecorator(
                                          size: Size.fromRadius(4),
                                          activeSize: Size.fromRadius(4),
                                          activeShape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0)),
                                          color: Colors.black26,
                                          activeColor: Colors.black87,
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
            Func.getNavigator(context)
          ],
        ),
      ),
    );
  }
}
