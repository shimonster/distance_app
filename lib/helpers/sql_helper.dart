import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:latlong/latlong.dart' as ll;

import 'package:distanceapp/providers/distances.dart';

class SQLHelper {
  static Future<Database> distanceDbSetup(String uid) async {
    final dbPath = await getDatabasesPath();
    return await openDatabase(
      join(dbPath, '${uid}Distances.db'),
      version: 1,
      onCreate: (db, _) {
        return db.execute('CREATE TABLE Distances '
            '(idNum INTEGER PRIMARY KEY AUTOINCREMENT, id TEXT, name TEXT, cat TEXT, time TEXT, lat INTEGER, lng INTEGER, alt REAL)');
      },
    );
  }

  static Future<Database> categoryDbSetup(String uid) async {
    print('db setup');
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath + '${uid}Cats.db'),
      version: 1,
      onCreate: (db, _) {
        print('executing');
        return db.execute(
          'CREATE TABLE Categories'
          '(id INTEGER PRIMARY KEY, title TEXT)',
        );
      },
    );
  }

  static Future<void> addCategory(String name, String uid, int idx) async {
    final Database db = await categoryDbSetup(uid);
    final cats = await getCategories(uid);
    if (!cats.contains(name)) {
      await db.insert(
        'Categories',
        {'title': name, 'id': idx},
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    }
  }

  static Future<List> getCategories(String uid) async {
    print('geting cats');
    final db = await categoryDbSetup(uid);
    final cats = await db.query('Categories', distinct: true, orderBy: 'id');
    List listCats = [];
    cats.forEach((element) => listCats.add(element['title']));
    print('recieved cats: $cats');
    return listCats;
  }

  static Future<void> addDistance(String id, String name, String units,
      String category, List<Map<String, dynamic>> points, String uid) async {
    final Database db = await distanceDbSetup(uid);
    points.forEach((point) {
      db.insert(
        'Distances',
        {
          'id': id ?? DateTime.now().toString(),
          'name': name,
          'cat': category,
          'time': point['time'].toString(),
          'lat': point['lat'].round(),
          'lng': point['lng'].round(),
          'alt': (point['alt'] * 100).round(),
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    });
  }

  static Future<List<Distance>> getDistances(
      String uid, BuildContext context) async {
    try {
      final db = await distanceDbSetup(uid);
      Map<String, List<Map>> pointList = {};
      List<Distance> distances = [];
      final points = await db.query(
        'Distances',
        orderBy: 'idNum',
      );
      points.forEach((Map<dynamic, dynamic> point) {
        if (pointList.containsKey(point['id'])) {
          pointList[point['id']].add(point);
        } else {
          pointList.putIfAbsent(point['id'], () => [point]);
        }
      });
      pointList.forEach((key, value) {
        distances.add(
          Distance(
            id: key,
            name: value[0]['name'],
            time: DateTime.parse(value[0]['time']),
            markers: value
                .map((e) => {
                      'LatLng':
                          ll.LatLng(e['lat'] / 100000000, e['lng'] / 100000000),
                      'alt': e['alt'] / 100,
                      'time': DateTime.parse(e['time'])
                    })
                .toList(),
            cat: value[0]['cat'],
          ),
        );
        print('added to distances');
      });
      print('$distances');
      return distances;
    } catch (error) {
      print(error);
      throw error;
    }
  }
}
