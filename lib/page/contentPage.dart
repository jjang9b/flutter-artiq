import 'dart:async';
import 'dart:ui';

import 'package:artiq/data.dart';
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
  String playMode = "PAUSED";
  String musicGenre;
  bool isMoveBtn = true;
  bool isHeadsetInit = false;
  bool isHeadsetStop = false;
  bool isBackground = false;
  bool isPlayEnd = false;

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

        if (_youtubeController != null) {
          if (playMode != "PAUSED") {
            _youtubeController.play();
          }
        }

        MoveToBackground.moveTaskToBack();
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
      case "UNSTARTED":
        if (isBackground) {
          if (_youtubeController != null) {
            print("isPlayEnd : ${isPlayEnd}, isHeadsetStop : ${isHeadsetStop}");

            if (!isPlayEnd && !isHeadsetStop) {
              _youtubeController.play();
            }
          }
        }

        playMode = "PAUSED";
        break;
      case "PLAYING":
        playMode = "PLAYING";
        isHeadsetStop = false;

        if (ArtiqData.playLikeTimer == null) {
          ArtiqData.playLikeTimer = Timer.periodic(Duration(milliseconds: 5000), (timer) {
            playSec += 5;

            if (playSec >= 60) {
              Func.setPlayCount(musicGenre);

              ArtiqData.playLikeTimer = null;
              timer.cancel();
            }
          });
        }

        setState(() {
          isMoveBtn = true;
        });
        break;
      case "ENDED":
        isPlayEnd = true;
        isHeadsetStop = false;

        if (_youtubeController != null) {
          _youtubeController.seekTo(-5);
          _youtubeController.play();
          _youtubeController.pause();
        }

        Timer.periodic(Duration(milliseconds: 1000), (timer) {
          timer.cancel();
          isPlayEnd = false;

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
  void onError(String error) {}

  @override
  void onVideoDuration(double duration) {}

  @override
  void onCurrentSecond(double second) {}

  void listenHeadset() async {
    Stream<HeadsetEvent> stream = await Headset.subscribe();

    stream.listen((HeadsetEvent event) {
      bool isHeadset = event.toString().contains("isConnected: true");

      if (isHeadsetInit) {
        if (_youtubeController == null) {
          return;
        }

        if (!isHeadset) {
          _youtubeController.pause();
          isHeadsetStop = true;
          return;
        }

        return;
      }

      if (isHeadset) {
        isHeadsetInit = true;
      }
    });
  }

  void youtubePause() {
    if (_youtubeController != null) {
      _youtubeController.pause();
    }
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
          musicGenre = post.genre;

          return Container(
            height: MediaQuery.of(context).size.height * 0.55,
            margin: EdgeInsets.only(top: 20, bottom: 40),
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
            margin: EdgeInsets.only(bottom: 20),
            alignment: Alignment.topLeft,
            child: Text(content.data, style: GoogleFonts.notoSans(textStyle: TextStyle(color: Colors.black, height: 1.5, fontSize: 16))),
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
                                          height: MediaQuery.of(context).size.height * 0.25,
                                          decoration: BoxDecoration(
                                              image: DecorationImage(image: CachedNetworkImageProvider(snapshot.data.imageUrl), fit: BoxFit.cover)),
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
                                                  child:
                                                      Icon(Icons.arrow_back, color: (snapshot.data.backBtnType == 'w') ? Colors.white : Colors.black),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: 3),
                                      height: MediaQuery.of(context).size.height * 0.066,
                                      width: MediaQuery.of(context).size.width * 0.97,
                                      child: FutureBuilder<Ads>(
                                          future: Func.getAds(),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              return ClipRRect(
                                                borderRadius: BorderRadius.all(Radius.circular(5)),
                                                child: CachedNetworkImage(
                                                  imageUrl: snapshot.data.url,
                                                  fit: BoxFit.fitWidth,
                                                ),
                                              );
                                            }

                                            return Container();
                                          }),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(30, 20, 30, 0),
                                      alignment: Alignment.topCenter,
                                      child: Text(
                                        snapshot.data.imageText,
                                        style: GoogleFonts.nanumGothic(
                                            textStyle: TextStyle(color: Colors.black, height: 1.5, fontSize: 18.5, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(30, 10, 30, 0),
                                      alignment: Alignment.topCenter,
                                      child: Text(snapshot.data.origin,
                                          style: GoogleFonts.notoSans(textStyle: TextStyle(color: Colors.black, height: 1.5, fontSize: 15))),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(30, 30, 30, 10),
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
                                              style: GoogleFonts.notoSans(
                                                  textStyle: TextStyle(color: Colors.black, height: 1, fontSize: 17, fontWeight: FontWeight.bold)))
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
                                valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
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
