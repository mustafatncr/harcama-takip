double parseAmountByCurrency(String input, String currencyCode) {
  final trimmed = input.trim();

  // Avrupa formatı (TRY + EUR)
  if (currencyCode == "TRY" || currencyCode == "EUR") {
    final normalized = trimmed
        .replaceAll(' ', '')
        .replaceAll('.', '') // binlik ayıracı sil
        .replaceAll(',', '.'); // ondalık noktaya çevir

    return double.tryParse(normalized) ?? 0;
  }

  // Anglo formatı (USD + GBP)
  final normalized =
      trimmed.replaceAll(' ', '').replaceAll(',', ''); // binlik ayıracı sil

  return double.tryParse(normalized) ?? 0;
}
