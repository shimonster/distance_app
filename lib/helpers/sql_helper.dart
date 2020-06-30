import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

Future<Database> distanceDbSetup() async {
  final dbPath = await getDatabasesPath();
  return await openDatabase(
    join(dbPath, 'distances.db'),
    version: 1,
    onCreate: (db, _) {
      db.execute(
          'CREATE TABLE UserDistances (id INTEGER PRIMARY KEY AUTOINCREMENT, units TEXT, distance REAL');
    },
  );
}

Future<Database> categoryDbSetup() async {
  final dbPath = await getDatabasesPath();
  return await openDatabase(
    join(dbPath + 'categories.db'),
    version: 1,
    onCreate: (db, _) {
      db.execute(
          'CREATE TABLE UserCategories (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT');
    },
  );
}

Future<void> addCategory(String name) async {
  final Database db = await categoryDbSetup();
  db.insert('UserCategories', {'title': name});
}

Future<List> getCats() async {
  final db = await categoryDbSetup();
  final cats = await db.query('UserCategories', columns: ['title']);
  print(cats);
  return cats;
}
