import 'package:flutter/material.dart';

class Expense {
  final double amount;
  final String category;
  final String? note;
  final DateTime date;

  /// Harcamanın para birimi (TRY, USD, EUR, GBP)
  final String currency;

  /// Icon bilgisi artık IconData yerine
  /// codePoint + family şeklinde saklanıyor
  final int? iconCode;
  final String? iconFamily;

  Expense({
    required this.amount,
    required this.category,
    this.note,
    required this.date,
    required this.currency,
    this.iconCode,
    this.iconFamily,
  });

  /// UI'de ikon göstermek için hazır getter
  Icon get iconWidget {
    if (iconCode == null) {
      return const Icon(Icons.receipt_long);
    }
    return Icon(
      IconData(iconCode!, fontFamily: iconFamily ?? 'MaterialIcons'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'category': category,
      'note': note,
      'date': date.toIso8601String(),
      'currency': currency,

      // ikon kayıtları
      'iconCode': iconCode,
      'iconFamily': iconFamily,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      amount: (map['amount'] ?? 0).toDouble(),
      category: map['category'] ?? '',
      note: map['note'],
      date: DateTime.parse(map['date']),
      currency: map['currency'] ?? 'TRY',

      iconCode: map['iconCode'],
      iconFamily: map['iconFamily'],
    );
  }
}
