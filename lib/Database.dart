import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'DishModel.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();

  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "dishes.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute("PRAGMA foreign_keys = ON");
      await db.execute("CREATE TABLE dishes ("
          "id INTEGER PRIMARY KEY,"
          "name TEXT"
          ")");
      await db.execute("CREATE TABLE days_dishes ("
          "day INTEGER,"
          "ordering INTEGER,"
          "dish INTEGER,"
          "note TEXT,"
          "FOREIGN KEY (dish)"
          "  REFERENCES dishes (id)"
          ")");
    });
  }

  newDish(Dish newDish) async {
    final db = await database;
    var raw = await db.rawInsert(
        "INSERT INTO dishes (name)"
        " VALUES (?)",
        [newDish.name]);
    return raw;
  }

  addDishToDay(int day, int order, int dish, String note) async {
    final db = await database;
    var raw = await db.rawInsert(
        "INSERT INTO days_dishes (day,ordering,dish,note)"
        " VALUES (?,?,?,?)",
        [day, order, dish, note]);
    return raw;
  }

  updateDish(Dish newDish) async {
    final db = await database;
    var res = await db.update("dishes", newDish.toMap(),
        where: "id = ?", whereArgs: [newDish.id]);
    return res;
  }

  getDish(int id) async {
    final db = await database;
    var res = await db.query("dishes", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? Dish.fromMap(res.first) : null;
  }

  Future<List<Dish>> getAllDishes() async {
    final db = await database;
    var res = await db.query("dishes");
    List<Dish> list =
        res.isNotEmpty ? res.map((c) => Dish.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<Dish>> getDay(int day) async {
    final db = await database;
    var res = await db.rawQuery("SELECT l.day AS day, l.ordering AS ordering, l.note AS note, r.id AS dish, r.name AS name FROM days_dishes l LEFT JOIN dishes r ON l.dish = r.id WHERE day=?", [day]);
    List<Dish> list =
        res.isNotEmpty ? res.map((c) => Dish.fromMap(c)).toList() : [];
    return list;
  }

  deleteDish(int id) async {
    final db = await database;
    return db.delete("dishes", where: "id = ?", whereArgs: [id]);
  }

  deleteAll() async {
    final db = await database;
    db.rawDelete("DELETE * FROM dishes");
  }
}