double parseAmountByCurrency(String input, String currencyCode) {
  if (currencyCode == "TRY") {
    final normalized = input
        .replaceAll(' ', '')
        .replaceAll('.', '')   // binlik ayıracı sil
        .replaceAll(',', '.'); // virgülü ondalığa çevir

    return double.tryParse(normalized) ?? 0;
  }

  // Diğer para birimleri (USD, EUR vs.)
  return double.tryParse(input) ?? 0;
}
