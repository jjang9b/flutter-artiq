import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

final Map<String, List<Post>> futureMap = new Map<String, List<Post>>();

class ArtiqData {
  static bool isMusicAuto = false;

  static List<Post> getPostList(String type) {
    return futureMap[type];
  }
}

class Fetch {
  Future<List<Post>> fetchPost(String type) async {
    List<Post> cacheMap = futureMap[type];
    if (cacheMap != null) {
      return cacheMap;
    }

    var uri;

    switch (type) {
      case "art":
        uri = Uri.parse("https://us-central1-artiq-api.cloudfunctions.net/art");
        break;
      case "music":
        uri =
            Uri.parse("https://us-central1-artiq-api.cloudfunctions.net/music");
        break;
    }

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      List postList = json.decode(response.body);

      List<Post> result = postList.map((post) => Post.fromJson(post)).toList();

      futureMap[type] = result;

      return result;
    } else {
      throw Exception('Failed to load album');
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

  Post(
      {this.imageUrl,
      this.imageText,
      this.backBtnType,
      this.content,
      this.origin,
      this.date});

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
