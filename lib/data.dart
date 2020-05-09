import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Map<String, List<Post>> futureMap = new Map<String, List<Post>>();

class ArtiqData {
  static String categoryMusic = "music";
  static String categoryArt = "art";
  static String category = categoryMusic;
  static int categoryIdx = 0;
  static var musicNextStateIcon = [Icons.repeat_one, Icons.repeat, Icons.shuffle];
  static var musicNextStateArr = ["repeat", "auto", "shuffle"];
  static int musicNextStateIdx = 0;
  static String musicNextState = musicNextStateArr[0];
  static bool isOnload = false;
  static bool isPostScrolling = false;
  static String version = "1.0.12";

  static Timer refreshTimer;
  static int refreshPerSec = 20;
  static int refreshSec = 0;
  static Color refreshColor;

  static List<Post> getPostList(String type) {
    return futureMap[type];
  }

  static void emptyFutureMap(String category) {
    futureMap[category] = null;
  }
}

class Fetch {
  Future<List<Guide>> fetchGuide() async {
    var uri = Uri.parse("https://asia-northeast1-artiq-api-7d81d.cloudfunctions.net/guide");

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      List list = json.decode(response.body);

      return list.map((post) => Guide.fromJson(post)).toList();
    } else {
      return null;
    }
  }

  Future<List<Post>> fetchPost(String category) async {
    List<Post> cacheMap = futureMap[category];

    if (cacheMap != null) {
      return cacheMap;
    }

    var uri;

    switch (category) {
      case "art":
        uri = Uri.parse("https://asia-northeast1-artiq-api-7d81d.cloudfunctions.net/art");
        break;
      case "music":
        uri = Uri.parse("https://asia-northeast1-artiq-api-7d81d.cloudfunctions.net/music");
        break;
    }

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      List postList = json.decode(response.body);

      List<Post> result = postList.map((post) => Post.fromJson(post)).toList();
      futureMap[category] = result;

      if (!ArtiqData.isOnload) {
        ArtiqData.isOnload = true;
      }

      return result;
    } else {
      return null;
    }
  }
}

class Post {
  final String imageUrl;
  final String imageText;
  final String backBtnType;
  final List<Content> content;
  final String origin;
  final String date;

  Post({this.imageUrl, this.imageText, this.backBtnType, this.content, this.origin, this.date});

  factory Post.fromJson(Map<String, dynamic> json) {
    var contentList = json['content'] as List;

    return Post(
      imageUrl: json['image'],
      imageText: json['imageText'],
      backBtnType: json['backBtnType'],
      content: contentList.map((content) => Content.fromJson(content)).toList(),
      origin: json['origin'],
      date: json['date'],
    );
  }
}

class Content {
  final String type;
  final String data;
  final String desc;

  Content({this.type, this.data, this.desc});

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      type: json['type'],
      data: json['data'],
      desc: json['desc'],
    );
  }
}

class Guide {
  final String image;
  final String title;
  final String text;

  Guide({this.image, this.title, this.text});

  factory Guide.fromJson(Map<String, dynamic> json) {
    return Guide(
      image: json['image'],
      title: json['title'],
      text: json['text'],
    );
  }
}
