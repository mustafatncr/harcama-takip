import 'package:flutter/material.dart';

class Expense {
  final double amount;
  final String category;
  final String? note;
  final DateTime date;
  final IconData? icon;

  Expense({
    required this.amount,
    required this.category,
    this.note,
    required this.date,
    this.icon,
  });

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'category': category,
      'note': note,
      'date': date.toIso8601String(),
      // 🔹 İkonu 2 parçalı kaydet
      'iconCode': icon?.codePoint,
      'iconFamily': icon?.fontFamily,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      amount: (map['amount'] ?? 0).toDouble(),
      category: map['category'] ?? '',
      note: map['note'],
      date: DateTime.parse(map['date']),
      // 🔹 İkonu 2 parça veriden geri oluştur
      icon: (map['iconCode'] != null && map['iconFamily'] != null)
          ? IconData(map['iconCode'], fontFamily: map['iconFamily'])
          : null,
    );
  }
}
