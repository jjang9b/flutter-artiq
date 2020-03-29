import 'dart:math';

import 'package:artiq/data.dart';
import 'package:artiq/page/contentPage.dart';
import 'package:artiq/page/morePage.dart';
import 'package:artiq/page/postPage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Func {
  static Fetch fetch = new Fetch();
  static Future<List<Guide>> futureGuideList = fetch.fetchGuide();
  static Future<List<Post>> futureData = fetch.fetchPost('music');
  static double _categoryPage = 0;
  static double _postPage = 0;

  static Future<List<Guide>> getGuideList() {
    return futureGuideList;
  }

  static Future<List<Post>> getPostList() {
    return futureData;
  }

  static Post getRandomPost(String category, Post post) {
    List<Post> postList = ArtiqData.getPostList(category);

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
    List<Post> postList = ArtiqData.getPostList(category);

    int bef = postList.indexOf(post) - 1;
    if (bef < 0) {
      bef = postList.length - 1;
    }

    return postList[bef];
  }

  static Post getNextPost(String category, Post post) {
    List<Post> postList = ArtiqData.getPostList(category);

    int next = postList.indexOf(post) + 1;
    if (next >= postList.length) {
      next = 0;
    }

    return postList[next];
  }

  static void setData(String category, int categoryIdx) {
    ArtiqData.category = category;
    ArtiqData.categoryIdx = categoryIdx;
    Func.futureData = fetch.fetchPost(category);
  }

  static void setCategoryPage(double categoryPage) {
    Func._categoryPage = categoryPage;
  }

  static double getPostPage() {
    return _postPage.abs();
  }

  static void setPostPage(double page) {
    Func._postPage = page;
  }

  static double getScale(int position) {
    return 1;
  }

  static void categoryTab(
      PageController _categoryController, String category, int categoryIdx) {
    setData(category, categoryIdx);
    _categoryController.jumpToPage(categoryIdx);
    setPostPage(0);
  }

  static void goContentPage(BuildContext context, Post post) {
    Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context) {
      return new ContentPage(post);
    }));
  }

  static void goPage(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  static InkWell getCategory(PageController _categoryController,
      String category, String title, int idx) {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () {
        categoryTab(_categoryController, category, idx);
      },
      child: Container(
        margin: EdgeInsets.only(top: 10, right: 20),
        child: Column(
          children: <Widget>[
            Text(
              title,
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Arita'),
            ),
            Visibility(
              visible: (_categoryPage == idx),
              child: Container(
                width: 20,
                height: 5,
                margin: EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                    color: Colors.red,
                    shape: BoxShape.rectangle),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Container getContent(
      BuildContext context, int length, int position, Post post) {
    Alignment originAlign = Alignment.bottomLeft;

    if (position % 2 == 0) {
      originAlign = Alignment.bottomRight;
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      child: Transform.scale(
        scale: getScale(position),
        child: Column(
          children: <Widget>[
            InkWell(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              onTap: () {
                goContentPage(context, post);
              },
              child: Container(
                height: MediaQuery.of(context).size.height * 0.6,
                child: Column(
                  children: <Widget>[
                    Container(
                      height: MediaQuery.of(context).size.height * 0.4,
                      child: CachedNetworkImage(
                        imageUrl: post.imageUrl,
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: imageProvider, fit: BoxFit.cover),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 20, right: 20, bottom: 12),
                      alignment: originAlign,
                      child: Text(post.imageText,
                          style: TextStyle(
                              color: Colors.black,
                              height: 1.2,
                              fontSize: 21,
                              fontFamily: 'UTOIMAGE')),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 20, right: 20, bottom: 35),
                      alignment: originAlign,
                      child: Text(post.origin,
                          style: TextStyle(
                              color: Colors.black,
                              height: 1.3,
                              fontSize: 14,
                              fontFamily: 'JSDongkang')),
                    )
                  ],
                ),
              ),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              width: MediaQuery.of(context).size.width * 0.68,
              margin: EdgeInsets.only(top: 8),
              child: DotsIndicator(
                dotsCount: (length >= 0) ? length : 0,
                position: getPostPage(),
                decorator: DotsDecorator(
                  activeSize: Size.fromRadius(5),
                  activeShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0)),
                  color: Colors.black26,
                  activeColor: Colors.black87,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  static Container getNavigator(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(50, 0, 50, 10),
      height: MediaQuery.of(context).size.height * 0.05,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: () {
              if (ArtiqData.isPostScrolling) {
                return;
              }

              goPage(context, PostPage.routeName);
            },
            child: Container(
              width: 45,
              height: 60,
              margin: EdgeInsets.only(left: 20, top: 6, right: 20),
              child: Column(
                children: <Widget>[
                  Icon(
                    Icons.wallpaper,
                    size: 27,
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: () {
              goPage(context, MorePage.routeName);
            },
            child: Container(
              width: 45,
              height: 60,
              margin: EdgeInsets.only(top: 6),
              child: Column(
                children: <Widget>[
                  Icon(
                    Icons.more_horiz,
                    size: 27,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
