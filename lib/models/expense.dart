import 'package:flutter/material.dart';
import '../utils/icon_map.dart';

class Expense {
  final double amount;
  final String category;
  final String? note;
  final DateTime date;
  final String currency;

  final String iconName;

  Expense({
    required this.amount,
    required this.category,
    this.note,
    required this.date,
    required this.currency,
    required this.iconName,
  });

  Icon get iconWidget {
    return Icon(iconMap[iconName] ?? Icons.receipt_long);
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'category': category,
      'note': note,
      'date': date.toIso8601String(),
      'currency': currency,
      'iconName': iconName,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      amount: (map['amount'] ?? 0).toDouble(),
      category: map['category'] ?? '',
      note: map['note'],
      date: DateTime.parse(map['date']),
      currency: map['currency'] ?? 'TRY',
      iconName: map['iconName'] ?? "receipt",
    );
  }
}
