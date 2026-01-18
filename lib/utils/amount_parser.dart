double parseAmountByCurrency(String input, String currencyCode) {
  final trimmed = input.trim();

  if (currencyCode == "TRY" || currencyCode == "EUR") {
    final normalized = trimmed
        .replaceAll(' ', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');

    return double.tryParse(normalized) ?? 0;
  }

  final normalized =
      trimmed.replaceAll(' ', '').replaceAll(',', '');

  return double.tryParse(normalized) ?? 0;
}
