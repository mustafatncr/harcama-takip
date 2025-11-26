import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/expense.dart';

class StorageService {
  static const String _key = "expenses";
  static const String _currencyKey = "currencyCode";

  static Future<void> saveCurrency(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, code);
  }

  static Future<String> loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_currencyKey);

    if (saved != null) return saved;

    final deviceLang =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;

    switch (deviceLang) {
      case "tr":
        return "TRY";
      case "en":
        return "USD";
      case "de":
        return "EUR";
      default:
        return "USD";
    }
  }

  static Future<void> saveExpenses(List<Expense> expenses) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = expenses.map((e) => jsonEncode(e.toMap())).toList();
    await prefs.setStringList(_key, jsonList);
  }

  static Future<List<Expense>> loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key) ?? [];
    return jsonList.map((e) => Expense.fromMap(jsonDecode(e))).toList();
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('expenses');
  }
}
