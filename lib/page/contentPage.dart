import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:artiq/data.dart';

class Content {
  Scaffold contentPage(BuildContext context, Post post) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: 56.0),
          child: ListView.builder(
              itemBuilder: (context, position) {
                return Column(
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.35,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(post.imageUrl),
                                  fit: BoxFit.cover)),
                          child: Column(
                            children: <Widget>[
                              Container(
                                alignment: Alignment.topLeft,
                                margin: const EdgeInsets.fromLTRB(0, 10, 10, 0),
                                child: IconButton(
                                    iconSize: 60,
                                    icon: BackButton(
                                      color: Colors.white,
                                    ),
                                    onPressed: () =>
                                        Navigator.of(context).pop()),
                              ),
                              Expanded(
                                child: Container(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(30, 15, 30, 0),
                      alignment: Alignment.bottomCenter,
                      child: Text(post.origin,
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
                      child: Text(post.imageText,
                          style: TextStyle(
                              color: Colors.black,
                              height: 1.3,
                              fontSize: 22,
                              fontFamily: 'UTOIMAGE')),
                    ),
                    Container(
                      margin: const EdgeInsets.all(30),
                      alignment: Alignment.topLeft,
                      child: Text(post.content,
                          style: TextStyle(
                              color: Color(0xff313131),
                              height: 1.5,
                              fontSize: 17,
                              fontFamily: 'JSDongkang')),
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(30, 10, 30, 30),
                      alignment: Alignment.topLeft,
                      child: Row(
                        children: <Widget>[
                          Text(post.date,
                              style: TextStyle(
                                  color: Colors.black,
                                  height: 1,
                                  fontSize: 17,
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
    );
  }
}
