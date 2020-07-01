import 'dart:math';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../providers/distances.dart';
import 'package:latlong/latlong.dart' as ll;
import 'package:maps_toolkit/maps_toolkit.dart';

class SQLHelper {
  static Future<Database> distanceDbSetup() async {
    final dbPath = await getDatabasesPath();
    return await openDatabase(
      join(dbPath, 'distancePoints.db'),
      version: 1,
      onCreate: (db, _) {
        return db.execute(
            'CREATE TABLE UserDistancePoints (id TEXT PRIMARY KEY, name TEXT, cat TEXT, time TEXT, lat REAL, lng REAL, alt REAL)');
      },
    );
  }

  static Future<Database> categoryDbSetup() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath + 'cats.db'),
      version: 1,
      onCreate: (db, _) {
        return db.execute(
          'CREATE TABLE UserCategories'
          '(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT)',
        );
      },
    );
  }

  static Future<void> addCategory(String name) async {
    final Database db = await categoryDbSetup();
    final id = await db.insert(
      'UserCategories',
      {'title': name},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  static Future<List> getCategories() async {
    final db = await categoryDbSetup();
    final cats = await db.query('', columns: ['title']);
    return cats;
  }

  static Future<void> addDistance(String id, String name, String units,
      String category, List<Map<String, dynamic>> points) async {
    final Database db = await distanceDbSetup();
    points.forEach((point) {
      db.insert('UserDistancePoints', {
        'id': id,
        'name': name,
        'time': point['time'],
        'cat': category,
        'lat': point['LatLng'].latitude,
        'lng': point['LatLng'].longitude,
        'alt': point['Alt'],
      });
    });
  }

  static Future<List<Distance>> getDistances() async {
    final db = await categoryDbSetup();
    Map<String, List<Map>> pointList = {};
    List<Distance> distances = [];
    final points =
        await db.query('UserDistancePoints', groupBy: 'id', orderBy: 'time');
    points.forEach((point) {
      if (pointList.containsKey(point['id'])) {
        pointList[point['id']].add(point);
      } else {
        pointList.update(point['id'], (value) => [point]);
      }
    });
    pointList.forEach((key, value) {
      var distance = 0.0;
      Map<String, dynamic> prevPoint;
      value.forEach((element) {
        if (prevPoint != null) {
          final flatDis = SphericalUtil.computeLength([
            LatLng(prevPoint['lat'], prevPoint['lng']),
            LatLng(element['lat'], element['lng']),
          ]);
          distance +=
              sqrt(pow(flatDis, 2) + pow(element['alt'] - prevPoint['alt'], 2));
        }
        prevPoint = element;
      });
      distances.add(Distance(
        id: key,
        distance: distance,
        markers: value.map((e) => ll.LatLng(e['lat'], e['lng'])).toList(),
        cats: value[0]['cat'],
        units: 'meters',
      ));
    });
    return distances;
  }
}
