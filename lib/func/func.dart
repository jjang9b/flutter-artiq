import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:artiq/page/contentPage.dart';
import 'package:artiq/data.dart';

class Func {
  double _page = 0;
  bool isStart = false;

  setPage(double page) {
    this._page = page;
  }

  _getScale(int position) {
    double scale = 1 - (_page - position).abs();

    return (scale < 0.8) ? 0.8 : scale;
  }

  void openPage(BuildContext context, Post post) {
    Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context) {
      return new Content().contentPage(context, post);
    }));
  }

  Center getContent(BuildContext context, int position, Post post) {
    Alignment originAlign = Alignment.bottomLeft;

    if (position % 2 == 0) {
      originAlign = Alignment.bottomRight;
    }

    return Center(
      child: Transform.scale(
        scale: _getScale(position),
        child: Stack(
          overflow: Overflow.visible,
          children: <Widget>[
            InkWell(
              onTap: () {
                openPage(context, post);
              },
              child: Container(
                color: Colors.black,
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.height * 0.6,
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
          ],
        ),
      ),
    );
  }
}
