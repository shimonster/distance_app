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

  bool operator ==(dynamic other) {
    return time == other.time;
  }

  int get hashCode => time.hashCode;
}

class Distances extends ChangeNotifier {
  Distances(this.uid, this.categories, [this._distances]);

  final String uid;
  String preferredUnit = 'Kilometers';
  final List<String> categories;
  List<Distance> _distances = [];
  bool _isExpectingNew = false;

  List<Distance> get distances {
    return [..._distances.reversed];
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
      final sQLdists = await SQLHelper.getDistances(uid, context);
      final dists = [...sQLdists];
      final dbResult = await Firestore.instance
          .collection('users/$uid/distances')
          .getDocuments();
      final dbDists = dbConvertResult(dbResult);
      print(dbDists.length);
      List<Distance> addToSql = [];
      List<Distance> addToFirebase = [];
      dbDists.forEach((element) {
        if (!dists.contains(element)) {
          addToSql.add(element);
        }
      });
      dists.forEach((element) {
        if (!dbDists.contains(element)) {
          addToFirebase.add(element);
        }
      });
      await Future.forEach(addToSql, (Distance element) async {
        await SQLHelper.addDistance(
            element.id,
            element.name,
            element.units,
            element.cat,
            element.markers
                .map((e) => {
                      'lat': e['LatLng'].latitude * 100000000,
                      'lng': e['LatLng'].longitude * 100000000,
                      'alt': e['alt'],
                      'time': e['time']
                    })
                .toList(),
            uid);
      });
      print('before');
      var batch = Firestore.instance.batch();
      addToFirebase.forEach((Distance element) {
        final DocumentReference ref =
            Firestore.instance.collection('users/$uid/distances').document();
        batch.setData(ref, {
          'name': element.name,
          'time': element.time.toString(),
          'distance': element.distance,
          'units': element.units,
          'category': element.cat,
          'markers': element.markers
              .map((e) => {
                    'lat': e['LatLng'].latitude,
                    'lng': e['LatLng'].longitude,
                    'alt': e['alt'],
                    'time': e['time'].toString(),
                  })
              .toList()
        });
      });
      await batch.commit();
      print('after');
      dbDists.sort((a, b) => a.time.isAfter(b.time) ? -1 : 1);
      dists.sort((a, b) => a.time.isAfter(b.time) ? -1 : 1);
//      print('got dists: $dbDists');
//      print('add to firebase: $addToFirebase');
//      print('add to sql: $addToSql');
      print('right before check');
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
      double distance,
      bool isWifi) async {
    try {
      if (isWifi) {
        final DocumentSnapshot result = await Firestore.instance
            .collection('users/$uid/distances')
            .document()
            .get();
        print('after getting ref');
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
      } else {
        print('before adding');
        Firestore.instance
            .collection('users/$uid/distances')
            .document()
            .setData({
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
      }
      print('after adding');
      return null;
    } catch (error) {
      print('there was an error in adding to database');
      throw error;
    }
  }

  Future<void> addDistance(
      String name,
      DateTime time,
      String units,
      String category,
      List<Map<String, dynamic>> markers,
      double distance) async {
    _isExpectingNew = true;
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
        final result = await addToDatabase(
            name, time, units, category, markers, distance, true);
//        SQLHelper.addDistance(
//            result.documentID, name, units, category, newMarks, uid);
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
      print('add distance error: $error');
      await addToDatabase(
          name, time, units, category, markers, distance, false);
      print('after cach');
//      Firestore.instance.document('users/$uid/distances').setData({data})
//      SQLHelper.addDistance(
//          time.toIso8601String(), name, units, category, newMarks, '');
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
      return;
    } catch (error) {
      throw error;
    } finally {
      _isExpectingNew = false;
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
      loadedDistances.add(
        Distance(
          id: dist.documentID,
          name: dist.data['name'],
          time: DateTime.parse(dist.data['time']),
          distance: dist.data['distance'],
          units: dist.data['units'],
          cat: dist.data['category'],
          markers: marks,
        ),
      );
    });
    loadedDistances.sort((a, b) => a.time.isAfter(b.time) ? 1 : -1);
    return loadedDistances;
  }

  Future<void> getDistances (BuildContext context) {}

  Stream<Future<void>> streamGetDistances(BuildContext context) {
    return Stream.periodic(Duration(seconds: 2), (_) async {
      if (_distances.isEmpty ||
          (_distances.last.time.difference(DateTime.now()).inSeconds < 2 &&
              _isExpectingNew))
        try {
          if (uid != null) {
//        final dists = await sync(context);
            final result = await Firestore.instance
                .collection('users/$uid/distances')
                .getDocuments(source: Source.server);
            _distances = dbConvertResult(result);
            notifyListeners();
          } else {
            final loadedDistances =
                await SQLHelper.getDistances(uid ?? '', context);
            loadedDistances.sort((a, b) => a.time.isAfter(b.time) ? 1 : -1);
            _distances = loadedDistances;
            notifyListeners();
          }
        } on PlatformException catch (error) {
          print('platform exception get: $error');
//      final loadedDistances =
//          await SQLHelper.getDistances(uid ?? DateTime.now(), context);
//      loadedDistances.sort((a, b) => a.time.isAfter(b.time) ? 1 : -1);
          final docs = await Firestore.instance
              .collection('users/$uid/distances')
              .getDocuments(source: Source.cache);
          final loadedDistances = dbConvertResult(docs);
          _distances = loadedDistances;
          notifyListeners();
        } catch (error) {
          throw error;
        }
    });
  }
}
