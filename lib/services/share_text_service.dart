import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/expense.dart';
import '../utils/formatters.dart';

class ShareTextService {
  static String _formatDate(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).languageCode;
    final pattern = locale == "tr" ? "dd.MM.yyyy" : "MM/dd/yyyy";
    return DateFormat(pattern).format(date);
  }

  static String buildReportText(
    BuildContext context,
    List<Expense> expenses,
    DateTimeRange range,
  ) {
    final loc = AppLocalizations.of(context)!;
    final buffer = StringBuffer();

    buffer.writeln("📊 ${loc.shareReportTitle}");
    buffer.writeln(
      "${_formatDate(context, range.start)} - ${_formatDate(context, range.end)}",
    );
    buffer.writeln();
    buffer.writeln(loc.shareReportDetails);
    buffer.writeln();

    // 🔥 Toplamları para birimine göre ayır
    final Map<String, num> totalsByCurrency = {};

    for (final e in expenses) {
      totalsByCurrency[e.currency] =
          (totalsByCurrency[e.currency] ?? 0) + e.amount;

      buffer.writeln(
        "• ${formatCurrency(context, e.amount, e.currency)}"
        " – ${e.category}"
        " – ${_formatDate(context, e.date)}"
        "${(e.note != null && e.note!.trim().isNotEmpty) ? ' – ${e.note}' : ''}",
      );
    }

    buffer.writeln();
    buffer.writeln(loc.shareTotalLabel);

    for (final entry in totalsByCurrency.entries) {
      buffer.writeln(
        formatCurrency(context, entry.value, entry.key),
      );
    }

    return buffer.toString();
  }

  static Future<void> shareText(String text) async {
    await Share.share(text);
  }
}
