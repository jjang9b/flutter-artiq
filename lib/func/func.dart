import 'dart:async';
import 'dart:math';

import 'package:artiq/data/artiqData.dart';
import 'package:artiq/data/httpData.dart';
import 'package:artiq/page/contentPage.dart';
import 'package:artiq/page/postPage.dart';
import 'package:artiq/sql/artiqDb.dart';
import 'package:artiq/sql/sqlLite.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';

class Func {
  static Fetch fetch = new Fetch();
  static Future<List<Guide>> futureGuideList = fetch.fetchGuide();
  static Future<Ads> futureAds = fetch.fetchAds('music');
  static Future<List<Post>> futurePostList;
  static Future<Post> futurePost;
  static double _categoryPage = 0;

  static Future<List<Post>> fetchPost(String category) async {
    String maxGenre = await getMaxGenre();

    if (maxGenre != null) {
      ArtiqData.likeGenre = maxGenre.replaceAll("music-", "");
    }

    futurePostList = fetch.fetchPost(category);

    return futurePostList;
  }

  static Future<List<Guide>> getGuideList() {
    return futureGuideList;
  }

  static Future<Ads> getAds() {
    return futureAds;
  }

  static Future<List<Post>> getPostList() {
    if (futurePostList == null) {
      return fetchPost("music");
    }

    return futurePostList;
  }

  static void insertIsFavorite(bool isFavorite) async {
    await SqlLite().delete("isFavorite");

    await SqlLite().insert(ArtiqDb(key: "isFavorite", data: isFavorite.toString()));
  }

  static void setIsFavorite() async {
    ArtiqDb artiqDb = await SqlLite().get("isFavorite");

    if (artiqDb != null) {
      ArtiqData.isFavoriteMusic = (artiqDb.data == "true");
    }
  }

  static void refreshInit() {
    if (ArtiqData.refreshTimer != null) {
      ArtiqData.refreshTimer.cancel();
    }

    ArtiqData.refreshSec = 0;
    ArtiqData.refreshColor = Colors.black;
  }

  static void refreshPost(BuildContext context, PageController _pageController) async {
    ArtiqData.refreshColor = Colors.red;
    ArtiqData.refreshSec = ArtiqData.refreshPerSec;

    Post.emptyFutureMap(ArtiqData.category);
    Func.futurePostList = fetchPost(ArtiqData.category);

    _pageController.jumpToPage(0);
  }

  static Post getRandomPost(String category, Post post) {
    List<Post> postList = Post.getPostList(category);

    var random = new Random();
    var ran = random.nextInt(postList.length);
    var now = postList.indexOf(post);

    while (ran == now) {
      ran = random.nextInt(postList.length);

      if (ran < 0 || ran >= postList.length) {
        break;
      }
    }

    return postList[ran];
  }

  static Post getBeforePost(String category, Post post) {
    List<Post> postList = Post.getPostList(category);

    int bef = postList.indexOf(post) - 1;
    if (bef < 0) {
      bef = postList.length - 1;
    }

    return postList[bef];
  }

  static Post getNextPost(String category, Post post) {
    List<Post> postList = Post.getPostList(category);

    int next = postList.indexOf(post) + 1;
    if (next >= postList.length) {
      next = 0;
    }

    return postList[next];
  }

  static void refreshAds(String category) {
    Func.futureAds = fetch.fetchAds(category);
  }

  static void setData(String category, int categoryIdx) {
    ArtiqData.category = category;
    ArtiqData.categoryIdx = categoryIdx;
    Func.futurePostList = fetchPost(category);

    refreshAds(category);
  }

  static void setCategoryPage(double categoryPage) {
    Func._categoryPage = categoryPage;
  }

  static void categoryTab(PageController _categoryController, String category, int categoryIdx) {
    setData(category, categoryIdx);
    _categoryController.jumpToPage(categoryIdx);
  }

  static void goPostPage(BuildContext context) {
    Func.refreshInit();

    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (BuildContext context) {
              return PostPage();
            },
            settings: RouteSettings(name: PostPage.routeName)));
  }

  static void goContentPage(BuildContext context, Post post) {
    Func.futurePost = new Future<Post>.value(post);
    Func.refreshInit();

    refreshAds(ArtiqData.category);

    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (BuildContext context) {
              return ContentPage(post);
            },
            settings: RouteSettings(name: ContentPage.routeName)));
  }

  static void goPage(BuildContext context, String routeName) {
    Func.refreshInit();

    Navigator.pushNamed(context, routeName);
  }

  static void goPageRemove(BuildContext context, String routeName) {
    Func.refreshInit();

    Navigator.pushNamedAndRemoveUntil(context, routeName, (_) => false);
  }

  static InkWell getCategory(PageController _categoryController, String category, String title, int idx) {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () {
        if (ArtiqData.isPostScrolling) {
          return;
        }

        categoryTab(_categoryController, category, idx);
      },
      child: Container(
        margin: EdgeInsets.only(top: 15, left: 20, right: 20, bottom: 5),
        child: Column(
          children: <Widget>[
            Text(
              title,
              style: TextStyle(color: ArtiqData.backgroundColor, fontSize: 15, fontFamily: 'UTOIMAGE', fontWeight: FontWeight.bold),
            ),
            Visibility(
              visible: (_categoryPage == idx),
              child: Container(
                width: 20,
                height: 5,
                margin: EdgeInsets.only(top: 5),
                decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(3)), color: Color(0xff2B2B2B), shape: BoxShape.rectangle),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static InkWell getContent(BuildContext context, int length, int position, Post post) {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () {
        goContentPage(context, post);
      },
      child: Stack(
        children: <Widget>[
          ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height * 0.105,
            ),
            child: Container(
              margin: EdgeInsets.only(top: 5, right: 10, bottom: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xff55545D), width: 0),
                borderRadius: BorderRadius.all(
                  Radius.circular(5),
                ),
              ),
              child: Row(
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width * 0.12,
                        height: MediaQuery.of(context).size.width * 0.12,
                        margin: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
                        child: CachedNetworkImage(
                          imageUrl: post.imageUrl,
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 0),
                              borderRadius: BorderRadius.all(Radius.circular(5)),
                              image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.72,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.topLeft,
                          margin: EdgeInsets.only(top: 5, left: 15, right: 15),
                          child: Text(post.imageText,
                              overflow: TextOverflow.visible,
                              style: GoogleFonts.nanumGothic(
                                  textStyle: TextStyle(color: Color(0xffffffff), height: 1.5, fontSize: 12.5, fontWeight: FontWeight.bold))),
                        ),
                        Container(
                          alignment: Alignment.topLeft,
                          margin: EdgeInsets.only(top: 7, left: 15, right: 15, bottom: 10),
                          child: Container(
                            alignment: Alignment.centerLeft,
                            margin: EdgeInsets.only(right: 8),
                            child: Row(
                              children: <Widget>[
                                Text(post.origin,
                                    style: GoogleFonts.notoSans(textStyle: TextStyle(color: ArtiqData.darkGreyColor, height: 1.3, fontSize: 13))),
                                Visibility(
                                  visible: (ArtiqData.likeGenre != "" && post.genre == ArtiqData.likeGenre),
                                  child: Container(
                                    width: 54,
                                    height: 17,
                                    margin: EdgeInsets.only(left: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.all(Radius.circular(5)),
                                    ),
                                    child: Container(
                                      margin: EdgeInsets.only(top: 3, left: 5),
                                      child: Text("post.musicFriendly",
                                              overflow: TextOverflow.visible,
                                              style: GoogleFonts.nanumGothic(
                                                  textStyle: TextStyle(color: Colors.white, height: 1, fontSize: 11, fontWeight: FontWeight.bold)))
                                          .tr(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Future<String> getMaxGenre() async {
    var key = "music-";

    ArtiqDb artiqDb = await SqlLite().getLikeMax(key);
    if (artiqDb == null) {
      return null;
    }

    return artiqDb.key;
  }

  static void setPlayCount(String genre) async {
    var key = "music-" + genre;

    ArtiqDb artiqDb = await SqlLite().get(key);
    if (artiqDb == null) {
      await SqlLite().insert(ArtiqDb(key: key, count: 1));
      return;
    }

    if (artiqDb.count == null) {
      artiqDb.count = 1;
      await SqlLite().update(artiqDb);
      return;
    }

    artiqDb.count += 1;

    await SqlLite().update(artiqDb);
  }

  static void initGenre() async {
    await SqlLite().deleteLike("music-");
  }
}
