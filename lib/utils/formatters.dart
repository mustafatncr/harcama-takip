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

String formatCurrencyWithoutSymbol(
  BuildContext context,
  num value,
  String currencyCode,
) {
  final normalizedCode = currencyCode == "TL" ? "TRY" : currencyCode;

  late final String locale;

  switch (normalizedCode) {
    case "TRY":
      locale = "tr_TR";
      break;
    case "USD":
      locale = "en_US";
      break;
    case "EUR":
      locale = "de_DE";
      break;
    case "GBP":
      locale = "en_GB";
      break;
    default:
      locale = "en_US";
  }

  return NumberFormat.currency(
    locale: locale,
    name: normalizedCode,
    symbol: "", // 🔥 SEMBOL YOK
    decimalDigits: 2,
  ).format(value).trim(); // trim önemli
}

String formatAmountForInput(
  num value,
  String currencyCode,
) {
  final normalizedCode = currencyCode == "TL" ? "TRY" : currencyCode;

  late final String locale;

  switch (normalizedCode) {
    case "TRY":
      locale = "tr_TR";
      break;
    case "EUR":
      locale = "de_DE";
      break;
    case "USD":
      locale = "en_US";
      break;
    case "GBP":
      locale = "en_GB";
      break;
    default:
      locale = "en_US";
  }

  final f = NumberFormat.decimalPattern(locale)
    ..minimumFractionDigits = 2
    ..maximumFractionDigits = 2;

  return f.format(value);
}
