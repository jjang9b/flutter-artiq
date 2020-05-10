import 'dart:ui';

import 'package:artiq/data.dart';
import 'package:artiq/func/func.dart';
import 'package:artiq/page/postPage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_youtube_view/flutter_youtube_view.dart';
import 'package:google_fonts/google_fonts.dart';

class ContentPage extends StatefulWidget {
  static const routeName = '/content';
  final Post post;

  ContentPage(this.post);

  @override
  _ContentPageState createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> implements YouTubePlayerListener {
  FirebaseAnalytics analytics = FirebaseAnalytics();
  ScrollController _contentScrollController = new ScrollController();
  FlutterYoutubeViewController _youtubeController;
  Post cuPost;
  double nowOffset = 0;
  bool isMoveBtn = true;

  @override
  void onReady() {}

  @override
  void onStateChange(String state) {
    switch (state) {
      case "PLAYING":
        setState(() {
          isMoveBtn = true;
        });
        break;
      case "ENDED":
        switch (ArtiqData.musicNextState) {
          case "shuffle":
            return goRandomContent();
            break;
          case "auto":
            return goNextContent();
            break;
          default:
            _youtubeController.play();
            break;
        }
        break;
      default:
        break;
    }
  }

  @override
  void onError(String error) {}

  @override
  void onVideoDuration(double duration) {}

  @override
  void onCurrentSecond(double second) {}

  void goBeforeContent() {
    if (_youtubeController != null) {
      _youtubeController.pause();
    }

    Post befPost = Func.getBeforePost(ArtiqData.category, cuPost);

    Func.goContentPage(context, befPost);
  }

  void goRandomContent() {
    if (_youtubeController != null) {
      _youtubeController.pause();
    }

    Post nextPost = Func.getRandomPost(ArtiqData.category, cuPost);

    Func.goContentPage(context, nextPost);
  }

  void goNextContent() {
    if (_youtubeController != null) {
      _youtubeController.pause();
    }

    Post nextPost = Func.getNextPost(ArtiqData.category, cuPost);

    Func.goContentPage(context, nextPost);
  }

  void sendAnalyticsEvent(Post post) async {
    await analytics.logEvent(name: "post_name", parameters: <String, dynamic>{'string': post.imageText});
  }

  Column getContentList(BuildContext context, Post post) {
    sendAnalyticsEvent(post);
    cuPost = post;

    List<Content> contentList = post.content;
    List<Widget> conContentList = contentList.map((content) {
      switch (content.type) {
        case "text-title":
          return Container(
              margin: EdgeInsets.only(top: 30, bottom: 10),
              alignment: Alignment.topLeft,
              child: Text(
                content.data,
                style: GoogleFonts.notoSans(textStyle: TextStyle(color: Color(0xff313131), height: 1.5, fontSize: 18, fontWeight: FontWeight.bold)),
              ));
          break;
        case "image":
          return Container(
            margin: EdgeInsets.only(top: 20, bottom: 40),
            child: Column(
              children: <Widget>[
                CachedNetworkImage(
                  imageUrl: content.data,
                  fit: BoxFit.cover,
                ),
                Text(content.desc, style: GoogleFonts.notoSans(textStyle: TextStyle(color: Color(0xff313131), height: 1.5, fontSize: 13)))
              ],
            ),
          );
          break;
        case "youtube":
          return Container(
            height: MediaQuery.of(context).size.height * 0.55,
            margin: EdgeInsets.only(top: 20, bottom: 40),
            child: new FlutterYoutubeView(
                onViewCreated: (controller) {
                  setState(() {
                    _youtubeController = controller;
                    isMoveBtn = false;
                  });
                },
                listener: this,
                scaleMode: YoutubeScaleMode.none,
                params: YoutubeParam(
                    videoId: content.data, showUI: true, startSeconds: 0.0, autoPlay: true, showFullScreen: false, showYoutube: false) // <option>
                ),
          );
          break;
        default:
          return Container(
            margin: EdgeInsets.only(bottom: 20),
            alignment: Alignment.topLeft,
            child: Text(content.data, style: GoogleFonts.notoSans(textStyle: TextStyle(color: Color(0xff313131), height: 1.5, fontSize: 17))),
          );
          break;
      }
    }).toList();

    return Column(children: conContentList);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (_youtubeController != null) {
          _youtubeController.pause();
        }

        Navigator.pop(context);
        return;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              ConstrainedBox(
                constraints: BoxConstraints(minHeight: 56.0),
                child: NotificationListener<ScrollNotification>(
                  onNotification: (scrollNotification) {
                    setState(() {
                      nowOffset = _contentScrollController.offset;
                    });

                    return true;
                  },
                  child: ListView.builder(
                      controller: _contentScrollController,
                      itemBuilder: (context, position) {
                        return Column(
                          children: <Widget>[
                            Stack(
                              children: <Widget>[
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height * 0.35,
                                  decoration: BoxDecoration(
                                      image: DecorationImage(image: CachedNetworkImageProvider(widget.post.imageUrl), fit: BoxFit.cover)),
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        alignment: Alignment.topLeft,
                                        margin: const EdgeInsets.only(top: 15, left: 10),
                                        child: InkWell(
                                          highlightColor: Colors.transparent,
                                          splashColor: Colors.transparent,
                                          onTap: () {
                                            return Navigator.pop(context, true);
                                          },
                                          child: Icon(Icons.arrow_back, color: (widget.post.backBtnType == 'w') ? Colors.white : Colors.black),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              margin: const EdgeInsets.fromLTRB(30, 20, 30, 0),
                              alignment: Alignment.topCenter,
                              child: Text(widget.post.imageText,
                                  style: TextStyle(color: Colors.black, height: 1.3, fontSize: 22, fontFamily: 'UTOIMAGE')),
                            ),
                            Container(
                              margin: const EdgeInsets.fromLTRB(30, 10, 30, 0),
                              alignment: Alignment.topCenter,
                              child: Text(widget.post.origin,
                                  style: GoogleFonts.notoSans(textStyle: TextStyle(color: Colors.black, height: 1.5, fontSize: 15))),
                            ),
                            Container(
                              margin: const EdgeInsets.fromLTRB(30, 30, 30, 10),
                              alignment: Alignment.topLeft,
                              child: getContentList(context, widget.post),
                            ),
                            Container(
                              margin: const EdgeInsets.fromLTRB(30, 0, 30, 30),
                              alignment: Alignment.topLeft,
                              height: 40,
                              child: Row(
                                children: <Widget>[
                                  Text(widget.post.date,
                                      style: GoogleFonts.notoSans(
                                          textStyle: TextStyle(color: Colors.black, height: 1, fontSize: 17, fontWeight: FontWeight.bold)))
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                      itemCount: 1),
                ),
              ),
              Positioned(
                bottom: 70,
                right: 70,
                child: Visibility(
                  visible: (ArtiqData.category == ArtiqData.categoryMusic && isMoveBtn),
                  child: FloatingActionButton(
                    mini: true,
                    heroTag: null,
                    backgroundColor: Colors.red,
                    onPressed: () {
                      setState(() {
                        if (ArtiqData.musicNextStateIdx + 1 >= ArtiqData.musicNextStateArr.length) {
                          ArtiqData.musicNextStateIdx = 0;
                        } else {
                          ArtiqData.musicNextStateIdx += 1;
                        }

                        return ArtiqData.musicNextState = ArtiqData.musicNextStateArr[ArtiqData.musicNextStateIdx];
                      });
                    },
                    child: Container(
                      child: Icon(
                        ArtiqData.musicNextStateIcon[ArtiqData.musicNextStateIdx],
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 70,
                right: 20,
                child: Visibility(
                  child: FloatingActionButton(
                    mini: true,
                    heroTag: null,
                    backgroundColor: Colors.black,
                    onPressed: () {
                      Func.goPageRemove(context, PostPage.routeName);
                    },
                    child: Container(
                      child: Icon(
                        Icons.home,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                right: 20,
                child: Visibility(
                  visible: isMoveBtn,
                  child: FloatingActionButton(
                    mini: true,
                    heroTag: null,
                    backgroundColor: Colors.black,
                    onPressed: () {
                      goNextContent();
                    },
                    child: Container(
                      child: Icon(
                        Icons.navigate_next,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                right: 70,
                child: Visibility(
                  visible: isMoveBtn,
                  child: FloatingActionButton(
                    mini: true,
                    heroTag: null,
                    backgroundColor: Colors.black,
                    onPressed: () {
                      goBeforeContent();
                    },
                    child: Container(
                      child: Icon(
                        Icons.navigate_before,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                right: 120,
                child: Visibility(
                  visible: (nowOffset > 100),
                  child: FloatingActionButton(
                    mini: true,
                    heroTag: null,
                    backgroundColor: Colors.black,
                    onPressed: () {
                      _contentScrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.ease);
                    },
                    child: Container(
                      child: Icon(
                        Icons.keyboard_arrow_up,
                        color: Colors.white,
                      ),
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
