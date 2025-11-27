import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category.dart';

class CategoryService {
  static const _key = 'categories';

  static Future<List<Category>> loadCategories() async {
    final deviceLang =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;

    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

    if (jsonString == null) return _defaultCategories(deviceLang);

    final List decoded = jsonDecode(jsonString);
    return decoded.map((e) => Category.fromJson(e)).toList();
  }

  static Future<void> saveCategories(List<Category> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString =
        jsonEncode(categories.map((e) => e.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }

  // -------------------------
  //   DÜZELTİLMİŞ DEFAULTLAR
  // -------------------------
  static List<Category> _defaultCategories(String deviceLang) {
    if (deviceLang == "tr") {
      return [
        Category(
          name: "Yemek",
          iconCode: Icons.restaurant.codePoint,
          iconFamily: Icons.restaurant.fontFamily!,
        ),
        Category(
          name: "Yakıt",
          iconCode: Icons.directions_car.codePoint,
          iconFamily: Icons.directions_car.fontFamily!,
        ),
        Category(
          name: "Fatura",
          iconCode: Icons.receipt_long.codePoint,
          iconFamily: Icons.receipt_long.fontFamily!,
        ),
        Category(
          name: "Market",
          iconCode: Icons.shopping_cart.codePoint,
          iconFamily: Icons.shopping_cart.fontFamily!,
        ),
      ];
    }

    return [
      Category(
        name: "Food",
        iconCode: Icons.restaurant.codePoint,
        iconFamily: Icons.restaurant.fontFamily!,
      ),
      Category(
        name: "Fuel",
        iconCode: Icons.directions_car.codePoint,
        iconFamily: Icons.directions_car.fontFamily!,
      ),
      Category(
        name: "Bill",
        iconCode: Icons.receipt_long.codePoint,
        iconFamily: Icons.receipt_long.fontFamily!,
      ),
      Category(
        name: "Groceries",
        iconCode: Icons.shopping_cart.codePoint,
        iconFamily: Icons.shopping_cart.fontFamily!,
      ),
    ];
  }
}
