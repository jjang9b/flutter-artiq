import 'dart:io';

import 'package:artiq/sql/artiqDb.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class SqlLite {
  SqlLite._();

  static final SqlLite db = SqlLite._();

  factory SqlLite() => db;
  static Database _database;
  String dbName = 'artiq.db';
  String table = 'artiq';

  Future<Database> get database async {
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, dbName);
    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute(
          "CREATE TABLE ${table}(id INTEGER PRIMARY KEY, key TEXT, data TEXT, date TEXT)");
    }, onOpen: (db) async {
      await db.execute(
          "CREATE TABLE IF NOT EXISTS ${table}(id INTEGER PRIMARY KEY, key TEXT, data TEXT, date TEXT)");
    });
  }

  get(String key) async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query(table, where: 'key = ?', whereArgs: [key]);
    if (maps.length == 0) {
      return null;
    }

    return ArtiqDb(
        id: maps[0]['id'],
        key: maps[0]['key'],
        data: maps[0]['data'],
        date: maps[0]['date']);
  }

  upsert(ArtiqDb artiqDb) async {
    final db = await database;
    var res = await db.insert(table, artiqDb.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return res;
  }

  Future<void> delete(String key) async {
    final db = await database;

    await db.delete(
      table,
      where: "key = ?",
      whereArgs: [key],
    );
  }
}
