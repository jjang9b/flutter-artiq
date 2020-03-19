import 'dart:async';
import 'dart:ui';

import 'package:artiq/data.dart';
import 'package:artiq/func/func.dart';
import 'package:artiq/main.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ContentPage extends StatefulWidget {
  static const routeName = '/content';
  final Post post;

  ContentPage(this.post);

  @override
  _ContentPageState createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  Func func = new Func();
  YoutubePlayerController _youtubueController;
  ScrollController _contentScrollController = new ScrollController();
  double nowOffset = 0;
  bool isYoutubeTimer = false;
  bool isYoutubeLoad = false;

  void runYoutubeTimer() {
    Timer.periodic(const Duration(milliseconds: 3000), (timer) {
      if (isYoutubeLoad) {
        timer.cancel();
        return;
      }

      _youtubueController.reload();
    });
  }

  Column getContentList(Post post) {
    List<Content> contentList = post.content;
    List<Container> conContentList = contentList.map((content) {
      if (content.type == "text-title") {
        return Container(
          margin: EdgeInsets.only(top: 30, bottom: 10),
          alignment: Alignment.topLeft,
          child: Text(content.data,
              style: TextStyle(
                  color: Color(0xff313131),
                  height: 1.5,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'JSDongkang')),
        );
      }

      if (content.type == "image") {
        return Container(
          margin: EdgeInsets.only(top: 20, bottom: 40),
          child: Column(
            children: <Widget>[
              CachedNetworkImage(
                imageUrl: content.data,
                fit: BoxFit.cover,
              ),
              Text(content.desc,
                  style: TextStyle(
                      color: Color(0xff313131),
                      height: 1.5,
                      fontSize: 13,
                      fontFamily: 'JSDongkang'))
            ],
          ),
        );
      }

      if (content.type == "youtube") {
        _youtubueController = YoutubePlayerController(
          initialVideoId: content.data,
          flags: YoutubePlayerFlags(autoPlay: true, loop: true),
        );

        if (!isYoutubeTimer) {
          isYoutubeTimer = true;
          runYoutubeTimer();
        }

        return Container(
          margin: EdgeInsets.only(top: 20, bottom: 40),
          child: YoutubePlayer(
            onReady: () {
              setState(() {
                isYoutubeLoad = true;
              });
            },
            onEnded: (metaData) {
              if (ArtiqData.isMusicAuto) {
                setState(() {
                  _youtubueController.pause();
                });

                Navigator.pop(context);
                Post nextPost = func.getNextPost("music", post);
                func.goContentPage(context, nextPost);
              }
            },
            controller: _youtubueController,
            showVideoProgressIndicator: false,
            progressColors: ProgressBarColors(playedColor: Colors.red),
            bottomActions: <Widget>[
              PlayPauseButton(bufferIndicator: Container()),
              ProgressBar(isExpanded: true),
              RemainingDuration(),
            ],
          ),
        );
      }

      return Container(
        margin: EdgeInsets.only(bottom: 20),
        alignment: Alignment.topLeft,
        child: Text(content.data,
            style: TextStyle(
                color: Color(0xff313131),
                height: 1.5,
                fontSize: 17,
                fontFamily: 'JSDongkang')),
      );
    }).toList();

    return Column(children: conContentList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                                height:
                                    MediaQuery.of(context).size.height * 0.35,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: CachedNetworkImageProvider(
                                            widget.post.imageUrl),
                                        fit: BoxFit.cover)),
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      alignment: Alignment.topLeft,
                                      margin: const EdgeInsets.only(top: 5),
                                      child: IconButton(
                                          padding: EdgeInsets.all(0.0),
                                          iconSize: 55,
                                          icon: BackButton(
                                            color:
                                                (widget.post.backBtnType == 'w')
                                                    ? Colors.white
                                                    : Colors.black,
                                          ),
                                          onPressed: () =>
                                              Navigator.of(context).pop()),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: const EdgeInsets.fromLTRB(30, 15, 30, 0),
                            alignment: Alignment.bottomCenter,
                            child: Text(widget.post.origin,
                                style: TextStyle(
                                    color: Color(0xffFF0266),
                                    height: 1.5,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'JSDongkang')),
                          ),
                          Container(
                            margin: const EdgeInsets.fromLTRB(30, 10, 30, 0),
                            alignment: Alignment.bottomCenter,
                            child: Text(widget.post.imageText,
                                style: TextStyle(
                                    color: Colors.black,
                                    height: 1.3,
                                    fontSize: 22,
                                    fontFamily: 'UTOIMAGE')),
                          ),
                          Container(
                            margin: const EdgeInsets.fromLTRB(30, 30, 30, 10),
                            alignment: Alignment.topLeft,
                            child: getContentList(widget.post),
                          ),
                          Container(
                            margin: const EdgeInsets.fromLTRB(30, 0, 30, 30),
                            alignment: Alignment.topLeft,
                            height: 40,
                            child: Row(
                              children: <Widget>[
                                Text(widget.post.date,
                                    style: TextStyle(
                                        color: Colors.black,
                                        height: 1,
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Arita'))
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
              bottom: 20,
              right: 20,
              child: Visibility(
                child: new FloatingActionButton(
                  mini: true,
                  heroTag: null,
                  backgroundColor: Color(0xff212121),
                  onPressed: () {
                    Navigator.pop(context);
                    func.goPage(context, PostPage.routeName);
                  },
                  child: Container(
                    child: Icon(
                      Icons.wallpaper,
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
                visible: (nowOffset > 100),
                child: new FloatingActionButton(
                  mini: true,
                  heroTag: null,
                  backgroundColor: Color(0xff212121),
                  onPressed: () {
                    _contentScrollController.animateTo(0.0,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.ease);
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
    );
  }
}
