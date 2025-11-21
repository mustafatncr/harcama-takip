import 'package:flutter/material.dart';
import 'package:harcama_takip/l10n/app_localizations.dart';
import '../screens/grafik_ekrani.dart';

class AppDrawer extends StatelessWidget {
  final VoidCallback? onCategoriesChanged;

  const AppDrawer({super.key, this.onCategoriesChanged});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.drawerTitle,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(AppLocalizations.of(context)!.drawerSubtitle),
              ],
            ),
          ),

          // 🔹 Ana Sayfa
          ListTile(
            leading: const Icon(Icons.home),
            title: Text(AppLocalizations.of(context)!.drawerHome),
            onTap: () {
              Navigator.pop(context);
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),

          // 🔹 Grafikler
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: Text(AppLocalizations.of(context)!.drawerCharts),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GrafikEkrani()),
              );
            },
          ),

          // 🔹 Kategoriler
          ListTile(
            leading: const Icon(Icons.category),
            title: Text(AppLocalizations.of(context)!.drawerCategories),
            onTap: () async {
              Navigator.pop(context);

              final result = await Navigator.pushNamed(context, '/kategoriler');

              // Kategoriler değiştiyse HomeScreen'e haber ver
              if (result == true && onCategoriesChanged != null) {
                onCategoriesChanged!();
              }
            },
          ),

          // 🔹 Ayarlar
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(AppLocalizations.of(context)!.drawerSettings),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/ayarlar');
            },
          ),
        ],
      ),
    );
  }
}
