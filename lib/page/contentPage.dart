import 'dart:async';
import 'dart:ui';

import 'package:artiq/data/artiqData.dart';
import 'package:artiq/data/httpData.dart';
import 'package:artiq/func/func.dart';
import 'package:artiq/page/postPage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:conreality_headset/conreality_headset.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_youtube_view/flutter_youtube_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:move_to_background/move_to_background.dart';

class ContentPage extends StatefulWidget {
  static const routeName = '/content';
  final Post post;

  ContentPage(this.post);

  @override
  _ContentPageState createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> with WidgetsBindingObserver implements YouTubePlayerListener {
  FirebaseAnalytics analytics = FirebaseAnalytics();
  ScrollController _contentScrollController = new ScrollController();
  FlutterYoutubeViewController _youtubeController;
  Post currentPost;
  double nowOffset = 0;
  int playSec = 0;
  String musicGenre;
  String currentYoutubeId;
  bool isMoveBtn = true;
  bool isHeadset = false;
  bool isBackground = false;
  bool isNeedPause = false;
  bool isEndBuffer = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    listenHeadset();
  }

  @override
  void dispose() {
    super.dispose();

    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.inactive:
        isBackground = true;
        MoveToBackground.moveTaskToBack();

        if (_youtubeController == null) {
          _youtubeController.play();
        }
        break;
      case AppLifecycleState.resumed:
        isBackground = false;
        break;
      default:
        break;
    }
  }

  @override
  void onReady() {}

  @override
  void onStateChange(String state) {
    switch (state) {
      case "PAUSED":
      case "BUFFERING":
      case "UNSTARTED":
      case "VIDEO_CUED":
        if (_youtubeController == null) {
          return;
        }

        if (isEndBuffer || isNeedPause || !isBackground) {
          return;
        }

        Timer.periodic(Duration(milliseconds: 500), (timer) {
          timer.cancel();
          _youtubeController.play();
        });
        break;
      case "PLAYING":
        setState(() {
          isMoveBtn = true;
          isNeedPause = false;
        });

        if (!ArtiqData.isFavoriteMusic) {
          return;
        }

        if (ArtiqData.playLikeTimer != null) {
          return;
        }

        ArtiqData.playLikeTimer = Timer.periodic(Duration(milliseconds: 5000), (timer) {
          playSec += 5;

          if (playSec >= 60) {
            Func.setPlayCount(musicGenre);

            ArtiqData.playLikeTimer = null;
            timer.cancel();
          }
        });
        break;
      case "ENDED":
        isEndBuffer = true;

        if (_youtubeController != null) {
          _youtubeController.seekTo(-5);
          _youtubeController.play();
          _youtubeController.pause();
        }

        Timer.periodic(Duration(milliseconds: 1000), (timer) {
          timer.cancel();
          isEndBuffer = false;

          switch (ArtiqData.musicNextState) {
            case "shuffle":
              if (isBackground) {
                loadRandomYoutube();
                return;
              }

              return goRandomContent();
              break;
            case "auto":
              if (isBackground) {
                loadNextYoutube();
                return;
              }

              return goNextContent();
              break;
            default:
              _youtubeController.play();
              break;
          }
        });
        break;
      default:
        break;
    }
  }

  @override
  void onError(String error) {
    _youtubeController.initialization();
    _youtubeController.loadOrCueVideo(currentYoutubeId, 0);
  }

  @override
  void onVideoDuration(double duration) {}

  @override
  void onCurrentSecond(double second) {}

  void listenHeadset() async {
    Stream<HeadsetEvent> stream = await Headset.subscribe();

    stream.listen((HeadsetEvent event) {
      isHeadset = event.toString().contains("isConnected: true");

      if (!isHeadset) {
        if (isBackground) {
          isNeedPause = true;
        }

        if (_youtubeController == null) {
          return;
        }

        _youtubeController.pause();
      }
    });
  }

  void youtubePause() {
    if (_youtubeController == null) {
      return;
    }

    _youtubeController.pause();
  }

  void setCurrentPost(Post nextPost) {
    Func.futurePost = new Future<Post>.value(nextPost);
    setState(() {});
  }

  Future<Post> getFuturePost() {
    return Func.futurePost;
  }

  void loadOnIdYoutube(Post post) {
    List<Content> contentList = post.content;

    if (contentList == null) {
      loadNextYoutube();
      return;
    }

    String id = contentList[0].data;
    currentYoutubeId = id;
    _youtubeController.initialization();
    _youtubeController.loadOrCueVideo(id, 0);
  }

  void loadNextYoutube() {
    Func.futurePost.then((post) {
      Post nextPost = Func.getNextPost(ArtiqData.category, post);

      setCurrentPost(nextPost);
      loadOnIdYoutube(nextPost);
    });
  }

  void loadRandomYoutube() {
    Func.futurePost.then((post) {
      Post nextPost = Func.getRandomPost(ArtiqData.category, post);

      setCurrentPost(nextPost);
      loadOnIdYoutube(nextPost);
    });
  }

  void goBeforeContent() {
    youtubePause();

    Func.futurePost.then((post) {
      Post nextPost = Func.getBeforePost(ArtiqData.category, post);

      Func.goContentPage(context, nextPost);
    });
  }

  void goRandomContent() {
    youtubePause();

    Func.futurePost.then((post) {
      Post nextPost = Func.getRandomPost(ArtiqData.category, post);

      Func.goContentPage(context, nextPost);
    });
  }

  void goNextContent() {
    youtubePause();

    Func.futurePost.then((post) {
      Post nextPost = Func.getNextPost(ArtiqData.category, post);

      Func.goContentPage(context, nextPost);
    });
  }

  void sendAnalyticsEvent(Post post) async {
    await analytics.logEvent(name: "post_name", parameters: <String, dynamic>{'string': post.imageText});
  }

  Column getContentList(BuildContext context, Post post) {
    sendAnalyticsEvent(post);

    List<Content> contentList = post.content;
    List<Widget> conContentList = contentList.map((content) {
      switch (content.type) {
        case "text-title":
          return Container(
              margin: const EdgeInsets.only(top: 30, bottom: 10),
              alignment: Alignment.topLeft,
              child: Text(
                content.data,
                style: GoogleFonts.notoSans(textStyle: TextStyle(color: Color(0xffffffff), height: 1.5, fontSize: 18, fontWeight: FontWeight.bold)),
              ));
          break;
        case "image":
          return Container(
            margin: const EdgeInsets.only(top: 20, bottom: 40),
            child: Column(
              children: <Widget>[
                CachedNetworkImage(
                  imageUrl: content.data,
                  fit: BoxFit.cover,
                ),
                Text(content.desc, style: GoogleFonts.notoSans(textStyle: TextStyle(color: ArtiqData.greyPinkColor, height: 1.5, fontSize: 13)))
              ],
            ),
          );
          break;
        case "youtube":
          musicGenre = post.genre;

          return Container(
            height: MediaQuery.of(context).size.height * 0.55,
            margin: const EdgeInsets.only(top: 20, bottom: 40),
            child: FlutterYoutubeView(
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
            margin: const EdgeInsets.only(bottom: 20),
            alignment: Alignment.topLeft,
            child: Text(content.data, style: GoogleFonts.notoSans(textStyle: TextStyle(color: Color(0xffffffff), height: 1.5, fontSize: 16))),
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
        backgroundColor: Color(0xff2B2B2B),
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 56.0),
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
                        return FutureBuilder<Post>(
                          future: getFuturePost(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return SizedBox(
                                child: Column(
                                  children: <Widget>[
                                    Stack(
                                      children: <Widget>[
                                        Container(
                                          width: MediaQuery.of(context).size.width,
                                          height: MediaQuery.of(context).size.height * 0.26,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(image: CachedNetworkImageProvider(snapshot.data.imageUrl), fit: BoxFit.cover),
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(50),
                                              bottomRight: Radius.circular(50),
                                            ),
                                          ),
                                          child: Column(
                                            children: <Widget>[
                                              Container(
                                                alignment: Alignment.topLeft,
                                                margin: const EdgeInsets.only(top: 15, left: 15),
                                                child: InkWell(
                                                  highlightColor: Colors.transparent,
                                                  splashColor: Colors.transparent,
                                                  onTap: () {
                                                    return Navigator.pop(context, true);
                                                  },
                                                  child: Icon(Icons.arrow_back,
                                                      size: 35, color: (snapshot.data.backBtnType == 'w') ? Colors.white : Colors.black),
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
                                      child: Text(
                                        snapshot.data.imageText,
                                        style: GoogleFonts.nanumGothic(
                                            textStyle: TextStyle(color: Color(0xffFFFFFF), height: 1.5, fontSize: 17, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(30, 10, 30, 0),
                                      alignment: Alignment.topCenter,
                                      child: Text(snapshot.data.origin,
                                          style:
                                              GoogleFonts.notoSans(textStyle: TextStyle(color: ArtiqData.darkGreyColor, height: 1.5, fontSize: 15))),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(30, 10, 30, 0),
                                      alignment: Alignment.topLeft,
                                      child: getContentList(context, snapshot.data),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(30, 0, 30, 30),
                                      alignment: Alignment.topLeft,
                                      height: 40,
                                      child: Row(
                                        children: <Widget>[
                                          Text(snapshot.data.date,
                                              style:
                                                  GoogleFonts.notoSans(textStyle: TextStyle(color: ArtiqData.darkGreyColor, height: 1, fontSize: 16)))
                                        ],
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
                    backgroundColor: ArtiqData.fluorescenceColor,
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
                        color: Colors.black,
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
                    backgroundColor: ArtiqData.darkGreyColor,
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
                    backgroundColor: ArtiqData.darkGreyColor,
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
                    backgroundColor: ArtiqData.darkGreyColor,
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
                    backgroundColor: ArtiqData.darkGreyColor,
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
