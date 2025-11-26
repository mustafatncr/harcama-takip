import 'package:flutter/material.dart';

/// PREMIUM DARK FINTECH TEMA
///
/// Bu tema Revolut / Binance / Monzo modern koyu tema yapısına göre
/// tasarlanmıştır. Kartlar, ikonlar, yazılar, gölgeler, divider ve FAB
/// tamamen premium bir koyu tema deneyimi sunar.

final ThemeData premiumDarkTheme = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,

  // 📌 Arka Plan
  scaffoldBackgroundColor: const Color(0xFF071312), // premium koyu yeşil-siyah

  // 📌 Renk Şeması (Brand Colors)
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF00C6A9), // Mint (ana vurgu)
    secondary: Color(0xFF0A8071), // Koyu mint
    surface: Color(0xFF0F2624), // Kart arka planı
    onPrimary: Colors.black, // Mint üzerindeki yazı
    onSurface: Colors.white, // Kart üzeri yazı
  ),

  // 📌 AppBar
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    foregroundColor: Colors.white,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 22,
      fontWeight: FontWeight.w700,
    ),
  ),

  // 📌 Kart Tasarımı
  cardTheme: const CardThemeData(
    color: Color(0xFF0F2624),
    elevation: 3,
    shadowColor: Color(0x73000000),
    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
      side: BorderSide(color: Color(0xFF1C3A37)),
    ),
  ),

  // 📌 Liste ikon baloncuğu vs. için varsayılan IconTheme
  iconTheme: const IconThemeData(
    color: Color(0xFF00C6A9), // Mint ikon rengi
    size: 22,
  ),

  // 📌 Yazı Tipi Teması (Typography)
  textTheme: const TextTheme(
    // Başlıklar
    headlineLarge: TextStyle(
        fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
    headlineMedium: TextStyle(
        fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),

    // Liste elemanları
    bodyLarge: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: Color(0xFF14E4C6)), // mint tutar
    bodyMedium: TextStyle(
        fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
    bodySmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Color(0xFFB6C3C2)), // açıklama

    // Tarih & zayıf metin
    labelSmall: TextStyle(
        fontSize: 13, fontWeight: FontWeight.w300, color: Color(0xFF7C8B8A)),
  ),

  // 📌 Input alanları
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF0F2624),
    hintStyle: const TextStyle(color: Color(0xFF7C8B8A)),
    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF1C3A37)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF14E4C6)), // mint glow
    ),
  ),

  // 📌 FAB (Harcama ekleme butonu)
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF00C6A9),
    foregroundColor: Colors.black,
    elevation: 6,
  ),

  // 📌 Divider / Ayırıcılar
  dividerColor: const Color(0xFF113A37),
  dividerTheme: const DividerThemeData(
    thickness: 1,
    color: Color(0xFF113A37),
  ),
);
