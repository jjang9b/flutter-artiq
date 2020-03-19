import 'package:artiq/data.dart';
import 'package:artiq/main.dart';
import 'package:artiq/page/contentPage.dart';
import 'package:artiq/page/morePage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Func {
  Fetch fetch = new Fetch();
  Future<List<Post>> futureData;
  double _categoryPage = 0;
  double _page = 0;

  Func() {
    futureData = fetch.fetchPost('art');
  }

  Future<List<Post>> getData() {
    return futureData;
  }

  Post getNextPost(String type, Post post) {
    List<Post> postList = ArtiqData.getPostList(type);

    int next = postList.indexOf(post) + 1;

    return postList[next];
  }

  void setData(String type) {
    this.futureData = fetch.fetchPost(type);
  }

  void setCategoryPage(double categoryPage) {
    this._categoryPage = categoryPage;
  }

  void setPage(double page) {
    this._page = page;
  }

  double getScale(int position) {
    double scale = 1 - (_page - position).abs();

    return (scale < 0.8) ? 0.8 : scale;
  }

  void categoryTab(
      PageController _categoryController, String type, int categoryIdx) {
    setData(type);
    _categoryController.jumpToPage(categoryIdx);
    setPage(0);
  }

  void goContentPage(BuildContext context, Post post) {
    Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context) {
      return new ContentPage(post);
    }));
  }

  void goPage(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  InkWell getCategory(
      PageController _categoryController, String type, String title, int idx) {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () {
        categoryTab(_categoryController, type, idx);
      },
      child: Container(
        width: 70,
        margin: EdgeInsets.all(10),
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
                    color: Color(0xffef0078),
                    shape: BoxShape.rectangle),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Center getContent(BuildContext context, int length, int position, Post post) {
    Alignment originAlign = Alignment.bottomLeft;

    if (position % 2 == 0) {
      originAlign = Alignment.bottomRight;
    }

    return Center(
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
                width: MediaQuery.of(context).size.width * 0.68,
                height: MediaQuery.of(context).size.height * 0.6,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.all(Radius.circular(3)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Container(
                      height: MediaQuery.of(context).size.height * 0.47,
                      child: CachedNetworkImage(
                        imageUrl: post.imageUrl,
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: imageProvider, fit: BoxFit.cover),
                            borderRadius: BorderRadius.all(Radius.circular(3)),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 20, right: 20, bottom: 5),
                      alignment: originAlign,
                      child: Text(post.imageText,
                          style: TextStyle(
                              color: Colors.white,
                              height: 1.2,
                              fontSize: 21,
                              fontFamily: 'UTOIMAGE')),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
                      alignment: originAlign,
                      child: Text(post.origin,
                          style: TextStyle(
                              color: Colors.white,
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
                dotsCount: length,
                position: _page.abs(),
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

  Container getNavigator(BuildContext context) {
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
