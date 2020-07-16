import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:connectivity/connectivity.dart';

import '../helpers/sql_helper.dart';

class Categories extends ChangeNotifier {
  Categories(this.uid);

  final String uid;
  List<dynamic> _categories = ['All', 'Runs', 'Bikes'];

  List<String> get categories {
    return [..._categories];
  }

  Future<void> putInitialCategories([String userId]) async {
    try {
      if (userId != null) {
        await Firestore.instance
            .document('users/$userId')
            .setData({'categories': _categories});
      } else {
        if (!(await SQLHelper.getCategories(userId)).contains('All')) {
          _categories.forEach((element) async {
            await SQLHelper.addCategory(
                element, userId ?? '', _categories.indexOf(element));
          });
        }
      }
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addCategory(String title) async {
    try {
      if (uid != null) {
        await Firestore.instance.document('users/$uid').setData({
          'categories': [..._categories, title]
        });
        _categories.add(title);
      } else {
        await SQLHelper.addCategory(title, uid ?? '', categories.length);
        _categories.add(title);
      }
    } catch (error) {
      throw error;
    }
    notifyListeners();
  }

  Future<void> getCategories() async {
    final ConnectivityResult wifi = await Connectivity().checkConnectivity();
    print(wifi);
    try {
      if (uid != null) {
        if (wifi == ConnectivityResult.mobile ||
            wifi == ConnectivityResult.wifi ||
            wifi == null) {
          final cats = await Firestore.instance.document('users/$uid').get();
          _categories =
              cats.data == null ? _categories : cats.data['categories'];
        } else {
          final result = await Firestore.instance
              .document('users/$uid')
              .get(source: Source.cache);
          _categories = result['categories'];
        }
      } else {
        _categories = await SQLHelper.getCategories('');
      }
    } on PlatformException catch (error) {
      print('error getting categories: $error');
      final result = await Firestore.instance
          .document('users/$uid')
          .get(source: Source.cache);
      _categories = result['categories'];
    } catch (error) {
      print(error);
      throw error;
    }
    notifyListeners();
  }
}
