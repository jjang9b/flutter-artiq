class ArtiqDb {
  int id;
  String key;
  String data;
  String date;

  ArtiqDb({this.id, this.key, this.data, this.date});

  Map<String, dynamic> toMap() {
    return {'id': id, 'key': key, 'data': data, 'date': date};
  }
}
