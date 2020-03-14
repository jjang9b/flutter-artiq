import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

Future<List<Post>> fetchStory() async {
  var uri =
      Uri.parse("https://us-central1-story-api-ce270.cloudfunctions.net/data");

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    List list = json.decode(response.body);

    return list.map((story) => Post.fromJson(story)).toList();
  } else {
    throw Exception('Failed to load album');
  }
}

class Post {
  final String imageUrl;
  final String imageText;
  final String content;
  final String origin;
  final String date;

  Post({this.imageUrl, this.imageText, this.content, this.origin, this.date});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      imageUrl: json['image'],
      imageText: json['imageText'],
      content: json['content'],
      origin: json['origin'],
      date: json['date'],
    );
  }
}
