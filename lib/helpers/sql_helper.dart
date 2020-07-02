import 'dart:math';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../providers/distances.dart';
import 'package:latlong/latlong.dart' as ll;
import 'package:maps_toolkit/maps_toolkit.dart';

class SQLHelper {
  static Future<Database> distanceDbSetup(String uid) async {
    final dbPath = await getDatabasesPath();
    return await openDatabase(
      join(dbPath, '${uid}Distances.db'),
      version: 1,
      onCreate: (db, _) {
        return db.execute('CREATE TABLE ${uid}Distances '
            '(id TEXT PRIMARY KEY, name TEXT, cat TEXT, time TEXT, lat REAL, lng REAL, alt REAL)');
      },
    );
  }

  static Future<Database> categoryDbSetup(String uid) async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath + '${uid}Categories.db'),
      version: 1,
      onCreate: (db, _) {
        return db.execute(
          'CREATE TABLE ${uid}Categories'
          '(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT)',
        );
      },
    );
  }

  static Future<void> addCategory(String name, String uid) async {
    final Database db = await categoryDbSetup(uid);
    final id = await db.insert(
      'UserCategories',
      {'title': name},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  static Future<List> getCategories(String uid) async {
    final db = await categoryDbSetup(uid);
    final cats = await db.query('', columns: ['title']);
    return cats;
  }

  static Future<void> addDistance(String id, String name, String units,
      String category, List<Map<String, dynamic>> points, String uid) async {
    final Database db = await distanceDbSetup(uid);
    points.forEach((point) {
      db.insert('UserDistancesPoints', {
        'id': id + point['time'].toString(),
        'name': name,
        'cat': category,
        'time': point['time'].toString(),
        'lat': point['LatLng'].latitude,
        'lng': point['LatLng'].longitude,
        'alt': point['alt'],
      });
    });
  }

  static Future<List<Distance>> getDistances(String uid) async {
    final db = await distanceDbSetup(uid);
    Map<String, List<Map>> pointList = {};
    List<Distance> distances = [];
    final points =
        await db.query('UserDistancesPoints', groupBy: 'id', orderBy: 'time');
    points.forEach((Map<dynamic, dynamic> point) {
      if (pointList.containsKey(point['id'])) {
        pointList[point['id']].add(point);
      } else {
        pointList.putIfAbsent(point['id'], () => [point]);
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
        name: value[0]['name'],
        time: DateTime.parse(value[0]['time']),
        distance: distance,
        markers: value.map((e) => ll.LatLng(e['lat'], e['lng'])).toList(),
        cat: value[0]['cat'],
        units: 'meters',
      ));
    });
    print(distances);
    return distances;
  }
}
