import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Locale-aware tarih formatı
String formatDate(BuildContext context, DateTime date) {
  final locale = Localizations.localeOf(context).toString();
  return DateFormat.yMMMd(locale).format(date);
}

/// Locale-aware para formatı (HER ZAMAN 2 KURUŞ)
String formatCurrency(
  BuildContext context,
  num value,
  String currencyCode,
) {
  final locale = Localizations.localeOf(context).toString();

  final normalizedCode = currencyCode == "TL" ? "TRY" : currencyCode;

  String symbol;
  if (normalizedCode == "TRY") {
    symbol = "₺"; // 🔥 ZORLA ₺
  } else {
    symbol = NumberFormat.simpleCurrency(name: normalizedCode).currencySymbol;
  }

  return NumberFormat.currency(
    locale: locale,
    name: normalizedCode,
    symbol: symbol,
    decimalDigits: 2, // her zaman kuruş
  ).format(value);
}
