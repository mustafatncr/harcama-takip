import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category.dart';

class CategoryService {
  static const _key = 'categories';

  static Future<List<Category>> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

    if (jsonString == null) {
      final deviceLang =
          WidgetsBinding.instance.platformDispatcher.locale.languageCode;
      return _sortOtherLast(_defaultCategories(deviceLang));
    }

    final List decoded = jsonDecode(jsonString);

    final categories = decoded.map((e) => Category.fromJson(e)).toList();

    return _sortOtherLast(categories);
  }

  static Future<void> saveCategories(List<Category> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(categories.map((e) => e.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }

  static List<Category> _sortOtherLast(
    List<Category> categories,
  ) {
    return List<Category>.from(categories)
      ..sort((a, b) {
        final aIsOther = _isOther(a.name);
        final bIsOther = _isOther(b.name);

        if (aIsOther && !bIsOther) return 1; // a sona
        if (!aIsOther && bIsOther) return -1; // b sona
        return 0; // sıralamayı bozma
      });
  }

  static bool _isOther(String name) {
    final lower = name.toLowerCase();
    return lower == "diğer" || lower == "other";
  }

  static List<Category> _defaultCategories(String lang) {
    if (lang == "tr") {
      return [
        Category(name: "Yemek", iconName: "restaurant"),
        Category(name: "Yakıt", iconName: "car"),
        Category(name: "Fatura", iconName: "receipt"),
        Category(name: "Market", iconName: "shopping"),
        Category(name: "Diğer", iconName: "more"),
      ];
    }

    return [
      Category(name: "Food", iconName: "restaurant"),
      Category(name: "Fuel", iconName: "car"),
      Category(name: "Bill", iconName: "receipt"),
      Category(name: "Groceries", iconName: "shopping"),
      Category(name: "Other", iconName: "more"),
    ];
  }
}
