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
          '(title TEXT PRIMARY KEY)',
        );
      },
    );
  }

  static Future<void> addCategory(String name, String uid) async {
    final Database db = await categoryDbSetup(uid);
    await db.insert(
      '${uid}Categories',
      {'title': name},
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  static Future<List> getCategories(String uid) async {
    print('geting cats');
    final db = await categoryDbSetup(uid);
    final cats =
        await db.query('${uid}Categories', columns: ['title'], distinct: true);
    List listCats = [];
    cats.forEach((element) => listCats.add(element['title']));
    print('recieved cats: $cats');
    return listCats;
  }

  static Future<void> addDistance(String id, String name, String units,
      String category, List<Map<String, dynamic>> points, String uid) async {
    final Database db = await distanceDbSetup(uid);
    points.forEach((point) {
      db.insert('${uid}Distances', {
        'id': id + point['time'].toString(),
        'name': name,
        'cat': category,
        'time': point['time'].toString(),
        'lat': point['lat'],
        'lng': point['lng'],
        'alt': point['alt'],
      });
    });
  }

  static Future<List<Distance>> getDistances(String uid) async {
    final db = await distanceDbSetup(uid);
    Map<String, List<Map>> pointList = {};
    List<Distance> distances = [];
    final points =
        await db.query('${uid}Distances', groupBy: 'id', orderBy: 'time');
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
        markers: value
            .map((e) =>
                {'LatLng': ll.LatLng(e['lat'], e['lng']), 'alt': e['alt']})
            .toList(),
        cat: value[0]['cat'],
        units: 'meters',
      ));
    });
    print(distances);
    return distances;
  }
}
