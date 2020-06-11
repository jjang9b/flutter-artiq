class ArtiqDb {
  int id;
  String key;
  String data;
  int count;
  String date;

  ArtiqDb({this.id, this.key, this.data, this.count, this.date});

  Map<String, dynamic> toMap() {
    return {'id': id, 'key': key, 'data': data, 'count': count, 'date': date};
  }
}
