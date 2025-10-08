import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AyarlarEkrani extends StatefulWidget {
  final ThemeMode currentThemeMode;
  final Function(ThemeMode) onThemeChange;

  const AyarlarEkrani({
    super.key,
    required this.currentThemeMode,
    required this.onThemeChange,
  });

  @override
  State<AyarlarEkrani> createState() => _AyarlarEkraniState();
}

class _AyarlarEkraniState extends State<AyarlarEkrani> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.currentThemeMode;
  }

  // 🔹 Tema değiştiğinde kaydet + uygulamayı güncelle
  Future<void> _changeTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode.toString().split('.').last);

    setState(() => _themeMode = mode);
    widget.onThemeChange(mode); // 🔸 Ana uygulamaya bildir
  }

  // 🔹 Tüm verileri temizleme işlemi
  Future<void> _clearAllData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Tüm Verileri Sil"),
        content: const Text(
          "Tüm harcamalar kalıcı olarak silinecek. Emin misin?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("İptal"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Evet, sil"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await StorageService.clearAll();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tüm veriler silindi")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ayarlar"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), // ✅ Geri ana ekrana döner
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Tema",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // 🔹 Tema seçimi butonları
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.system, label: Text("Sistem")),
              ButtonSegment(value: ThemeMode.light, label: Text("Açık")),
              ButtonSegment(value: ThemeMode.dark, label: Text("Koyu")),
            ],
            selected: {_themeMode},
            onSelectionChanged: (value) => _changeTheme(value.first),
          ),

          const Divider(height: 32),

          // 🔹 Tüm verileri silme
          ListTile(
            leading: const Icon(Icons.delete_forever),
            title: const Text("Tüm Verileri Sıfırla"),
            subtitle: const Text("Tüm harcamaları kalıcı olarak siler"),
            onTap: _clearAllData,
          ),
        ],
      ),
    );
  }
}

/// 🔹 Uygulama genelinde tema değiştirmek için yardımcı InheritedWidget
class MyAppThemeNotifier extends InheritedWidget {
  final void Function(ThemeMode) updateTheme;

  const MyAppThemeNotifier({
    super.key,
    required this.updateTheme,
    required super.child,
  });

  static MyAppThemeNotifier? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MyAppThemeNotifier>();
  }

  @override
  bool updateShouldNotify(MyAppThemeNotifier oldWidget) => false;
}
