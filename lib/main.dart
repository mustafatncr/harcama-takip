import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/ayarlar_ekrani.dart';
import 'screens/grafik_ekrani.dart';
import 'screens/kategori_ekrani.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🌗 Kaydedilmiş temayı SharedPreferences’tan al
  final prefs = await SharedPreferences.getInstance();
  final themeString = prefs.getString('themeMode') ?? 'system';
  final themeMode = _stringToThemeMode(themeString);

  runApp(HarcamaTakipApp(initialTheme: themeMode));
}

// 🔹 String → ThemeMode dönüşümü
ThemeMode _stringToThemeMode(String str) {
  switch (str) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
}

class HarcamaTakipApp extends StatefulWidget {
  final ThemeMode initialTheme;
  const HarcamaTakipApp({super.key, required this.initialTheme});

  @override
  State<HarcamaTakipApp> createState() => _HarcamaTakipAppState();
}

class _HarcamaTakipAppState extends State<HarcamaTakipApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialTheme;
  }

  // 🔹 Tema değiştiğinde hem kaydedilir hem uygulama güncellenir
  Future<void> _updateTheme(ThemeMode newMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', newMode.toString().split('.').last);
    setState(() => _themeMode = newMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Harcama Takip',
      debugShowCheckedModeBanner: false,

      // 🌗 Kullanıcının seçtiği tema modu
      themeMode: _themeMode,

      // 🌞 Açık tema
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.light,
      ),

      // 🌙 Koyu tema
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.dark,
      ),

      // 🌍 Yerelleştirme (TR + EN)
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr', 'TR'),
        Locale('en', 'US'),
      ],

      // 🔹 Route yapılandırması
      routes: {
        '/': (_) => const HomeScreen(),
        '/grafikler': (_) => const GrafikEkrani(),
        '/kategoriler': (_) => const KategoriEkrani(),
        '/ayarlar': (_) => AyarlarEkrani(
              currentThemeMode: _themeMode,
              onThemeChange: _updateTheme,
            ),
      },

      // 🏠 Uygulama açılış ekranı
      initialRoute: '/',
    );
  }
}
