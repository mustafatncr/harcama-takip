import 'package:flutter/material.dart';
import 'package:harcama_takip/l10n/app_localizations.dart';
import '../services/storage_service.dart';

class AyarlarEkrani extends StatefulWidget {
  const AyarlarEkrani({super.key});

  @override
  State<AyarlarEkrani> createState() => _AyarlarEkraniState();
}

class _AyarlarEkraniState extends State<AyarlarEkrani> {
  String _currency = "TRY"; // Varsayılan

  @override
  void initState() {
    super.initState();
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    final code = await StorageService.loadCurrency();
    setState(() => _currency = code);
  }

  Future<void> _changeCurrency(String code) async {
    await StorageService.saveCurrency(code);
    setState(() => _currency = code);
  }

  Future<void> _clearAllData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          AppLocalizations.of(context)!.settingsClearDataTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          AppLocalizations.of(context)!.settingsClearDataMessage,
        ),
        actions: [
          TextButton(
            child: Text(AppLocalizations.of(context)!.buttonCancel),
            onPressed: () => Navigator.pop(context, false),
          ),
          FilledButton(
            child: Text(AppLocalizations.of(context)!.settingsConfirmDelete),
            onPressed: () => Navigator.pop(context, true),
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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Para Birimi
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: Text(AppLocalizations.of(context)!.settingsCurrencyTitle),
            trailing: DropdownButton<String>(
              value: _currency,
              dropdownColor: Theme.of(context).colorScheme.surface,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: "TRY", child: Text("TRY  (₺)")),
                DropdownMenuItem(value: "USD", child: Text("USD  (\$)")),
                DropdownMenuItem(value: "EUR", child: Text("EUR  (€)")),
                DropdownMenuItem(value: "GBP", child: Text("GBP  (£)")),
              ],
              onChanged: (value) {
                if (value != null) _changeCurrency(value);
              },
            ),
          ),

          const Divider(height: 32),

          // Veri Temizleme
          ListTile(
            leading: const Icon(Icons.delete_forever),
            title: Text(
              AppLocalizations.of(context)!.settingsClearDataListTitle,
            ),
            subtitle: Text(
              AppLocalizations.of(context)!.settingsClearDataListSubtitle,
            ),
            onTap: _clearAllData,
          ),
        ],
      ),
    );
  }
}
