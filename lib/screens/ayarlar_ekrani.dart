import 'package:flutter/material.dart';
import 'package:harcama_takip/l10n/app_localizations.dart';
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
        title: Text(AppLocalizations.of(context)!.settingsClearDataTitle),
        content: Text(AppLocalizations.of(context)!.settingsClearDataMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.buttonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.settingsConfirmDelete),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await StorageService.clearAll();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.settingsDataCleared),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settingsTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), // ✅ Geri ana ekrana döner
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            AppLocalizations.of(context)!.settingsThemeTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SegmentedButton<ThemeMode>(
            segments: [
              ButtonSegment(
                value: ThemeMode.system,
                label: Text(AppLocalizations.of(context)!.settingsThemeSystem),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                label: Text(AppLocalizations.of(context)!.settingsThemeLight),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                label: Text(AppLocalizations.of(context)!.settingsThemeDark),
              ),
            ],
            selected: {_themeMode},
            onSelectionChanged: (value) => _changeTheme(value.first),
          ),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.delete_forever),
            title:
                Text(AppLocalizations.of(context)!.settingsClearDataListTitle),
            subtitle: Text(
                AppLocalizations.of(context)!.settingsClearDataListSubtitle),
            onTap: _clearAllData,
          ),
        ],
      ),
    );
  }
}

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
