import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import "package:path/path.dart";

Future<Database> getDatabase() async {
  final databasePath = await getDatabasesPath();
  final path = join(databasePath, "my_database.db");

  Database database = await openDatabase(
    path,
    version: 1,
    onCreate: (db, version) async {
      await db.execute(
        "CREATE TABLE schedules (id INTEGER PRIMARY KEY ,content TEXT NOT NULL)",
      );

      await db.insert("schedules", {
        "id": 1,
        "content": jsonEncode({
          "scheduleName": "デフォルト",
          "originHour": 10,
          "originMinute": 0,
          "eventsJsonList": [
            {"number": 1, "times": 3, "name": "Alice"},
            {"number": 2, "times": 5, "name": "Bob"},
          ],
        }),
      });
    },
  );

  return database;
}

void addDatabase(Database db, String content) {
  db.insert("schedules", {"content": content});
}

void updateDatabase(Database db, int id, String content) {
  db.update("schedules", {"content": content}, where: "id = $id");
}

void test2() async {
  final databasePath = await getDatabasesPath();
  final path = join(databasePath, "my_database.db");
  deleteDatabase(path);
  Database db = await getDatabase();
  addDatabase(db, "abcdefg");
  db.delete("schedules", where: "id = 2");
  final List<Map<String, dynamic>> result = await db.query(
    "schedules",
    where: "id = 1",
  );

  print(result);
}

/*
既存のデータベースにデータがある場合消さないといけない。
 */
