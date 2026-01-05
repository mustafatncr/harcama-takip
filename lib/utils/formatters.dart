import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Locale-aware tarih formatı
String formatDate(BuildContext context, DateTime date) {
  final locale = Localizations.localeOf(context).toString();
  return DateFormat.yMMMd(locale).format(date);
}

/// Locale-aware para formatı
String formatCurrency(
  BuildContext context,
  num value,
  String currencyCode,
) {
  final locale = Localizations.localeOf(context).toString();

  final digits = value % 1 == 0 ? 0 : 2;

  return NumberFormat.currency(
    locale: locale,
    name: currencyCode,
    symbol:
        NumberFormat.simpleCurrency(name: currencyCode).currencySymbol,
    decimalDigits: digits,
  ).format(value);
}
