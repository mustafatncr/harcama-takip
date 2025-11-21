import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category.dart';
import 'dart:ui' as ui;

class CategoryService {
  static const _key = 'categories';

  static Future<List<Category>> loadCategories(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return _defaultCategories(context);
    final List decoded = jsonDecode(jsonString);
    return decoded.map((e) => Category.fromJson(e)).toList();
  }

  static Future<void> saveCategories(List<Category> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(categories.map((e) => e.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }

  static List<Category> _defaultCategories(BuildContext context) {
    final lang = ui.PlatformDispatcher.instance.locale.languageCode;
    if (lang == "tr") {
      return [
        Category(name: "Yemek", icon: Icons.restaurant),
        Category(name: "Yakıt", icon: Icons.directions_car),
        Category(name: "Fatura", icon: Icons.receipt_long),
        Category(name: "Market", icon: Icons.shopping_cart),
      ];
    }

    return [
      Category(name: "Food", icon: Icons.restaurant),
      Category(name: "Fuel", icon: Icons.directions_car),
      Category(name: "Bill", icon: Icons.receipt_long),
      Category(name: "Groceries", icon: Icons.shopping_cart),
    ];
  }
}
