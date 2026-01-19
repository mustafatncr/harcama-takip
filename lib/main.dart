import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:harcama_takip/l10n/app_localizations.dart';
import 'package:harcama_takip/screens/report_screen.dart';
import 'theme/premium_dark_theme.dart';
import 'screens/home_screen.dart';
import 'screens/ayarlar_ekrani.dart';
import 'screens/grafik_ekrani.dart';
import 'screens/kategori_ekrani.dart';

final RouteObserver<PageRoute> routeObserver =
    RouteObserver<PageRoute>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HarcamaTakipApp());
}

class HarcamaTakipApp extends StatelessWidget {
  const HarcamaTakipApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppLocalizations.of(context)?.appTitle,
      debugShowCheckedModeBanner: false,
      theme: premiumDarkTheme,
      themeMode: ThemeMode.dark,

      navigatorObservers: [routeObserver],

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('tr'), Locale('en')],
      localeResolutionCallback: (locale, supportedLocales) {
        for (final supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return const Locale('en');
      },
      routes: {
        '/': (_) => const HomeScreen(),
        '/grafikler': (_) => const GrafikEkrani(),
        '/kategoriler': (_) => const KategoriEkrani(),
        '/rapor': (_) => const ReportScreen(),
        '/ayarlar': (_) => const AyarlarEkrani(),
      },
      initialRoute: '/',
    );
  }
}
