import 'dart:async';
import 'dart:ui';

import 'package:artiq/data.dart';
import 'package:artiq/func/func.dart';
import 'package:artiq/sql/artiqDb.dart';
import 'package:artiq/sql/sqlLite.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PostPage extends StatefulWidget {
  static const routeName = '/post';

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  PageController _categoryController = new PageController();
  PageController _pageController = new PageController();
  Fetch fetch = new Fetch();
  Func func = new Func();
  bool isRefresh = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      func.categoryTab(
          _categoryController, ArtiqData.category, ArtiqData.categoryIdx);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 30),
                  height: MediaQuery.of(context).size.height * 0.08,
                  child: Stack(
                    children: <Widget>[
                      Container(
                        alignment: Alignment.topLeft,
                        margin: EdgeInsets.only(top: 25),
                        child: Column(
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width * 0.6,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "A",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'UTOIMAGE'),
                                  ),
                                  Text(
                                    "r",
                                    style: TextStyle(
                                        color: Color(0xffffd54f),
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'UTOIMAGE'),
                                  ),
                                  Text(
                                    "t",
                                    style: TextStyle(
                                        color: Color(0xff455a64),
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'UTOIMAGE'),
                                  ),
                                  Text(
                                    "i",
                                    style: TextStyle(
                                        color: Color(0xffef0078),
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'UTOIMAGE'),
                                  ),
                                  Text(
                                    "Q",
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'UTOIMAGE'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 30),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.08,
                    child: Row(
                      children: <Widget>[
                        func.getCategory(
                            _categoryController, 'music', 'MUSIC', 0),
                        func.getCategory(_categoryController, 'art', 'ART', 1),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 30),
                  height: MediaQuery.of(context).size.height * 0.71,
                  child: Container(
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (scrollNotification) {
                        setState(() {
                          func.setCategoryPage(_categoryController.page);
                        });

                        return true;
                      },
                      child: PageView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          controller: _categoryController,
                          itemBuilder: (context, position) {
                            return Container(
                              child: FutureBuilder<List<Post>>(
                                future: func.getPostList(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return NotificationListener<
                                            ScrollNotification>(
                                        onNotification: (scrollNotification) {
                                          setState(() {
                                            func.setPage(_pageController.page);
                                          });

                                          return true;
                                        },
                                        child: PageView.builder(
                                          controller: _pageController,
                                          itemBuilder: (context, position) {
                                            return func.getContent(
                                                context,
                                                snapshot.data.length,
                                                position,
                                                snapshot.data[position]);
                                          },
                                          itemCount: snapshot.data.length,
                                        ));
                                  }

                                  return Center(
                                    child: CircularProgressIndicator(
                                      backgroundColor: Colors.black,
                                      valueColor:
                                          new AlwaysStoppedAnimation<Color>(
                                              Colors.white),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                          itemCount: 2),
                    ),
                  ),
                ),
                func.getNavigator(context)
              ],
            )
          ],
        ),
      ),
    );
  }
}
