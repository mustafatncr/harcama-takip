import 'package:flutter/material.dart';

class Expense {
  final double amount;
  final String category;
  final String? note;
  final DateTime date;

  /// 🔥 Harcamanın para birimi (TRY, USD, EUR, GBP)
  final String currency;

  /// 🔹 Harcama ikon bilgisi
  final IconData? icon;

  Expense({
    required this.amount,
    required this.category,
    this.note,
    required this.date,
    required this.currency, // ⭐ zorunlu hale geldi
    this.icon,
  });

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'category': category,
      'note': note,
      'date': date.toIso8601String(),

      // 🔹 İkon kaydı
      'iconCode': icon?.codePoint,
      'iconFamily': icon?.fontFamily,

      // 🔥 Para birimi kaydı
      'currency': currency,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      amount: (map['amount'] ?? 0).toDouble(),
      category: map['category'] ?? '',
      note: map['note'],
      date: DateTime.parse(map['date']),

      icon: (map['iconCode'] != null && map['iconFamily'] != null)
          ? IconData(map['iconCode'], fontFamily: map['iconFamily'])
          : null,

      currency: map['currency'] ?? 'TRY',
    );
  }
}
