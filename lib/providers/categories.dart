import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import '../helpers/sql_helper.dart';

class Categories extends ChangeNotifier {
  Categories(this.uid);

  final String uid;
  List<dynamic> _categories = ['All', 'Runs', 'Bikes'];

  List<String> get categories {
    return [..._categories];
  }

  Future<void> sync() async {
    try {
      final cats = await SQLHelper.getCategories(uid);
      Firestore.instance.document('users/$uid').setData({
        'categories': cats,
      });
    } catch (error) {
      throw error;
    }
    notifyListeners();
  }

  Future<void> putInitialCategories([String userId]) async {
    print('putting in intitial cats');
    try {
      if (userId != null) {
        await Firestore.instance
            .document('users/$userId')
            .setData({'categories': _categories});
      }
      print(['uid $uid', 'userId $userId']);
      if (!(await SQLHelper.getCategories(userId)).contains('All')) {
        _categories.forEach((element) async {
          await SQLHelper.addCategory(
              element, userId ?? '', _categories.indexOf(element));
        });
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
      }
      await SQLHelper.addCategory(title, uid ?? '', categories.length);
      _categories.add(title);
    } catch (error) {
      throw error;
    }
    notifyListeners();
  }

  Future<void> getCategories() async {
    try {
      if (uid != null) {
        await sync();
        print('firebase');
        final cats = await Firestore.instance.document('users/$uid').get();
        _categories = cats.data == null ? _categories : cats.data['categories'];
      } else {
        print('devise');
        _categories = await SQLHelper.getCategories('');
      }
    } on PlatformException catch (error) {
      _categories = await SQLHelper.getCategories(uid ?? '');
    } catch (error) {
      throw error;
    }
    notifyListeners();
  }
}
