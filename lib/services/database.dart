import 'dart:async';
import 'dart:io';

import 'package:ober_menu_planner/model/category.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../model/dish.dart';

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

// persistenz ...
// kategorien und tags komplett aus db laden damit sie nicht jedesmal gelesen werden müssen
// dishes bei bedarf lesen ... oder lieber auch gleich komplett
// relationen dann auch dazu laden und datenmodell dazu komplett in memory ...
// aber das ist doch json oder nicht

// hive benutzen ... Code_CODE_OK

// dishes (id, name)
// days_dishes (day, ordering, dishid, note)
// categories (id, name)
// categories_dishes (dishid, categoryid)
// tags (id, name)
// tags_dishes (dishid, tagid)

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "dishes.db");

    // comment before release
    await deleteDatabase(path);

    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute("PRAGMA foreign_keys = ON");
      await db.execute("CREATE TABLE dishes ("
          "id INTEGER PRIMARY KEY,"
          "name TEXT,"
          "note TEXT"
          ")");
      await db.execute("CREATE TABLE days_dishes ("
          "day INTEGER,"
          "ordering INTEGER,"
          "dish INTEGER,"
          "note TEXT,"
          "FOREIGN KEY (dish) REFERENCES dishes (id)"
          ")");
      await db.execute("CREATE TABLE categories ("
          "id INTEGER PRIMARY KEY,"
          "name TEXT"
          ")");
      await db
          .rawInsert("INSERT INTO categories (name) VALUES (?)", ['Frühstück']);
      await db
          .rawInsert("INSERT INTO categories (name) VALUES (?)", ['Mittag']);
      await db.rawInsert(
          "INSERT INTO categories (name) VALUES (?)", ['Abendessen']);

      await db.execute("CREATE TABLE categories_dishes ("
          "cid INTEGER,"
          "did INTEGER,"
          "FOREIGN KEY (cid) REFERENCES categories (id),"
          "FOREIGN KEY (did) REFERENCES dishes (id)"
          ")");
      await db.execute("CREATE TABLE tags ("
          "id INTEGER PRIMARY KEY,"
          "name TEXT"
          ")");
      await db.execute("CREATE TABLE tags_dishes ("
          "tid INTEGER,"
          "did INTEGER,"
          "FOREIGN KEY (tid) REFERENCES tags (id),"
          "FOREIGN KEY (did) REFERENCES dishes (id)"
          ")");
    });
  }

  Future<int> newDish(Dish newDish) async {
    final db = await database;
    newDish.id = await db.rawInsert(
        "INSERT INTO dishes (name, note)"
        " VALUES (?,?)",
        [newDish.name, newDish.note]);

    // get or create category id
    for (var i = 0; i < newDish.categories.length; i++) {
      int cid;
      if (newDish.categories[i] != '') {
        var cr = await db.query("categories",
            columns: ['id'],
            where: "name = ?",
            whereArgs: [newDish.categories[i]]);
        if (cr.length == 0) {
          // insert new
          cid = await db.rawInsert(
              "INSERT INTO categories (name)"
              " VALUES (?)",
              [newDish.categories[i]]);
        } else if (cr.length == 1) {
          // use existing
          cid = cr.first['id'];
        }
      }
      await db.rawInsert(
          "INSERT INTO categories_dishes (cid,did)"
          " VALUES (?,?)",
          [cid, newDish.id]);
    }

    //TODO tags

    return newDish.id;
  }

  Future<int> addDishToDay(int day, int order, int dish, String note) async {
    final db = await database;
    var raw = await db.rawInsert(
        "INSERT INTO days_dishes (day,ordering,dish,note)"
        " VALUES (?,?,?,?)",
        [day, order, dish, note]);
    return raw;
  }

  Future<int> updateDish(Dish dish) async {
    final db = await database;
    var res = await db
        .update("dishes", dish.toMap(), where: "id = ?", whereArgs: [dish.id]);

    db.delete("categories_dishes", where: "did = ?", whereArgs: [dish.id]);
    // get or create category id
    for (var i = 0; i < dish.categories.length; i++) {
      int cid;
      if (dish.categories[i] != '') {
        var cr = await db.query("categories",
            columns: ['id'],
            where: "name = ?",
            whereArgs: [dish.categories[i]]);
        if (cr.length == 0) {
          // insert new
          cid = await db.rawInsert(
              "INSERT INTO categories (name)"
              " VALUES (?)",
              [dish.categories[i]]);
        } else if (cr.length == 1) {
          // use existing
          cid = cr.first['id'];
        }
      }
      await db.rawInsert(
          "INSERT INTO categories_dishes (cid,did)"
          " VALUES (?,?)",
          [cid, dish.id]);
    }

    return res;
  }

  Future<Dish> getDish(int id) async {
    final db = await database;
    var res = await db.query("dishes", where: "id = ?", whereArgs: [id]);
    if (res.isNotEmpty) {
      var d = Dish.fromMap(res.first);
      res = await db.rawQuery(
          "SELECT"
          " c.name AS name "
          "FROM categories_dishes cd"
          " LEFT JOIN categories c ON cd.cid = c.id"
          " WHERE cd.did=?",
          [d.id]);
      if (res.isNotEmpty) {
        for (var i = 0; i < res.length; i++) {
          d.categories.add(res[i]['name']);
        }
      }
      res = await db.rawQuery(
          "SELECT"
          " t.name AS name "
          "FROM tags_dishes td"
          " LEFT JOIN tags t ON td.tid = t.id"
          " WHERE td.did=?",
          [d.id]);
      if (res.isNotEmpty) {
        for (var i = 0; i < res.length; i++) {
          d.tags.add(res[i]['name']);
        }
      }

      return d;
    }
    return null;
  }

  Future<List<Dish>> getAllDishes() async {
    final db = await database;
    var res = await db.query("dishes");
    List<Dish> list =
        res.isNotEmpty ? res.map((c) => Dish.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<Category>> getAllCategories() async {
    final db = await database;
    var res = await db.query("categories");
    List<Category> list =
        res.isNotEmpty ? res.map((c) => Category.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<Dish>> getDay(int day) async {
    final db = await database;
    var res = await db.rawQuery(
        "SELECT"
        " l.day AS day,"
        " l.ordering AS ordering,"
        " l.note AS note,"
        " r.id AS dish,"
        " r.name AS name "
        "FROM days_dishes l"
        " LEFT JOIN dishes r ON l.dish = r.id"
        " WHERE day=?",
        [day]);
    List<Dish> list =
        res.isNotEmpty ? res.map((c) => Dish.fromMap(c)).toList() : [];
    return list;
  }

  Future<int> deleteDish(int id) async {
    final db = await database;
    return db.delete("dishes", where: "id = ?", whereArgs: [id]);
  }

  Future<int> deleteAll() async {
    final db = await database;
    db.rawDelete("DELETE * FROM dishes");
  }
}
