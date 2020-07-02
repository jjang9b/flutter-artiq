import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:artiq/data.dart';
import 'package:artiq/func/func.dart';
import 'package:artiq/page/morePage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
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
  bool isExit = false;

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
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(left: 30),
                height: MediaQuery.of(context).size.height * 0.055,
                child: Container(
                  alignment: Alignment.topLeft,
                  margin: const EdgeInsets.only(top: 5),
                  child: Row(
                    children: <Widget>[
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "A",
                              style: const TextStyle(color: Color(0xff26A69A), fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'UTOIMAGE'),
                            ),
                            Text(
                              "r",
                              style: const TextStyle(color: Color(0xffffdd40), fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'UTOIMAGE'),
                            ),
                            Text(
                              "t",
                              style: const TextStyle(color: Color(0xff039be5), fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'UTOIMAGE'),
                            ),
                            Text(
                              "i",
                              style: const TextStyle(color: Color(0xffef0078), fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'UTOIMAGE'),
                            ),
                            Text(
                              "Q",
                              style: const TextStyle(color: Colors.red, fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'UTOIMAGE'),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 5, right: 20),
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
                alignment: Alignment.center,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(top: 5, left: 20, right: 20),
                    height: MediaQuery.of(context).size.height * 0.755,
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
                                            height: MediaQuery.of(context).size.height * 0.755,
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
                                      textStyle: TextStyle(color: Colors.black, height: 0.9, fontWeight: FontWeight.bold, fontSize: 11)),
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
              Container(
                margin: const EdgeInsets.only(top: 5, left: 23, right: 17),
                height: MediaQuery.of(context).size.height * 0.07,
                child: FutureBuilder<Ads>(
                    future: Func.getAds(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return SizedBox(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: CachedNetworkImage(
                              imageUrl: snapshot.data.url,
                              imageBuilder: (context, imageProvider) => Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(5)),
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.fitWidth,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      return Container();
                    }),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.055,
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
    );
  }
}
