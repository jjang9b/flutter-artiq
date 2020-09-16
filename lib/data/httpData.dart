import 'dart:async';
import 'dart:convert';

import 'package:artiq/data/artiqData.dart';
import 'package:http/http.dart' as http;

Map<String, List<Post>> futureMap = new Map<String, List<Post>>();

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

  Future<Ads> fetchAds(String category) async {
    var uri;

    switch (category) {
      case "art":
        uri = Uri.parse("https://asia-northeast1-artiq-api-7d81d.cloudfunctions.net/adart");
        break;
      case "music":
        uri = Uri.parse("https://asia-northeast1-artiq-api-7d81d.cloudfunctions.net/admusic");
        break;
    }

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return Ads.fromJson(json.decode(response.body));
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
        uri = Uri.parse("https://asia-northeast1-artiq-api-7d81d.cloudfunctions.net/musiclike?genre=" + ArtiqData.likeGenre);
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
  final String genre;
  final List<Content> content;
  final String origin;
  final String date;

  Post({this.imageUrl, this.imageText, this.backBtnType, this.genre, this.content, this.origin, this.date});

  factory Post.fromJson(Map<String, dynamic> json) {
    var contentList = json['content'] as List;

    return Post(
      imageUrl: json['image'],
      imageText: json['imageText'],
      backBtnType: json['backBtnType'],
      genre: (json.containsKey("genre")) ? json['genre'] : "",
      content: contentList.map((content) => Content.fromJson(content)).toList(),
      origin: json['origin'],
      date: json['date'],
    );
  }

  static List<Post> getPostList(String type) {
    return futureMap[type];
  }

  static void emptyFutureMap(String category) {
    futureMap[category] = null;
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
  final double con1;
  final double con2;
  final double con3;

  Guide({this.image, this.title, this.text, this.con1, this.con2, this.con3});

  factory Guide.fromJson(Map<String, dynamic> json) {
    return Guide(
      image: json['image'],
      title: json['title'],
      text: json['text'],
      con1: (json['con1'] != null) ? double.parse(json['con1']) : null,
      con2: (json['con2'] != null) ? double.parse(json['con2']) : null,
      con3: (json['con3'] != null) ? double.parse(json['con3']) : null,
    );
  }
}

class Ads {
  final String url;

  Ads({this.url});

  factory Ads.fromJson(Map<String, dynamic> json) {
    return Ads(
      url: json['url'],
    );
  }
}
