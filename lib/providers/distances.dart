import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:latlong/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mt;
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/sql_helper.dart';

class Distance {
  const Distance({
    @required this.id,
    @required this.name,
    @required this.time,
    @required this.distance,
    @required this.units,
    @required this.cat,
    @required this.markers,
  });

  final String id;
  final String name;
  final DateTime time;
  final double distance;
  final String units;
  final String cat;
  final List<Map<String, dynamic>> markers;
}

class Distances extends ChangeNotifier {
  Distances(this.uid, this.categories, [this._distances]);

  final String uid;
  String preferredUnit = 'Kilometers';
  final List<String> categories;
  List<Distance> _distances = [];

  List<Distance> get distances {
    return [..._distances];
  }

  Future<void> setUnit(String unit) async {
    preferredUnit = unit;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('preferredUnit$uid', unit);
    notifyListeners();
  }

  Future<void> getUnits() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('preferredUnit$uid')) {
      preferredUnit = prefs.getString('preferredUnit$uid');
    }
  }

  Future<List<Distance>> sync(BuildContext context) async {
    try {
      print('start');
      final SQLdists = await SQLHelper.getDistances(uid, context);
      final dists = [...SQLdists];
      print('after sql');
      final dbResult = await Firestore.instance
          .collection('users/$uid/distances')
          .getDocuments();
      print('after fetching things');
      final dbDists = dbConvertResult(dbResult);
      List<Distance> addToSql = [];
      List<Distance> addToFirebase = [];
      dbDists.forEach((element) {
        if (!dists.contains(element)) {
          addToSql.add(element);
        }
      });
      print('converted to distance');
      dists.forEach((element) {
        if (!dbDists.contains(element)) {
          addToFirebase.add(element);
        }
      });
      addToSql.forEach((element) {
        SQLHelper.addDistance(
            element.id,
            element.name,
            element.units,
            element.cat,
            element.markers
                .map((e) => {
                      'lat': e['LatLng'].latitude,
                      'lng': e['LatLng'].longitude,
                      'alt': e['alt'],
                      'time': e['time']
                    })
                .toList(),
            uid);
      });
      addToFirebase.forEach((element) {
        addToDatabase(element.id, element.markers.first['time'], element.units,
            element.cat, element.markers, element.distance);
      });
      print('added missing');
      addToFirebase.forEach((element) {
        dbDists.add(element);
      });
      dbDists.sort((a, b) => a.time.isAfter(b.time) ? -1 : 1);
      print(dbDists);
//      dists.sort((a, b) => a.time.isAfter(b.time) ? -1 : 1);
//      print([...addToFirebase, ...dbDists]);
//      print([
//        ...dists,
//      ]);
//      assert(dbDists == dists);
      print('end');
      return dbDists;
    } catch (error) {
      print('sync: $error');
      throw error;
    }
  }

  double computeTotalDist(List<Map<String, dynamic>> markers) {
    var distance = 0.0;
    Map<String, dynamic> prevPoint;
    markers.forEach((element) {
      if (prevPoint != null) {
        final flatDis = mt.SphericalUtil.computeLength([
              mt.LatLng(
                  prevPoint['LatLng'].latitude, prevPoint['LatLng'].longitude),
              mt.LatLng(
                  element['LatLng'].latitude, element['LatLng'].longitude),
            ]) /
            (preferredUnit == 'Miles' ? 1609.34 : 1000);
        final calcDis =
            sqrt(pow(flatDis, 2) + pow((element['alt'] - prevPoint['alt']), 2));
        distance += calcDis;
      }
      prevPoint = element;
    });
    return distance;
  }

  Future<DocumentSnapshot> addToDatabase(
      String name,
      DateTime time,
      String units,
      String category,
      List<Map<String, dynamic>> markers,
      double distance) async {
    final result = await Firestore.instance
        .collection('users/$uid/distances')
        .document()
        .get();
    await result.reference.setData({
      'name': name,
      'time': time.toString(),
      'distance': distance,
      'units': units,
      'category': category,
      'markers': markers
          .map((e) => {
                'lat': e['LatLng'].latitude,
                'lng': e['LatLng'].longitude,
                'alt': e['alt'],
                'time': e['time'].toString(),
              })
          .toList(),
    });
    return result;
  }

  Future<void> addDistance(
      String name,
      DateTime time,
      String units,
      String category,
      List<Map<String, dynamic>> markers,
      double distance) async {
    Map<String, dynamic> prevE;
    final newMarks = markers.expand<Map<String, dynamic>>((e) {
      if (e != prevE) {
        prevE = e;
        return [
          {
            'lat': (e['LatLng'].latitude * 100000000).round(),
            'lng': (e['LatLng'].longitude * 100000000).round(),
            'alt': e['alt'],
            'time': e['time'].toString(),
          }
        ];
      }
      prevE = e;
      return [];
    }).toList();
    try {
      //final distance = computeTotalDist(markers);
      if (uid != null) {
        final result =
            await addToDatabase(name, time, units, category, markers, distance);
        SQLHelper.addDistance(
            result.documentID, name, units, category, newMarks, uid);
        _distances.add(
          Distance(
            id: result.documentID,
            name: name,
            time: time,
            distance: distance,
            units: units,
            cat: category,
            markers: markers,
          ),
        );
      } else {
        SQLHelper.addDistance(
            time.toIso8601String(), name, units, category, newMarks, '');
        _distances.add(
          Distance(
            id: time.toIso8601String(),
            name: name,
            time: time,
            distance: distance,
            units: units,
            cat: category,
            markers: markers,
          ),
        );
      }
      notifyListeners();
    } on PlatformException catch (error) {
      SQLHelper.addDistance(
          time.toIso8601String(), name, units, category, newMarks, '');
      _distances.add(
        Distance(
          id: time.toIso8601String(),
          name: name,
          time: time,
          distance: distance,
          units: units,
          cat: category,
          markers: markers,
        ),
      );
      print('add distance: $error');
    } catch (error) {
      throw error;
    }
  }

  List<Distance> dbConvertResult(QuerySnapshot result) {
    List<Distance> loadedDistances = [];
    result.documents.forEach((dist) {
      final List<Map<String, dynamic>> marks = dist.data['markers']
          .map<Map<String, dynamic>>((mar) => {
                'LatLng': LatLng(mar['lat'], mar['lng']),
                'alt': mar['alt'],
                'time': DateTime.parse(mar['time'])
              })
          .toList();
      marks.sort((a, b) => a['time'].isAfter(b['time']) ? 1 : -1);
      loadedDistances.add(
        Distance(
          id: dist.documentID,
          name: dist.data['name'],
          time: DateTime.parse(dist.data['time']),
          distance: double.parse(dist.data['distance'].toString()),
          units: dist.data['units'],
          cat: dist.data['category'],
          markers: marks,
        ),
      );
    });
    loadedDistances.sort((a, b) => a.time.isAfter(b.time) ? 1 : -1);
    return loadedDistances;
  }

  Future<void> getDistances(BuildContext context) async {
    print('got dists');
    try {
      if (uid != null) {
        print('before');
        final dists = await sync(context);
        print('recieved distances: $dists');
        _distances = dists;
        notifyListeners();
      } else {
        print('uid was null');
        final loadedDistances =
            await SQLHelper.getDistances(uid ?? '', context);
        loadedDistances.sort((a, b) => a.time.isAfter(b.time) ? 1 : -1);
        _distances = loadedDistances;
        notifyListeners();
      }
    } on PlatformException catch (error) {
      print('platform exception');
      final loadedDistances =
          await SQLHelper.getDistances(uid ?? DateTime.now(), context);
      loadedDistances.sort((a, b) => a.time.isAfter(b.time) ? 1 : -1);
      _distances = loadedDistances;
      notifyListeners();
    } catch (error) {
      throw error;
    }
    print('after try');
  }
}
