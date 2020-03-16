import 'package:cached_network_image/cached_network_image.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:artiq/data.dart';

class ContentPage {
  YoutubePlayerController _youtubueController;

  Scaffold goContent(BuildContext context, Post post) {
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
                                  image:
                                      CachedNetworkImageProvider(post.imageUrl),
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
                                      color: Colors.white,
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
                      child: getContentList(post.content),
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
    );
  }

  Column getContentList(List<Content> contentList) {
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

        return Container(
          margin: EdgeInsets.only(top: 20, bottom: 40),
          child: YoutubePlayer(
            controller: _youtubueController,
            showVideoProgressIndicator: false,
            bottomActions: <Widget>[
              PlayPauseButton(),
              ProgressBar(isExpanded: true)
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
}
