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
  final normalizedCode = currencyCode == "TL" ? "TRY" : currencyCode;

  late final String locale;
  late final String symbol;

  switch (normalizedCode) {
    case "TRY":
      locale = "tr_TR";
      symbol = "₺";
      break;
    case "USD":
      locale = "en_US";
      symbol = "\$";
      break;
    case "EUR":
      locale = "de_DE";
      symbol = "€";
      break;
    case "GBP":
      locale = "en_GB";
      symbol = "£";
      break;
    default:
      locale = "en_US";
      symbol = normalizedCode;
  }

  return NumberFormat.currency(
    locale: locale,
    name: normalizedCode,
    symbol: symbol,
    decimalDigits: 2,
  ).format(value);
}
