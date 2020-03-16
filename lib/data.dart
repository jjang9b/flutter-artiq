import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:http/http.dart' as http;

class FutureMap {
  Map<String, List<Post>> futureMap;

  FutureMap() {
    futureMap = new HashMap();
  }

  void setFutureMap(String key, List<Post> futureList) {
    futureMap[key] = futureList;
  }

  List<Post> getFutureMap(String key) {
    return futureMap[key];
  }
}

class Fetch {
  FutureMap futureMap;

  Fetch() {
    futureMap = new FutureMap();
  }

  Future<List<Post>> fetchPost(String type) async {
    List<Post> cacheMap = futureMap.getFutureMap(type);
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

      futureMap.setFutureMap(type, result);

      return result;
    } else {
      throw Exception('Failed to load album');
    }
  }
}

class Post {
  final String imageUrl;
  final String imageText;
  final List<Content> content;
  final String origin;
  final String date;

  Post({this.imageUrl, this.imageText, this.content, this.origin, this.date});

  factory Post.fromJson(Map<String, dynamic> json) {
    var contentList = json['content'] as List;

    return Post(
      imageUrl: json['image'],
      imageText: json['imageText'],
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
