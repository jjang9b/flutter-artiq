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
    return await openDatabase(path, version: 2, onCreate: (db, version) async {
      await db.execute("CREATE TABLE ${table}(id INTEGER PRIMARY KEY, key TEXT, data TEXT, count INTEGER, date TEXT)");
    }, onOpen: (db) async {
      await db.execute("CREATE TABLE IF NOT EXISTS ${table}(id INTEGER PRIMARY KEY, key TEXT, data TEXT, count INTEGER, date TEXT)");
    }, onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 2) {
        await db.execute("DROP TABLE IF EXISTS ${table}");
      }
    });
  }

  get(String key) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(table, where: 'key = ?', whereArgs: [key]);
    if (maps.length == 0) {
      return null;
    }

    return ArtiqDb(id: maps[0]['id'], key: maps[0]['key'], data: maps[0]['data'], count: maps[0]['count'], date: maps[0]['date']);
  }

  getLikeMax(String key) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery("SELECT key, MAX(count) as 'count' FROM " + table + " WHERE key LIKE ?", ['%$key%']);
    if (maps.length == 0) {
      return null;
    }

    return ArtiqDb(key: maps[0]['key'], count: maps[0]['count']);
  }

  insert(ArtiqDb artiqDb) async {
    final db = await database;
    var res = await db.insert(table, artiqDb.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    return res;
  }

  update(ArtiqDb artiqDb) async {
    final db = await database;
    var res = await db.update(table, artiqDb.toMap(), where: "id = ?", whereArgs: [artiqDb.id]);
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

  Future<void> deleteLike(String key) async {
    final db = await database;

    await db.delete(
      table,
      where: "key LIKE ?",
      whereArgs: ['%$key%'],
    );
  }
}
