import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';

class ShareTextService {
  static String formatDate(DateTime date) {
    return DateFormat("dd.MM.yyyy").format(date);
  }

  static String buildReportText(List<Expense> expenses, DateTimeRange range) {
    final buffer = StringBuffer();

    buffer.writeln("📊 Harcama Raporu");
    buffer.writeln("${formatDate(range.start)} - ${formatDate(range.end)}");
    buffer.writeln("");
    buffer.writeln("Detaylar:");
    buffer.writeln("");

    num total = 0;

    for (var e in expenses) {
      total += e.amount;

      buffer.writeln(
        "• ${e.amount} ${e.currency} – ${e.category} – ${formatDate(e.date)}"
        "${(e.note != null && e.note!.trim().isNotEmpty) ? ' – ${e.note}' : ''}",
      );
    }

    buffer.writeln("");
    buffer.writeln("Toplam: $total");

    return buffer.toString();
  }

  static Future<void> shareText(String text) async {
    await Share.share(text);
  }
}
