import 'package:flutter/material.dart';
import 'package:harcama_takip/l10n/app_localizations.dart';
import '../services/storage_service.dart';

class AyarlarEkrani extends StatefulWidget {
  const AyarlarEkrani({super.key});

  @override
  State<AyarlarEkrani> createState() => _AyarlarEkraniState();
}

class _AyarlarEkraniState extends State<AyarlarEkrani> {
  String _currency = "TRY";

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
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF0F2624),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.settingsClearDataTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.settingsClearDataMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    child: Text(
                      AppLocalizations.of(context)!.buttonCancel,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    onPressed: () => Navigator.pop(context, false),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(
                      AppLocalizations.of(context)!.settingsConfirmDelete,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );

    if (confirm == true) {
      await StorageService.clearAll();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF0F2624),
          content: Text(
            AppLocalizations.of(context)!.settingsDataCleared,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  String currencyIcon(String code) {
    switch (code) {
      case "USD":
        return "\$";
      case "EUR":
        return "€";
      case "GBP":
        return "£";
      default:
        return "₺";
    }
  }

  Widget _buildCurrencySelector() {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2624),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Text(
            currencyIcon(_currency),
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: cs.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.settingsCurrencyTitle,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF071312),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cs.primary.withValues(alpha: 0.35)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _currency,
                dropdownColor: const Color(0xFF0F2624),
                icon: Icon(Icons.expand_more, color: cs.primary),
                style: const TextStyle(color: Colors.white),
                items: const [
                  DropdownMenuItem(value: "TRY", child: Text("TRY  (₺)")),
                  DropdownMenuItem(value: "USD", child: Text("USD  (\$)")),
                  DropdownMenuItem(value: "EUR", child: Text("EUR  (€)")),
                  DropdownMenuItem(value: "GBP", child: Text("GBP  (£)")),
                ],
                onChanged: (v) {
                  if (v != null) _changeCurrency(v);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteCard() {
    return GestureDetector(
      onTap: _clearAllData,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF0F2624),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.delete_forever, color: Colors.redAccent, size: 26),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.settingsClearDataListTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)!.settingsClearDataListSubtitle,
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.settingsTitle,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCurrencySelector(),
          const SizedBox(height: 22),
          Divider(color: Colors.white12, thickness: 1),
          const SizedBox(height: 22),
          _buildDeleteCard(),
        ],
      ),
    );
  }
}
