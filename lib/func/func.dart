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
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.height * 0.6,
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                    image: DecorationImage(
                        image: NetworkImage(post.imageUrl), fit: BoxFit.cover)),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Container(),
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(25, 0, 20, 0),
                      alignment: originAlign,
                      child: Text(post.imageText,
                          style: TextStyle(
                              color: Colors.white,
                              height: 1.6,
                              fontSize: 20,
                              fontFamily: 'UTOIMAGE')),
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(25, 0, 20, 30),
                      alignment: originAlign,
                      child: Text(post.origin,
                          style: TextStyle(
                              color: Colors.white,
                              height: 1.6,
                              fontSize: 16,
                              fontFamily: 'JSDongkang')),
                    ),
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
