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
      return _defaultCategories(deviceLang);
    }

    final List decoded = jsonDecode(jsonString);
    return decoded.map((e) => Category.fromJson(e)).toList();
  }

  static Future<void> saveCategories(List<Category> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString =
        jsonEncode(categories.map((e) => e.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }

  static List<Category> _defaultCategories(String lang) {
    if (lang == "tr") {
      return [
        Category(name: "Yemek", iconName: "restaurant"),
        Category(name: "Yakıt", iconName: "car"),
        Category(name: "Fatura", iconName: "receipt"),
        Category(name: "Market", iconName: "shopping"),
      ];
    }

    return [
      Category(name: "Food", iconName: "restaurant"),
      Category(name: "Fuel", iconName: "car"),
      Category(name: "Bill", iconName: "receipt"),
      Category(name: "Groceries", iconName: "shopping"),
    ];
  }
}
